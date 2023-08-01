open! Core
open! Async
module Stats = Stats

type models

(*Perform all the simulations*)
val main
  :  start_date:string
  -> end_date_historical:string
  -> end_date_pred:string
  -> stock:string
  -> model_type:models
  -> float array option Deferred.t

val get
  :  start_date:string
  -> end_date:string
  -> stock:string
  -> string Deferred.t

val command : Command.t
