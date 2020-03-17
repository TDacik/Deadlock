import os

import xml.etree.ElementTree as ET
import networkx as nx

class Entry():

    def __init__(self, filename):
        self.filename = filename
        self.lockgraph_labels = {}
        self.threadgraph = nx.DiGraph()
        self.lockgraph = []
        self.threads = []
        self.deadlock = []
        self.cs_functions = []

        self.return_code = 0
        self.time = 0
        self.imprecise_threads = 0
        self.imprecise_locks = 0
        self.locking_operations = 0
        self.graph_iterations = 0

    def has_deadlock(self):
        return self.deadlock != []

    def lockgraph_size(self):
        return len(self.lockgraph)

    def lockgraph_weighted_size(self):
        size = 0
        for e in self.lockgraph:
            size += int(self.lockgraph_labels[e])

        return size

    def n_threads(self):
        if len(self.threads) > 0:
            return len(self.threads)
        else: 
            return 1

    def has_cs_functions(self):
        return self.cs_functions != []

    def has_thread_graph_cycle(self):
        try:
            nx.find_cycle(self.threadgraph)
            return True
        except nx.NetworkXNoCycle:
            return False

    def result_to_string(self):
        if self.has_deadlock():
            return " DL"
        elif self.return_code != 0:
            return "ERR"
        else:
            return " OK"

    def classify_error(self, errcode):
        if os.WIFEXITED(errcode):
            errcode = os.WEXITSTATUS(errcode)

        if errcode == 1:
            return "eva"
        if errcode == 124:
            return "timeout"
        elif errcode == 256:
            return "compile error"
        else:
            return "other"

    def get_from_xml(self, xml_file, times=None):

        if times is None:
            self.time = 0

        else:
            self.time = times[self.filename]

        try: 
            tree = ET.parse(xml_file)
        except ET.ParseError:
            print("Error while reading " + xml_file)
            exit(1)
            
        root = tree.getroot()

        for child in root:

            if child.tag == "return-code":
                self.return_code = int(child.attrib["code"])
            
            if child.tag == "value-analysis":
                for elem in child:
                    if elem.tag == "graph-iterations":
                        self.graph_iterations = int(elem.attrib["count"])
                    if elem.tag == "imprecise-threads":
                        self.imprecise_threads = int(elem.attrib["count"])
                    if elem.tag == "imprecise-locks":
                        self.imprecise_locks = int(elem.attrib["count"])

            if child.tag == "lockset-analysis":
                for elem in child: # FIX: there is only one child
                    if elem.tag == "lock-operations":
                        self.n_locking_operations = int(elem.attrib["count"])

            if child.tag == "cs-functions":
                for elem in child:
                    self.cs_functions.append(elem.attrib["name"])

            if child.tag == "threads":
                for thread in child:
                    function = thread.attrib["function"]
                    self.threads.append(function)

            if child.tag == "thread-graph":
                for edge in child:
                    parent_thread = edge.attrib["parent"]
                    child_thread = edge.attrib["child"]
                    self.threadgraph.add_edge(parent_thread, child_thread)

            if child.tag == "lockgraph":
                for edge in child:
                    lock1 = edge.attrib["lock1"]
                    lock2 = edge.attrib["lock2"]
                    count = edge.attrib["count"]
                    self.lockgraph.append((lock1,lock2))
                    self.lockgraph_labels[(lock1,lock2)] = count

            if child.tag == "deadlock":
                for subchild in child:
                    if subchild.tag == "dependency":
                        lock1 = subchild.attrib["lock1"]
                        lock2 = subchild.attrib["lock2"]
                        self.deadlock.append((lock1,lock2))
