import yaml
import json

import sys

source = sys.argv[1]
target = sys.argv[2]

if source == target:
    print("")
    exit(1)

with open(source) as f:
    data = yaml.load(f)

with open(target, "w") as f:
    f.write(json.dumps(data, indent=2))

