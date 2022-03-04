
# Large C++ projects

## Projects with multiple files

Most projects will have multiple files.

Compile each file independently (most likely not Mex), specify linked objects with the compiler.

Then compile the main Mex file at the end, specifying all linked objects.