import os
from entry import Entry

class colors:
    red = "\033[91m"
    green = "\033[92m"
    white = "\033[m"

def print_ok(text):
    print(f"{colors.green}[OK] {text} {colors.white}")

def print_fail(text):
    print(f"{colors.red}[ERR] {text} {colors.white}")

class Test():

    def __init__(self, path, filename):
        self.path = path
        self.filename = filename

    def prepare_command(self):
        command = []
        command.append("frama-c -deadlock")
        command.append("-dl-xml __dl_test.xml")
        command.append("-eva-verbose 0")
        command.append("-dl-retvals")
        command.append("> __dl_test.out")
        command.append(self.path + "/" + self.filename)

        return " ".join(command)

    def create_error_xml(self, retcode):
        with open(self.filename + ".xml", "x") as f:
            f.write("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n")
            f.write("<summary>\n")
            f.write("  <return-code code=\"" + str(retcode) + "\"/>\n")
            f.write("</summary>\n")

    def handle_error(self, retcode):
        print_fail(self.filename + " returned exit code " + str(retcode))
        self.create_error_xml(retcode)
        os.system("cat " + filename + ".out")

    def run(self):
        command = self.prepare_command()
        res = os.system(command)

        if res != 0:
            self.handle_error(res)

        result = Result(self.filename)
        result.get_from_xml("__dl_test.xml")

        return result

class Result(Entry):

    def show(self):
        os.system("cat __dl_test.out")

    def assert_has_deadlock(self):
        if self.has_deadlock():
            print_ok(self.filename)
        else:
            print_fail(self.filename + " : no deadlock found")

    def assert_no_deadlock(self):
        if not self.has_deadlock():
            print_ok(self.filename)
        else:
            print_fail(self.filename + " : false positive")

    def assert_lockgraph_size(self, n):
        if self.lockgraph_size() == n:
            print_ok(self.filename)
        else:
            print_fail(self.filename + " : size of lockgraph doesn't match")

    def assert_lockgraph_weighted_size(self, n):
        if self.lockgraph_weighted_size() == n:
            print_ok(self.filename)
        else:
            print_fail(self.filename + " : size of lockgraph doesn't match")

    def assert_n_cs_functions(self, n):
        if len(self.cs_functions) == n:
            print_ok(self.filename)
        else:
            print_fail(self.filename + " : number of cs functions doesn't match")

    def assert_n_threads(self, n):
        if self.n_threads() == n:
            print_ok(self.filename)
        else:
            print_fail(self.filename + " : number of threads doesn't match")

simple_dl_path = os.path.abspath("benchmarks/simple_deadlocks/")
no_dl_path = os.path.abspath("benchmarks/no_deadlocks/")
cs_path = os.path.abspath("benchmarks/context_sensitivity/")
threads_path = os.path.abspath("benchmarks/threads/")
retval_path = os.path.abspath("benchmarks/retval/")
lockset_analysis_path = os.path.abspath("benchmarks/lockset_analysis/")

def check_file_not_exists(filename):
    try:
        with open(filename):
            print("Error: file " + filename + " already exists")
            exit(1)
    except FileNotFoundError:
        pass

def test(func):
    def inner():
        check_file_not_exists("__dl_test.xml")
        check_file_not_exists("__dl_test.out")
        func()
        os.system("rm __dl_test.xml")
        os.system("rm __dl_test.out")

    return inner

@test
def test_simple_dl1():
    test = Test(simple_dl_path, "dl_2threads.c")
    result = test.run()
    
    result.assert_has_deadlock()
    result.assert_lockgraph_size(2)

@test
def test_simple_dl2():
    test = Test(simple_dl_path, "dl_3threads.c")
    result = test.run()
    
    result.assert_has_deadlock()
    result.assert_lockgraph_size(3)

@test
def test_simple_dl3():
    test = Test(simple_dl_path, "dl_nested_thread.c")
    result = test.run()

    result.assert_has_deadlock()
    result.assert_lockgraph_size(2)

@test
def test_simple_dl4():
    test = Test(simple_dl_path, "dl_fn_call.c")
    result = test.run()
    
    result.assert_has_deadlock()
    result.assert_lockgraph_size(2)

@test
def test_simple_dl5():
    test = Test(simple_dl_path, "dl_lock_in_struct.c")
    result = test.run()
    
    result.assert_has_deadlock()
    result.assert_lockgraph_size(2)

