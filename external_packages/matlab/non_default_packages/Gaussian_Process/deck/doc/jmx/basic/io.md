
# Inputs and Outputs

The JMX argument wrapper should be initialised at the beginning of your `mexFunction` like so:
```cpp
auto args = jmx::Arguments( nargout, out, nargin, in );
args.verify( 2, 1, usage ); // for example, 2 inputs and 1 output
```

Below is a list of methods that can be used to retrieve inputs, or create outputs.
For more details, note that this wrapper implements the [creator/extractor interfaces](jmx/more/interface) with key-type `index_t`.

## Inputs

```cpp
// get input argument k
args.getbool(k);
args.getstr(k);
args.getnum(k);                 // template T = double
args.getvec(k);                 // template T = double
args.getmat(k);                 // template T = double
args.getvol(k);                 // template T = double

// get writable arrays
args.getvec_rw(k);              // template T = double
args.getmat_rw(k);              // template T = double
args.getvol_rw(k);              // template T = double

// with default value
args.getnum(k,42);              // template T = double
args.getbool(k,true);
args.getstr(k,"Hello");

// special containers
args.getcell(k);
args.getstruct(k);
args.getstruct(k,n);            // item n in struct-array
```

Output arrays returned by `get(vec|mat|vol)` are `_ro` variants by default (using [`ReadOnlyMemory`](jmx/more/memory)), meaning that they cannot be reallocated or freed, and that their value-type is const. Use `get(vec|mat|vol)_rw` to return the `_mx` array variants (using [`MatlabMemory`](jmx/more/memory)), which have a non-const value-type.

More info about [arrays](jmx/more/array), [struct](jmx/more/struct) and [cells](jmx/more/cell).

## Outputs

```cpp
// get input argument k
args.mkbool(k,true);
args.mkstr(k,"Hello");
args.mknum(k,42);               // template T = double
args.mkvec(k,len,col=false);    // template T = double
args.mkmat(k,nr,nc);            // template T = double
args.mkvol(k,nr,nc,ns);         // template T = double

// special containers
args.mkcell(k,len);
args.mkstruct(k,{"f1","f2",...});
args.mkstruct(k,{"f1","f2",...},nr,nc); // struct-array
args.mkstruct(k,nr,nc); // struct-array with no field
args.mkstruct(k); // struct with no field
```

Working with struct-arrays is a little bit complicated, and only row-shaped cells are implemented at the moment.
