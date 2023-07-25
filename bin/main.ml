open! Core
open! Async

let command =
  Command.group
    ~summary:"A cool tool"
    [ "scraper", Scraper.command; "shuffle", Scraper.Stats.command ]
;;

let () = Command_unix.run command
