open! Core
open! Owl_base

(*Options put and stock accuracy methods*)

let options_call ~ending_stock_price ~call_option_price ~strike_price =
  let gain = ending_stock_price *. 100. in
  let loss = call_option_price +. strike_price *. 100. in
  let profit = gain -. loss in
  profit
;;
