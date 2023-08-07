(* this file will be renamed later *)
open! Core
open Async
open! Jsonaf.Export
module Server = Cohttp_async.Server

module Stock_data = struct
  type t =
    { dates : string array
    ; stocks : float array
    }
  [@@deriving sexp, jsonaf]

  let of_arrays (dates, stocks) = { dates; stocks }
end

module Monte_Carlo_data = struct
  type t =
    { accuracy : float
    ; predictions : float array
    }
  [@@deriving sexp, jsonaf]

  let of_arrays (accuracy, predictions) = { accuracy; predictions }
end

let create_plot () = ()
let draw_UI () = ()

(* url format example: ../stock/aapl/2012-01-01/2013-12-31
   ../predict/aapl/2012-01-01/2013-12-31 [not yet implemented] *)
let handler ~body:_ _sock req =
  let uri = Cohttp.Request.uri req in
  let header = Cohttp.Header.init_with "Access-Control-Allow-Origin" "*" in
  let request = Uri.path uri |> String.split ~on:'/' in
  print_s [%message (request : string list)];
  match request with
  | [ _; "stock"; stock; start_date; end_date ] ->
    let%bind _response = Scraper.get ~start_date ~end_date ~stock in
    let response =
      Source.Data.fetch_data_as_array ~retrieved_stock_data:_response
      |> Stock_data.of_arrays
      |> Stock_data.jsonaf_of_t
      |> Jsonaf.to_string
    in
    print_s [%message (response : string)];
    Server.respond_string ~headers:header response
  | [ _
    ; "Monte_Carlo"
    ; _stock
    ; _start_date
    ; _end_date_historical
    ; _end_date_pred
    ] ->
    let params =
      { Scraper.Monte_Carlo.start_date = "2006-08-01"
      ; end_date_historical = "2008-10-01"
      ; end_date_pred = "2009-11-10"
      ; stock = "MSFT"
      }
    in
    let%bind _response =
      Scraper.main ~prediction_type:(Stock (Monte_Carlo params))
    in
    let _response =
      match _response with
      | Stock n -> n
      | _ -> failwith "Monte Carlo returned an option prediction ?????"
    in
    let response =
      Monte_Carlo_data.of_arrays _response
      |> Monte_Carlo_data.jsonaf_of_t
      |> Jsonaf.to_string
    in
    print_s [%message (response : string)];
    Server.respond_string ~headers:header response
  | _ ->
    Server.respond_string
      ~headers:header
      ~status:`Not_found
      "\" Route not found \""
;;

let start_server port () =
  Stdlib.Printf.eprintf "Listening for HTTP on port %d\n" port;
  Stdlib.Printf.eprintf
    "Try 'curl http://localhost:%d/test?hello=xyz'\n%!"
    port;
  Server.create
    ~on_handler_error:`Raise
    (Async.Tcp.Where_to_listen.of_port port)
    handler
  >>= fun _server -> Deferred.never ()
;;

let command =
  Command.async
    ~summary:"Start server for example [starter_template]"
    (let%map_open.Command port =
       flag
         "port"
         (optional_with_default 8181 int)
         ~doc:"port on which to serve"
     in
     fun () -> start_server port ())
;;
