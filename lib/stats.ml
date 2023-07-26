open! Core
open! Async
open! Owl_base

let shuffle () =
  let shuffled = Owl_base.Stats.var [| 1.; 2.; 3.; 4. |] in
  print_s [%message (shuffled : float)];
  return ()
;;

let _blah = ()

let command =
  Command.async
    ~summary:"Practice getting a random element"
    (let%map_open.Command () = return () in
     fun () -> shuffle ())
;;
