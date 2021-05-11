#!/usr/bin/env bash

#
# This script checks the ownCloud desktop client documentation manual to 
# see if any of the example files are orphaned.
#

MANUALS=( ROOT )

echo "Checking for orphaned example files."
echo "Please run this scrip from your docs root"
echo

for manual in "${MANUALS[@]}"; do
    [[ ! -e "./modules/${manual}/" ]] && echo "Cannot find ${manual} manual." && continue

    echo "Checking the ${manual} manual"
    find "./modules/${manual}/examples/" \
        \( -path "**/.DS_Store" -o -path "**/vendor" -o -path "**/.gitkeep" \) -prune -o \
        -type f \
        -exec bash -c 'grep -rnq -E "^include.*$(basename $0 | sed "s/\./\\./")" ./modules/$1/pages || echo "Detected orphan file: $0"' {} "${manual}" \;
    echo
done

echo "Check completed."
echo
echo "Please consider that files may have been added intentionally but have currently not been included in the documentation."
echo
echo "You may want to check the orphan history via:"
echo "git log --full-history -- full_path_file_from_above"
echo
