
# About Deck

I originally created this library to gather all the little things I expected Matlab to do, but could not find. 
Over the years, I kept adding such "missing utilities", but also scripts that unified the behaviour of certain Matlab functions across versions (Mathworks seem to enjoy introducing version-breaking changes..), and eventually tools for data analysis that I use in my everyday work. 

It is worth noting that most of Deck is not formally tested (i.e. no unit-testing, [contributions](contribute) welcome!). However: I have used it myself for several years; most functions do a fair bit of checking internally, so they should not fail silently; I have used it to build other toolboxes; and have occasionally shared it with others. Therefore I am reasonably confident that most functions work as intended. 

Deck is now quite a large toolbox, but it is designed to _stay out of your way_. The only "names" that actually end up on your path are:
 - the modules themselves `dk` and `ant`;
 - the startup/shutdown scripts `dk_startup, dk_shutdown`;
 - the C++ Mex library utilities `jmx` and `jmx_*`.

As long as these names are not used as variables in your scripts, and that you do not have functions named like this, you can add Deck to your path without interference with any of your stuff. (You're welcome!)

Finally, you may wonder where the name "Deck" comes from, or what it stands for. 
There isn't one specific reason, but I often like to compare work management with running a ship, and it is also difficult to ignore this:

<center><iframe width="420" height="315" src="https://www.youtube.com/embed/i6c4Nupnup0"></iframe></center>