
# Structures

Both structures and struct-arrays supported, but working with struct-arrays is somewhat complicated right now. Structures implement the [creator/extractor interfaces](jmx/more/interface) with key-type `const char*`.

## API

```cpp
index_t numel() const;
index_t nfields() const;
bool empty() const;

bool has_field( std::string name ) const;
bool has_fields( inilst<const char*> names ) const;
bool has_any( inilst<const char*> names ) const;

int set_value( std::string name, mxArray *value );
mxArray* get_value( std::string name ) const;
mxArray* operator[] ( std::string name ) const;
```

> **Note:** the `operator[]` cannot be used to create fields!

Specifically for struct-arrays:
```cpp
index_t ndims() const;
index_t nrows() const;
index_t ncols() const;

bool is_matrix() const; // ndims==2
bool is_scalar() const; // numel==1
bool is_array() const;  // numel > 1

Struct& select( index_t k );
Struct& select( index_t r, index_t c );
```

## Practical use

Using an input structure:
```cpp
auto s = args.getstruct(0);        // field 0 is the first input
auto x = s.getvec<uint8_t>("foo"); // vector of uint8 in field "foo"

JMX_ASSERT( x.length() > 2, "Bad length." )
jmx::println( "%" PRIu8, x[2] ); // #include <cinttypes>
```

Creating an output structure:
```cpp
// create struct with fields {foo, bar} in first output
auto s = args.mkstruct( 0, {"foo","bar"} );
auto M = s.mkmat<float>("foo",3,4); // 3x4 matrix of singles in field "foo"

M(0,2) = -1.0f; // use the matrix
```

## Struct-arrays

Struct-arrays in JMX are regular `Struct` objects, within which individual structs can be "selected" one at a time by specifying an index. 

Using an input struct-matrix:
```cpp
auto sa = args.getstruct(0);

// is_array checks numel() > 1, is_matrix checks ndims() == 2
JMX_ASSERT( sa.is_array() && sa.is_matrix(), "Input is not a struct-matrix." )

// select struct within array, then get matrix of singles in field "foo"
auto M = sa.select(1,2).getmat<float>("foo");
```

Creating an output struct-array:
```cpp
// 3x2 struct-array with fields {foo,bar} as output 0
auto sa = args.mkstruct(0, {"foo","bar"}, 3,2); 

// create 10x1 vector of doubles in field "bar" at index (2,3)
auto x = sa.select(1,2).mkvec("bar",10,true);
x[2] = 3.14;
```
