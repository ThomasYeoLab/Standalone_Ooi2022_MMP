
## Design and architecture

 - Reading and creating variables
   - Data types
   - Mappable containers
   - Sequence containers
   - Memory allocation
 - Printing to the console

## In order

```
common:
  printing + type conversion Matlab/C++

makers:
  create mxArray*

setters:
  assign mxArray* cells / fields / variables 

array: (cf memory)
  define Vector, Matrix and Volume
  + forward declare Struct and Cell

getters:
  wrap const mxArray* into previous containers
  memory is ReadOnly by default, Matlab variants with _rw suffix
  + forward declare get_struct / get_cell

creator:
  abstract class with methods mkvec/mkmat/etc using makers
  relies on: mxArray* _creator_assign( <key>, mxArray* )

extractor:
  abstract class with methods getnum/getvec/etc using getters
  relies on: const mxArray* _extractor_get( <key> )

mapping:
  wrapper around unordered map (string -> mxArray*)
  implements Creator and Extractor patterns with string keys

container:
  concrete definitions of MAT, Struct and Cell

forward:
  definition of getters + creator + extractor

args:
  wrapper around Mex function inputs
  implements Creator + Extractor patterns with index keys
  simplifies getting inputs / creating outputs

```

On the side:
```
redirect:
  redirecting cout/cerr to mexPrintf

memory:
  ReadOnly, Matlab (mxCalloc) and Cpp (new[]) allocators


display: not available yet
  display containers to console

```