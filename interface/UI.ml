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

module Black_Scholes_data = struct
  type t =
    { stock_expiration_price : float
    ; option_contract_price : float
    ; pnl : float
    }
  [@@deriving sexp, jsonaf]

  let of_arrays (stock_expiration_price, option_contract_price, pnl) =
    { stock_expiration_price; option_contract_price; pnl }
  ;;
end

let create_plot () = ()
let draw_UI () = ()

(* url format example: ../stock/aapl/2012-01-01/2013-12-31
   ../predict/aapl/2012-01-01/2013-12-31/2014-12-31 [not yet implemented] *)
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
    print_endline "Stock complete :)";
    Server.respond_string ~headers:header response
  | [ _
    ; "Monte_Carlo"
    ; stock
    ; start_date
    ; end_date_historical
    ; end_date_pred
    ] ->
    let params =
      { Scraper.Monte_Carlo.start_date
      ; end_date_historical
      ; end_date_pred
      ; stock
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
    print_endline "Monte Carlo complete :)";
    Server.respond_string ~headers:header response
  | [ _
    ; "Black_Scholes"
    ; stock
    ; strike_price
    ; interest_rate
    ; start_date
    ; expiration_date
    ; historical_date_start
    ; call_put
    ] ->
    let strike_price = float_of_string strike_price in
    let interest_rate = float_of_string interest_rate in
    let call_put =
      match call_put with
      | "call" -> Source.Options.Contract_type.Call
      | "put" -> Source.Options.Contract_type.Put
      | _ -> Source.Options.Contract_type.Call
    in
    let params =
      { Scraper.Black_Scholes.stock
      ; strike_price
      ; interest_rate
      ; start_date
      ; expiration_date
      ; historical_date_start
      ; call_put
      }
    in
    print_s [%message (params : Scraper.Black_Scholes.t)];
    let%bind _response =
      Scraper.main ~prediction_type:(Options (Black_Scholes params))
    in
    print_endline "hello???";
    let _response =
      match _response with
      | Options n ->
        print_endline "whee";
        n
      | _ ->
        print_endline "very bad";
        failwith "Black Scholes received incorrect input?????"
    in
    let response =
      Black_Scholes_data.of_arrays _response
      |> Black_Scholes_data.jsonaf_of_t
      |> Jsonaf.to_string
    in
    print_endline "Black-Scholes complete :)";
    Server.respond_string ~headers:header response
  | _ ->
    print_endline "not found :(";
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
