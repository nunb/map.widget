(defpackage #:map.widget-asd
  (:use :cl :asdf))

(in-package :map.widget-asd)

(defsystem map.widget
  :name "map.widget"
  :version "0.0.1"
  :maintainer ""
  :author ""
  :licence ""
  :description "map.widget"
  :depends-on (:weblocks)
  :components ((:file "map.widget")
	       (:module conf
			:components ((:file "stores"))
			:depends-on ("map.widget"))
	       (:module src 
			:components ((:file "init-session")
				     (:module model 
					      :components ((:file "geo-address")
							   (:file "hackathon"))))
			:depends-on ("map.widget" conf))))
