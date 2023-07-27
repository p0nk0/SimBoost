open! Core

val fetch_data_as_csv :
    start_date:string -> 
    end_date:string -> 
    name:string -> 
    unit

(* given start/end dates, stock name; returns (date array, adj. close
   array) *)
val fetch_data_as_array : unit -> unit
