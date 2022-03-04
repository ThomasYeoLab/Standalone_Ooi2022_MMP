
#include "jmx.h"
#include <cmath>
#include <vector>
using namespace jmx_types;

// ------------------------------------------------------------------------

constexpr real_t square( const real_t& x ) { return x*x; }

template <class T>
void copyvec( const T& target, const std::vector<index_t>& source )
{
    for ( index_t k = 0; k < source.size(); ++k )
        target[k] = source[k];
}

// ------------------------------------------------------------------------

void usage() {
    jmx::println("Usage [find points within L2 distance]:");
    jmx::println("    index = withinL2( reference, query, radius )");
    jmx::println("where");
    jmx::println("    reference = nxd matrix");
    jmx::println("    query     = pxd matrix");
    jmx::println("    radius    = scalar");
    jmx::println("    index     = 1xp cell\n");
    jmx::println("For each query point, find indices of all reference points within a given radius.");
    jmx::println("Complexity is O(pnd) time, O(np) space worst case.");
}

void mexFunction(	
    int nargout, mxArray *out[],
    int nargin, const mxArray *in[] )
{
    auto args = jmx::Arguments( nargout, out, nargin, in );
    args.verify( 3, 1, usage ); // 3 inputs, 1 output

    // parse inputs
    auto Ref = args.getmat(0);
    auto Qry = args.getmat(1);
    const real_t sqrad = square(args.getnum(2));

    // check inputs
    const index_t nd = Ref.nc;
    const index_t nr = Ref.nr;
    const index_t nq = Qry.nr;

    JMX_ASSERT( Qry.nc == nd, "Input size mismatch" );
    JMX_ASSERT( sqrad > 0, "Radius should be positive." );

    // allocate output
    auto ind = args.mkcell(0, nq);
    std::vector<index_t> tmp;
    tmp.reserve(100); // completely arbitrary

    // find fixed-radius near neighbours
    index_t r,c,p;
    real_t sqdist;
    for ( p = 0; p < nq; p++ ) { // iterate over rows of Qry
        tmp.clear();
        for ( r = 0; r < nr; r++ ) { // iterate over rows of H

            // advance over columns as long as the difference is below threshold
            sqdist = 0.0;
            for ( c = 0; c < nd; c++ ) {
                sqdist += square(Qry(p,c) - Ref(r,c));
                if ( sqdist >= sqrad ) break;
            }

            // if all coordinates are close enough, we found a match
            if ( c == nd ) tmp.push_back(r+1); // +1 because Matlab indices start at 1
        }
        auto ind_p = ind.mkvec( p, tmp.size() );
        copyvec(ind_p, tmp);
    }
}