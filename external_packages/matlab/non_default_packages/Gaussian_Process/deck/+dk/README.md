
# The Deck toolbox

All the sources within this folder are part of the Deck toolbox. 
There is some Python too, which needs to be installed, but that's only if you want to automate running parallel jobs on the Jalapeno cluster.
You can read more about this in the folder `+mapred`.

You can call almost any file within this toolbox, as you would call any module in Matlab. 
For example, to call `+dk/+struct/fields` you should type `dk.struct.fields` in the Matlab console (assuming that the folder _containing_ `+dk` is on your path). 
Please **do not** add the folder `+dk` itself to the path!

There is documentation at several levels. 
If you are just browsing, or you don't know what you are looking for, but that the name of a folder looks relevant, there is probably a `README.md` that will tell you about what it contains.
These are usually kept short, and will give you all the high-level information you need.

The best way to get a quick tour is to navigate the folders directly on Gitlab or Github, and read along. 
If you want to know more about a particular function, then you can read the helptext, or type `help dk.folder.function` from the Matlab console.

## Topics and corresponding tools

Serious stuff:

 - Maths: `dk.math`
 - Time-series: `dk.ts`
 - Metrics: `dk.msr`
 - Rotation matrices: `dk.rot`

Matlab enhancements:

 - Tools for matrices: `dk.mtx`
 - Tools for structures: `dk.struct`
 - Tools for strings: `dk.str`
 - Tools for Mex files: `dk.mex` and `dk.obj.Compiler`

UI tools (either plotting/drawing, or manipulating figures):

 - Drawing things: `dk.ui`
 - Making pretty colors: `dk.clr`
 - Fancy colormaps: `dk.cmap`
 - Dealing with figures: `dk.fig`
 - Components for user interfaces: `dk.widget`

Matlab shorthands or aliases:

 - Instead of `bsxfun( @times ... )`, use `dk.bsx.mul`
 - Instead of `isstruct() && isscalar() && all(isfield())`, use `dk.is.struct`
 - Instead of `cellfun( @foo, data, 'UniformOutput', false )`, use `dk.mapfun( @foo, data, false )`

Lower-level stuff:

 - Interaction with the file-system: `dk.fs`
 - Environment variables and paths: `dk.env`
 - Information about your display(s): `dk.screen`

Data-structures:

 - Node and tree: `dk.obj.Node` and `dk.obj.Tree`
 - Sample of points: `dk.obj.Sample`
 - Nearest-neighbour search: `dk.obj.GeoData_NNS.m`
 - Python-like list: `dk.obj.List`
 - Data store: `dk.obj.Datastore`

Useful tools:

 - JSON read/write: `dk.json`
 - Arguments parser: `dk.obj.kwArgs`
 - Timer and date utils: `dk.time`

Various utilities (link to separate readme).

