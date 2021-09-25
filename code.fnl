(local gos
       {:dep {:fennel (require :fennel)
                  :socket (require :socket)}
            :act {}
            :model {}
            :util {}})
(lambda gos.act.remove-attribute [thing attr]
  (tset thing attr nil))
(lambda gos.act.run-time [timer]
  (timer:tick-time)
  (gos.dep.socket.select nil nil (or timer.tick-rate 0.2)))
(lambda gos.act.schedule-event [timer event]
  (table.insert timer.events event))
(lambda gos.act.set-attribute [thing attr val]
  (tset thing attr val))
(lambda gos.act.set-attributes [thing attrs]
  (each [attr val (pairs attrs)]
    (tset thing attr val)))
(lambda gos.act.tick-time [timer]
  (set timer.tick-count (+ timer.tick-count 1))
  (let [current-events timer.events]
    (set timer.events [])
    (each [_ event (pairs current-events)] (event))))
(lambda gos.model.basic-thing [?base ?attributes]
  "Make a basic thing."
  (let [thing (or ?base {})]
    (tset thing :set-attributes gos.act.set-attributes)
    (thing:set-attributes
     {:set-attribute gos.act.set-attribute
      :remove-attribute gos.act.remove-attribute})
    (when ?attributes (thing:set-attributes ?attributes))
    thing))
(lambda gos.model.timer [?base ?tick-rate]
  (let [timer (or ?base (gos.model.basic-thing))]
    (timer:set-attributes
     {:tick-count 0 :tick-rate (or ?tick-rate 0.2)
      :events [] :schedule-event gos.act.schedule-event
      :run-time gos.act.run-time :tick-time gos.act.tick-time})
    timer))
;;; dont delete this line
gos
