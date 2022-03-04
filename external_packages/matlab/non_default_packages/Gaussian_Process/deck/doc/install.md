
# Installation

## Requirements

 - Matlab R2015+;
 - a recent version of `git` (tested with 2.0+);
 - preferrably a Linux or OSX system, athough most of it should work on Windows;
 - up-to-date C++ compiler (tested with `g++` and `clang++`);
 - mex setup (see [how to](https://uk.mathworks.com/help/matlab/matlab_external/changing-default-compiler.html)).

## Quick install 

Choose a folder where you would like to put this toolbox; a good default choice is Matlab's `userpath()` (usually `~/Documents/MATLAB`).
Whatever you choose, we refer to this location as `FOLDER` in Matlab, and `$FOLDER` in a shell.

From a terminal:
```bash
# wherever you chose:
FOLDER="~/Documents/MATLAB"

git clone https://gitlab.com/jhadida/deck.git "$FOLDER/deck"
pushd "$FOLDER/deck/jmx"
bash install.sh
popd
```

Then from a Matlab console:
```matlab
% wherever you chose
FOLDER = fullfile( userpath(), 'deck' );

addpath(FOLDER);     % !! DO NOT USE genpath() !!
dk_startup;
ant.compile();       % optional, if you want to use ant+jmx
```

If you are having issues with Mex/compilation, see the section below. 

Finally, if you like Deck and would like to use it by default when Matlab starts, then add the following to your [startup.m](http://uk.mathworks.com/help/matlab/ref/startup.html):
```matlab
% Add Deck toolbox to the path
addpath(fullfile( userpath(), 'deck' )); % or wherever you installed it
dk_startup();
```

## Mex issues

Check the sections below for help. If after trying all this you are still having issues getting the toolbox to compile, [let me know](mailto:jhadida87@gmail.com).

### On OSX

First, make sure you have installed the command-line tools:
```bash
# from terminal
xcode-select --install
sudo xcodebuild -license
```

Then, make sure you have setup a compiler properly in Matlab:
```matlab
% from Matlab console
mex -setup c++
```

If that gives you errors, it might be because of a version mismatch between Xcode and your Matlab version. There is a way to solve this, but it essentially boils down to hacking Matlab:

**Step 1**

Matlab should be located somewhere in your `/Applications` folder, typically `/Applications/MATLAB_R2017a.app`. 
Edit the file `bin/mexopts.sh` (might require sudo), and change the following:

 - `MACOSX_DEPLOYMENT_TARGET`: that should correspond to your system version, which you can find by clicking the apple at the top your screen and select "About This Mac". For example, mine changed from `10.7` to `10.14` (ignore the last digits of the version).
 - `xcrun -sdk macosx10.8 clang++`: to check which SDK is actually installed on your machine, run the command `xcrun --sdk macosx --show-sdk-version`. Whatever number you find should replace the version used in the `xcrun` commands.

Save the changes, and then try running `mex -setup c++` again. If this works, try compiling the toolbox again with `ant.compile();`. If that fails, see step 2.

**Step 2**

Even if Mex is setup correctly, you can still run into issues when you actually try to use it. This could be because your compiler configuration is outdated, here is how to fix this:

 - Type `prefdir` in Matlab, and go to that folder in a terminal.
 - Edit the file `mex_C++_maci64.xml`
 - Change the `MACOSX_DEPLOYMENT_TARGET` again if the version number doesn't correspond to your system
 - You should also see a list of SDK versions, which might not include the version installed on your machine (e.g. 10.9, 10.10 and 10.11, but not 10.12). Select the entire line with the latest version, and copy-paste it JUST BEFORE that line.

Save the changes, and then try compiling again. This should work now :)

> FYI, the relevant commands to get the path and version of your Xcode SDK on OSX are:
> ```
> xcrun --sdk macosx --show-sdk-path
> xcrun --sdk macosx --show-sdk-version
> ```

### On Linux

First, make sure you have setup a compiler properly in Matlab:
```matlab
% from Matlab console
mex -setup c++
```

If that fails, I cannot help you unfortunately, but you might be able to fix your Mex installation following similar steps to the OSX case in the previous section.

If that works, then try compiling the library with `ant.compile();`. If you still get errors, please [let me know](mailto:jhadida87@gmail.com).

If everything compiles fine, but you have runtime issues about "_GLIBCXX symbols not found_" or something similar, it means that there is a mismatch between the compiler version that Matlab expects, and the one installed on your computer. This can usually be solved by creating a new executable for Matlab:
```bash
#!/bin/bash

GNU_LIB=/usr/lib/x86_64-linux-gnu
#
# Check library symbols with:
#   strings "$GNU_LIB/libstdc++.so.6" | grep LIBCXX
#

LD_PRELOAD="$GNU_LIB/libstdc++.so.6" \
LD_LIBRARY_PATH="$GNU_LIB" \
    matlab "$@"
```

Close Matlab, and start it from the console instead, by calling this executable. 
If that solves your problem, you might want to save that script with other binaries on your path (eg in `$HOME/.local/bin` and edit your `~/.bash_profile` accordingly).
