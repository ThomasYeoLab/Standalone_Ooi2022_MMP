
#include "jmx.h"
#include <algorithm>
using namespace jmx_types;

// ------------------------------------------------------------------------

void usage() {
    jmx::println("Usage [find lower-bound along specified dimension]:");
    jmx::println("    index = lbound( vals, query )");
    jmx::println("where");
    jmx::println("    vals  = nxd matrix");
    jmx::println("    query = 1xd vector of threshold");
    jmx::println("    index = 1xd vector of indices\n");
    jmx::println("For each row or column, find index of lower-bound.");
    jmx::println("Assumes columns of vals to be SORTED ASCENDING.");
}

void mexFunction(	
    int nargout, mxArray *out[],
    int nargin, const mxArray *in[] )
{
    auto args = jmx::Arguments( nargout, out, nargin, in );
    args.verify( 2, 1, usage ); // 2 inputs, 1 output

    // parse inputs
    auto Val = args.getmat(0);
    auto Qry = args.getvec(1);

    // allocate output
    const index_t nd = Val.nc;
    const index_t nr = Val.nr;
    const index_t nq = Qry.n;

    JMX_ASSERT( nq == nd, "There should be as many queries as columns" );
    auto ind = args.mkvec(0, nd, false);

    // find fixed-radius near neighbours
    for ( index_t k = 0; k < nd; k++ ) { // iterate over columns of Val
        auto first = &( Val(0,k) );
        auto last = &( Val(nr-1,k) );
        auto bound = std::lower_bound( first, last, Qry[k] );

        ind[k] = 1 + (bound - first)/sizeof(decltype(*first));
    }
}