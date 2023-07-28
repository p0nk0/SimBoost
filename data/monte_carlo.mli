open! Core
open! Owl_base

(*Will ultimately take the initial data to 'train' on and perform the model
  --> return the predictions that it makes in an array form*)
val main
  :  historical_dates:string array
  -> historical_stock_prices:float array
  -> float array option
