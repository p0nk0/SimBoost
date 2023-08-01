open! Core
open! Async
module Stats = Stats

type models = Monte_Carlo

let get ~start_date ~end_date ~stock =
  let path = "/api/v3/datasets/WIKI/" ^ stock ^ "/data.csv" in
  let uri =
    Uri.make
      ~scheme:"https"
      ~host:"data.nasdaq.com"
      ~path
      ~query:
        [ "column_index", [ "4" ]
        ; "start_date", [ start_date ]
        ; "end_date", [ end_date ]
        ; "order", [ "asc" ]
        ; "api_key", [ "KNuGGawwwBcDtAzTzaGi" ]
        ]
      ()
  in
  let%bind _response, body = Cohttp_async.Client.get uri in
  let%bind body = Cohttp_async.Body.to_string body in
  return body
;;

(*Error handling for appropriate stock name and beginning / ending dates -->
  and then calling and choosing the appropriate models from here*)
let main ~start_date ~end_date_historical ~end_date_pred ~stock ~model_type =
  match model_type with
  | Monte_Carlo ->
    let%bind historical_stock_data =
      get ~start_date ~end_date:end_date_historical ~stock
    in
    let hist_dates, hist_stock_prices =
      Source.Data.fetch_data_as_array
        ~retrieved_stock_data:historical_stock_data
    in
    let%bind pred_stock_data =
      get ~start_date:end_date_historical ~end_date:end_date_pred ~stock
    in
    let pred_dates, pred_stock_prices =
      Source.Data.fetch_data_as_array ~retrieved_stock_data:pred_stock_data
    in
    let predicted_prices =
      Source.Monte_carlo.main
        ~historical_dates:hist_dates
        ~historical_stock_prices:hist_stock_prices
        ~pred_dates
    in
    print_s [%message (pred_stock_prices : float array)];
    return predicted_prices
;;

let command =
  Command.async
    ~summary:"Practice getting cool data"
    (let%map_open.Command () = return () in
     fun () ->
       let%bind _data =
         main
           ~start_date:"2006-08-01"
           ~end_date_historical:"2008-10-01"
           ~end_date_pred:"2009-11-10"
           ~stock:"GT"
           ~model_type:Monte_Carlo
       in
       return ())
;;
(* let%bind response = Cohttp_async.Client.get uri in () *)
