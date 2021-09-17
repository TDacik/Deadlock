(* Imperative wrapper over EVA. 
 *
 * There are two instances of the wrapper:
 *  a) CIL (@see cil_wrapper)
 *  b) EVA (@see eva_wrapper)
 *
 * Usage of wrapper is following:
 *  1. Active wrapper is by default CIL. EVA wrapper can be used by calling init ().
 *  2. All communication with EVA should be done via wrapper.
 *
 *  Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open Trace_utils
open Eva_wrapper_sig

include EVA_WRAPPER
(** Basic functionality of wrapper*)

(** {2 Functions build on top of basic wrapper functionality} *)

val get_stmt_state_with_arg : Cil_types.stmt -> Thread.Thread_initial_state.t
(** Assuming statement is thread create, return initial state of created thread *)

val eval_expr_in_context : Cvalue.Model.t -> Cil_types.exp -> abstract_context

val eval_fn_call : Cil_types.stmt -> Cil_types.exp -> Cil_types.fundec list

val get_created_threads : Cil_types.stmt -> Thread.t list

val save_thread_state : Thread.t -> unit
