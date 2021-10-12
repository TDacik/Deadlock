"""Extract informations from Frama-C's output"""

import re

def incorrect_main_signature(output):
    m = re.search("Incompatible declaration for main", output)
    return m is not None

def recursion(output):
    m = re.search("Recursive call to", output)
    return m is not None

def detect(output):
    res = ""
    if incorrect_main_signature(output): res += "- Incorrect main signature\n\n"
    if recursion(output): res += "- Recursion\n\n"
    
    return res
