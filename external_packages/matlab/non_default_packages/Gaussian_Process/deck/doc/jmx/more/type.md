
# Type conversion

## Correspondence

| Matlab | C++ |
|--|--|
| `mxLOGICAL_CLASS` | `bool` |
| `mxINT8_CLASS` | `int8_t` |
| `mxINT16_CLASS` | `int16_t` |
| `mxINT32_CLASS` | `int32_t` |
| `mxINT64_CLASS` | `int64_t` |
| `mxUINT8_CLASS` | `uint8_t` |
| `mxUINT16_CLASS` | `uint16_t` |
| `mxUINT32_CLASS` | `uint32_t` |
| `mxUINT64_CLASS` | `uint64_t` |
| `mxSINGLE_CLASS` | `float` |
| `mxDOUBLE_CLASS` | `double` |

## Practical use

```cpp
// from mex to c++
using T = jmx::mex2cpp<mxUINT32_CLASS>::type;
jmx::Matrix<T> M(2,3);          // runtime
auto M = args.mkmat<T>(2,3);    // output

// from c++ to mex
mxArray *M = mxCreateNumericMatrix( 2, 3, jmx::cpp2mex<float>::classid, mxREAL );
```
