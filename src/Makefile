FRAMAC_SHARE := $(shell frama-c-config -print-share-path)
FRAMAC_LIBDIR := $(shell frama-c-config -print-libpath)

PLUGIN_NAME = Deadlock
PLUGIN_VERSION = "1.0"

PLUGIN_REQUIRES = containers ounit2

PLUGIN_BASE_EXTRA_DIRS = concurrency_model \
					lockset_analysis \
					cfa_analysis \
					thread_analysis \
					deadlock_analysis \
					eva_wrapper \
					utils \
					deadlock_gui

UNIT_TESTS_EXTRA_DIRS = unit_tests \
						unit_tests/lockset_analysis \
						unit_tests/eva_wrapper \
						unit_tests/utils

PLUGIN_CMI = utils/monomorphic_map \
			 cfa_analysis/CFA_analysis_signatures \
	     	 eva_wrapper/eva_wrapper_sig 

UNIT_TESTS_CMO = unit_tests/cil_stubs \
                 unit_tests/deadlock_stubs \
                 unit_tests/unit_tests_top \
				 unit_tests/lockset_analysis/cycle_detection_test \
                 unit_tests/utils/trace_utils_test \
                 unit_tests/utils/CFG_utils_test \
                 unit_tests/lockset_analysis/lockset_analysis_test \
                 unit_tests/lockset_analysis/lock_types_test \
				 unit_tests/eva_wrapper/cil_wrapper_test \
				 unit_tests/test_main 

PLUGIN_BASE_CMO = deadlock_options \
			 concurrency_model/concurrency_model_data \
			 concurrency_model/load_model \
			 utils/statement_utils \
			 concurrency_model/concurrency_model \
			 deadlock_top \
			 utils/print_utils \
			 thread_analysis/thread \
			 utils/trace_utils \
			 utils/CFG_utils \
			 utils/imperative_counter \
			 lockset_analysis/lock_types \
			 deadlock_analysis/deadlock_types \
			 lockset_analysis/lockgraph \
			 eva_wrapper/eva_wrapper_utils \
			 eva_wrapper/eva_wrapper_instance \
			 eva_wrapper/cil_wrapper_instance \
			 eva_wrapper/eva_wrapper \
			 thread_analysis/thread_graph \
			 deadlock_analysis/happend_before \
			 thread_analysis/thread_analysis \
			 cfa_analysis/CFA_analysis_debug \
			 cfa_analysis/CFA_analysis \
			 cfa_analysis/CFA_analysis_utils \
			 lockset_analysis/function_summaries \
			 lockset_analysis/stmt_summaries \
			 lockset_analysis/lockset_analysis_results \
			 lockset_analysis/abstraction_refinement \
			 lockset_analysis/lockset_analysis \
			 deadlock_analysis/concurrency_check \
			 deadlock_analysis/deadlock_analysis \
			 statistics \
			 utils/json_output \
			 deadlock_main

ifeq ($(test), true)
 PLUGIN_EXTRA_DIRS = $(PLUGIN_BASE_EXTRA_DIRS) $(UNIT_TESTS_EXTRA_DIRS)
 PLUGIN_CMO = $(PLUGIN_BASE_CMO) $(UNIT_TESTS_CMO)
else
 PLUGIN_EXTRA_DIRS = $(PLUGIN_BASE_EXTRA_DIRS)
 PLUGIN_CMO = $(PLUGIN_BASE_CMO)
endif

PLUGIN_GUI_CMO = deadlock_gui/graph_views \
				 deadlock_gui/gui_utils \
				 deadlock_gui/lockset_gui

# Compilation

# IGNORED_WARNINGS = -4-40-42-48-50-67
		   #  4 Fragile pattern matching
		   # 48 Implicit elimination of optional arguments
		   # 50 Doc comments
		   # 67 Unused functor param ??
				

#PLUGIN_BFLAGS = -w +A$(IGNORED_WARNINGS) #-warn-error A-8-27
#PLUGIN_OFLAGS = -warn-error A

include $(FRAMAC_SHARE)/Makefile.dynamic

odoc:
	mkdir -p ../doc
	odoc support-files -o ../doc
	odoc compile Deadlock.mld --package Deadlock
	odoc html Deadlock.mld -o ../doc
	$(foreach file, $(wildcard ls */*.cmti), odoc compile $(file) -o ../doc --package Deadlock;)
	$(foreach file, $(wildcard ls */*.odoc), odoc html $(file) -o ../doc;)
	$(foreach file, $(wildcard ls */*.odoc), echo $(file))
	
setup:
	# Create shared directory for Deadlock
	mkdir -p $(FRAMAC_SHARE)/deadlock

	# Copy models
	cp ../models/*.json $(FRAMAC_SHARE)/deadlock

	# Copy inputs for unit tests
	cp -r unit_tests/inputs $(FRAMAC_SHARE)/deadlock
	

conf-test:
	echo $(FRAMAC_SHARE)

run:
	make
	make install

unit-tests:
	sh unit_tests/run.sh

test:
	@cd ../tests; python3.9 run_tests.py

simple-test:
	frama-c -deadlock ../tests/benchmarks/simple_deadlocks/dl_2threads.c

DEVELOPMENT=yes
