open! Core
open! Async
module Stats = Stats

val get : unit -> unit Deferred.t
val command : Command.t
