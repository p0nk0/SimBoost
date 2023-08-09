open! Core
open! Owl_base

val main
  :  stock_prices:float array
  -> strike_price:float
  -> interest_rate:float
  -> start_date:string
  -> expiration_date:string
  -> number_of_time_steps:int
  -> float
