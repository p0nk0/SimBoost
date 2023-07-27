open! Core
open! Async

let command =
  Command.group
    ~summary:"Stock dashboard"
    [ "server", Source.UI.command; "scraper", Scraper.command ]
;;

let () = Command_unix.run command
