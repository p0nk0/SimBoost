open! Core
open! Owl_base

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

let main ~historical_dates ~historical_stock_prices =
  let open Option.Let_syntax in
  let time_elapsed = Array.length historical_dates in
  let%bind total_growth =
    total_growth_percentage ~stock_prices:historical_stock_prices
  in
  let num_yrs_elapsed = float_of_int time_elapsed /. 365. in
  let _annualized_growth_rate =
    calc_annualized_growth_percentage ~total_growth ~num_yrs_elapsed
  in
  ();
  Some true
;;

(* let calc_annualized_growth_percentage = () let calc_scaled_std = () let
   gen_rand_vals = () let accuracy = () *)
