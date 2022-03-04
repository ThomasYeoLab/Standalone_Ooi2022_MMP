
# Cell-arrays

JMX only supports row-shaped cell-arrays at the moment. Cells implement the [creator/extractor interfaces](jmx/more/interface) with key-type `index_t`.

If you really need a 2D cell-array, note that struct-arrays are stored in exactly the same way within Matlab, so you can always use a struct-array with one field. From experience, higher-dimensional cells are usually a bad idea.

## API

```cpp
index_t numel() const;
bool empty() const;

mxArray* get_value( index_t k ) const;
mxArray* set_value( index_t k, mxArray *value ) const;
mxArray* operator[] ( index_t k ) const;
```

## Practical use

Using an input cell:
```cpp
auto c = args.getcell(0);        // field 0 is the first input

JMX_ASSERT( c.numel() > 2, "Bad cell-length." )
auto x = c.getvec(2); // vector of doubles at index 3

JMX_ASSERT( x.length() > 2, "Bad length." )
jmx::println( "%g", x[2] );
```

Creating an output cell:
```cpp
// create cell of length 10 in first output
auto s = args.mkcell(0,10);
auto M = s.mkmat<float>(5,3,4); // 3x4 matrix of singles in sixth cell

M(0,2) = -1.0f; // use the matrix
```