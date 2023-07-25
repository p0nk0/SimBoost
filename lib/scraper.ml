open! Core
open! Async
module Stats = Stats

let get () =
  let open Deferred.Let_syntax in
  let uri =
    Uri.make
      ~scheme:"https"
      ~host:"data.nasdaq.com"
      ~path:"/api/v3/datasets/WIKI/FB/data.csv"
      ~query:
        [ "column_index", [ "4" ]
        ; "start_date", [ "2014-01-01" ]
        ; "end_date", [ "2014-12-31" ]
        ; "collapse", [ "monthly" ]
        ; "transform", [ "rdiff" ]
        ; "api_key", [ "KNuGGawwwBcDtAzTzaGi" ]
        ]
      ()
  in
  let%bind _response, body = Cohttp_async.Client.get uri in
  let%bind body = Cohttp_async.Body.to_string body in
  print_endline body;
  return ()
;;

let command =
  Command.async
    ~summary:"Practice getting cool data"
    (let%map_open.Command () = return () in
     fun () -> get ())
;;
(* let%bind response = Cohttp_async.Client.get uri in () *)
