open! Core
open! Owl_base

(*Assume each options contract has 100 shares of the stock*)
val options_call
  :  ending_stock_price:float
  -> call_option_price:float
  -> strike_price:float
  -> float
