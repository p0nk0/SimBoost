open! Core
open! Owl_base

module Contract_type = struct
  type t =
    | Call
    | Put
end

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

let volatility ~prices =
  let volatility = Owl_base_stats.std (calc_log_returns ~prices) in
  volatility
;;

let time_till_expiration ~start_date ~end_date =
  let start_date = Date.of_string start_date in
  let end_date = Date.of_string end_date in
  let days_difference = float_of_int (Date.diff end_date start_date) in
  days_difference /. 365.
;;
