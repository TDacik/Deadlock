open Trace_utils

(** Representation of lock *)
module Lock : sig

  type t

  val create : Cil_types.varinfo -> int -> Callstack.t -> t
  
  val get_varinfo : t -> Cil_types.varinfo

  val is_weak : t -> bool
  (** Lock is weak if its underlying variable is formal or local *)
  
  val get_address : t -> Cil_types.varinfo * int
  
  val compare : t -> t -> int

  val equal : t -> t -> bool

  val hash : t -> int

  (** Following functions should be used only during the lockset analysis.
   *  When lock is obtained from the lockgraph, information about traces
   *  is stored in its edges *)

  val get_trace : t -> Callstack.t

  val update_trace : t -> Callstack.t -> t
  
  val origin_stmt : t -> Cil_types.stmt

  val return_var : t -> Cil_types.exp option

  (** {1 Printing } *)

  val to_string : t -> string

  val pp : Format.formatter -> t -> unit

end

(** Set of locks *)
module Lockset : sig

  include Set.S with type elt = Lock.t

  module Map : Map.S with type key = t

  val from_list : elt list -> t

  val to_list : t -> elt list

  val cartesian_product : t -> t -> (elt * elt) list

  val are_disjoint : t -> t -> bool

  val to_string : t -> string

  val pp : Format.formatter -> t -> unit

end

(** Set of locksets *)
module LocksetSet : sig

  include Set.S with type elt = Lockset.t

  val from_list : t list -> t

  val singletons_from_list : Lock.t list -> t

  val to_list : t -> elt list

  val map_locks : (Lockset.elt -> Lockset.elt) -> t -> t
  (** [map_locks f lss] apply f on each lock of each member of lss *)

  val add_each : elt -> elt -> t

  val remove_each : elt -> elt -> t

  val elems_union : t -> elt

  exception Empty_intersection

  val elems_inter : t -> elt

  val to_string : t -> string

  val pp : Format.formatter -> t -> unit

end
