import os
import re
import sys
import yaml

from collections import defaultdict

sys.path.append("..")
sys.path.append("../scripts")
from utils import *
from deadlock_result import DeadlockResult
from run_deadlock import DeadlockRunner

PROP_LINE_REGEX = r'\s*//#\s(.*)'

class NoSpecification(Exception):
    pass

class TestCase(DeadlockRunner):
    """ TestCase extends DeadlockRunner by loading and verifying yaml specificication """

    def __init__(self, path):
        super().__init__([path], timeout=60)

        self.name = os.path.basename(path)
        self.path = path

        self.spec_string = ""
        self.spec = None

        self.has_passed = True
        self.err_string = ""

    def prepare_command(self, json_out):
        
        # Load options from specification
        options = self.spec["Options"]
        if options is not None:
            for option in options:
                assert len(option) == 1
                for key, value in option.items():
                    self.set_option(key, value)

        return super().prepare_command(json_out)

    def setup(self, using_eva):
        self.set_option("dl-use-eva", using_eva)
        
        with open(self.path) as f:
            lines = []
            for line in f.readlines():
                match = re.match(PROP_LINE_REGEX, line)
                if match is not None:
                    lines.append(match[1])

        if not lines:
            print_err(f"Test case {self.name} missing specification")
            raise NoSpecification

        spec = "\n".join(lines)
        self.spec_string = spec
        self.spec = yaml.load(spec)
        
        # Conversion to defaultdict to avoid KeyErrors
        self.spec = defaultdict(lambda: None, self.spec)

    def is_todo(self):
        return self.spec["Todo"]

    def is_with_eva_only(self):
        return self.spec["With-eva-only"] and (not self.options["dl-use-eva"])

    def exercise(self):
        self.run()

    @property
    def status(self):
        if self.is_todo() or self.is_with_eva_only():
            if self.has_passed:
                return "todo_ok"
            else:
                return "todo_err"
        elif self.has_passed:
            return "ok"
        else:
            return "err"

    def print_result(self, using_eva=None):
        mode = "" if using_eva is None else " EVA" if using_eva else " CIL"
        if self.is_todo() or self.is_with_eva_only():
            if self.has_passed:
                print_todo_works(f"[OK{mode}] {self.name}")
            else:
                print_todo(f"[ERR{mode}] {self.name}")

        else:
            if self.has_passed:
                print_ok(f"[OK{mode}] {self.name}")
            else:
                print_err(f"[ERR{mode}] {self.name} {self.err_string}")

    def verify(self):
        self.assert_passed()

        if not self.has_passed:
            return

        self.verify_deadlocks()
        self.verify_lockgraph(self.spec["Lockgraph"])
        self.verify_thread_graph(self.spec["Thread-graph"])

        self.verify_functions()

    def verify_deadlocks(self):
        """ 
        If field "Deadlocks" is missing in specification, implicitly assume
        that there is no deadlock.
        """
        deadlock = self.spec["Deadlock"]
        # Either None or False
        if not deadlock:
            self.assert_no_deadlock()
        else:
            self.assert_deadlock()

        nb_deadlocks = self.spec["Nb-deadlocks"]
        if nb_deadlocks is not None:
            self.assert_nb_deadlocks(nb_deadlocks)

    def parse_json_graph(self, graph : [[str]]):
        edges = []
        for edge in graph:
            u = edge[0]
            v = edge[1]
            edges.append((u, v))
        return set(edges)

    def parse_yaml_graph(self, graph : [str]):
        edges = []
        for edge in graph:
            [u, v] = edge.split("->")
            u = u.strip()
            v = v.strip()
            edges.append((u, v))
        return set(edges)
    
    def verify_lockgraph(self, lockgraph):
        if lockgraph is None:
            return

        expected = self.parse_yaml_graph(lockgraph)
        actual = self.parse_json_graph(self.result.lockgraph)
        self.verify_graph(expected, actual, "Lockgraph")

    def verify_thread_graph(self, thread_graph):
        if thread_graph is None:
            return

        expected = self.parse_yaml_graph(thread_graph)
        actual = self.parse_json_graph(self.result.thread_graph)
        self.verify_graph(expected, actual, "Thread graph")

    def verify_graph(self, expected, actual, name):
        #diff = expected.symmetric_difference(actual)
        #diff = [f"        {u} -> {v}" for (u,v) in diff]
        #diff = "\n".join(diff)
        #msg = f"{name}s differs: \n{diff}"

        msg = f"{name} size does not match."
        self.assert_(len(actual) == len(expected), msg)
    
    def verify_functions(self):
        cs = self.spec["Context-sensitive-functions"]
        if cs is not None:
            self.verify_function_list(
                    len(cs), 
                    self.result.nb_context_sensitive_functions,
                    "context sensitive"
            )
        
        ps = self.spec["Path-sensitive-functions"]
        if ps is not None:
            self.verify_function_list(
                len(ps), 
                self.result.nb_path_sensitive_functions,
                "path sensitive"
            )

    def verify_function_list(self, expected, actual, name):
        msg = f"""Number of {name} functions does not match. Got {actual}
                  expected {expected}."""
        self.assert_(actual == expected, msg)
        
    def assert_(self, cond, err_string):
        if not cond:
            self.has_passed = False
            self.err_string += ("\n    - " + err_string)
            
    def assert_passed(self): 
        self.assert_(self.return_code == 0, 
                     f"Analysis failled with return code {self.return_code}")

    def assert_deadlock(self):
        self.assert_(self.result.has_deadlock(), "No deadlock found")

    def assert_no_deadlock(self):
        self.assert_(not self.result.has_deadlock(), "False positive")

    def assert_nb_deadlocks(self, expected):
        actual = len(self.result.deadlocks)
        msg = f"""Number of deadlocks does not much. 
                  Expected {expected}, got {actual}."""
        self.assert_(expected == actual, msg)

    def assert_lockgraph_size(self, n):
        self.assert_(self.result.lockgraph_size == n,
                     "Lockgraph size doesn´t match")

    def assert_n_threads(self):
        self.assert_(self.thread_graph_size == n, "")

