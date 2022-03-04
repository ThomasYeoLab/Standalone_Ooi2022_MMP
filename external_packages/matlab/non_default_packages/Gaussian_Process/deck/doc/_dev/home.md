# Documentation for Deck

Deck is a "general-purpose" Matlab package.
It contains some functions you could have expected Matlab to have, and others which extend Matlab's features, eg for interactive graphics, structure manipulations or managing computations on a cluster. There is nothing too heavy, but there's a lot of it.

Follow the links to access subsections of this documentation:

 - [Installation instructions](install)
 - [Structures](struct)
 - [Strings](string)
 - [Objects](object)
 - [Mex utils](mex)
 - [GUI related](gui)
 - [Maths](maths)
 - [Matrices](matrix)
 - [Time and date](time)
 - [Filesystem](filesystem)
 - [Environment](environment)
 - [Other](util)

There are also a few topics that deserved to be listed independently:

- [Functions with Named Arguments](kwargs): write functions with named arguments (ie, key/value pairs), for clarity and to avoid positional mistakes.
- [Submitting Parallel Jobs](mapred): work with Python to define, submit and monitor parallel jobs to the Jalapeno cluster.
- [Json Parsing](json): an almost standalone submodule to read/write [JSON](https://en.wikipedia.org/wiki/JSON) files.
- [Compiling Mex files](mex): write clear and cross-platform compiling instructions for Mex files.

# Bugs & Contributions

If you find a bug, please make sure that you are using the latest version (type `git pull` from the root folder) before reporting it. If the bug persists, then [search the issues](https://git.fmrib.ox.ac.uk/jhadida/deck/issues) on the GitLab page; it's possible that someone else reported it and that a fix was found but not pushed to the main repository. If you don't find anything similar, then please open a new issue and provide a [MCVE](http://stackoverflow.com/help/mcve) (and a possible fix if you have one) in order to reduce the time needed to identify and fix the bug.

Contributions are welcome from anyone, but you need to be added as a member to the project in order to push your contribution to the repository. Send me a message if you would like to contribute.
