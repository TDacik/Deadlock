"""
Abstract class for building scripts for running Frama-c's plugins.

Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
"""

import os
import re
import sys
import time
import json
import shutil
import tempfile
import subprocess

from abc import abstractmethod
from utils import pretty_command
from framac_utils import generate_main_stub
from framac_output_parser import detect

class FramacRunner():

    def __init__(self, plugin, shortname, paths, timeout, options, output_path=None, name=None):
        self.plugin = plugin
        self.shortname = shortname
        self.name = name if name is not None else paths[0]
        self.output_dir = output_path

        self.paths = [os.path.abspath(p) for p in paths]
        
        # Source codes that could be included to paths. The files are stored in
        # a dictionary source_name -> code
        self.stubs = {}

        self.timeout = timeout
        self.options = options if options is not None else {}
    
        # Fields initialised after running Frama-C
        self.return_code : int = None
        self.stdout : str = None
        self.stderr : str = None
        self.result = None
        
        self.warnings = None

        self.has_tmp_dir = False
        self.tmp = None
        self.init_directory()

    def init_directory(self):
        if self.output_dir is None:
            tmp_dir = tempfile.TemporaryDirectory()
            self.output_dir = tmp_dir.name
            self.tmp = tmp_dir
            self.has_tmp_dir = True

        os.mkdir(os.path.join(self.output_dir, "stubs"))

    def __del__(self):
        if self.has_tmp_dir:
            self.tmp.cleanup()

    @abstractmethod
    def set_heuristics(self):
        pass

    @abstractmethod
    def get_result(self, json):
        pass

    @abstractmethod
    def is_result_ok(self):
        pass

    @abstractmethod
    def postprocess_fail(self):
        pass

    @abstractmethod
    def postprocess_succ(self):
        pass

    @abstractmethod
    def get_shared_dir(self):
        pass

    def dict_item_to_option(self, key, value):
        option = "-" + key

        def option_to_false(option):
            """ Convert option -<plugin>-option to -<plugin>-no-option """
            elems = option.split("-")
            elems = [elems[1], "no"] + elems[2:]
            return "-" + "-".join(elems)

        if value is None:
            assert False
        elif value is True:
            return [option]
        elif value is False:
            return [option_to_false(option)]
        else:
            return [option, str(value)]
    
    def set_option(self, option, value):
        self.options[option] = value

    def set_quiet(self):
        self.set_option("eva-verbose", 0)
        self.set_option("kernel-verbose", 0)
        self.set_option("variadic-verbose", 0)

    def add_main_stub(self, n_args=5, arg_length=256):
        """Generate a stub for main function"""
        code = generate_main_stub(n_args, arg_length)

        path = os.path.join(self.output_dir, "stubs", "main_stub.c")
        with open(path, "w+") as f:
            f.write(code)

        # Set eva main as main function
        self.set_option("main", "eva_main")
        self.stubs["main_stub.c"] = code
        self.paths.append(path)

    def set_eva_heuristics(self, all_addresses_valid=True):
        options = {
            "kernel-warn-key" : "*=inactive",
            "eva-warn-key" : "*=inactive",
            "eva-initialized-locals" : True,
            "eva-context-valid-pointers" : True,
            "c11" : True,
            "machdep" : "x86_64",
	    "absolute-valid-range" : "0-1000",
        }
        self.options = {**options, **self.options}

    def set_permissive_level(self, level):
        if level == 1: self.set_permissive(context_width=1)
        if level == 2: self.set_permissive(all_addresses_valid=True)
        if level == 3: self.set_permissive(all_addresses_valid=True, context_widht=4)
        if level == 4: self.set_permissive(all_addresses_valid=True, context_width=1)

    def prepare_command(self, json_out):
        """Prepare command to be run

        Convert dictionary of options

        return: command as string
        """

        command = ["frama-c", "-" + self.plugin] + self.paths

        for key, value in self.options.items():
            command += self.dict_item_to_option(key, value)

        command += [f"-{self.shortname}-out-json", str(json_out)]
        
        return command

    def pretty_command(self, json_out, shebang, gui):
        shebang = "#!/bin/bash\n" if shebang else ""
        rm_json = f"rm {json_out} \n"
        return shebang + rm_json + pretty_command(self.prepare_command(json_out), gui)

    def store(self, dirname, filename, content):
        path = os.path.join(dirname, filename)
        with open(path, "w") as f:
            f.write(content)

    def store_all_data(self, dirname):
        self.store(dirname, "out", self.stdout)
        self.store(dirname, "err", self.stderr)
        self.store(dirname, "result.json", self.result.to_json())
        self.store(dirname, "warnings.txt", self.warnings)

        # Create a shell script, that can reproduce results
        json_path = os.path.abspath(os.path.join(dirname, "result.json"))
        command_cmd = self.pretty_command(json_path, shebang=True, gui=False)
        command_gui = self.pretty_command(json_path, shebang=True, gui=True)
        self.store(dirname, "run.sh", command_cmd)
        self.store(dirname, "run-gui.sh", command_gui)

        # Generate stubs
        stubs_path = os.path.join(dirname, "stubs")
        os.mkdir(stubs_path)
        for path, code in self.stubs.items():
            self.store(stubs_path, path, code)

        # Copy source files
        for path in self.paths:
            basename = os.path.basename(path)
            dst = os.path.abspath(os.path.join(dirname, basename))
            shutil.copy(path, dst)


    def run(self, json_out=None, multiple_tries=False, level=1):

        if json_out is None:
            with tempfile.NamedTemporaryFile() as tmpfile:
                self.run_(tmpfile.name)
        else:
            self.run_(json_out)

        if (multiple_tries 
            and self.return_code == 0
            and not self.is_result_ok(self.result, level)):
            #uns_run_dir = os.path.join(os.path.dirname(self.out), "unsuccessful_runs")
            #os.mkdir(uns_run_dir)
            #os.remove(self.out)
            #os.replace(self.err, os.path.join(uns_run_dir, os.path.basename(self.err)))
            #os.replace(self.json_path, os.path.join(uns_run_dir, os.path.basename(self.json_path)))
            print(f"  -> Attemp {level+1}")
            self.run(json_out, multiple_tries=True, level=level+1)

    def run_(self, json_out):
        command = self.prepare_command(json_out)

        try:
            process = subprocess.run(command,
                capture_output=True,
                timeout=self.timeout
            )

            self.stdout = process.stdout.decode().strip()
            self.stderr = process.stderr.decode().strip()
            self.return_code = process.returncode
        
        except subprocess.TimeoutExpired as to:
            self.stdout = to.stdout.decode().strip()
            self.stderr = to.stderr.decode().strip() if to.stderr is not None else ""
            self.return_code = 124 # Same as timeout utility

        data = {}

        # Load json output only if plugin finished correctly
        if self.return_code == 0:
            with open(json_out, "r") as f:
                data = json.load(f)

        if self.return_code == 0:
            plugin_data = self.postprocess_succ()
        else:
            plugin_data = self.postprocess_fail()

        data.update(plugin_data)

        with open(json_out, "w") as f:
            json.dump(data, f, indent=2)

        # Use heuristics to find warnings
        self.warnings = detect(self.stdout)

        # Load json file as DeadlockResult object
        data = {}
        if self.return_code == 0:
            with open(json_out, "r") as f:
                data = json.load(f)

        self.result = self.get_result(json_out)
