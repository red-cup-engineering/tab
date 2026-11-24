;;;; Shared player and original authored dimension for terminal and MUDSocket play.
(local tab (require :tab))
(local model :vr/mud/client)
(local commands [:look :move :commands :quit])

(fn load-world []
  ((. (require :instance) :configure))
  (local dimension (tab.make-thing :instance/dimension))
  (dimension:load)
  dimension)

{: model : commands : load-world}
