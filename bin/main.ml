open! Core
open! Async

let command =
  Command.group
    ~summary:"Stock and Options dashboard"
    [ "server", Interface.UI.command; "scraper", Scraper.command ]
;;

let () = Command_unix.run command
