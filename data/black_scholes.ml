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
