;; (in-package :map.widget)

;; (defclass* geo-address ()
;;   ((canonical-address nil :documentation "Canonical address result of geocoding, originally intended to hold canonical json-slot from google-geocoding")
;;    (geo-data-json     nil :documentation "JSON hash containing geo data, originally intended to hold canonical json-slot from google-geocoding")
;;    (latitude          nil :documentation "The latitude")
;;    (longitude         nil :documentation "The longitude")
;;    (map-tile          nil :documentation "Perhaps the map graphic tile, unless against google TOS...")
;;    (city              nil :documentation "Best with cl-geonames/geonames.org -- Can also be extracted from google-geocoding")
;;    (country           nil :documentation "Best with cl-geonames/geonames.org -- Can also be extracted from google-geocoding")))


;; (defmethod city-country-of ((obj geo-address))
;;   (with-slots (city country canonical-address) obj
;;     (cond
;;       ((and canonical-address)
;;        (format nil "~A" canonical-address))
;;       ((and city country)
;;        (format nil "~A, ~A" city country))
;;       (t
;;        (format nil "~A" canonical-address))
;;       #+nomore
;;       (t
;;        (let* ((list  (cl-ppcre::split " " canonical-address))
;; 	      (list2 (subseq (reverse list) 0 (min (length list) 2)))) ;; Assume what?
;; 	 (format nil "~{~A ~}" (first list2) (second list2)))))))

