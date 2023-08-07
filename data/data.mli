open! Core
open! Async

(* specifically for monte carlo simulation for stock prices*)
val fetch_data_as_array
  :  retrieved_stock_data:string
  -> string array * float array

val pad_array_with_zeros
  :  current_array:float array
  -> num_zeros_to_add:int
  -> float array
