open! Core
open! Async

(*Test that this function produces the right output*)
let fetch_data_as_array ~retrieved_stock_data =
  let potential_data = String.split_lines retrieved_stock_data in
  match potential_data with
  | [] -> [], []
  | headers :: actual_data ->
    let headers = String.split headers ~on:',' in
    print_s [%message (headers : string list)];
    print_s [%message (actual_data : string list)];
    headers, actual_data
;;
