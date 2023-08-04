open! Core
open! Async
module Stats = Stats

type stock_models
type predictions

(*Perform all the simulations*)
val main : prediction_type:predictions -> float array option Deferred.t

val get
  :  start_date:string
  -> end_date:string
  -> stock:string
  -> string Deferred.t

val command : Command.t
