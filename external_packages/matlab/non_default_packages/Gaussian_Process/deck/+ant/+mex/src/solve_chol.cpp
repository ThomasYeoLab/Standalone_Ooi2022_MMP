
#include "jmx.h"
#include <algorithm>
using namespace jmx_types;

/**
 * Rewritten from GPML's solve_chol.c
 */

#ifdef MEX_INFORMATION_VERSION             /* now we are compiling for Matlab */
  #if defined(_WIN64)
    #define longint  long long
  #else
    #define longint  long
  #endif
  #define dreal double
#else                                      /* now we are compiling for Octave */
  #ifdef __APPLE__
    #include <Accelerate/Accelerate.h>
    typedef __CLPK_integer    longint;
    typedef __CLPK_doublereal dreal;
  #else
    typedef int    longint;
    typedef double dreal;
  #endif
#endif

#if !defined(_WIN32) || !defined(MEX_INFORMATION_VERSION) /* not Win32/Matlab */
  #define dpotrs dpotrs_
#endif

// ------------------------------------------------------------------------

extern "C" {
    longint dpotrs( char*, 
        longint*, longint*, dreal*, longint*, 
        dreal*, longint*, longint* );
}

void usage() {
    jmx::println("Solve A*X = B with A SPD, using Cholesky factorisation implemented in LAPACK/DPOTRS.");
    jmx::println("Usage:");
    jmx::println("    X = solve_chol( A, B )");
    jmx::println("where");
    jmx::println("    A = nxn SPD matrix");
    jmx::println("    B = nxm matrix");
    jmx::println("    X = nxm matrix");
}

void mexFunction(	
    int nargout, mxArray *out[],
    int nargin, const mxArray *in[] )
{
    auto args = jmx::Arguments( nargout, out, nargin, in );
    args.verify( 2, 1, usage ); // 2 inputs, 1 output

    // parse inputs
    auto A = args.getmat(0);
    auto B = args.getmat(1);

    // allocate output
    longint n = A.nr;
    longint m = B.nc;

    JMX_ASSERT( A.nc == n, "A should be square." );
    JMX_ASSERT( B.nr == n, "A and B should have the same number of rows." );
    auto X = args.mkmat(0, n, m);
    if (n == 0) return;

    // call LAPACK
    char U[] = "U";
    longint q;
    std::copy_n( B.memptr(), B.numel(), X.memptr() );
    dpotrs( U, &n, &m, const_cast<real_t*>(A.memptr()), &n, X.memptr(), &n, &q );
    JMX_ASSERT( q >= 0, "Illegal input to solve_chol." );
}