"""Instance of FramacRunner for Deadlock plugin
"""

import os
import re
import sys
import subprocess

from run_framac import FramacRunner
from deadlock_result import DeadlockResult

class DeadlockRunner(FramacRunner):

    def __init__(self, paths, timeout=None, options=None):
        super().__init__("deadlock", "deadlock", paths, timeout, options)

    def get_shared_dir(self):
        process = subprocess.run(["frama-c-config", "-print-share-path"], capture_output=True)
        framac_shared_dir = process.stdout.decode().strip()
        return os.path.join(framac_shared_dir, "deadlock")

    def get_result(self, path):
        return DeadlockResult(path)

    def is_result_ok(self, result, level):
        """Is result acceptable for given level of precision"""
        if result.error_str == "Compilation": return True
        if level <= 3: return result.is_precise() and result.is_relevant()
        if level <= 4: return not result.has_error() and result.n_locking_operations > 0
        else: return True

    def postprocess(self):
        data = self.resources()
        data["Name"] = self.name
        
        json = {}
        json["Execution info"] = data
        return json

    def postprocess_succ(self):
        return self.postprocess()

    def postprocess_fail(self):
        return self.postprocess()

    def set_heuristics(self):
        options = {
            "deadlock-retvals" : True,
            "deadlock-auto-find-lock-types" : True,
            "deadlock-match-pairs" : True,
            "deadlock-conc-check" : False
        }
        self.options = {**self.options, **options}
 
    def resources(self):
        time_re = re.compile(".*User time.*")
        memory_re = re.compile(".*Maximum resident set size.*")
        
        time = memory = -1

        lines = self.stderr.splitlines()
        for line in reversed(lines):
            if time_re.match(line):
                time = line.split(" ")[3].replace("\n", "")
                break
            elif memory_re.match(line):
                memory = line.split(" ")[5].replace("\n", "")
        
        data = {
            "Paths" : self.paths,
            "Memory" : memory,
            "Total time" : time,
            "Return code" : self.return_code,
        }
        
        return data

if __name__ == "__main__":
    runner = DeadlockRunner(120)
    runner.run(sys.argv[1:])
