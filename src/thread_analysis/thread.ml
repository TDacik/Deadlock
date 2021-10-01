(* Representation of a logic thread -- function that is passed as entry point to thread create
 * function and its initial state consisting of values of global variables and value of thread's
 * argument.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020 
 *)

open! Deadlock_top

open Print_utils
open Cil_datatype

(** Thread initial state is a direct product of abstract domains Cvalue.Model and
    Cvalue.V. Frama-C has a functor for this, but Cvalue.Model does not implements
    its signature, so we have to define it here. *)

module Thread_initial_state = struct

  module Globals = Cvalue.Model (* Values of global variables *)
  module Arg = Cvalue.V         (* Value of thread's argument *)

  type t = Globals.t * Arg.t

  (* Dummy widening hints for argumemt *)

  let size_hint = Integer.zero
  let hint = (Datatype.Integer.Set.empty, Fc_float.Widen_Hints.default_widen_hints)
  let numerical_hint = (fun _ -> hint)
  let args_widen_hint = (size_hint, numerical_hint)

  (* Dummy widening hints for globals *)

  let base_set = Base.Set.empty
  let hint_fn = (fun _ -> numerical_hint)
  let globals_widen_hint = (base_set, hint_fn)

  (* Minimal set of operations over the product *)

  let bottom = (Cvalue.Model.bottom, Arg.bottom)

  let join (g1, a1) (g2, a2) = (Globals.join g1 g2, Arg.join a1 a2)

  let compare (g1, a1) (g2, a2) =
    let aux = Globals.compare g1 g2 in
    if aux <> 0 then aux
    else Arg.compare a1 a2

  let equal state1 state2 = (compare state1 state2) = 0

  let widening (g1, a1) (g2, a2) =
    (Globals.widen globals_widen_hint g1 g2, Arg.widen args_widen_hint a1 a2)

end

(* ==== Thread ==== *)

type t = {
  entry_point : Cil_types.fundec;
  init_state : Thread_initial_state.t;
  is_main : bool;
}

let create ?(is_main=false) entry_point globals arg = {
  entry_point = entry_point;
  init_state = (globals, arg);
  is_main = is_main;
}

let create_bottom ?(is_main=false) entry_point = {
  entry_point = entry_point;
  init_state = Thread_initial_state.bottom;
  is_main = is_main;
}

let dummy = create_bottom (Cil.emptyFunction "dummy")

let update_state thread (globals, args) = 
  {
    entry_point = thread.entry_point;
    init_state = (globals, args);
    is_main = thread.is_main;
  }

(** Threads are identified and compared only using their entry points *)

let compare t1 t2 = Fundec.compare t1.entry_point t2.entry_point

let equal t1 t2 = Fundec.equal t1.entry_point t2.entry_point

let hash t = Fundec.hash t.entry_point

let compare_with_states t1 t2 = 
  let aux = compare t1 t2 in
  if aux <> 0 then aux
  else Thread_initial_state.compare t1.init_state t2.init_state

(* TODO: use caching? *)
let compare_states t1 t2 = Thread_initial_state.compare t1.init_state t2.init_state

let equal_states t1 t2 = (compare_states t1 t2) = 0

(* ==== Accessors ==== *)

let is_main thread = thread.is_main

let get_entry_point thread = thread.entry_point

let get_init_state thread = thread.init_state

let get_globals thread = fst thread.init_state

let get_args thread = snd thread.init_state

let get_arg_base thread =
  let args = get_args thread in
  try Cvalue.V.fold_bases List.cons args []
  with Abstract_interp.Error_Top -> []

module Thread = struct
  type nonrec t = t
  let compare = compare
end

module Set = Set.Make(Thread)

module Map = Map.Make(Thread)

open CCOpt

(* Formal argument of thread entry point may not exist *)
let get_formal_arg_base thread =
  let entry_point = thread.entry_point in
  Base.of_varinfo <$> (List.nth_opt entry_point.sformals 0)

let is_computed thread = match thread.init_state with
  | (globals, args) ->
    not (globals = Cvalue.Model.bottom) && not (Cvalue.V.is_bottom args)


(* ==== Pretty printers ==== *)

let to_string t = Format.asprintf "%a" Printer.pp_fundec t.entry_point

let to_string_globals t = Format.asprintf "%a" pp_globals (fst t.init_state)

let to_string_args t = Format.asprintf "%a" Db.Value.pretty (snd t.init_state)

let pp fmt t = Format.fprintf fmt "%s" (to_string t)

let pp_init_state fmt t =
  Format.fprintf fmt "Initial state of %s: \n Globals: %s \n Argument: %s\n"
    (to_string t) (to_string_globals t) (to_string_args t)
