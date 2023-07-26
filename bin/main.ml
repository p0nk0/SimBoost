open! Core
open! Async

let command =
  Command.group ~summary:"A cool tool" [ "server", Source.UI.command ]
;;

let () = Command_unix.run command
