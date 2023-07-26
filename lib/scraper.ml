open! Core
open! Async
module Stats = Stats

let get ~start_date ~end_date ~stock =
  let path = "/api/v3/datasets/WIKI/" ^ stock ^ "/data.csv" in
  let uri =
    Uri.make
      ~scheme:"https"
      ~host:"data.nasdaq.com"
      ~path
      ~query:
        [ "column_index", [ "11" ]
        ; "start_date", [ start_date ]
        ; "end_date", [ end_date ]
        ; "order", [ "asc" ]
        ; "api_key", [ "KNuGGawwwBcDtAzTzaGi" ]
        ]
      ()
  in
  let%bind _response, body = Cohttp_async.Client.get uri in
  let%bind body = Cohttp_async.Body.to_string body in
  return body
;;

let main () =
  let%bind stock_data =
    get ~start_date:"2000-01-01" ~end_date:"2001-01-01" ~stock:"AAPL"
  in
  let potential_data = String.split_lines stock_data in
  match potential_data with
  | [] -> return ()
  | headers :: actual_data ->
    print_s [%message (headers : string)];
    print_s [%message (actual_data : string list)];
    return ()
;;

let command =
  Command.async
    ~summary:"Practice getting cool data"
    (let%map_open.Command () = return () in
     fun () ->
       let%bind _data =
         get ~start_date:"2000-01-01" ~end_date:"2001-01-01" ~stock:"AAPL"
       in
       main ())
;;
(* let%bind response = Cohttp_async.Client.get uri in () *)
