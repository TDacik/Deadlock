""" Class representing results of single run of Deadlock based on its json output
    
Json file is convertex explicitly in order that it stay human readeble.
"""

import json

class DeadlockResult():
    
    def __init__(self, path):
        with open(path, "r") as f:
            self._data = json.load(f)

    @property
    def __header(self): 
        return self._data["Analysis informations"]

    @property
    def __thread_analysis(self):
        return self._data["Thread analysis summary"]

    @property
    def __lockset_analysis(self):
        return self._data["Lockset analysis summary"]

    @property
    def __conc_check(self):
        return self._data["Concurrency check"]

    @property
    def __execution_times(self):
        return self._data["Execution times"]

    @property
    def __execution_info(self):
        return self._data["Execution info"]

    @property
    def lockgraph(self):
        return self._data["Lockgraph"]

    @property
    def deadlocks(self):
        return self._data["Deadlocks"]

    @property
    def name(self):
        return self.__execution_info["Name"]

    @property
    def return_code(self):
        return self.__execution_info["Return code"]

    @property
    def nb_deadlocks(self):
        return len(self.deadlocks)

    def has_deadlock(self):
        return self.nb_deadlocks > 0

    @property
    def lockgraph_size(self):
        return len(self.lockgraph)

    @property
    def lockgraph_weighted_size(self):
        return len(self.lockgraph)

    @property
    def thread_graph(self):
        return self.__thread_analysis["Thread graph"]

    @property
    def thread_graph_size(self):
        return len(self.thread_graph)

    ## Statistics

    @property
    def nb_threads(self):
        return self.__thread_analysis["Threads"]

    @property
    def nb_locking_operations(self):
        return self.__lockset_analysis["Lock operations"]

    @property
    def nb_fixpoint_iterations(self):
        return self.__thread_analysis["Fixpoint iterations"]

    @property
    def nb_analysed_functions(self):
        return self.__lockset_analysis["Analysed functions"]

    @property
    def context_sensitive_functions(self):
        return self.__lockset_analysis["Context sensitive functions"]
    
    @property
    def nb_context_sensitive_functions(self):
        return len(self.context_sensitive_functions)

    @property
    def path_sensitive_functions(self):
        return self.__lockset_analysis["Path sensitive functions"]
    
    @property
    def nb_path_sensitive_functions(self):
        return len(self.path_sensitive_functions)

    @property
    def avg_function_analyses(self):
        return self.__lockset_analysis["Avg. function analyses"]

    ## Imprecision and relevance

    @property
    def nb_imprecise_lock_operations(self):
        return self.__lockset_analysis["Imprecise lock operations"]

    @property
    def nb_imprecise_threads(self):
        return self.__thread_analysis["Imprecise threads"]
    
    @property
    def is_precise(self):
        return (self.return_code == 0
                and self.nb_imprecise_lock_operations == 0
                and self.nb_imprecise_threads == 0)

    def is_imprecise(self):
        return self.return_code == 0 and not self.is_precise()

    def has_error(self):
        return self.return_code != 0

    def has_some_locking(self, limit=0):
        """Has at least one precise lock operation"""
        return (self.nb_locking_operations - self.nb_imprecise_lock_operations) > limit

    def is_multithreaded(self):
        """Has at least two precise threads"""
        return self.nb_threads > 1

    def is_relevant(self):
        """Either timeout or analysis found some locking and multiple threads"""
        return (self.return_code == 124
                or (self.has_some_locking() and self.is_multithreaded()))

    ## Concurrency check

    @property
    def nonc_deadlocks(self):
        return self.__conc_check["Non-concurrent deadlocks"]

    @property
    def nonc_before_create(self):
        return self.__conc_check["Before create"]

    @property
    def nonc_after_join(self):
        return self.__conc_check["After join"]

    @property
    def nonc_same_instance(self):
        return self.__conc_check["Same instance"]

    @property
    def nonc_threads(self):
        return self.__conc_check["Non-concurrent threads"]

    @property
    def nonc_gatelocks(self):
        return self.__conc_check["Gatelocks"]

    ## Running times of analysis phases

    @property
    def time_total(self):
        return float(self.__execution_times["Total"])

    @property
    def time_main(self):
        return float(self.__execution_times["Main thread analysis"])

    @property
    def time_thread_analysis(self):
        return float(self.__execution_times["Thread analysis"])

    @property
    def time_lockset_analysis(self):
        return float(self.__execution_times["Lockset analysis"])

    @property
    def time_deadlock_analysis(self):
        return float(self.__execution_times["Deadlock analysis"])

    ## Following functions are properties to simlify loading to pandas DF

    @property
    def error_str(self):
        if self.return_code == 0: return "OK"
        if self.return_code == 1: return "Compilation"
        if self.return_code == 124: return "Timeout"
        if self.return_code == 125: return "ERR" # Internal error of Deadlock
        return "Other"

    @property
    def result_str(self):
        if self.return_code != 0: return self.error_str
        if self.nb_deadlocks == 0: return "OK"
        return "DL"

    @property
    def imprecision_str(self):
        if self.nb_imprecise_lock_operations > 0 and self.nb_imprecise_threads > 0: return "BOTH"
        if self.nb_imprecise_lock_operations > 0: return "LOCK"
        if self.nb_imprecise_threads > 0: return "THREAD"
        return "NONE"

    #
    def to_dict(self):
        d = {}
        for attr in dir(self):
            if "__" not in attr and attr not in ["to_dict"]:
                try:
                    d[attr] = getattr(self, attr)
                except KeyError:
                    d[attr] = None
        return d

    def to_json(self):
        return json.dumps(self._data, separators=(",", ":"), indent=2)

