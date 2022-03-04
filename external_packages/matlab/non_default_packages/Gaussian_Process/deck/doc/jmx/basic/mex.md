
# Writing Mex files

Here is what you need to write Mex files using JMX.

## Boilerplate

Mex files are C++ programs which define a special function called `mexFunction()`, instead of the traditional `main()` function. Most Mex files using JMX will look like this:

```cpp
// include standard headers here, e.g. iostream, vector, etc.
#include "jmx.h"
using namespace jmx_types; // index_t, integ_t, real_t

void usage() {
    jmx::println("Usage: <Output> = function( <Input1>, <Input2> )");
}

void mexFunction( int nargout, mxArray *out[],
                  int nargin, const mxArray *in[] ) 
{
    // redirect stdout and stderr to the Matlab console
    jmx::cout_redirect();
    jmx::cerr_redirect();

    // wrap input and output arguments
    auto args = jmx::Arguments( nargout, out, nargin, in );
    args.verify( 2, 1, usage ); // for example, 2 inputs and 1 output

    // do your thing
}
```

## Inputs and outputs

The class `jmx::Arguments` greatly simplifies the interaction with Mex inputs and outputs. For example, to retrieve a matrix as first input, and a vector of `uint8` as a second input, you would simply write:
```cpp
auto x = args.getmat(0); // input count starts at 0
auto y = args.getvec<uint8_t>(1);
```

This will throw an error if the actual inputs do not match the types specified.

> **Note:** strictly speaking, `y` should actually be of type `jmx::mex2cpp< mxUINT8_CLASS >::type`. 
> But that is long and complicated, and it is clear that the corresponding C++ type is `uint8_t` (from the header `cstdint`).
>
> In general though, remember that you can use `jmx::mex2cpp` and `jmx::cpp2mex` to convert numeric types (logical, integers and floats).

Similarly, to return a struct in output with fields `foo="Hello!"` and `bar=true`, you would simply write:
```cpp
auto z = args.mkstruct( 0, {"foo","bar"} ); // first output
z.mkstr( "foo", "Hello!" );
z.mkbool( "bar", true );
```

Try to write a Mex file without JMX that simply does this (retrieve two inputs, and create one output, with all required checking), and you will realise quickly how useful this is.

More information about inputs and outputs is provided [here](jmx/basic/io).

## Compilation

Another usually painful step when working with Mex files comes when one tries to compile them into executables, by calling `mex` from the Matlab console. If anything, there are [a lot of options](https://uk.mathworks.com/help/matlab/ref/mex.html) described in the documentation, and dealing with integer size varying across platforms or using the C++14 standard for example can be difficult to manage in practice.

The JMX library defines the Matlab function `jmx()` which greatly simplifies the compilation step. Internally, this function calls `jmx_compile()`, which can be used to compile any Mex file, whether using JMX or not. Type `help jmx_compile` for more information. 

More details about compilation in large projects is provided [here](jmx/more/project).
