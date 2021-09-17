(* Top-level definitions *)

(* Frama-c modules *)

include Cil_datatype

(* Deadlock modules *)

include Deadlock_options

module Conc_model = Concurrency_model

(* External libraries *)

module List = CCList
