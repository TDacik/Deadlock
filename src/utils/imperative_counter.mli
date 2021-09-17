(* Generic imperative counter.
 *
 * Counter is a generative functor initialised as follows:
 *
 *  module Counter = Counter()
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

module type IMPERATIVE_COUNTER = sig
  val set : int -> unit
  val get : unit -> int
  val reset : unit -> unit

  val inc : unit -> unit
  val dec : unit -> unit

  val inc_cond : bool -> unit
  val dec_cond : bool -> unit

  val add : int -> unit
  val sub : int -> unit

  val add_cond : int -> bool -> unit
  val sub_cond : int -> bool -> unit
end

module Counter () : IMPERATIVE_COUNTER
(** Functor for counter initialisation. *)
