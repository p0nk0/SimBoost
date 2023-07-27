open! Core
open! Async
module Stats = Stats

(*Perform all the simulations*)
val main
  :  start_date:string
  -> end_date:string
  -> stock:string
  -> unit Deferred.t

val command : Command.t
