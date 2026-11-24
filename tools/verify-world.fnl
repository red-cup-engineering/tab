;;;; Verify a configured TAB world from its directory, without starting listeners.
(local tab (require :tab))
(local instance (require :instance))
(instance.configure)

(local files (tab.scan-directory "attributes" true :f))
(var models 0)
(each [_ file (ipairs files)]
  (when (= ".fnl" (string.sub file -4))
    (tab.make-thing (string.sub file 1 -5))
    (set models (+ models 1))))
(assert (> models 0) "No world models discovered")

(local dimension (tab.make-thing :instance/dimension))
(dimension:load)
(local mapper dimension.map)
(assert (and mapper.loaded? (> (length mapper.area-list) 0)) "Empty or unloaded map")
(each [_ id (ipairs mapper.area-list)]
  (local room (assert (. mapper.areas id) id))
  (each [direction destination (pairs (or room.exits {}))]
    (assert (. mapper.areas destination) (.. id " / " direction " leads outside the map: " destination))))
(when mapper.start-area
  (local start (assert (mapper:find-area mapper.start-area) mapper.start-area))
  (local client (dimension:make-thing :vr/mud/client))
  (client:move start)
  (client:parse "look")
  (assert (string.find client.buffer (start:describe) 1 true) "Look omitted the room description")
  (local directions (tab.collect-keys start.exits true))
  (local direction (assert (tab.find-by directions
                             (fn [key] (when (not= (. start.exits key) mapper.start-area) key)))
                           "Start room needs an exit to another room"))
  (client:parse (.. "move " direction))
  (assert (= client.location (mapper:find-area (. start.exits direction))) "Move did not reach the named exit"))
(print "Verified" models "models and" (length mapper.area-list) "rooms in" dimension.name)
