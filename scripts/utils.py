class colors:
    red = "\033[91m"
    green = "\033[92m"
    yellow = "\033[93m"
    blue = "\033[94m"
    white = "\033[m"

def print_ok(text):
    print(f"{colors.green}{text}{colors.white}")

def print_err(text):
    print(f"{colors.red}{text}{colors.white}")

def print_todo(text):
    print(f"{colors.yellow}{text}{colors.white}")

def print_todo_works(text):
    print(f"{colors.blue}{text}{colors.white}")
    
def get_loc_dict():
    locs = {}
    with open("resources/locs.csv", "r") as f:
        for line in f:
            cols = line.split(",")
            locs[cols[0] + ".c"] = int(cols[1])

def pretty_command(command, gui, plugins=["-deadlock", "-racer"]):
    """
    Assumes command in form <prefix> frama-c -<plugin> [option [value]]*
    that is printed as:
        <prefix> frama-c -<plugin>
            option1 value
            option2
            ...
    """

    result = command[0] if not gui else command[0] + "-gui"
    prefix = True

    for elem in command[1:]:
        if prefix:
            result += " " + elem
            if elem in plugins:
                prefix = False

        elif elem.startswith("-"):
            result += " \\\n\t" + elem
        else:
            result += " " + elem

    return result
