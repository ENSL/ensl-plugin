ENSL Plugin
===========

This is the source code of ENSL Plugin. It was used on European NS League for many years. Full description of all the features is here:
http://www.ensl.org/articles/426

## How to compile

Use the provided Dockerfile to install libs, amxmodx and compile it.

1. Run `docker-compose up --build` to build docker image and run it.
  * First it will copy the builed plugin and zip file to `./build`
  * It will enter bash prompt if you want to compile something manually

## Credits

Originally based on CAL Plugin, but later completely remade by jiriki. Rest of the credits below:

 + DarkSnow's socket example
 + CAL Features by CAL-ns|Austin (xHomicide) and Jim "JazzX" Olson
 + Asmodee for waypoint fixes, weaponfix and other fixes
 + Multivac's Jetpack fix
 + sawce's icons plugin
 + www.nsmod.org
 + www.amxmodx.org

Right now only legacy code is the unstuck function from CAL Plugin.