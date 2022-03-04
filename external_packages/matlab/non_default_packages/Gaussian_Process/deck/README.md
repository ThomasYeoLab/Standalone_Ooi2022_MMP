
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Documentation](https://img.shields.io/badge/Documentation-https%3A%2F%2Fjhadida.gitlab.io%2Fdeck-orange.svg)](https://jhadida.gitlab.io/deck)

> **NOTE (June 2019):**
> This toolbox has undergone a considerable refactoring; a [new documentation](https://jhadida.gitlab.io/deck) is being written, but in case of inconsistencies, please rely on the functions' helptext.

# Deck

A general-purpose Matlab (2015+) toolbox that doesn't get in your way. Deck is now an aggregate of 3 sub-projects:

 - The original `dk` toolbox, containing general tools to extend Matlab's capabilities;
 - The new `ant` toolbox, containing analysis tools mainly for time-series data;
 - The new `jmx` library, with a lightweight C++ library making it super-easy to write Mex files.

## Requirements

 - Matlab 2015+;
 - A recent version of `git` (tested with 2.0+);
 - Linux or OSX system (some users reported ok on Windows, but untested);
 - Up-to-date C++ compiler (tested with `g++` and `clang++`);
 - Mex setup (see [how to](https://uk.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html)).

## Installation 

Choose a folder where you would like to put this toolbox; a good default choice is Matlab's `userpath()` (usually `~/Documents/MATLAB`).
Whatever you choose, we refer to this location as `FOLDER` in Matlab, and `$FOLDER` in a shell.

From a terminal:
```
# wherever you chose:
FOLDER="~/Documents/MATLAB"

git clone https://gitlab.com/jhadida/deck.git "$FOLDER/deck"
pushd "$FOLDER/deck/jmx"
bash install.sh
popd
```

**_Then_** from a Matlab console:
```
% wherever you chose
FOLDER = fullfile( userpath(), 'deck' );

addpath(FOLDER);     % !! DO NOT USE genpath() !!
dk_startup;
ant.compile();       % optional, if you want to use ant+jmx
```

If this gives you an error, [let me know](mailto:jonathan.hadida@ohba.ox.ac.uk).

Finally, if you like Deck and would like to use it by default when Matlab starts, then add the following to your [startup.m](http://uk.mathworks.com/help/matlab/ref/startup.html):
```
% Add Deck toolbox to the path
addpath(fullfile( userpath, 'deck' )); % or wherever you installed it
dk_startup();
```

## Bugs & Issues

Please report new issues [here](https://gitlab.com/jhadida/deck/issues) (check the existing open+closed ones before posting please).

## Usage

### How do I call these functions?

All Deck functions can be called as if they were methods of an object `dk.<submodule>.<function>( <args> )`. For example: `dk.util.array2string( [1,2,3], 'latex' );`. Similarly for the `ant` library: `I = imread('cameraman.tif'); ant.img.show(im2double(I));`.

The functions in the `jmx` are prefixed with `jmx_`; they are mainly used to compile Mex files (see `help jmx`).

### Undefined variable "dk" or class "dk.blah".

You installed Deck previously, and it worked, but now it doesn't?
You just need to add the folder to your Matlab path again. From the Matlab console:
```
addpath(fullfile( userpath, 'deck' )); % or wherever you installed it
dk_startup();
```

### Updates

If you downloaded Deck using `git`, you will also be able to get all future versions simply by typing from a terminal:
```
cd /wherever/deck/is
git pull
```

Then from the Matlab console:
```
jmx_build(); % optional, if you want to use ant+jmx
ant.compile(); 
```

## Documentation

The documentation is being written on and off; the latest version can be found [here](https://jhadida.gitlab.io/deck).
This is by no means a comprehensive documentation, and if you find inconsistencies between helptext and documentation, please assume that **the helptext takes precedence**.

Most functions have a helpful helptext, which should be enough to get you started (the code should also be fairly legible). 
To get help about a function, type `help dk.some.function` from the Matlab console. 
If that's not helpful, and you really want to know, [open an issue](https://gitlab.com/jhadida/deck/issues) asking for documentation about that particular function.

## Contributions

This is free and open software; all contributions are welcome. 

For contributing, you'll need a [GitLab account](https://gitlab.com/users/sign_in#register-pane). Also, checkout [the docs](https://docs.gitlab.com/ee/ssh/) to link your various computers with your account using SSH keys (avoids having to type passwords).

<!-- Then, the recipe is: [fork](https://help.github.com/articles/fork-a-repo/) it, change it ([learn how](https://rogerdudler.github.io/git-guide/)), push it, [pull-request](https://help.github.com/articles/creating-a-pull-request/) it. Send me a message if you're not sure. -->
