open Lock_types
open Trace_utils
open Cil_datatype

type precondition = Thread.t * Lockset.t * Cvalue.Model.t
type postcondition = LocksetSet.t * Lockgraph.t

val precondition_compare : precondition -> precondition -> int

module Summaries : Map.S with type key = Cil_types.fundec * precondition

include Monomorphic_map.S with type key = Cil_types.fundec * precondition
                           and type data = postcondition

val union : t -> t -> t

val summaries_of_fn : t -> Cil_types.fundec -> t

val summary_is_identity : key -> t -> bool

val fn_is_identity : Cil_types.fundec -> t -> bool

val nb_functions : t -> int

(** {2 Pretty Printers} *)

val pp_entry : Format.formatter -> key -> postcondition -> unit

val pp : Format.formatter -> t -> unit

val pp_non_id : Format.formatter -> t -> unit
