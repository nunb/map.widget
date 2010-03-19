(in-package :app)

(defwidget address-geo-checker (state-changer-mixin composite)
  ((address-string :initform nil :documentation "A API formatted formal address string")
   (location-hint  :initform nil :documentation "initial value for textbox"   :accessor location-hint)
   (loc-field-writer :initarg :loc-field-writer :accessor loc-field-writer :documentation "A closure that can write to a place")
   (loc-field        :initarg :loc-field  :initform nil :documentation "A field of type geo-address" :accessor loc-field)
   (loc-hint        :initarg :loc-hint  :initform nil :documentation "A field of type string" :accessor loc-hint)
   (loc-dialog       :initform (gensym)  :accessor geo-dialog))
  
   (:default-initargs :dom-class "yui-skin-sam"))


(defmethod dependencies append ((obj address-geo-checker))
   #+nomore(list (make-instance 'script-dependency :url "http://www.google.com/jsapi?key=ABQIAAAAgEzFUEK7RNBLMZ_4FzJ9lhRHOth0CcqyRt27t8xdyI9cHwYSpBTCGUHV3O7iaetvFvGqwGV94okw_w")))

(defun geo-check-this (str)
  t)

(defmethod render-widget-body ((obj address-geo-checker) &rest args)
  (warn (format nil "RWB state of address geo is ~A" (get-state obj)))
  (if (initial-state obj)
      (render-map-chooser obj)
      (if (loc-field obj)   (render-map-chosen  obj))))

(defmethod render-map-chooser ((obj address-geo-checker) &rest args)
  ;(m-insert-google-apis)init 
  (m-send-location-chooser-js obj (loc-field obj))
  (render-map-chooser-link
   obj
   :value (aif (loc-hint obj) it "")
   :prompt (if (loc-field obj)
	       #!"MapPromptModify"
	       #!"MapPromptSelect")))

(defmethod render-map-chosen ((obj address-geo-checker) &rest args)
  (with-html (:span (str (format nil "~A"
				  (if (eq (type-of (loc-field obj)) 'geo-address)
				      (city-country-of (loc-field obj))
				      (loc-field obj)))))))

(defmethod m-send-location-chooser-js ((obj address-geo-checker) loc-field &rest args)
  (cond
    (t
     (send-script  
      (format nil "
                   update_location_chosen =  function (canon, lat, long, json) {
                            var args = { first : canon, second : json, lat : lat, long : long, country : json.Country.CountryName,
                                         town :json.Country.AdministrativeArea.SubAdministrativeArea.Locality.LocalityName  };
                                         var argshash = $H( args );
                                                                                  console.log('This' + $H(json).toJSON());
                                                                                  ~A ; }" ;dialog~A.hide();
	      ;(geo-dialog obj)
	      (make-action-string-with-args (lambda (&key first second lat long town country &allow-other-keys)
					      (setf (loc-field obj)
						    (make-instance 'geo-address
								   :canonical-address first
								   :geo-data-json     second
								   :latitude lat
								   :longitude long
								   :city town
								   :country country
								   ))
					      (safe-funcall (loc-field-writer obj) (loc-field obj))) ;(set-state obj :chosen)
					;(break (format nil "Saving address: ~A" first)) This works reliably, yet we have trouble with writing to the location slot
					;of a claim in such a way that validation goes through? WTF? FIXME TODO
					    "argshash"))))))

(defmethod render-map-chooser-link ((obj address-geo-checker) &key (value "") (prompt "Select") (map-button-text ""))
  ; was defmethod render-map-chooser-link-3 (&key (value "") (prompt "Select") (map-button-text ""))
  ; (break "normal geochecker chooser was called")
  (with-gensyms (map-popup option-view map-view map-canvas map-button text-field search-button module-name dialog-id form-id)
    (if (loc-field obj)   (render-map-chosen  obj))
    (with-html
      (:span :id map-button :class "map_popup"
	 	    (:span :class "blue map_prompt"
		   	   (:span (render-icon-small
			   (if (loc-field obj)
			       "pencil"
			       "add"
			       )
			   (if (loc-field obj)
			       #!"MapPromptModify"
			       #!"MapPromptSelect")))))
       (:div :class "yui-skin-sam" :style "height:0px;width:0px;" ;:style "display:block; overflow:hidden;"	;bloody 'ell forgot this!
	    (:div :id map-popup		; :class "map-dialog"
		  (:div :class "hd" "Select location")
		  (:div :class "bd"
			(:table
			 (:tr
			  (:td :colspan "2"
			       (:div :id map-view :class "map_search" :style "float:left;"
				     (:form :action "#" :onsubmit "showLocation(); return false;" :id form-id
					    (:p
					     (:b :class "blue linky" #!"Search")
					     (:span :style "width:10em;"
						    	     (:input :id text-field :type "text" :name "q" :value (if value value "") :size 30))				
					     "&nbsp;"
					     (:img :src "/pub/images/search_icon.png")
					     (:span :id search-button :class "blue search_button" map-button-text)))) )
			  (:td :rowspan "2"
			   (:div :id map-canvas  :class "map_canvas" ;:style "width:550px; height:350px;"
				 )))
			 #+nomore(:img :src "http://maps.google.com/staticmap?center=43.100983,12.150879&zoom=5&size=550x350&key=ABQIAAAAgEzFUEK7RNBLMZ_4FzJ9lhRHOth0CcqyRt27t8xdyI9cHwYSpBTCGUHV3O7iaetvFvGqwGV94okw_w")
			 (:tr
			  (:td
			   (:div :class "map_results_box"
				 (:div :id option-view :class "map_results" )))
			   
			  ;:style "width:200px;"
			   ))))))

    (send-script
     (with-string-stream
       (html-template::fill-and-print-template
      "  
	YAHOO.util.Event.onDOMReady(function () {
          dialog<!-- tmpl_var dialog-id --> = new YAHOO.widget.Panel('<!-- tmpl_var panelid -->', {
                                           modal : true,
      	                                   visible : false,  
	                                   constraintoviewport:false,
					   fixedcenter: true,
					   //width:'16em',
                                           context: [['beforeShow', 'windowResize']],
					   draggable:false,
                                           underlay: 'shadow',
                                           zIndex:100,
					   close:true});
          dialog<!-- tmpl_var dialog-id -->.render(document.body); // DAMMIT seemed like document.body was fixing it, but the fucken thing fixed itself without !?
          dialog<!-- tmpl_var dialog-id -->.hide()  ;
          dialog<!-- tmpl_var dialog-id -->.center();
          
          YAHOO.util.Dom.setStyle( 
  		     '<!-- tmpl_var map-canvas -->',
 		     'background-image',
                     'url(http://maps.google.com/staticmap?center=43.100983,12.150879&zoom=5&size=550x380&key=ABQIAAAAgEzFUEK7RNBLMZ_4FzJ9lhRHOth0CcqyRt27t8xdyI9cHwYSpBTCGUHV3O7iaetvFvGqwGV94okw_w)'
          ); 
          YAHOO.util.Dom.setStyle( 
  		     '<!-- tmpl_var map-canvas -->',
 		     'width', \"550px\");
          YAHOO.util.Dom.setStyle( 
  		     '<!-- tmpl_var map-canvas -->',
 		     'height', \"350px\");


          // :style \"width:550px; height:350px; background-image:url(http://maps.google.com/staticmap?center=43.100983,12.150879&zoom=5&
          //   size=550x350&key=ABQIAAAAgEzFUEK7RNBLMZ_4FzJ9lhRHOth0CcqyRt27t8xdyI9cHwYSpBTCGUHV3O7iaetvFvGqwGV94okw_w);\"
       });
"
      (list :dialog-id dialog-id :panelid map-popup :map-button map-button :map-canvas map-canvas)
      :stream *stream*)))

    (send-script
     (with-string-stream
       (html-template::fill-and-print-template
	"
    YAHOO.util.Event.on('<!-- tmpl_var map-button -->', 'click',
       function() {
                var kl = new YAHOO.util.KeyListener(dialog<!-- tmpl_var dialog-id -->,
                                                      { keys:27 },                               
 	                                              { fn:function(){ alert('saw'); showLocation()},
 	                                                scope: dialog<!-- tmpl_var dialog-id -->,
 	                                                correctScope:true } ); 	 
 	        dialog<!-- tmpl_var dialog-id -->.cfg.queueProperty('keylisteners', kl);

         YAHOO.util.Dom.setStyle( 
  		     YAHOO.util.Dom.getElementsByClassName('mask', 'div'),
 		     'opacity', 0.80); 

                dialog<!-- tmpl_var dialog-id -->.show();

         YAHOO.util.Dom.setStyle( 
  		     YAHOO.util.Dom.getElementsByClassName('mask', 'div'),
 		     'opacity', 0.80); 
	 //insert_api_key();
	 //map_initialize();
	 //map_first_init();
	 if (YAHOO.env.ua.opera && document.documentElement) {
	      document.documentElement.style += ''; // Opera needs to force a repaint
	  }
       });"
	(list :dialog-id dialog-id :map-button map-button )
	:stream *stream*)
       ))

    (send-script
     (with-string-stream
       (html-template::fill-and-print-template
	
	"

/*
    var dialog;
    var map;
    var geocoder;
*/

 map=0, geocoder=0;

    loadMap = function () {
        //alert(\"I running load map now.\");
        if ( typeof(GMap2) == \"undefined\") { alert(\"Maps not available!\"); }
	map = new GMap2(document.getElementById('<!-- tmpl_var map-canvas -->'));
	map.addMapType(G_PHYSICAL_MAP);
	var point = new GLatLng(43.100983,12.150879);
	map.setCenter(point, 5);
	map.addControl(new GLargeMapControl());
	map.addControl(new GScaleControl());
	map.addControl(new GMapTypeControl());
        geocoder = new google.maps.ClientGeocoder();
        googleMapScript = \"loaded\"; 
	//add any markers etc needed here

	setTimeout(function(){document.getElementById('<!-- tmpl_var map-canvas -->').style.backgroundImage = '';},2000);
    }

    function activateMap() {
        //alert(\"activation running\"); /*alert(\"I think map js is already loaded!\");*/
        if ( typeof(GMap2) == \"undefined\") {
	 var script = document.createElement('script');
	 script.setAttribute('src', 'http://maps.google.com/maps?file=api&v=2&key=ABQIAAAAgEzFUEK7RNBLMZ_4FzJ9lhRHOth0CcqyRt27t8xdyI9cHwYSpBTCGUHV3O7iaetvFvGqwGV94okw_w&async=2&callback=loadMap');
	 script.setAttribute('type', 'text/javascript');
	 document.documentElement.firstChild.appendChild(script);
         //alert(\"I created gmap script element\");
	 
        } else {
         //alert(\"I think map js is already loaded!\");
         setTimeout( function(){loadMap();}, 2000); return;
        }        
     }
     YAHOO.util.Event.onDOMReady(function () {
                                             setTimeout( function(){activateMap();}, 2000);
     });
"
	(list :map-button map-button :map-canvas map-canvas)
	:stream *stream*)
       ))


     (send-script
      (with-string-stream
	(html-template::fill-and-print-template
	 "
    function close_popup_and_cleanup () {
       dialog<!-- tmpl_var dialog-id -->.hide(); //google.maps.Unload();
    }

    function addAddressToMap(response) {
       //alert('callback in add address to map');
       map.clearOverlays();
       if (!response || response.Status.code != 200) {
          alert('<!-- tmpl_var translated-error-message -->');
        } else {
          var attributes = { width: { to: 400 } };
          //var anim = new YAHOO.util.Anim(' <!-- tmpl_var something -->', attributes, 1, YAHOO.util.Easing.easeOut);
	  var howmany = 17;
	  if (response.Placemark.length < 17) { howmany = response.Placemark.length;  }
	  minLat = 90.0;
	  maxLat = -90.0;
	  minLng = 180.0;
	  maxLng = -180;
	  for (var i = 0; i < howmany ; i++) {
			      place = response.Placemark[i];
			      point = new  google.maps.LatLng(place.Point.coordinates[1], place.Point.coordinates[0]);
			      var lng = point.lng();
			      var lat = point.lat();
			      marker = new google.maps.Marker(point);
			      map.addOverlay(marker);
			      var link = document.createElement('text');			
			      link.innerHTML='<p style=\"map_address\">' + place.address+'</p>'; 
			      link.onclick = function() {		
						           update_location_chosen( place.address, lat, lng, place.AddressDetails); close_popup_and_cleanup();  };
			      document.getElementById('<!-- tmpl_var option-view -->').appendChild(link); 
			      // Remember the range of coordinates that have been marked
			      // so that we can make the map encompass all of them.
			      minLat = Math.min (minLat, lat);
			      maxLat = Math.max (maxLat, lat);
			      minLng = Math.min (minLng, lng);
			      maxLng = Math.max (maxLng, lng);
	  } //end for. 

          // anim.animate();
          // Recenter the map to the centroid.
	  map.setCenter (new google.maps.LatLng ((minLat + maxLat) / 2, (minLng + maxLng) / 2));

	  // Find the maximum zoom level at which all of the requested addresses
	  // will fit into the map (with a bit of margin), and zoom the map accordingly.
	   
	  var bounds = new google.maps.LatLngBounds;
	  bounds.extend (new google.maps.LatLng (minLat - ((maxLat - minLat) / 12),   minLng - ((maxLng - minLng) / 12)));
	  bounds.extend (new google.maps.LatLng (maxLat + ((maxLat - minLat) / 12),   maxLng + ((maxLng - minLng) / 12)));
	  map.setZoom (map.getBoundsZoomLevel (bounds));
      } //end if-else.
    }//end fn address-to-map



    // showLocation() is called when you click on the Search button or press enter
    function showLocation() {
      var address = document.getElementById('<!-- tmpl_var text-box -->').value;
      //new Effect.toggle('<!-- tmpl_var something -->','appear',{duration:1.2});
      if(address.length > 1) {
           document.getElementById('<!-- tmpl_var option-view -->').innerHTML='<p class=\"text\"> <!-- tmpl_var translated-click-to-sel-message --> </p>';
           if (geocoder) {geocoder.getLocations(address, addAddressToMap);}
       }// end if.
     }// end fn show-location

     
     YAHOO.util.Event.on('<!-- tmpl_var text-box -->', 'change',
                                                    function() {
                                                          showLocation(); var elem = document.getElementById('<!-- tmpl_var text-box -->');
                                                          //shortcut.add(\"Return\", function() { showLocation();   },  {'type':'keyup', 'propagate':false, 'target': elem} );
                                                 	  //shortcut.add(\"Enter\", function()  { showLocation();   },  {'type':'keyup', 'propagate':false, 'target': elem} ); 
                                                     });

       


     
"
	 (list
	  :option-view option-view :map-button map-button :map-canvas map-canvas
	  :text-box text-field  :dialog-id dialog-id :form-id form-id
	  :translated-click-to-sel-message #!"prompt:click-address-to-select"
	  :translated-error-message #!"error:address-not-geo-locatable") ; #!"prompt:click-address-to-select" #!"error:address-not-geo-locatable"
	:stream *stream*)
       ))))







;; ;; An alternative: mush both into one send-script
;; #+nomore(format nil 
;; "  dialog<!-- tmpl_var dialogid --> = new YAHOO.widget.Panel('<!-- tmpl_var panelid -->', {  modal : true,
;;       	                                   visible : false,  
;; 	                                   constraintoviewport : true,
;; 					   fixedcenter: true,
;; 					   //width:'16em',
;;                                            //context: [['beforeShow', 'windowResize']],
;; 					   draggable:false,
;;                                            underlay: 'shadow',
;; 					   close:true});
;;           dialog<!-- tmpl_var dialogid -->.render();
;;           dialog<!-- tmpl_var dialogid -->.hide()  ;
;; YAHOO.util.Event.on(<!-- tmpl_var map-button -->, 'click', function() { dialog<!-- tmpl_var dialogid -->.show();
;;    //insert_api_key();
;;    //map_initialize();
;;    //map_first_init();
;;    if (YAHOO.env.ua.opera && document.documentElement) {
;; 	document.documentElement.style += ''; // Opera needs to force a repaint
;;     } });
;; ")
