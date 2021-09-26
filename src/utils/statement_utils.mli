(* Helper functions for manipulation with cil types
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

val are_in_same_kf : Cil_types.stmt -> Cil_types.stmt -> bool

val kernel_fn_from_fundec : Cil_types.fundec -> Kernel_function.t

val find_englobing_fn : Cil_types.stmt -> Cil_types.fundec 

val fundec_from_varinfo : Cil_types.varinfo -> Cil_types.fundec

val nth_formal : Kernel_function.t -> int -> Cil_types.varinfo

val call_params : Cil_types.stmt -> Cil_types.exp list

val nth_call_param : Cil_types.stmt -> int -> Cil_types.exp

val is_guard : Cil_types.stmt -> bool

val guard_to_condition : Cil_types.stmt -> Cil_types.exp

val is_exit_point : Cil_types.stmt -> bool
(** True if statement is either a return or a goto that jumps to a return. This
    function is useful because CIL normalize all functions to single-exit-point
    form. *)
