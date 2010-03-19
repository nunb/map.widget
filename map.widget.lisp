(defpackage #:map.widget
  (:use :cl :weblocks
        :f-underscore :anaphora)
  (:import-from :hunchentoot #:header-in
    #:set-cookie #:set-cookie* #:cookie-in
    #:user-agent #:referer)
  (:documentation
   "A web application based on Weblocks."))

(in-package :map.widget)

(export '(start-map.widget stop-map.widget))

;; A macro that generates a class or this webapp

(defwebapp map.widget
    :prefix "/" 
    :description "map.widget: A new application"
    :init-user-session 'map.widget::init-user-session
    :autostart nil                   ;; have to start the app manually
    :ignore-default-dependencies nil ;; accept the defaults
    :debug t
    )   

;; Top level start & stop scripts

(defun start-map.widget (&rest args)
  "Starts the application by calling 'start-weblocks' with appropriate arguments."
  (apply #'start-weblocks args)
  (start-webapp 'map.widget))

(defun stop-map.widget ()
  "Stops the application by calling 'stop-weblocks'."
  (stop-webapp 'map.widget)
  (stop-weblocks))


