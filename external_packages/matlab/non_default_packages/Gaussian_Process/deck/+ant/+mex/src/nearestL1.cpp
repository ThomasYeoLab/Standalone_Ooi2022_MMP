
#include "jmx.h"
#include <cmath>
#include <limits>
using namespace jmx_types;

// ------------------------------------------------------------------------

void usage() {
    jmx::println("Usage [nearest neighbour search using L1 distance]:");
    jmx::println("    [index,dist] = nearestL1( reference, query )");
    jmx::println("where");
    jmx::println("    reference = nxd matrix");
    jmx::println("    query     = pxd matrix");
    jmx::println("    index     = 1xp vector");
    jmx::println("    dist      = 1xp vector\n");
    jmx::println("For each query point, find index of closest reference point.");
    jmx::println("Return its index and distance.");
    jmx::println("Complexity is O(pnd) time worst case, O(p) space.");
}

void mexFunction(	
    int nargout, mxArray *out[],
    int nargin, const mxArray *in[] )
{
    auto args = jmx::Arguments( nargout, out, nargin, in );
    args.verify( 2, 1, usage ); // 2 inputs, 1 output

    // parse inputs
    auto Ref = args.getmat(0);
    auto Qry = args.getmat(1);

    // check inputs
    const index_t nd = Ref.nc;
    const index_t nr = Ref.nr;
    const index_t nq = Qry.nr;

    JMX_ASSERT( Qry.nc == nd, "Input size mismatch" );

    // allocate output
    auto ind = args.mkvec(0, nq);
    jmx::Vector<real_t> dst(nq);

    // find nearest neighbour
    index_t r,c,p;
    real_t mindist, dist;
    for ( p = 0; p < nq; p++ ) { // iterate over rows of Qry
        mindist = std::numeric_limits<real_t>::max();
        for ( r = 0; r < nr; r++ ) { // iterate over rows of Ref

            // advance over columns as long as the difference is below threshold
            dist = 0.0;
            for ( c = 0; c < nd; c++ ) {
                dist += std::abs(Qry(p,c) - Ref(r,c));
                if ( dist >= mindist ) break;
            }

            // if all coordinates are close enough, we found a match
            if ( c == nd ) {
                mindist = dist;
                ind[p] = r+1; // +1 because Matlab indices start at 1
            }
        }
        dst[p] = mindist;
    }

    // create second output
    jmx::Vector_mx<real_t> dst_mx;
    if ( nargout > 1 ) {
        dst_mx = args.mkvec( 1, nq, true );
        for ( p = 0; p < nq; p++ ) dst_mx[p] = dst[p];
    }
    dst.free();
}