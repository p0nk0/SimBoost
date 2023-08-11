open! Core
open! Async

let fetch_data_as_array ~retrieved_stock_data =
  let potential_data = String.split_lines retrieved_stock_data in
  match potential_data with
  | [] -> Array.create ~len:0 "", Array.create ~len:0 0.0
  | _headers :: actual_data ->
    let dates, stock_prices =
      List.fold
        actual_data
        ~init:(Array.create ~len:0 "", Array.create ~len:0 0.0)
        ~f:(fun (dates, prices) date_price_string ->
          let date_price_split = String.split date_price_string ~on:',' in
          match date_price_split with
          | date :: price ->
            let price =
              List.map price ~f:(fun curr_price ->
                float_of_string curr_price)
            in
            ( Array.append dates (Array.of_list [ date ])
            , Array.append prices (Array.of_list price) )
          | [] -> dates, prices)
    in
    dates, stock_prices
;;

let pad_array_with_zeros ~(current_array : float array) ~num_zeros_to_add =
  let zero_array = Array.create ~len:(num_zeros_to_add - 1) 0.0 in
  let new_array = Array.append zero_array current_array in
  new_array
;;

let get_valid_date ~date =
  let date = Date.of_string date in
  Date.previous_weekday date
;;
