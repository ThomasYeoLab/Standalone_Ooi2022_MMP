# Structures

Matlab [structures](http://uk.mathworks.com/help/matlab/structures.html) are associative data containers mapping a field name (string) to a value (any).
The methods of this submodule allow you to define, modify and transform these structures.

- [`dk.struct.repeat`](#repeat) An adaptation of [`repmat`](https://uk.mathworks.com/help/matlab/ref/repmat.html) for structures
- [`dk.struct.grid|array`](#grid) Create struct-arrays with specified fields
- [`dk.struct.set|get|rem`](#manip) Manipulate fields of structures (scalar or array)
- [`dk.struct.fields|values`](#fieldval) Get fields/values of structures (scalar or array)
- [`dk.struct.merge`](#merge) Merge two structures (recursively or not)
- [`dk.struct.to_table`](#to_table) Convert struct-array to [table object](https://uk.mathworks.com/help/matlab/ref/table.html)
- [`dk.struct.to_cell`](#to_cell) What I expected [`struct2cell`](https://uk.mathworks.com/help/matlab/ref/struct2cell.html) to do
- [`dk.struct.to_vars`](#to_vars) Turn the fields of a structure into scope variables

---

### <a name="repeat"/> `dk.struct.repeat`

An adaptation of [`repmat`](https://uk.mathworks.com/help/matlab/ref/repmat.html) for structures. Convenient to allocate empty struct-arrays with predefined fields.

Signature:
```
    s = dk.struct.repeat( fields, varargin )
```

Example:
```matlab
dk.struct.repeat( {}, [2,3,4] ) % 2x3x4 struct-array with no field
dk.struct.repeat( {'single'}, [1,2] ) % fields must be a cell, even for a single field
dk.struct.repeat( {'field1','field2'}, [2,3] ) % multiple fields without repeat
```

---

### <a name="grid"/> `dk.struct.grid|array`

These two methods extend the previous `dk.struct.repeat` by allowing the user to allocate _and_ initialise struct-arrays.

Signatures:
```
    s = dk.struct.array( field1, values, field2, ... )
    s = dk.struct.grid( rowfield, rowvals, colfield, colvals )
```

First, the method `dk.struct.array` allows you to define an arbitrary number of fields, and an arbitrary number of elements. The output will always be a _column vector_ of structures, which can subsequently be reshaped as desired. For example:
```matlab
% allocate and initialise a 2x3 struct-array
s = dk.struct.array( 'foo.bar', 1:6, 'baz', {[0 1], 'hello', struct(), [], {}, NaN} );
s = reshape(s,[2 3]);
```

Note that the field `foo.bar` contains a subfield; this means that each element of the struct-array `s` will be a structure with fields `foo` and `baz`, and that the field `foo` will itself contain a structure with a single field `bar`.

Note also that for both fields `foo.bar` and `baz`, the following argument is either a cell-array or an array, but they _must_ contain the same number of elements, which corresponds to the length of the output struct-column.


The method `dk.struct.grid` is slightly more complicated. It only allows struct-matrices to be defined (row and column values only), but this time the ouput structure corresponds to an "outer-product" of a struct-column (with the specified row values) and a struct-row (with the column values). For example:
```matlab
dk.struct.grid( 'row.foo', {'a','b','c'}, 'col', 10:10:40 )
```
allocates a 3x4 struct-matrix with fields `row` and `col`. Here again you can specify subfields, so the field `row` in each structure is itself a structure with a single field `foo`.

The values in this matrix correspond to an outer-product operation; in the second column (size 3x1), the field `col` of each structure contains the value 20, while the subfield `row.foo` is assigned values `{'a','b','c'}` in order. Similarly in the third row (size 1x4), all subfields `row.foo` contain the same value `'c'`, while the field `col` is assigned values `[10,20,30,40]` in order.

---

### <a name="manip"/> `dk.struct.set|get|rem`

These methods apply to both scalar strutures and struct-arrays.
The examples below demonstrate typical usage.

Signatures:
```
    s = dk.struct.set( s, field, value, overwrite=false )
    v = dk.struct.get( s, field, default )
    s = dk.struct.rem( s, varargin )
```

Example:
```matlab
% 2x3 struct-array with single field 'a'
s = dk.struct.repeat( {'a'}, [2 3] )

% field 'b' is added with values 0
s = dk.struct.set( s, 'b', 0 ); {s.b}

% field 'b' already exists, so this won't do anything
t = dk.struct.set( s, 'b', 10:10:60 ); {t.b}

% we need to authorise overwrite
t = dk.struct.set( s, 'b', 10:10:60, true ); {t.b}

% field 'c' is undefined
v = dk.struct.get( t, 'c', [0,1] ) % 2x3 cell repeating default value [0,1]
v = dk.struct.get( t, 'c' ) % throws an error

% field 'b' exists
v = dk.struct.get( t, 'b' ) % 2x3 cell with field values

% remove field 'a', but don't throw an error about 'c' being undefined
u = dk.struct.rem( t, 'c', 'a' )
```

---

### <a name="fieldval"/> `dk.struct.fields|values`

Extract the fields and values from a scalar structure or struct-array.

Signatures:
```
    f = dk.struct.fields( s )
    v = dk.struct.values( s, order={} )
```

Example:
```matlab
% create 2x3 struct-array
s = dk.struct.array( 'a', 1:6, 'b', 10:10:60 );
s = reshape( s, [2,3] );

% fields is just an alias for fieldnames
f = dk.struct.fields(s)

% values returns a NxF cell-array where
%   N is the number of structures
%   F is the number of fields
v = dk.struct.values(s)

% you can modify the column order
% or even filter desired fields only with the second input
v = dk.struct.values(s,{'b','a'})
```

---

### <a name="merge"/> `dk.struct.merge`

This method can be used to merge several structures or struct-array together, recursively in option. The merging is done from **right-to-left**, meaning that the last input structures overwrite the ones before them if they define the same fields.

Signature:
```
    s = dk.struct.merge( s1, s2, ..., sN, recursive=false )
```

Example:
```matlab
a.foo = struct('a',42); b.bar = 'hello'; c.foo = struct('c',5);
nonrecursive = dk.struct.merge( a, b, c ); nonrecursive.foo % struct('c',5)
recursive = dk.struct.merge( a, b, c, true ); recursive.foo % struct('a',42,'c',5)
```

---

### <a name="to_table"/> `dk.struct.to_table`

Convert struct-array to table, with variable names corresponding to fieldnames.

Signature:
```
    T = dk.struct.to_table( s )
```

Example:
```matlab
s = dk.struct.array( ...
    'FirstName', {'Frank','Douglas','Edward','Zoey'}, ...
    'LastName', {'Underwood','Stamper','Meechum','Barnes'} ...
);
dk.struct.to_table(s)
```

---

### <a name="to_cell"/> `dk.struct.to_cell`

Does what I would expect [`struct2cell`](https://uk.mathworks.com/help/matlab/ref/struct2cell.html) to do; it builds a cell `{ field1, value1, field2, ... }` from a scalar structure `struct( 'field1', value1, 'field2', ... )`.
Note that this function only supports **scalar** structures (no struct-array).

Signature:
```
    c = dk.struct.to_cell( s, recursive=false )
```

Example:
```matlab
s = struct( 'a', 1, 'b', struct('aa',[],'bb',0) )
dk.struct.to_cell(s) % non-recursive by default
dk.struct.to_cell(s,true)
```

---

### <a name="to_vars"/> `dk.struct.to_vars`

Define the fields of a named structure as variables in the calling function (or console).

Signature:
```
    varargout = dk.struct.to_vars( s, varname_handle )
```

Example:
```matlab
clear foo bar
s = struct('foo',1,'bar','baz');
dk.struct.to_vars(s); {foo,bar}

% If an output is required, a string is returned with the commands to define each variable, but it is not evaluated.
% The additional function handle allows to edit variable names.
cmd = dk.struct.to_vars( s, @(x) ['tmp_' x] ) % 'tmp_foo=s.foo; tmp_bar=s.bar;'
```
