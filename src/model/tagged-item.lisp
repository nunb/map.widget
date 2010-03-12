 (in-package :map.widget)

;; A mixin that stores tags as keywords

(defparameter *all-tags* (make-hash-table))

(defun inc-tag (tag)
  (sif (gethash tag *all-tags*)
       (incf it)
       (setf it 1)))

(defun remove-tag (tag)
  (sif (gethash tag *all-tags*)
       (and (> it 0) (decf it))
       (setf it 0)))

(defun any->keyword (tag)
  )

(defclass-star::defclass* tagged-item-mixin ()
  ((tagged-with :initform (make-hash-table))))

(defmethod has-tag ((tim tagged-item-mixin) tag))

(defmethod add-tag ((tim tagged-item-mixin) tag))

(defmethod del-tag ((tim tagged-item-mixin) tag))

(defmethod all-tag ((tim tagged-item-mixin))
  ())
