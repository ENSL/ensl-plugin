#!/bin/bash

cd /home/amxx/addons/amxmodx/scripting

./amxxpc $1
cp *.amxx /var/build

cd /home/amxx

mkdir -p /var/build/tmp /var/build/pkg

yes|unzip -f amxx.zip -d /var/build/tmp/
yes|unzip -f amxx_ns.zip -d /var/build/tmp/
tar -zxf amxx.tgz -C /var/build/tmp/
tar -zxf amxx_ns.tgz -C /var/build/tmp/

cp -ra /var/pkg/* /var/build/pkg

cd /var/build/pkg/

cp -ra ../tmp/metamod/ .
cp -ra ../tmp/addons/amxmodx/modules/* addons/amxmodx/modules/
cp -ra ../tmp/addons/amxmodx/data/* addons/amxmodx/data/
cp -ra ../tmp/addons/amxmodx/dlls/* addons/amxmodx/dlls/
cp ../ENSL.amxx addons/amxmodx/scripting/plugins/

zip -r ENSL_SrvPkg.zip *
