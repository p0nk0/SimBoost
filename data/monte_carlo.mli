open! Core
open! Owl_base

val main
  :  historical_dates:string array
  -> historical_stock_prices:float array
  -> pred_dates:string array
  -> real_pred_prices:float array
  -> float * float array
