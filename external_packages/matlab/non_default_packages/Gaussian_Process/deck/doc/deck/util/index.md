
# General utilities

Help is available for each of these functions by typing `help <FunctionName>` in the Matlab console.

## Formatting

Change the shape of an array:
```
dk.formatmv             format matrix with associated vector
dk.torow
dk.tocol
```

Convert variable to string:
```
dk.tostr
dk.util.array2cpp
dk.util.array2str
dk.util.book2yn
dk.util.vec2str
```

## Programming

Algorithms for lists of values:
```
dk.grouplabel
dk.countunique
dk.groupunique
```

Working with variables:
```
dk.compare              deep comparison of any two values
dk.getelem              access elements in a cell or array
dk.bytesize             size of a variable

dk.load                 ... simplify load/save
dk.save
dk.savehd

dk.util.func_eq         ... work with function handles
dk.util.func_ismember   
dk.util.func_neq
```

General tools:
```
dk.getopt               simple key/value parser
dk.trywait              try calling a function, wait before retry
dk.notify               simplify passing data through event listeners
dk.util.timeit          statistics on execution time
dk.util.numcores        number of cores available
dk.chkmver              check Matlab version
```

## Other

```
dk.util.bytefmt         convert given bytesize to MB,GB,TB etc.
dk.util.path2name       convert filepath to callable name
dk.util.email           send email
```
