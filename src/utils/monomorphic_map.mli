(* Signature of map without type.
 *
 * The purpose of this signature is to be included in monomorphic maps that defines type "t"
 * that cannot be later overwrite by origincal Map.S signature.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

module type S = sig

  type key      (* Type for keys *)

  type data     (* Type for stored values *)

  type t        (* Monomorphic map *)

  type 'a _t    (* Polymorphic map *)

  val empty: t

  val is_empty: t -> bool

  val mem:  key -> t -> bool

  val add: key -> data -> t -> t

  val update: key -> (data option -> data option) -> t -> t

  val singleton: key -> data -> t

  val remove: key -> t -> t

  val merge: (key -> data option -> 'b option -> 'c option) -> t -> 'b _t -> 'c _t

  val union: (key -> data -> data -> data option) -> t -> t -> t

  val compare: (data -> data -> int) -> t -> t -> int

  val equal: (data -> data -> bool) -> t -> t -> bool

  val iter: (key -> data -> unit) -> t -> unit

  val fold: (key -> data -> 'b -> 'b) -> t -> 'b -> 'b

  val for_all: (key -> data -> bool) -> t -> bool

  val exists: (key -> data -> bool) -> t -> bool

  val filter: (key -> data -> bool) -> t -> t

  val filter_map: (key -> data -> 'b option) -> t -> 'b _t

  val partition: (key -> data -> bool) -> t -> t * t

  val cardinal: t -> int

  val bindings: t -> (key * data) list

  val min_binding: t -> (key * data)

  val min_binding_opt: t -> (key * data) option

  val max_binding: t -> (key * data)

  val max_binding_opt: t -> (key * data) option

  val choose: t -> (key * data)

  val choose_opt: t -> (key * data) option

  val split: key -> t -> t * data option * t

  val find: key -> t -> data

  val find_opt: key -> t -> data option

  val find_first: (key -> bool) -> t -> key * data

  val find_first_opt: (key -> bool) -> t -> (key * data) option

  val find_last: (key -> bool) -> t -> key * data

  val find_last_opt: (key -> bool) -> t -> (key * data) option

  val map: (data -> 'b) -> t -> 'b _t

  val mapi: (key -> data -> 'b) -> t -> 'b _t

  val to_seq : t -> (key * data) Seq.t

  val to_rev_seq : t -> (key * data) Seq.t

  val to_seq_from : key -> t -> (key * data) Seq.t

  val add_seq : (key * data) Seq.t -> t -> t

  val of_seq : (key * data) Seq.t -> t

end
