
# MAT files

JMX supports both reading and writing of MAT files. The `MAT` class implements the [creator/extractor interfaces](jmx/more/interface) with key-type `const char*`.

## API

```cpp
open( const char *name, const char *mode= "r" );

int set_value( std::string name, mxArray *value );
mxArray* get_value( std::string name ) const;
mxArray* operator[] ( std::string name ) const;
```

> **Note:** the `operator[]` cannot be used to create fields!

File-opening modes are:
```
r       read-only
u       update (preserve version)
w4      older than version 4
w6,wL   for Matlab 6 or 6.5 (native char encoding)
w7,wz   compressed MAT file with unicode
w7.3    HDF-5 format
```

## Practical use

Open an existing MAT-file:
```cpp
auto F = jmx::MAT( "foo.mat" );
auto x = F.getvec<float>("x"); // vector of floats saved as "x"
```

Creating a new MAT-file:
```cpp
auto F = jmx::MAT( "bar.mat", "w7" );
auto M = F.mkstruct( "s", {"a","b"} );

M.mkbool("a",true);
M.mkstr("b","Hello!");
```

