open! Core
open! Owl_base

let pi = ref 3.14159265359


let cdf_norm ~x =
  let b1 = 0.31938152 in
  let b2 = -0.356563782 in
  let b3 = 1.7814477937 in
  let b4 = -1.821255978 in
  let b5 = 1.330274429 in
  let p = 0.2316419 in
  let a = Float.abs x in
  let t = 1. /. (1. +. (a *. p)) in
  let w =
    ref
      (1.
       -. (1.
           /. sqrt (2. *. !pi)
           *. exp (-1. *. a *. a /. 2.)
           *. ((b1 *. t)
               +. (b2 *. t *. t)
               +. (b3 *. (t ** 3.))
               +. (b4 *. (t ** 4.))
               +. (b5 *. (t *. 5.)))))
  in
  if Float.( < ) x 0.0 then w := 1.0 -. !w;
  !w
;;

