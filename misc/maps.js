// use 1 marker and 1 infowindow    
// per location (max of 10 anyway).  see
// http://code.google.com/apis/maps/documentation/v3/events.html

var MAPPY = null;

var MAPPY_INIT = function() {			    

  var Dom = YAHOO.util.Dom,
  Element = YAHOO.util.Element,
  Event = YAHOO.util.Event; 
  
  // Google map, marker, info.
  var map   = null;
  var marker= null;
  var latlng= null;
  var info  = null;
  var currentInput = null;
  var where = ""; var listen_map = null;

  // alert('ver 5.8121');

	 // YUI panel that will hold map and results
         var pdiv  = document.createElement('div');			
	 var panel = new YAHOO.widget.Panel(pdiv, {
						modal : true,
      						visible : false,  
						constraintoviewport:true,
						fixedcenter: true,
						//width:'16em',
						context: [['beforeShow', 'windowResize']],
						draggable:false,
					        iframe: true,
						underlay: 'shadow',
						zIndex:1700,
						close:true});
         var kl = new YAHOO.util.KeyListener(document, { keys:27 },  							
					      { fn:panel.hide,
						scope:panel,
						correctScope:true } );
         panel.cfg.queueProperty("keylisteners", kl);

         panel.setHeader('<p style="font-size:1.2em;"> Mappe </p>');
	 panel.setBody('<table class="map_table" style="margin: 0 !important;"><tr><td><div style="width:260px;height:400px;"> '  +
  		          '<div class="map_search_box"><span class="map_search"><input name="q" id="map_input"/></span></div>' +
		       '<div class="map_results_box" id="map_parent"><div id="map_results" class="map_results"></div></div></div></td>' +
		       //'<td class="map_spacer" style="display:none;"> </td>' +
		       '<td><div id="map_canvas" style="width:350px; height:400px;"> Content </div></td></tr></table>');
         
         panel.subscribe("configzIndex", function(e) {alert('zIndex was changed! By who? Find the culprit and hang him!');} );

         panel.cfg.setProperty( 'zIndex', 1700);
         panel.stackMask();
         panel.render(document.body); 
    
         function hidePanel () {
	     panel.hide();
	 }
		
	
	 var showPanel = function() { //var
	     if (map === null){           
		 YAHOO.util.Get.script("http://maps.google.com/maps/api/js?sensor=false&callback=MAPPY.map_initialize",
				       { onFailure: function(){   alert('Google maps could not be loaded'); }, onSuccess : function(){ } }
				      ); 
	     } 
	     // panel.show(); panel.hide(); 
	     panel.cfg.setProperty( 'zIndex', 1700);
	     panel.stackMask();  panel.render(document.body); 
	     panel.show(); 
	     var maps_input = document.getElementById("map_input");
             YAHOO.util.Event.removeListener("map_input", "change");
	     YAHOO.util.Event.addListener("map_input", "change", function(e) { shownMapGeo(e); } );
	     if(listen_map!=null) { 
	       //alert('disable 1 listener');
               listen_map.disable(); 
	     }
             listen_map = new YAHOO.util.KeyListener("map_input", { ctrl:false, keys:13 },  
	                                               { fn: function(e) { shownMapGeo(e); },
	                                                 scope:maps_input,
							 correctScope:true } ); listen_map.enable();

	 };
	 
	 function map_extend () {
	     // according to http://stackoverflow.com/questions/1544739/google-maps-api-v3-how-to-remove-all-markers/1544885#1544885
	     google.maps.Map.prototype.markers = new Array();
	     google.maps.Map.prototype.addMarker = function(marker) {
		 this.markers[this.markers.length] = marker;
	     };

	     google.maps.Map.prototype.getMarkers = function() {
		 return this.markers;
	     };

	     google.maps.Map.prototype.clearMarkers = function() {
		 for(var i=0; i<this.markers.length; i++){
		     this.markers[i].set_map(null);
		 }
		 this.markers = new Array();
	     };
	 }

	 function map_clear () {
	   map.clearMarkers();
	 }

	 function map_initialize() {
	     latlng = new google.maps.LatLng(43.100983,12.150879);
	     var myOptions = {
		 zoom: 5,
		 center: latlng,
		 mapTypeId: google.maps.MapTypeId.ROADMAP
	     };
	     map_extend();
	     map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);  
	     // google.maps.event.addListener(map, "tilesloaded", function() {alert('tiles');} );
	     marker = new google.maps.Marker({
						 position: latlng, 
						 map: map, 
						 title: "Italia"
					     });     
	   // unnecessary? 
           panel.cfg.setProperty( 'zIndex', 1700);
           panel.stackMask();
	   panel.render(document.body); 
	 }
	 
	 // calls the geonames JSON webservice with the search term
	 function geo_search(where) {
	     var request = 'http://ws.geonames.org/searchJSON?q=' + where + '&maxRows=17&callback=MAPPY.geonamesFound';
	     YAHOO.util.Get.script(request, {  onFailure:    function(){ alert('Could not contact geonames.org, sorry!');}});
	 }
	 
        var get_accordion = function () { 
            return Dom.get('map_results');
        };

        var get_results_ares = function () { 
            return Dom.get('map_results');
        };
  
  
  
  

  var geonamesFound = function (jData) {
    // alert("geonames fn Got " + jData);
    // the parameter jData will contain an array with geonames objects
    //alert("Saw" + jData);
    console.log(jData);
    console.log("input is " + currentInput.value);
    if (jData == null) {
      //alert('Indirizzo non trovato');
      get_accordion().innerHTML = "<p color='red'> Indirizzo " + where + " non trovato </p>";
      return;
    } else if (jData.totalResultsCount == 0) {
      alert('Indirizzo non trovato');
      document.getElementById('map_results').innerHTML = "<p color='red'> Indirizzo " + where + " non trovato </p>";
		 return;
    } else {
      get_accordion().innerHTML = "";
    }
    
    var html = '';
    var geonames = jData.geonames;
    var theloc = new Array; 	   
    var hotels = new Array; 	   
    var places = new Array; 	   
    var other = new Array; 	
    var howmany = 50;
    if (geonames.length < howmany) { howmany = geonames.length;  }   
    for (i=0;i< howmany;i++) {
      var name = geonames[i]; 
      //console.log(name);
      var country  = name.countryName;
      var area = "";
      if(name.name == name.adminName1)
      {
	area = ", " + name.adminName1 + ", ";   
      }
      var the_desc  = name.name + ", " + country;
      //var the_loc = new google.maps.LatLng(name.lat, name.lng);
      var contentString = the_desc;
      var link = document.createElement('text');			
      link.innerHTML='<p class="map_address">' + the_desc + '</p>'; 
		 		
      // this gets passes as the json parameter to update_location_chosen
      var place = {
	type : name.fcl, typeDetail : name.fcode,
	countryName : name.countryName,
	countryCode : name.countryCode,
	lat : name.lat,
	lng : name.lng,
	name : name.name,
        // loc :  the_loc,
	// marker :  new google.maps.Marker({ position: new google.maps.LatLng(name.lat, name.lng), map: map,  title: name.name }),
	desc : the_desc	
	//link : link.innerHTML
      };
      
      //YAHOO.util.Event.addListener(link,'click', function() {  update_location_chosen( the_desc, name.lat, name.lng, place); panel.hide();} );

      //theloc.push(place);
      var fcl = name.fcl;
      if (fcl == "P") {
	places.push(place);
      } else if (fcl == "S") {
	hotels.push(place);
      } else {
	other.push(place);
      }
      
      
    } // end forloop (making places, and pushing onto one of places, hotels or other.

    //console.log ("places");
    //console.log (places);
    var heading = null;
    
    var parent_accordion = get_accordion();
    //parent_accordion.innerHTML="";
        
    makeGeoThingsNoAccordion ( "Places", places, get_accordion());
    //makeGeoThings ( "Hotel/Airport",  hotels, get_accordion());
    //makeGeoThings ( "Altri",  other,  get_accordion());

    //YAHOO.widget.AccordionManager.collapse( parent_accordion);
  };

  makeGeoThingsNoAccordion = function (title, contentarray, parentaccordion) {
    var displayGeoThings = document.createElement('div');;
    if (contentarray.length > 0) {
      var red = 7;    if (contentarray.length < red) { red = contentarray.length;  }   
      for(i=0; i<red; i++) {
	var geoObj = contentarray[i];
	var geoHtmlPara = document.createElement('p');
	geoHtmlPara.innerHTML = "<span>" + contentarray[i].desc + "</span>";	
	Event.addListener(geoHtmlPara, 'mouseover', 
			  function(e, theloc) {				   
			    //
			    // console.log("marker and event: "); console.log(theloc); console.log(e);
			    var oldpos = marker.getPosition();
			    var newpos = new google.maps.LatLng(theloc.lat, theloc.lng);
			    marker.setPosition(newpos); 
			    if( oldpos != null) {
			      var diff = oldpos.lat() - newpos.lat() + oldpos.lng() - newpos.lng();
			      if( diff <= 3.0 )
				{ map.setZoom(9); } else
			      if( diff <= 30.0 )
				{ map.setZoom(5); } else
			      if( diff <= 60.0 )
				{ map.setZoom(3); } else { map.setZoom(5); }


                               // else { alert('huuuur diff ' + diff + ' huuur oldpos ' + oldpos); }
			    } else { alert('old pos null'); }
			    var bounds = map.getBounds();
			    if(bounds!=null){
			      //bounds.extend(newpos);
			      map.panTo(newpos);
			    }else{ alert('map bounds are null'); }

			  },
			  contentarray[i], true); 
	Event.addListener(geoHtmlPara, 'click', 
			  function(e, theloc) {	
			    currentInput.value = theloc.desc;
			    if( MAPPY_update_location_chosen != null) { MAPPY_update_location_chosen ( theloc.desc, theloc.lat, theloc.lng, theloc); }
			    else { alert('did not set the location'); }
			    hidePanel();
			  },
			  contentarray[i], true); 
	//YAHOO.util.Event.on(geoHtmlPara, "mouseenter", function(e) { fn(geoHtmlParas[i]);} ); 
	displayGeoThings.appendChild(geoHtmlPara);
      }
      get_accordion().appendChild(displayGeoThings);
    }
  };

  makeGeoThings = function (title, contentarray, parentaccordion) {
    var displayGeoThings = document.createElement('div');;
    if (contentarray.length > 0) {
      var red = 7;    if (contentarray.length < red) { red = contentarray.length;  }   
      for(i=0; i<red; i++) {
	var geoObj = contentarray[i];
	var geoHtmlPara = document.createElement('p');
	geoHtmlPara.innerHTML = "<span>" + contentarray[i].desc + "</span>";	
	Event.addListener(geoHtmlPara, 'mouseover', 
			  function(e, theloc) {				   
			    //
			    console.log("marker and event: "); console.log(theloc); console.log(e);
			    // marker.setMap(null); 
			    marker.setPosition(theloc.loc); //marker.setMap(map);
			    map.setCenter(theloc.loc); //map.setZoom(5); // e.target.innerHTML += "done";
			  },
			  contentarray[i], true); 
	Event.addListener(geoHtmlPara, 'click', 
			  function(e, theloc) {	
			    currentInput.value = theloc.desc;
			    if( MAPPY.update_location_chosen != null) { update_location_chosen ( theloc.des, theloc.lat, theloc.lng, theloc); }
			    hidePanel();
			  },
			  contentarray[i], true); 
	//YAHOO.util.Event.on(geoHtmlPara, "mouseenter", function(e) { fn(geoHtmlParas[i]);} ); 
	displayGeoThings.appendChild(geoHtmlPara);
      }
      makeAccordionPanel (title, displayGeoThings, parentaccordion);
    }
  };
  
  makeAccordionPanel = function (title, contents, accordion) {	   
    var acc = document.createElement('div'); acc.setAttribute("class","yui-cms-item yui-panel");
    //acc.setAttribute("class","yui-cms-item");
    acc.innerHTML = '<h3><a href="#" class="noaccordionToggleItem" >' + title + '</a></h3>' ;
    var bd = document.createElement('div'); bd.setAttribute("class","bd");
    bd.appendChild(contents); acc.appendChild(bd);
   
    var ac = document.createElement('div'); ac.setAttribute("class","actions");
    ac.innerHTML = '<a href="#" class="accordionToggleItem">&nbsp;</a>';
    acc.appendChild(ac);
   
    accordion.appendChild(acc);
  };


	shownMapGeo =  function(e) { 
	    YAHOO.util.Event.stopPropagation(e); YAHOO.util.Event.preventDefault(e);
      	    var input = YAHOO.util.Event.getTarget(e); 
	    // currentInput = input;
	    //alert('Saw ' + input.value);
	    // showPanel();  TEST IF THIS IS IN REPO!!
	    geo_search( encodeURIComponent(input.value) ) ;
	};

	showMap =  function(e) { 
	    YAHOO.util.Event.stopPropagation(e); YAHOO.util.Event.preventDefault(e);
      	    var input = YAHOO.util.Event.getTarget(e); 
	    currentInput = input;
	    // alert('Saw ' + input.value);
	    showPanel(); 
	    geo_search( encodeURIComponent(input.value) ) ;
	};
   	
   	attachMap = function (mapInput) { // Add map to link rel="map" for onchange and when enter is pressed.
    	    YAHOO.util.Event.addListener(mapInput, "change", showMap);
    	    var k_map = new YAHOO.util.KeyListener(mapInput, { ctrl:false, keys:13 },  
	                                               { fn: showMap,
	                                                 scope:mapInput,
	                                                 correctScope:true } ); 
	    k_map.enable(); 
   	};


   	// Get all input elements. 
   	var aInputs = document.body.getElementsByTagName("input"); 
   	// Attach map popup to input with rel=map attribute. 
   	for(var i = 0, len = aInputs.length; i < len; i++) { 
    	    if (aInputs[i].getAttribute("rel") == "map") { 
		//alert('found, attaching');
		var input = aInputs[i]; 
     		attachMap(input); 
    	    } 
   	}

     return {
        // declare which properties and methods are supposed to be public
         geonamesFound: geonamesFound,
         geo_search: geo_search,
	 map_initialize: map_initialize,
	 map_clear: map_clear
    };

};

//var funit = function() { MAPPY=MAPPY_INIT(); } ();

YAHOO.util.Event.onDOMReady( function() { MAPPY=MAPPY_INIT(); });
