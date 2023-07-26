open! Core
open! Async

(* given start/end dates, stock name; returns (date array, adj. close
   array) *)
val fetch_data_as_array : stock_data:string -> unit