@test
def test_simple_dl6():
    test = Test(simple_dl_path, "dl_lock_in_struct2.c")
    result = test.run()
    
    result.assert_has_deadlock()
    result.assert_lockgraph_size(2)

@test
def test_simple_dl7():
    test = Test(simple_dl_path, "dl_array.c")
    result = test.run()
    
    result.assert_has_deadlock()
    result.assert_lockgraph_size(2)

@test
def test_simple_dl8():
    test = Test(simple_dl_path, "dl_2deadlocks.c")
    result = test.run()
    
    result.assert_has_deadlock() #add check for the second one
    result.assert_lockgraph_size(5)

@test
def test_simple_dl9():
    test = Test(simple_dl_path, "dl_wrong_unlock.c")
    result = test.run()
    
    result.assert_has_deadlock()

@test
def test_cs1():
    test = Test(cs_path, "lock_wrapper.c")
    result = test.run()

    result.assert_no_deadlock()
    result.assert_lockgraph_size(1)
    result.assert_n_cs_functions(2)

@test
def test_cs2():
    test = Test(cs_path, "nested_lock_wrapper.c")
    result = test.run()

    result.assert_no_deadlock()
    result.assert_lockgraph_size(1)
    result.assert_n_cs_functions(5)

@test
def test_no_dl1():
    test = Test(no_dl_path, "no_dl_local_lock.c")
    result = test.run()

    result.assert_no_deadlock()

@test
def test_no_dl2():
    test = Test(no_dl_path, "no_dl_cycle_exit.c")
    result = test.run()

    result.assert_no_deadlock()

@test
def test_no_dl3():
    test = Test(no_dl_path, "no_dl_cycle_break.c")
    result = test.run()

    result.assert_no_deadlock()

@test
def test_thread1():
    test = Test(threads_path, "threads1.c")
    result = test.run()

    result.assert_n_threads(3)

@test
def test_thread2():
    test = Test(threads_path, "threads2.c")
    result = test.run()

    result.assert_n_threads(4)

@test
def test_thread3():
    test = Test(threads_path, "fixpoint_computation_join_args.c")
    result = test.run()

    result.assert_lockgraph_size(5)
    result.assert_has_deadlock()

@test
def test_thread4():
    test = Test(threads_path, "fixpoint_computation_join_globals.c")
    result = test.run()

    result.assert_lockgraph_size(5)
    result.assert_has_deadlock()

@test
def test_retval1():
    test = Test(retval_path, "no_dl_retval.c")
    result = test.run()

    result.assert_no_deadlock()

@test
def test_retval2():
    test = Test(retval_path, "no_dl_retval_no_var.c")
    result = test.run()

    result.assert_no_deadlock()

@test
def test_retval3():
    test = Test(retval_path, "no_dl_retval_gotos.c")
    result = test.run()

    result.assert_no_deadlock()

@test
def test_retval4():
    test = Test(retval_path, "dl_retval.c")
    result = test.run()

    result.assert_has_deadlock()

@test
def test_retval5():
    test = Test(retval_path, "dl_retval_bottom.c")
    result = test.run()

    result.assert_has_deadlock()

@test
def test_lockset_analysis1():
    test = Test(lockset_analysis_path, "multiple_edges.c")
    result = test.run()

    result.assert_lockgraph_weighted_size(6)

def run_simple_dl_tests():
    print("Simple deadlocks:")
    test_simple_dl1()
    test_simple_dl2()
    test_simple_dl3()
    test_simple_dl4()
    test_simple_dl5()
    test_simple_dl6()
    test_simple_dl7()
    test_simple_dl8()
    test_simple_dl9()

def run_cs_tests():
    print("Context sensitivity:")
    test_cs1()
    test_cs2()

def run_thread_tests():
    print("Thread computation:")
    test_thread1()
    test_thread2()
    test_thread3()
    test_thread4()

def run_no_dl_tests():
    print("No deadlocks:")
    test_no_dl1()
    test_no_dl2()
    test_no_dl3()

def run_retval_heuristic():
    print("Retval heuristic:")
    test_retval1()
    test_retval2()
    test_retval3()
    test_retval4()
    test_retval5()

def run_lockset_analysis():
    print("Lockset analysis:")
    #test_lockset_analysis1()

run_simple_dl_tests()
run_lockset_analysis()
run_cs_tests()
run_thread_tests()
run_no_dl_tests()
run_retval_heuristic()
