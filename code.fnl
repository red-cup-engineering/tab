(local gos
       {:dep {:fennel (require :fennel)
                  :socket (require :socket)}
            :act {}
            :model {}
            :util {}})
(lambda gos.act.remove-attribute [thing attr]
  (tset thing attr nil))
(lambda gos.act.set-attribute [thing attr val]
  (tset thing attr val))
(lambda gos.act.set-attributes [thing attrs]
  (each [attr val (pairs attrs)]
    (tset thing attr val)))
(lambda gos.model.basic-thing [?base ?attributes]
  "Make a basic thing."
  (let [thing (or ?base {})]
    (tset thing :set-attributes gos.act.set-attributes)
    (thing:set-attributes
     {:set-attribute gos.act.set-attribute
      :remove-attribute gos.act.remove-attribute})
    (when ?attributes (thing:set-attributes ?attributes))
    thing))
