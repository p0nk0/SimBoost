open! Core
open! Owl_base

(* val main : stock_prices:float array -> strike_price:float ->
   interest_rate:float -> start_date:string -> expiration_date:string ->
   number_of_time_steps:int -> float *)

val main
  :  strike_price:float
  -> stock_prices:float array
  -> interest_rate:float
  -> number_of_time_steps:int
  -> call_put:Options.Contract_type.t
  -> start_date:string
  -> expiration_date:string
  -> expiration_price:float
  -> float * float * float
