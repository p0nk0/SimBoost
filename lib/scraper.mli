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
  [@@deriving sexp_of]
end

module Black_Scholes : sig
  type t =
    { stock : string
    ; strike_price : float
    ; interest_rate : float
    ; start_date : string
    ; expiration_date : string
    ; historical_date_start : string
    ; call_put : Source.Options.Contract_type.t
    }
end

type stock_models = Monte_Carlo of Monte_Carlo.t
type option_models = Black_Scholes of Black_Scholes.t

type predictions =
  | Stock of stock_models
  | Options of option_models

type stock_results = float * float array
type option_results = float * float * float

type results =
  | Stock of stock_results
  | Options of option_results

(*Perform all the simulations*)
val main : prediction_type:predictions -> results Deferred.t

val get
  :  start_date:string
  -> end_date:string
  -> stock:string
  -> string Deferred.t

val command : Command.t
