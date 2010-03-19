(in-package :app)


;; I am getting sick of designing widgets one way, to find they work in X but not in Y (eg work in d/d but not n/n aka claims)
;; So I am just going to fucken copy and paste. It's safer, all computing wisdom aside ;-)

(defwidget claims-geo-checker (state-changer-mixin composite)
  ((address-string :initform nil :documentation "A API formatted formal address string")
   (location-hint  :initform nil :documentation "initial value for textbox"   :accessor location-hint)
   (loc-field-writer :initarg :loc-field-writer :accessor loc-field-writer :documentation "A closure that can write to a place")
   (loc-field        :initarg :loc-field  :initform nil :documentation "A field of type geo-address" :accessor loc-field)
   (loc-hint        :initarg :loc-hint  :initform nil :documentation "A field of type string" :accessor loc-hint)
   (loc-dialog       :initform (gensym)  :accessor geo-dialog))
  (:default-initargs :dom-class "yui-skin-sam"))

(defparameter *google-map-png*
  "http://maps.google.com/staticmap?center=43.100983,12.150879&zoom=5&size=550x350&key=ABQIAAAAgEzFUEK7RNBLMZ_4FzJ9lhRHOth0CcqyRt27t8xdyI9cHwYSpBTCGUHV3O7iaetvFvGqwGV94okw_w")

;; (defmethod dependencies append ((obj claims-geo-checker)))

(defmethod dependencies append ((obj claims-geo-checker))
  "These are never called now. Niver yu'mind"
  (list
   ;;(make-nsb-dependency :script "maps")
   ;;(make-instance 'stylesheet-dependency :url "/pub/yui/bubbling/build/accordion/assets/accordion.css")
   ;;(make-instance 'stylesheet-dependency :url "/pub/yui/accordion.css")
   (make-instance 'stylesheet-dependency :url "/pub/stylesheets/maps.css")   
   ;(make-instance 'script-dependency :url "/pub/yui/bubbling/build/accordion/accordion.js")
   ;(make-instance 'script-dependency :url "/pub/yui/bubbling/build/bubbling/bubbling.js")
   ;;(make-instance 'script-dependency :url "/pub/yui/bubbling/build/bubbling/bubbling-accordion.js")
   (make-instance 'script-dependency :url "/pub/scripts/maps.js")))


;; <script type="text/javascript" src="http://yui.yahooapis.com/2.7.0/build/utilities/utilities.js"></script>
;; <script type="text/javascript" src="http://js.bubbling-library.com/2.1/build/bubbling/bubbling.js"></script>
;; <script type="text/javascript" src="http://js.bubbling-library.com/2.1/build/accordion/accordion.js"></script>

(defun geo-check-this (str)
  t)

(defmethod render-widget-body ((obj claims-geo-checker) &rest args)
  (send-script " YAHOO.util.Dom.setStyle(document.body, 'class', \"yui-skin-sam\");")
  ;; (send-script " var run_map = function() { if(MAPPY==null) { MAPPY=MAPPY_INIT();} console.log(\"had to create mappy\"); console.log(MAPPY); }();" :after-load)
  ;; (send-script " var run_map = function() { if(MAPPY==null) { MAPPY=MAPPY_INIT();}  }();" :after-load)
  (mappy-send-location-chooser-js obj (loc-field obj))
  (if (initial-state obj)
      (render-map-chooser obj)
      (if (loc-field obj)   
	  nil)))


(defmethod render-map-chooser ((obj claims-geo-checker) &rest args)
  (render-map-chooser-link
   obj
   :value (aif (loc-field obj) it "")
   :prompt (if (loc-field obj) #!"MapPromptModify" #!"MapPromptSelect")))


(defun custom-render-input-field (type name value &key id class maxlength style rel)
  (with-html
    (:input :type type :name (weblocks::attributize-name name) :id id
	    :value value :maxlength maxlength :class class :rel rel
            :style style)))


(defmethod render-map-chooser-link ((obj claims-geo-checker) &key (value "") (prompt "Select") (map-button-text ""))
  (with-gensyms (map-popup option-view map-view map-canvas map-button text-field search-button module-name dialog-id form-id)
    (with-html
       (if (initial-state obj)
	   (custom-render-input-field "text" "claim-location-text-prevent-write" (printable-address-geo obj)  :rel "map")
	   ;; note rel map, and prevent-write that prevents the weblocks form mechanism from writing to the field (since the make-action-string-with-args below handles the writing to the slot).
	   (htm (:span :class "value" (str (or (loc-field obj) ""))))))))


(defmethod printable-address-geo ((obj claims-geo-checker))
  ;; (break (format nil "~A" obj))
  (cond
    ((typep (loc-field obj) 'geo-address)
     (city-country-of (loc-field obj)))
    (t
     ;;(break "unkown type")
     (loc-field obj))))


 (defmethod mappy-send-location-chooser-js ((obj claims-geo-checker) loc-field &rest args)
  "Create a global MAPPY internal JS function, that when called, updates this object with the geocoded loc. (Takes canon, lat, long, jsonobj)"
  (send-script  
      (format nil "
                   MAPPY_update_location_chosen =  function (canon, lat, long, json) {
                            console.log('This' + $H(json).toJSON());
                            var use_name = \"\";
                            var args = { first : canon, second : json, lat : lat, long : long, country : json.countryCode, town : json.descr  };
                                         var argshash = $H( args );
                                                                                 
                                                                                  ~A ; }"
	      ;;                             dialog~A.hide();
	      ;;                             // alert('called');
	      ;;                             // alert('This' + $H(json).toJSON());
	      ;(geo-dialog obj)
	      (make-action-string-with-args (lambda (&key first second lat long town country &allow-other-keys)
					      (let (o2)
						(setf o2 
						    (make-instance 'geo-address
								   :canonical-address first
								   :geo-data-json     second
								   :latitude lat
								   :longitude long
								   :city town
								   :country country))
						(safe-funcall (loc-field-writer obj) o2)))
					;(break (format nil "Saving address: ~A" first)) This works reliably, yet we have trouble with writing to the location slot
					; of a claim in such a way that validation goes through? WTF? FIXME TODO WTF WTF WTF Is this still a todo ??
					    "argshash"))
      :after-load))
