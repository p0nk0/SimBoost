open! Core
open! Owl_base

module Contract_type : sig
  type t =
    | Call
    | Put
end

val main
  :  stock_prices:float array
  -> strike_price:float
  -> interest_rate:float
  -> start_date:string
  -> expiration_date:string
  -> expiration_price:float
  -> call_put:Contract_type.t
  -> float * float * float
