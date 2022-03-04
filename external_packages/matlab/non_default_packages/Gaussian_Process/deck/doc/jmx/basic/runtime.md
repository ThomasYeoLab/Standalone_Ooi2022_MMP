
# Runtime variables

Creating runtime arrays (using C++ memory allocation with `new`) is as simple as:
```cpp
Vector<T> x(len);
Matrix<T> M(nr,nc);
Volume<T> V(nr,nc,ns);
```
More details about arrays [here](jmx/more/array).

Creating [cells](jmx/more/cell) and [structs](jmx/more/struct) should not be necessary unless for input/ouput, which have been covered [previously](jmx/basic/io).
See also more details about creating [MAT files](jmx/more/mat).
