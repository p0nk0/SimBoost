open! Core
open! Async
module Stats = Stats

module Monte_Carlo : sig
  type t =
    { start_date : string
    ; end_date_historical : string
    ; end_date_pred : string
    ; stock : string
    }
end

module Black_Scholes : sig
  type t =
    { stock : string
    ; strike_price : float
    ; interest_rate : float
    ; start_date : string
    ; expiration_date : string
    ; historical_date_start : string
    }
end

type stock_models = Monte_Carlo of Monte_Carlo.t
type option_models = Black_Scholes of Black_Scholes.t

type predictions =
  | Stock of stock_models
  | Options of option_models

(*Perform all the simulations*)
val main : prediction_type:predictions -> (float * float array) Deferred.t

val get
  :  start_date:string
  -> end_date:string
  -> stock:string
  -> string Deferred.t

val command : Command.t
