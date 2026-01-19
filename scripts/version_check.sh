#!/bin/bash

# Version conflict detection script

# Compare two Move module bytecode files and report differences

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <module_old.mv> <module_new.mv>"
  exit 1
fi

module_old=$1
module_new=$2

if ! command -v diff &> /dev/null
then
    echo "diff command not found"
    exit 1
fi

echo "Comparing $module_old and $module_new..."
diff $module_old $module_new

if [ $? -eq 0 ]; then
  echo "No differences found."
else
  echo "Differences detected between modules."
fi
