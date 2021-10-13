import os
import sys
import shutil

from collections import defaultdict

from test_case import TestCase, NoSpecification

sys.path.append("../../")
from utils import *
from utils import print_ok, print_err

# Test suites
base_path = "benchmarks"

test_suites = {
  "simple_deadlocks"    : "Simple deadlocks",
  "no_deadlocks"        : "No deadlocks",
  "threads"             : "Thread analysis",
  "lockset_analysis"    : "Lockset analysis",
  "context_sensitivity" : "Context sensitivity",
  "path_sensitivity"    : "Path sensitivity",
  "retval"              : "Retval. heuristic",
  "cfa_analysis"        : "CFA analysis",
  "misc"                : "Miscellaneous",
  "regression"          : "Regression",
}

result_dir = "results"

## Results
results_eva = defaultdict(lambda: 0, {})
results_cil = defaultdict(lambda: 0, {})

def init():
    shutil.rmtree(result_dir, ignore_errors=True)
    os.mkdir(result_dir)

def run_test(path, using_eva):
  try:
      test = TestCase(path)
      
      test.setup(using_eva)
      test.exercise()
      test.verify()

      if not test.has_passed or True:
          suffix = "-EVA" if using_eva else "-CIL"
          dirname = os.path.join(result_dir, test.name) + suffix
          os.mkdir(dirname)
          test.store_all_data(dirname)
    
      if using_eva: 
          results_eva[test.status] += 1
      else: 
          results_cil[test.status] +=1
      
      test.print_result(using_eva)

  except NoSpecification:
      print_err(f"Test case {test.name} missing specification")

def parse_args():
    if len(sys.argv) == 1:
        return test_suites
    elif len(sys.argv) == 2:
        name = test_suites[sys.argv[1]]
        return {sys.argv[1] : name}
        
    else:
        print("Invalid number of arguments")
        exit(1)

if __name__ == "__main__":
    init()

    test_suites = parse_args()

    for dirname, name in test_suites.items():
        dirpath = os.path.join(base_path, dirname)
        dirpath = os.path.abspath(dirpath)
        print(name)

        for f in sorted(os.listdir(dirpath)):
            if f.endswith(".c"):
                path = os.path.join(dirpath, f)
                run_test(path, using_eva=True)
                run_test(path, using_eva=False)

    print("=====================================")
    print("Using EVA")
    print_ok("  OK: " + str(results_eva["ok"]))
    print_err("  ERR: " + str(results_eva["err"]))
    print_todo_works("  TODO_OK: " + str(results_eva["todo_ok"]))
    print_todo("  TODO_ERR: " + str(results_eva["todo_err"]))
    print("")
    print("Without EVA")
    print_ok("  OK: " + str(results_cil["ok"]))
    print_err("  ERR: " + str(results_cil["err"]))
    print_todo_works("  TODO_OK: " + str(results_cil["todo_ok"]))
    print_todo("  TODO_ERR: " + str(results_cil["todo_err"]))

    if results_eva["err"] > 0 or results_cil["err"] > 0:
        exit(1)
    
    exit(0)
