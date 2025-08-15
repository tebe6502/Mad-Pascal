#!/bin/bash
#iterate on subfolders and check for rebuild.sh file - if exits run it

echo "Building all assets"
for d in */ ; do
    if [ -f "$d/rebuild.sh" ]; then
        echo "Running rebuild.sh in $d"
        cd $d
        ./rebuild.sh
        cd ..
    fi
done


