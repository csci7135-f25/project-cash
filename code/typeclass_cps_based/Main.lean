import CumulativeSemantics.Tests.WhilePerf

def main (args: List String): IO Unit := do
  if args.contains "--while_perf" then
    match args.findIdx? (· == "--iterations") with
    | some idx =>
      if idx + 1 < args.length then
        match (args[idx + 1]!).toNat? with
        | some iter =>
          if args.contains "--mono" then
            let _ ← test_while_mono iter
          else
            let _ ← test_while iter
        | none => IO.println "Error: iterations argument must be a number"
      else
        IO.println "Error: --iterations requires a number argument"
    | none => IO.println "Error: --while_perf requires --iterations <number>"
  else
    IO.println s!"Unrecognized arguments: {args}"
