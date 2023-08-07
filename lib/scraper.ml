open! Core
open! Async
module Stats = Stats

module Monte_Carlo = struct
  type t =
    { start_date : string
    ; end_date_historical : string
    ; end_date_pred : string
    ; stock : string
    }
end

module Black_Scholes = struct
  type t =
    { stock : string
    ; strike_price : float
    ; interest_rate : float
    ; start_date : string
    ; expiration_date : string
    ; historical_date_start : string
    }
end

type stock_models = Monte_Carlo of Monte_Carlo.t
type option_models = Black_Scholes of Black_Scholes.t

type predictions =
  | Stock of stock_models
  | Options of option_models

type stock_results = float * float array
type option_results = float * float * float

type results =
  | Stock of stock_results
  | Options of option_results

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
  let%bind.Deferred _, body = Cohttp_async.Client.get uri in
  let%bind body = Cohttp_async.Body.to_string body in
  return body
;;

(*Error handling for appropriate stock name and beginning / ending dates -->
  and then calling and choosing the appropriate models from here*)

(*Handles all of the models for stock prediction*)
let main_stock ~model_type =
  match model_type with
  | Monte_Carlo params ->
    let%bind historical_stock_data =
      get
        ~start_date:params.start_date
        ~end_date:params.end_date_historical
        ~stock:params.stock
    in
    let hist_dates, hist_stock_prices =
      Source.Data.fetch_data_as_array
        ~retrieved_stock_data:historical_stock_data
    in
    let%bind pred_stock_data =
      get
        ~start_date:params.end_date_historical
        ~end_date:params.end_date_pred
        ~stock:params.stock
    in
    let pred_dates, pred_stock_prices =
      Source.Data.fetch_data_as_array ~retrieved_stock_data:pred_stock_data
    in
    let predicted_prices =
      Source.Monte_carlo.main
        ~historical_dates:hist_dates
        ~historical_stock_prices:hist_stock_prices
        ~pred_dates
        ~real_pred_prices:pred_stock_prices
    in
    return predicted_prices
;;

(*Handles all of the models for Black Scholes P*)
let main_options ~model_type =
  match model_type with
  | Black_Scholes params ->
    let%bind historical_stock_data =
      get
        ~start_date:params.historical_date_start
        ~end_date:params.start_date
        ~stock:params.stock
    in
    let _hist_dates, hist_stock_prices =
      Source.Data.fetch_data_as_array
        ~retrieved_stock_data:historical_stock_data
    in
    let%bind expiration_data =
      get
        ~start_date:params.expiration_date
        ~end_date:params.expiration_date
        ~stock:params.stock
    in
    let _, expiration_stock_price =
      Source.Data.fetch_data_as_array ~retrieved_stock_data:expiration_data
    in
    let expiration_stock_price = Array.get expiration_stock_price 0 in
    print_s [%message (expiration_stock_price : float)];
    let predicted_option_price =
      Source.Black_scholes.main
        ~stock_prices:hist_stock_prices
        ~strike_price:params.strike_price
        ~interest_rate:params.interest_rate
        ~start_date:params.start_date
        ~expiration_date:params.expiration_date
        ~expiration_price:expiration_stock_price
    in
    print_s [%message (predicted_option_price : float * float * float)];
    return predicted_option_price
;;

(*This should eventually be the only function in the main module*)
let main ~(prediction_type : predictions) =
  match prediction_type with
  | Stock model_with_params ->
    let%bind predictions = main_stock ~model_type:model_with_params in
    return (Stock predictions)
  | Options model_with_params ->
    let%bind predictions = main_options ~model_type:model_with_params in
    return (Options predictions)
;;

let command =
  Command.async
    ~summary:"Practice getting cool data"
    (let%map_open.Command () = return () in
     fun () ->
       let monte_carlo_params =
         { Monte_Carlo.start_date = "2006-08-01"
         ; end_date_historical = "2008-10-01"
         ; end_date_pred = "2009-11-10"
         ; stock = "MSFT"
         }
       in
       let black_scholes_params =
         { Black_Scholes.stock = "TSLA"
         ; interest_rate = 0.05
         ; strike_price = 20.
         ; start_date = "2017-01-01"
         ; expiration_date = "2017-02-01"
         ; historical_date_start = "2016-01-01"
         }
       in
       let%bind _data =
         main ~prediction_type:(Stock (Monte_Carlo monte_carlo_params))
       in
       let%bind _data_black_scholes =
         main ~prediction_type:(Options (Black_Scholes black_scholes_params))
       in
       return ())
;;
(* let%bind response = Cohttp_async.Client.get uri in () *)
