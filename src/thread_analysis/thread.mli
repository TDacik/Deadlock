(* Representation of a logic thread -- function that is passed as entry point to thread create
 * function and its initial state consisting of values of global variables and value of thread's
 * argument.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020 
 *)

(** Initial state represents possible values of global variables
    and thread argument at the begining of its execution *)
module Thread_initial_state : sig

  type t = Cvalue.Model.t * Cvalue.V.t

  val bottom : t

  val join : t -> t -> t

  val compare : t -> t -> int

  val equal : t -> t -> bool

  val widening : t -> t -> t

end

type t

val create : Cil_types.fundec -> Cvalue.Model.t -> Cvalue.V.t -> t
(** [create fn globals arg] creates thread with entry point [fn] and initial state
    ([globals], [args]) *)

val create_bottom : Cil_types.fundec -> t
(** Create thread with bottom initial state *)

val dummy : t

val get_main_thread : unit -> t
(** Create representation of the main thread *)

val compare : t -> t -> int
(** Compare entry points *)

val equal : t -> t -> bool
(** Equality of entry points *)

val hash : t -> int
(** Hash of entry point *)

val compare_with_states : t -> t -> int
(** Comparison that use both entry point and initial state *)

val equal_states : t -> t -> bool

val compare_states : t -> t -> int
(** Comparion based on initial states only *)

val is_computed : t -> bool
(** @return false when globals or arg is bottom *)

val is_main : t -> bool

val get_entry_point : t -> Cil_types.fundec

val get_init_state : t -> Thread_initial_state.t

val update_state : t -> Thread_initial_state.t -> t

val get_globals : t -> Cvalue.Model.t

val get_args : t -> Cvalue.V.t

val get_arg_base : t -> Base.t list
(** Return bases of all arguments from all thread's create stmts *)

val get_formal_arg_base : t -> Base.t option
(** Return base of formal parameter of thread's entry point. This base does not exist when
    entry point abuses pthread standard. *)

(** {2 Collections } *)

module Set : Set.S with type elt = t

module Map : Map.S with type key = t

(** {2 Pretty printing } *)

val to_string : t -> string

val pp : Format.formatter -> t -> unit

val pp_init_state : Format.formatter -> t -> unit
