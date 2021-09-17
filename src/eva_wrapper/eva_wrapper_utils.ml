(* Utilities for wrapper instances
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

open Cil_datatype
open Cil_types
open Locations

open Trace_utils
open Trace_utils.Callstack

module Conc_model = Concurrency_model

let zone_to_bases zone = Zone.fold_bases List.cons zone []
