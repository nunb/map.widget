(in-package :app)

(defclass* hackathon (tagged-item-mixin)
  ((location nil :documentation "Location of hackathon")
   (title    nil :documentation "Name of hackathon")
   (language-used :type (member :any :lisp :perl :blub) :initform :lisp)))