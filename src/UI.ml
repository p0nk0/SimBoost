(* this file will be renamed later *)
open! Core
open Async
module Server = Cohttp_async.Server

let create_plot () = ()
let draw_UI () = ()
(* let test_csv = "wdajoiawdjiowjadiojidawoijjiodwaoij" *)

let handler ~body:_ _sock req =
  let uri = Cohttp.Request.uri req in
  match Uri.path uri with
  | "/test" ->
    Uri.get_query_param uri "hello"
    |> Option.map ~f:(fun v -> "hello: " ^ v)
    |> Option.value ~default:"No param hello suplied"
    |> Server.respond_string
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
         (optional_with_default 8080 int)
         ~doc:"port on which to serve"
     in
     fun () -> start_server port ())
;;
