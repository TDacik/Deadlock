module Self = Plugin.Register
    (struct
      let name = "Deadlock"
      let shortname = "Deadlock"
      let help = ""
    end)

module Enabled = Self.False
    (struct
      let option_name = "-deadlock"
      let help = ""
    end)

module OutputSummary = Self.String
    (struct
      let option_name = "-deadlock-out-summary"
      let arg_name = "filename"
      let default = ""
      let help = "output summary of deadlock analysis"
    end)

module Do_pointer_analysis = Self.True
    (struct
      let option_name = "-pointer-analyses"
      let help = "Do pointer analysis for locks (default)"
    end)
  
module Lock_wrappers = Self.Fundec_set
  (struct
    let option_name = "-lock-wrapper"
    let arg_name = "Lock wrappers"
    let help = "Add lock wrapper"
  end)

module Unlock_wrappers = Self.Fundec_set
  (struct
    let option_name = "-unlock-wrapper"
    let arg_name = "Lock wrappers"
    let help = "Add unlock wrapper"
  end)
