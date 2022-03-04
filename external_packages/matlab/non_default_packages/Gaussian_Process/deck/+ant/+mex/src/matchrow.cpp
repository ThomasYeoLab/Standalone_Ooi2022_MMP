
#include "jmx.h"
#include <cmath>
using namespace jmx_types;

// ------------------------------------------------------------------------

void usage() {
    jmx::println("Usage [find matching row]:");
    jmx::println("    index = matchrow( haystack, needles, thresh=1e-12 )");
    jmx::println("where");
    jmx::println("    haystack  = nxd matrix");
    jmx::println("    needles   = pxd matrix");
    jmx::println("    thresh    = scalar");
    jmx::println("    index     = px1 vector\n");
    jmx::println("For each needle, find index of first matching row in haystack.");
    jmx::println("Two rows match if they differ by at most thresh.");
    jmx::println("Complexity is O(pnd) time worst case, O(p) space.");
}

void mexFunction(	
    int nargout, mxArray *out[],
    int nargin, const mxArray *in[] )
{
    auto args = jmx::Arguments( nargout, out, nargin, in );
    args.verify( 2, 1, usage ); // 2 inputs, 1 output

    // parse inputs
    auto H = args.getmat(0);
    auto N = args.getmat(1);
    const real_t thresh = args.getnum(2,1e-12);

    // check inputs
    const index_t nd = H.nc;
    const index_t nh = H.nr;
    const index_t nn = N.nr;

    JMX_ASSERT( N.nc == nd, "Input size mismatch" );

    // allocate output
    auto ind = args.mkvec(0,nn);

    // find match
    index_t r,c,p;
    for ( p = 0; p < nn; p++ ) { // iterate over rows of N
        ind[p] = 0; // default value is 0, means no match
        for ( r = 0; r < nh; r++ ) { // iterate over rows of H
            // advance over columns as long as the difference is below threshold
            for ( c = 0; c < nd && std::abs(N(p,c) - H(r,c)) < thresh; c++ ) {}
            // if all coordinates are close enough, we found a match
            if ( c == nd ) {
                ind[p] = r+1; // +1 because Matlab indices start at 1
                break;
            }
        }
    }
}