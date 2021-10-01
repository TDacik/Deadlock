(* Debugging for CFA analysis
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open! Deadlock_top

open Trace_utils

open Cil_types

module CFA = Interpreted_automata
open CFA

(* Defines how to print elements of CFA analysis *)
module type PRINTERS = sig
  module Analysis : CFA_analysis_signatures.ANALYSIS

  type state
  type states
  type results

  val pp_state : Format.formatter -> state -> unit
  val pp_states : Format.formatter -> states -> unit
  val pp_results : Format.formatter -> results -> unit
end

module Make (Printers : PRINTERS) = struct

  open Printers
  module Debug = Analysis.Debug

  (* Register debug key *)
  let dk_cfa = Debug.register_category "CFA"
  let () = Debug.add_debug_keys dk_cfa

  let vertex_cache_hit () = Debug.debug "Vertex cache hit"
  
  let refinement_start fn states callstack = 
    Debug.debug ~level:2 ~dkey:dk_cfa "Starting refinement of %a" Printer.pp_fundec fn;
    Debug.debug ~level:3 ~dkey:dk_cfa " callstack:\n%a" Callstack.pp callstack;
    Debug.debug ~level:3 ~dkey:dk_cfa " states: \n%a" pp_states states
  
  let refinement_finished fn states status =
    let status_str = if status then "Succesfull" else "Unsuccesfull" in
    Debug.debug ~level:2 ~dkey:dk_cfa "%s refinement of %a" status_str Printer.pp_fundec fn;
    Debug.debug ~level:3 ~dkey:dk_cfa " states: \n%a" pp_states states
   
  let trav_start () = ()

  let pp_vertex fmt (v : CFA.G.V.t) = Format.fprintf fmt "%d" v.vertex_key

  let pp_edge fmt (e : CFA.G.E.t) = 
    match e with (v1, _, v2) -> 
      Format.fprintf fmt "(%d, %d)"
        (v1.vertex_key)
        (v2.vertex_key)

  let pp_bool_with_unk fmt value = match value with
    | `True -> Format.fprintf fmt "true"
    | `False -> Format.fprintf fmt "false"
    | `Unknown -> Format.fprintf fmt "unknown"

  let pp_branch_kind fmt kind = match kind with
    | Then -> Format.fprintf fmt ""
    | Else -> Format.fprintf fmt "!"

  let pp_instr fmt i = Format.fprintf fmt "%a" Printer.pp_instr i 
  
  let pp_func fmt f = Format.fprintf fmt "%a" Printer.pp_fundec f

  let debug_edge edge =
    let _, e, _ = edge in
    let label = match e.edge_transition with
      | CFA.Skip -> "Skip"
      | CFA.Return _ -> "Return"
      | CFA.Guard _ -> "Guard"
      | CFA.Prop _ -> "Prop"
      | CFA.Instr _ -> "Instr"
      | CFA.Enter _ -> "Enter"
      | CFA.Leave _ -> "Leave"
    in
    Debug.debug ~level:3 ~dkey:dk_cfa "Edge: %s %a" label pp_edge edge

  let debug_vertex v fn =
    Debug.debug ~level:3 ~dkey:dk_cfa "Vertex: %a in %a" pp_vertex v pp_func fn

  let debug_instr callstack stmt instr state =
    let label = match instr with
      | Call _ -> begin match Analysis.analyse_call callstack stmt state with
          | `Analyse_atomically -> "Atomic call"
          | `Continue -> "Call"
        end
      | Local_init _ -> begin match Analysis.analyse_call callstack stmt state with
          | `Analyse_atomically -> "Atomic local init"
          | `Continue -> "Local init"
        end
      | _ -> "Other"
    in
    Debug.debug ~level:3 ~dkey:dk_cfa  "Instr: %s %a" label pp_instr instr

  let debug_stmt stmt state states =
    Debug.debug ~level:3 ~dkey:dk_cfa  "Stmt: %a" Print_utils.pp_loc stmt;
    Debug.debug ~level:3 ~dkey:dk_cfa " %a -> %a" pp_state state pp_states states

  let debug_fn_enter kf state =
    let fn = Kernel_function.get_definition kf in 

    (*    
    let automaton = CFA.get_automaton kf in 
    let fn_name = Format.asprintf "%a.cfa" Printer.pp_fundec fn in
    if true then
      let channel = open_out_gen [Open_creat; Open_wronly] 0o777 fn_name in
      let wto = CFA.get_wto kf in
      CFA.output_to_dot ~number:`Vertex ~wto:wto channel automaton;
      close_out channel;
    else ();
    *)

    Debug.debug ~level:2 ~dkey:dk_cfa "Entering fn: %a" pp_func fn;
    Debug.debug ~level:3 ~dkey:dk_cfa " state: %a" pp_state state

  let debug_cache_hit fn states results =
    Debug.debug ~level:3 ~dkey:dk_cfa "Leaving fn using cache: %a with\nStates: %a\nResults: %a" 
      pp_func fn 
      Printers.pp_states states
      Printers.pp_results results

  let debug_fn_leave fn states results = 
    Debug.debug ~level:3 ~dkey:dk_cfa "Leaving fn: %a with\nStates: %a\nResults: %a" 
      pp_func fn 
      Printers.pp_states states
      Printers.pp_results results
  
  let debug_guard expr kind value = 
    Debug.debug ~level:3 ~dkey:dk_cfa "[%a%a] = %a" 
      pp_branch_kind kind
      Printer.pp_exp expr 
      pp_bool_with_unk value
end
