open! Core
open! Owl_base

module Contract_type : sig
  type t =
    | Call
    | Put
  [@@deriving sexp_of]
end

val volatility : prices:float array -> float
val time_till_expiration : start_date:string -> end_date:string -> float
