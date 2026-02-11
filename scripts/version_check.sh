#!/bin/bash
set -Eeuo pipefail

# Version conflict detection script

# Compare two Move module bytecode files and report differences

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <module_old.mv> <module_new.mv>"
  exit 1
fi

module_old=$1
module_new=$2

if ! diff "$module_old" "$module_new" >/dev/null 2>&1; then
  echo "Differences detected between $module_old and $module_new"
  exit 1
fi

echo "No differences found."
