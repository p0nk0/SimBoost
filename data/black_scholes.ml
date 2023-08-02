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

let calculate_d1
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

let calculate_d2
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
