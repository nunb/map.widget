(in-package :map.widget)

(defwidget hackathon-displayer (composite)
  ()
  (:documentation "A widget which displays a list of hackathons, plus
                  UI for adding them. Each hackathon has a
                  location. If this is unset, there will be UI for
                  adding one. If location is set, there should be UI
                  for editing the location, and also quickly seeing a
                  map-tile."))


(defview hackathon-view (:type form)
  (title)
  (tags))

(defmethod render-widget-body hack-dis)