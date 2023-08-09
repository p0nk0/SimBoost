open! Core
open! Owl_base

(* let _calc_log_returns ~prices = let _, log_returns = Array.foldi prices
   ~init:(0.0, Array.create ~len:0 0.0) ~f:(fun idx (prev_price, returns)
   curr_asset_price -> if idx = 0 then curr_asset_price, returns else ( let
   log_return = log (curr_asset_price /. prev_price) in curr_asset_price,
   Array.append returns [| log_return |])) in log_returns ;;

   let _std_dev_log_returns ~prices = let volatility = Owl_base_stats.std
   (calc_log_returns ~prices) in print_s [%message (volatility : float)];
   volatility ;; *)

let _time_till_expiration ~start_date ~end_date =
  let start_date = Date.of_string start_date in
  let end_date = Date.of_string end_date in
  let days_difference = float_of_int (Date.diff end_date start_date) in
  days_difference /. 365.
;;

let calculate_d1_call
  ~strike_price
  ~stock_price
  ~interest_rate
  ~std_log_returns
  ~time_till_expiry
  =
  let _ =
    strike_price
    +. stock_price
    +. interest_rate
    +. std_log_returns
    +. time_till_expiry
  in
  let strike_price = 60. in
  let stock_price = 62. in
  let time_till_expiry = 40. /. 365. in
  let std_log_returns = 0.32 in
  let interest_rate = 0.04 in
  let d1 =
    (log (stock_price /. strike_price)
     +. ((interest_rate +. ((std_log_returns **. 2.) /. 2.))
         *. time_till_expiry))
    /. (std_log_returns *. sqrt time_till_expiry)
  in
  d1
;;

let calculate_d2 ~d1 ~std_log_returns ~time_till_expiry =
  let d2 = d1 -. (std_log_returns *. sqrt time_till_expiry) in
  d2
;;

(*Ensure that there is a list of stock prices -- error checking module*)
let main
  ~stock_prices
  ~strike_price
  ~interest_rate
  ~start_date
  ~expiration_date
  ~expiration_price
  ~call_put
  =
  let spot_price = Array.get stock_prices (Array.length stock_prices - 1) in
  let std_log_returns = Options.volatility ~prices:stock_prices in
  let time_till_expiry =
    Options.time_till_expiration ~start_date ~end_date:expiration_date
  in
  let d1 =
    calculate_d1_call
      ~strike_price
      ~stock_price:spot_price
      ~interest_rate
      ~std_log_returns
      ~time_till_expiry
  in
  let d2 = calculate_d2 ~d1 ~std_log_returns ~time_till_expiry in
  match call_put with
  | Options.Contract_type.Call ->
    let first_formula = spot_price *. Distributions.cdf_norm ~x:d1 in
    let second_formula =
      strike_price
      *. exp (-1. *. interest_rate *. time_till_expiry)
      *. Distributions.cdf_norm ~x:d2
    in
    let call_price = first_formula -. second_formula in
    print_s [%message (Distributions.cdf_norm ~x:d2 : float)];
    let pnl =
      Accuracy.options_call
        ~ending_stock_price:expiration_price
        ~call_option_price:call_price
        ~strike_price
    in
    expiration_price, call_price, pnl
  | Options.Contract_type.Put ->
    let norm_d2 = Distributions.cdf_norm ~x:(-1. *. d2) in
    let first_formula =
      strike_price
      *. exp (-1. *. interest_rate *. time_till_expiry)
      *. norm_d2
    in
    let second_formula =
      spot_price *. Distributions.cdf_norm ~x:(-1. *. d1)
    in
    let put_option_price = first_formula -. second_formula in
    let pnl =
      Accuracy.options_put
        ~ending_stock_price:expiration_price
        ~put_option_price
        ~strike_price
    in
    expiration_price, -1. *. put_option_price, pnl
;;
