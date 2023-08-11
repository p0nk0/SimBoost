open! Core
open! Owl_base

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
