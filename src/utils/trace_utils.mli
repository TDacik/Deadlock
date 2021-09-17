module Callstack : sig

  type path_taken =
    | Then
    | Else
    | Then_nondet
    | Else_nondet
  
  type event =
    | Thread_entry of Thread.t
    | Call of Cil_types.stmt * Cil_types.fundec
    | Guard of Cil_types.stmt * path_taken
    | Action of Cil_types.stmt * string

  type t = event list

  exception Empty_callstack

  exception Incomplete_callstack

  exception Invalid_callstack of string

  val compare_event : event -> event -> int

  val equal_event : event -> event -> bool

  val compare : t -> t -> int

  val equal : t -> t -> bool

  val compare_abstr : ?with_action_stmt:bool -> int -> t -> t -> int
  (** compare_abstr with_action n cs1 cs2 compare prefixes of length n
      and possibly the action stmt. *)

  (** {2 Callstack } *)

  val empty : t

  val push_thread_entry : Thread.t -> t

  val push_call : Cil_types.stmt -> Cil_types.fundec -> t -> t 

  val push_guard : Cil_types.stmt -> path_taken -> t -> t

  val push_action : Cil_types.stmt -> string -> t -> t

  val pop : t -> t

  val is_empty : t -> bool

  val depth : t -> int

  val remove_guards : t -> t

  val mem_call : t -> Cil_types.fundec -> bool

  val cut_prefix : Cil_types.fundec -> t -> t

  val concat : t -> t -> t

  (** {2 Accessors } *)

  val top : t -> event

  val top_stmt : t -> Cil_types.stmt

  val top_call_stmt : t -> Cil_types.stmt

  val top_call_fn : t -> Cil_types.fundec

  val top_call : t -> Cil_types.fundec * Cil_types.stmt

  val get_action : t -> Cil_types.stmt * string

  val get_action_stmt : t -> Cil_types.stmt

  (* TODO *)
  val get_bottom_stmt : t -> Cil_types.stmt

  val get_thread : t -> Thread.t

  val set_thread : Thread.t -> t -> t

  (** {2 Pretty-printers } *)

  val pp : Format.formatter -> t -> unit

end

module Edge_trace : sig
  
  type t = Callstack.t * Callstack.t

  val create : Callstack.t -> Callstack.t -> t

  val get_thread : t -> Thread.t

  val get_action_stmts : t -> Cil_types.stmt * Cil_types.stmt

  val get_callstacks : t -> Callstack.t * Callstack.t

  val length : t -> int

  val to_string : t -> string

end


