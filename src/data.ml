open! Core
open! Async

let fetch_data_as_array ~stock_data =
  let _dates = Array.create in
  let _adj_close_prices = Array.create in
  ignore stock_data
;;
