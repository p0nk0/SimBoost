open! Core
open! Async

module Monte_Carlo = struct
  type t =
    { start_date : string
    ; end_date_historical : string
    ; end_date_pred : string
    ; stock : string
    }
  [@@deriving sexp_of]
end

module Black_Scholes = struct
  type t =
    { stock : string
    ; strike_price : float
    ; interest_rate : float
    ; start_date : string
    ; expiration_date : string
    ; historical_date_start : string
    ; call_put : Source.Options.Contract_type.t
    }
  [@@deriving sexp_of]
end

module Binomial_Pricing = struct
  type t =
    { stock : string
    ; strike_price : float
    ; interest_rate : float
    ; start_date : string
    ; expiration_date : string
    ; historical_date_start : string
    ; call_put : Source.Options.Contract_type.t
    ; n_time_steps : int
    }
end

type stock_models = Monte_Carlo of Monte_Carlo.t

type option_models =
  | Black_Scholes of Black_Scholes.t
  | Binomial_Pricing of Binomial_Pricing.t

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
    let accuracy, predicted_prices =
      Source.Monte_carlo.main
        ~historical_dates:hist_dates
        ~historical_stock_prices:hist_stock_prices
        ~pred_dates
        ~real_pred_prices:pred_stock_prices
    in
    let zeros_to_add = Array.length hist_stock_prices in
    let predicted_prices =
      Source.Data.pad_array_with_zeros
        ~current_array:predicted_prices
        ~num_zeros_to_add:zeros_to_add
    in
    return (accuracy, predicted_prices)
;;

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
    let%bind expiration_stock_price =
      Deferred.repeat_until_finished params.expiration_date (fun date ->
        let%map expiration_data =
          get ~start_date:date ~end_date:date ~stock:params.stock
        in
        let _, expiration_stock_price =
          Source.Data.fetch_data_as_array
            ~retrieved_stock_data:expiration_data
        in
        if Array.is_empty expiration_stock_price
        then (
          let new_date = Source.Data.get_valid_date ~date in
          let new_date = Date.to_string new_date in
          `Repeat new_date)
        else `Finished (Array.get expiration_stock_price 0))
    in
    let predicted_option_price =
      Source.Black_scholes.main
        ~stock_prices:hist_stock_prices
        ~strike_price:params.strike_price
        ~interest_rate:params.interest_rate
        ~start_date:params.start_date
        ~expiration_date:params.expiration_date
        ~expiration_price:expiration_stock_price
        ~call_put:params.call_put
    in
    return predicted_option_price
  | Binomial_Pricing params ->
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
    let%bind expiration_stock_price =
      Deferred.repeat_until_finished params.expiration_date (fun date ->
        let%map expiration_data =
          get ~start_date:date ~end_date:date ~stock:params.stock
        in
        let _, expiration_stock_price =
          Source.Data.fetch_data_as_array
            ~retrieved_stock_data:expiration_data
        in
        if Array.is_empty expiration_stock_price
        then (
          let new_date = Source.Data.get_valid_date ~date in
          let new_date = Date.to_string new_date in
          `Repeat new_date)
        else `Finished (Array.get expiration_stock_price 0))
    in
    let predicted_option_price =
      Source.Binomial_pricer.main
        ~strike_price:params.strike_price
        ~interest_rate:params.interest_rate
        ~stock_prices:hist_stock_prices
        ~number_of_time_steps:params.n_time_steps
        ~call_put:params.call_put
        ~start_date:params.start_date
        ~expiration_date:params.expiration_date
        ~expiration_price:expiration_stock_price
    in
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
    ~summary:"Testing Various Options and Stock Models"
    (let%map_open.Command () = return () in
     fun () ->
       let monte_carlo_params =
         { Monte_Carlo.start_date = "2013-08-01"
         ; end_date_historical = "2014-10-01"
         ; end_date_pred = "2015-11-10"
         ; stock = "TSLA"
         }
       in
       let black_scholes_params =
         { Black_Scholes.stock = "PG"
         ; interest_rate = 0.05
         ; strike_price = 100.
         ; start_date = "2007-01-01"
         ; expiration_date = "2008-01-01"
         ; historical_date_start = "2006-01-01"
         ; call_put = Put
         }
       in
       let binomial_params =
         { Binomial_Pricing.call_put = Put
         ; start_date = "2007-01-01"
         ; expiration_date = "2008-01-01"
         ; historical_date_start = "2006-01-01"
         ; strike_price = 200.
         ; stock = "AAPL"
         ; n_time_steps = 5
         ; interest_rate = 0.05
         }
       in
       let%bind _data =
         main ~prediction_type:(Stock (Monte_Carlo monte_carlo_params))
       in
       let%bind _data_black_scholes =
         main ~prediction_type:(Options (Black_Scholes black_scholes_params))
       in
       let%bind _data_binomial_pricing =
         main ~prediction_type:(Options (Binomial_Pricing binomial_params))
       in
       return ())
;;
