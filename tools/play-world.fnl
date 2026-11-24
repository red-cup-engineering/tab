;;;; Play an authored TAB map using its existing MUD client and commands.
(local player (require :world-player))
(local dimension (player.load-world))
(local mapper dimension.map)
(local start (assert (mapper:find-area mapper.start-area) "Missing world start area"))
(local client (dimension:make-thing player.model))
(set client.command-list player.commands)
(client:move start)
(client:look start)

(fn show []
  (io.write client.buffer)
  (set client.buffer "")
  (io.flush))

(print (.. dimension.name " — look, look <thing>, move <exit>, commands, quit"))
(show)
(var playing true)
(while playing
  (io.write "> ")
  (io.flush)
  (local line (io.read "*l"))
  (if (or (not line) (= line "quit"))
      (set playing false)
      (do
        (when (not (= line "")) (client:parse line))
        (show))))
