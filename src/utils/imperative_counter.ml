(* Generic imperative counter
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

module Counter () = struct

  let value = ref 0

  let set n = value := n
  let get () = !value
  let reset () = value := 0

  let inc () = value := !value + 1
  let dec () = value := !value - 1

  let inc_cond c = if c then inc () else ()
  let dec_cond c = if c then dec () else ()

  let add n = value := !value + n
  let sub n = value := !value - n

  let add_cond n c = if c then add n else ()
  let sub_cond n c = if c then sub n else ()

end
