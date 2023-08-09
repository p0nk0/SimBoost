open! Core
open! Owl_base

val main
  :  stock_prices:float array
  -> strike_price:float
  -> interest_rate:float
  -> start_date:string
  -> expiration_date:string
  -> expiration_price:float
  -> call_put:Options.Contract_type.t
  -> float * float * float
