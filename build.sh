#!/bin/bash

echo "Copying files to build folder."
echo "-------------------------------"
mv -v /home/amxx/build/* /var/build

echo "Following files in the package:"
echo "-------------------------------"
cd /var/build/pkg
find . -type f
/bin/bash