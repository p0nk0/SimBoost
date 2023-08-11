open! Core
open! Owl_base

let options_call ~ending_stock_price ~call_option_price ~strike_price =
  let gain = ending_stock_price *. 100. in
  let loss = call_option_price +. (strike_price *. 100.) in
  let profit = gain -. loss in
  profit
;;

let options_put ~ending_stock_price ~put_option_price ~strike_price =
  let gain = strike_price *. 100. in
  let loss = put_option_price +. (ending_stock_price *. 100.) in
  let profit = gain -. loss in
  profit
;;
