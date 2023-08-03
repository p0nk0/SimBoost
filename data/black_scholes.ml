open! Core
open! Owl_base

let calc_volatilty ~prices =
  let variance = Owl_base_stats.var prices in
  sqrt variance
;;

let calc_log_returns ~prices =
  let _, log_returns =
    Array.foldi
      prices
      ~init:(0.0, Array.create ~len:0 0.0)
      ~f:(fun idx (prev_price, returns) curr_asset_price ->
        if idx = 0
        then curr_asset_price, returns
        else (
          let log_return = log (curr_asset_price /. prev_price) in
          curr_asset_price, Array.append returns [| log_return |]))
  in
  log_returns
;;

let std_dev_log_returns ~prices =
  Owl_base_stats.std (calc_log_returns ~prices)
;;

let time_till_expiration ~start_date ~end_date =
  let start_date = Date.of_string start_date in
  let end_date = Date.of_string end_date in
  Date.diff end_date start_date
;;

let calculate_d1_call
  ~strike_price
  ~stock_price
  ~interest_rate
  ~std_log_returns
  ~time_till_expiry
  =
  log (stock_price /. strike_price)
  +. ((interest_rate +. ((std_log_returns ** 2.) /. 2.))
      *. time_till_expiry
      /. (std_log_returns *. sqrt time_till_expiry))
;;

let calculate_d1_put
  ~strike_price
  ~stock_price
  ~interest_rate
  ~std_log_returns
  ~time_till_expiry
  =
  log (stock_price /. strike_price)
  +. ((interest_rate -. ((std_log_returns ** 2.) /. 2.))
      *. time_till_expiry
      /. (std_log_returns *. sqrt time_till_expiry))
;;

let calculate_d2 ~d1 ~std_log_returns ~time_till_expiry =
  d1 -. (std_log_returns *. sqrt time_till_expiry)
;;

(*Ensure that there is a list of stock prices -- error checking module*)
let main
  ~stock_prices
  ~strike_price
  ~interest_rate
  ~start_date
  ~expiration_date
  =
  let spot_price = Array.get stock_prices 0 in
  let std_log_returns = std_dev_log_returns ~prices:stock_prices in
  let time_till_expiry =
    float_of_int (time_till_expiration ~start_date ~end_date:expiration_date)
  in
  let d1 =
    calculate_d1_put
      ~strike_price
      ~stock_price:spot_price
      ~interest_rate
      ~std_log_returns
      ~time_till_expiry
  in
  let d2 = calculate_d2 ~d1 ~std_log_returns ~time_till_expiry in
  let first_formula = spot_price *. Distributions.cdf_norm ~x:d1 in
  let second_formula =
    strike_price
    *. exp (-1. *. interest_rate *. time_till_expiry)
    *. Distributions.cdf_norm ~x:d2
  in
  let call_price = first_formula -. second_formula in
  print_s [%message (call_price : float)]
;;
