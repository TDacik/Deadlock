(* Command line parameters
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

module Self = Plugin.Register
    (struct
      let name = "Deadlock"
      let shortname = "deadlock"
      let help = "Deadlock detection"
    end)
      
let version = "1.0"

(* Initialization of Deadlocks' share directory *)
let () = Kernel.Share.get_dir "deadlock" |> Self.Share.set

(* Debugging categories *)
let dkey_progress = Self.register_category "progress"
let dkey_la = Self.register_category "lockset analysis"
let dkey_ta = Self.register_category "thread analysis"
let dkey_t_init_state = Self.register_category "thread init state"
let dkey_eva_wrapper = Self.register_category "eva wrapper"
let dkey_function_summaries = Self.register_category "function summaries"
let dkey_lockset_step = Self.register_category "lockset step"
let dkey_lock_param_eval = Self.register_category "lock param eval"

let () =
  Self.add_debug_keys dkey_progress;
  Self.add_debug_keys dkey_la;
  Self.add_debug_keys dkey_ta;
  Self.add_debug_keys dkey_t_init_state;
  Self.add_debug_keys dkey_eva_wrapper;
  Self.add_debug_keys dkey_function_summaries;
  Self.add_debug_keys dkey_lockset_step;
  Self.add_debug_keys dkey_lock_param_eval

module Enabled = Self.False
    (struct
      let option_name = "-deadlock"
      let help = "Run deadlock detection"
    end)

module Json_summary_filename = Self.String
    (struct
      let option_name = "-dl-out-json"
      let arg_name = "filename"
      let default = ""
      let help = "Store summary of the analysis as json file"
    end)

module Use_EVA = Self.True
    (struct
      let option_name = "-dl-use-eva"
      let help = "Use values computed by eva to represent locks and threads. More \
                  precise for cost of scalability. Otherwise, locks are represented \
                  syntactically (basically as strings)."
    end)

(* ==== Heuristics for lockset analysis ==== *)

module Match_syntactic_pairs = Self.True
    (struct
      let option_name = "-dl-match-syntactic-pairs"
      let help = "Assumes that ..."
    end)

module Retvals = Self.False              
    (struct
      let option_name = "-dl-retvals"
      let help = "Heuristic to remove locks in branches where locking operations failled."
    end)

module Do_caching = Self.True
    (struct
      let option_name = "-dl-caching"
      let help = "Perform caching (option \"no\" is experimental)"
    end)

module Do_refinement = Self.True
    (struct
      let option_name = "-dl-refinement"
      let help = ""
    end)


(* Setting concurrency model *)
module Conc_model_param = Self.String
    (struct
      let default = "pthread"
      let arg_name = "model | path"
      let option_name = "-dl-conc-model"
      let help = "Set concurrency model. Predefined models are pthread (default), c11_threads and win32_threads."
    end)

(* Only for purposes of specific benchmark *)
let () = Parameter_customize.is_invisible ()
module Auto_find_lock_types = Self.False
    (struct
      let option_name = "-dl-auto-find-lock-types"
      let help = "Automatically find lock types in preprocessed programs using the Pthreads API"
    end)

let () = Parameter_customize.is_invisible ()
module Unit_tests = Self.String
    (struct
      let option_name = "-dl-unit-tests"
      let arg_name = "test-suite"
      let default = ""
      let help = "Run unit tests"
    end)

module Do_concurrency_check = Self.True
    (struct
      let option_name = "-dl-conc-check"
      let help = "Perform concurrency check"
    end)

module Ignore_self_deadlocks = Self.True
    (struct
      let option_name = "-dl-ignore-self-deadlocks"
      let help = "Ignore deadlocks caused by a single thread on a \
                  single lock by double locking it"
    end)
