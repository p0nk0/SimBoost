(* this file will be renamed later *)
open! Core
open Async
module Server = Cohttp_async.Server

let create_plot () = ()
let draw_UI () = ()

(* let test_csv = let%bind result = Scraper.get ~start_date:"2012-01-01"
   ~end_date:"2013-12-31" ~stock:"AAPL" in result ;; *)

let handler ~body:_ _sock req =
  let uri = Cohttp.Request.uri req in
  print_s
    (let uri = Uri.to_string uri in
     [%message "Received a request!" (uri : string)]);
  match Uri.path uri with
  | "/test" ->
    let response =
      Uri.get_query_param uri "hello"
      |> Option.map ~f:(fun v -> "hello: " ^ v)
      |> Option.value ~default:"No param hello suplied"
    in
    let response = "\"" ^ response ^ "\"" in
    print_s [%message "Attempting to respond with" (response : string)];
    let header = Cohttp.Header.init_with "Access-Control-Allow-Origin" "*" in
    Server.respond_string ~headers:header response
  | _ -> Server.respond_string ~status:`Not_found "Route not found"
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
