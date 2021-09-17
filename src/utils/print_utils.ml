(* Utilities for pretty-printing.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open Cil_datatype
open Filepath

let get_time () = Format.asprintf "(%.2f)" (Sys.time ())

(* True if base represents variable from original source code *)
let is_orig base =
  try
    let varinfo = Base.to_varinfo base in
    not (Cil.hasAttribute "fc_stdlib" varinfo.vattr
         || Cil.hasAttribute "fc_stdlib_generated" varinfo.vattr)
  with Base.Not_a_C_variable -> false

(* Based on print_initial_cvalue_state from /value/engine/initialization.ml *)
let pp_globals fmt state =
  let filtered = Cvalue.Model.filter_base is_orig state in
  Cvalue.Model.pretty fmt filtered

let stmt_line stmt =
  let loc = Stmt.loc stmt in
  (fst loc).pos_lnum

(* Print statement as a location in the source code *)
let pp_loc fmt stmt =
  let loc = Stmt.loc stmt in
  Format.fprintf fmt "%a" Printer.pp_location loc
