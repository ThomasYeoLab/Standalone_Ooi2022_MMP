
#include "jmx.h"

// it's considered bad practice to use entire namespace like this, 
// but that's ok for short functions...
using namespace jmx;

// ------------------------------------------------------------------------

void mexFunction( int nargout, mxArray *out[],
                  int nargin, const mxArray *in[] ) 
{
    // collect inputs
    JMX_ASSERT( nargin >= 1, "This function requires a vector in input" );
    auto x = get_vector<double>(in[0]);

    // print something to the console
    cout_redirect(true);
    println("Hello there :)");

    // call functions from included headers
    // simple_function(x);

    // create an output matrix
    if (nargout >= 1) {
        out[0] = make_matrix( 1, 2 );
        auto out0 = get_matrix_rw<double>(out[0]); // note the suffix '_rw'
        out0[0] = 1;
        out0(0,1) = -1;
    }
}
