open! Core
open! Owl_base

(*Change this function later*)
let cdf_norm ~x =
  let t1 = -358. *. x /. 23. in
  let t2 = 111. *. Float.atan (37. *. x /. 294.) in
  let t3 = exp (t1 +. t2) in
  1. /. (t3 +. 1.)
;;
