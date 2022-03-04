
#include "jmx.h"
#include <cmath>
using namespace jmx_types;

// ------------------------------------------------------------------------

void usage() {
    jmx::println("Usage [label unique rows]:");
    jmx::println("    [label,index] = labelrows( pts, thresh=1e-12 )");
    jmx::println("where");
    jmx::println("    pts    = nxd matrix");
    jmx::println("    thresh = scalar");
    jmx::println("    label  = nx1 vector");
    jmx::println("    index  = mx1 vector\n");
    jmx::println("Two rows have the same label if they only differ by at most thresh.");
    jmx::println("Second output is such that pts(index(k),:) is the first point with label k.");
    jmx::println("Complexity is O(n^2 d) time, O(n) space.");
}

void mexFunction(	
    int nargout, mxArray *out[],
    int nargin, const mxArray *in[] )
{
    auto args = jmx::Arguments( nargout, out, nargin, in );
    args.verify( 1, 1, usage ); // 1 input, 1 output

    // parse inputs
    auto x = args.getmat(0);
    const real_t thresh = args.getnum(1,1e-12);

    const index_t nd = x.nc;
    const index_t nx = x.nr;

    // allocate output
    auto L = args.mkvec( 0, nx, true );
    jmx::Vector<real_t> U(nx);

    // find match
    index_t r,c,p;
    index_t label = 0;

    for ( p = 0; p < nx; p++ ) { // iterate over rows of x
        
        // skip if current row is already labelled
        if ( L[p] > 0 ) continue; 

        // otherwise, label it and search for duplicates
        U[label] = p+1; // +1 because Matlab indexing
        L[p] = ++label; 

        for ( r = p+1; r < nx; r++ ) { // iterate over following rows

            // advance over columns as long as the difference is below threshold
            for ( c = 0; c < nd && std::abs(x(p,c) - x(r,c)) < thresh; c++ ) {}

            // if all coordinates are close enough, we found a match
            if ( c == nd ) L[r] = label;
        }
    }

    // create second output
    jmx::Vector_mx<real_t> Umx;
    if ( nargout > 1 ) {
        Umx = args.mkvec( 1, label, true );
        for ( p = 0; p < label; p++ ) Umx[p] = U[p];
    }
    U.free();

}
