open! Core
open! Async
(*Want to have a string of all of the dates and all of the stock prices
  values as floats*)

(*Test that this function produces the right output*)
let fetch_data_as_array ~retrieved_stock_data =
  let potential_data = String.split_lines retrieved_stock_data in
  match potential_data with
  | [] -> Array.create ~len:0 "", Array.create ~len:0 0.0
  | headers :: actual_data ->
    let headers = String.split headers ~on:',' in
    print_s [%message (headers : string list)];
    print_s [%message (actual_data : string list)];
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
    print_s [%message (dates : string array)];
    print_s [%message (stock_prices : float array)];
    dates, stock_prices
;;
