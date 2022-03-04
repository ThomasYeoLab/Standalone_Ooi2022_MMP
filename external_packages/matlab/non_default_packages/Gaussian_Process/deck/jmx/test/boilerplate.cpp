// include standard headers here
#include <iostream>
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

    auto x = args.getmat(0); // input count starts at 0
    auto y = args.getvec<uint8_t>(1);

    auto z = args.mkstruct( 0, {"foo","bar"} );
    z.mkstr( "foo", "Hello!" );
    z.mkbool( "bar", true );
}

// Example call: a = boilerplate( rand(3), zeros(1,2,'uint8') )