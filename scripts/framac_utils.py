import sys

def generate_argv(n, length):
    acc = ""
    for i in range(n):
        acc += f"    char argv{i}[{length}];\n" 

    acc += f"    char *argv[{n+1}] = {{"
    for i in range(n):
        acc += f"argv{i}, "

    acc += "0};\n"

    return acc

def generate_main_stub(n_args, arg_length):
    """
    Generate stub for a main function with up to *n_args* arguments each up
    to *arg_length* long.

    Based on https://git.frama-c.com/pub/frama-c/-/blob/master/share/analysis-scripts/fc_stubs.c
    """
    return f"""#ifdef __FRAMAC__
# include \"__fc_builtin.h\"
int main(int, char **);
static volatile int nondet;
int eva_main() {{
    int argc = Frama_C_interval(0, {n_args});
{generate_argv(n_args, arg_length)}
    //@ loop unroll {n_args};
    for (int i = 0; i < {n_args}; i++) {{
        Frama_C_make_unknown(argv[i], {arg_length - 1});
        argv[i][{arg_length-1}] = 0;
    }}
    return main(argc, argv);
}}
#endif // __FRAMAC__
"""

if __name__ == "__main__":
    n_args = int(sys.argv[1])
    arg_length = int(sys.argv[2])
    print(generate_main_stub(n_args, arg_length))
