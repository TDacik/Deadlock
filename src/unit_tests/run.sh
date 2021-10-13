inputs=$(frama-c -print-share-path)/deadlock/inputs

options="-kernel-verbose 0 \
         -deadlock-callstack-mode=branching \
    "

## Prepare frama-c

make uninstall
make clean

make setup
make test=true
make install


## Run tests

frama-c $options -deadlock-unit-tests="cycle_detection"         $inputs/dummy.c 
frama-c $options -deadlock-unit-tests="lockset_analysis"        $inputs/dummy.c
frama-c $options -deadlock-unit-tests="lock_types"              $inputs/dummy.c
frama-c $options -deadlock-unit-tests="trace_utils"             $inputs/dummy.c
frama-c $options -deadlock-unit-tests="abstraction_refinement"  $inputs/abstraction_refinement_test.c
frama-c $options -deadlock-unit-tests="cfg_utils"               $inputs/cfg_utils_test.c
frama-c $options -deadlock-unit-tests="cil_wrapper"             $inputs/cil_wrapper_test.c
frama-c $options -deadlock-unit-tests="exit_points"             $inputs/exit_points_test.c

## Clean

make uninstall test=true >/dev/null
make clean test=true >/dev/null

rm oUnit-*
