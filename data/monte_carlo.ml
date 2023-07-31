open! Core
open! Owl_base

let num_trading_days = ref 252.

(*Think of contraints on the dates for the data*)
let total_growth_percentage ~stock_prices : float option =
  if Array.length stock_prices < 2
  then None
  else (
    let last_element = Array.last stock_prices in
    let first_element = Array.get stock_prices 0 in
    Some (last_element /. first_element))
;;

let calc_annualized_growth_percentage ~total_growth ~num_yrs_elapsed =
  (total_growth ** (1. /. num_yrs_elapsed)) -. 1.0
;;

let calc_pct_change ~prev_element ~new_element =
  (new_element -. prev_element) /. prev_element
;;

let calc_pct_changes ~historical_stock_prices =
  if Array.length historical_stock_prices <= 1
  then Array.create ~len:0 0.0
  else (
    let first_element = Array.get historical_stock_prices 0 in
    let _, percent_change_array =
      Array.foldi
        historical_stock_prices
        ~init:(first_element, Array.create ~len:0 0.0)
        ~f:(fun idx (last_element, new_array) curr_element ->
          if idx = 0
          then last_element, new_array
          else (
            let pct_change =
              calc_pct_change
                ~prev_element:last_element
                ~new_element:curr_element
            in
            ( curr_element
            , Array.append new_array (Array.of_list [ pct_change ]) )))
    in
    percent_change_array)
;;

let calc_std ~prices =
  let mean = Owl_base.Stats.mean prices in
  Owl_base.Stats.std ~mean prices
;;

let random_samples ~number_of_pred_days ~annualized_growth_rate ~std_dev =
  let mu = annualized_growth_rate /. number_of_pred_days in
  let sigma = std_dev /. sqrt number_of_pred_days in
  let rand_numbers =
    Array.create ~len:(int_of_float number_of_pred_days) 0.0
  in
  Array.map rand_numbers ~f:(fun _curr_position ->
    1. +. Owl_base_stats_dist_gaussian.gaussian_rvs ~mu ~sigma)
;;

let get_predicted_prices
  ~(random_percentages : float array)
  ~(starting_price : float)
  =
  Array.fold
    random_percentages
    ~init:[| starting_price |]
    ~f:(fun predictions daily_return_percentage ->
    let last_elt = Array.last predictions in
    let next_value = last_elt *. daily_return_percentage in
    Array.append predictions (Array.of_list [ next_value ]))
;;

let main ~historical_dates ~historical_stock_prices ~pred_dates =
  let open Option.Let_syntax in
  let last_date = Array.last historical_dates in
  let last_date = Date.of_string last_date in
  let first_date = Array.get historical_dates 0 in
  let first_date = Date.of_string first_date in
  let time_elapsed = Date.diff last_date first_date in
  let () = num_trading_days := float_of_int (Array.length pred_dates) in
  let%bind total_growth =
    total_growth_percentage ~stock_prices:historical_stock_prices
  in
  let num_yrs_elapsed = float_of_int time_elapsed /. 365. in
  let annualized_growth_rate =
    calc_annualized_growth_percentage ~total_growth ~num_yrs_elapsed
  in
  let pct_changes_stock = calc_pct_changes ~historical_stock_prices in
  if Array.is_empty pct_changes_stock
  then None
  else (
    let std = calc_std ~prices:pct_changes_stock in
    let std = std *. sqrt !num_trading_days in
    let daily_return_percentage =
      random_samples
        ~number_of_pred_days:!num_trading_days
        ~annualized_growth_rate
        ~std_dev:std
    in
    let predictions =
      get_predicted_prices
        ~random_percentages:daily_return_percentage
        ~starting_price:(Array.last historical_stock_prices)
    in
    print_s [%message (predictions : float array)];
    Some predictions)
;;
