open! Core
open! Owl_base

let create_arrays n =
  let m_list = Array.create ~len:(n + 1) 0.0 in
  Array.mapi m_list ~f:(fun idx _elt -> float_of_int idx)
;;

let main
  ~stock_prices
  ~strike_price
  ~interest_rate
  ~start_date
  ~expiration_date
  ~number_of_time_steps
  =
  let spot_price = Array.get stock_prices (Array.length stock_prices - 1) in
  let volatility = Options.volatility ~prices:stock_prices in
  let time_till_expiry =
    Options.time_till_expiration ~start_date ~end_date:expiration_date
  in
  let time_step = time_till_expiry /. float_of_int number_of_time_steps in
  let u = exp (volatility *. sqrt time_step) in
  let d = 1. /. u in
  let prob = (exp (interest_rate *. time_step) -. d) /. (u -. d) in
  let m_list = create_arrays number_of_time_steps in
  let k_list = create_arrays number_of_time_steps in
  let tree =
    Array.make_matrix
      ~dimx:(number_of_time_steps + 1)
      ~dimy:(number_of_time_steps + 1)
      0.0
  in
  let num_steps = float_of_int number_of_time_steps in
  Array.iter m_list ~f:(fun curr_m ->
    let new_elt =
      Float.max
        ((spot_price *. (u ** ((2. *. curr_m) -. num_steps))) -. strike_price)
        0.0
    in
    let m_idx = int_of_float curr_m in
    tree.(number_of_time_steps).(m_idx) <- new_elt);
  let k_list = Array.rev k_list in
  Array.iteri k_list ~f:(fun _idx_k curr_k ->
    Array.iteri m_list ~f:(fun idx_m _curr_m ->
      let curr_k = int_of_float curr_k in
      if idx_m <= curr_k
      then (
        let new_elt =
          (exp (-1. *. interest_rate *. time_step)
           *. (prob *. tree.(curr_k + 1).(idx_m + 1)))
          +. ((1. -. prob) *. tree.(curr_k + 1).(idx_m + 1))
        in
        tree.(curr_k).(idx_m) <- new_elt)));
  tree.(0).(0)
;;
