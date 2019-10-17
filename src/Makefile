FRAMAC_SHARE := $(shell frama-c-config -print-share-path)
FRAMAC_LIBDIR := $(shell frama-c-config -print-libpath)

PLUGIN_NAME = Deadlock
PLUGIN_CMO = deadlock_options \
	     statement_matching \
	     deadlock_utils \
	     lockset \
	     lockgraph \
	     value \
	     thread_analysis \
	     lockset_analysis_results \
	     lockset_analysis \
	     deadlock_run \

include $(FRAMAC_SHARE)/Makefile.dynamic

DEVELOPMENT=yes

