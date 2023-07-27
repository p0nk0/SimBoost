open! Core
open! Async

(* specifically for monte carlo simulation for stock prices*)
val fetch_data_as_array
  :  retrieved_stock_data:string
  -> string array * float array
