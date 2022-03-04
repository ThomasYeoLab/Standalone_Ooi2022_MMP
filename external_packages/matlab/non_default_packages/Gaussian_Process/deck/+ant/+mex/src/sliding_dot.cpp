
//==================================================
// @title        sliding_dot.cpp
// @author       Jonathan Hadida
// @contact      Jhadida [at] fmrib.ox.ac.uk
//==================================================

#include "jmx.h"
#include "sliding_window.h"
#include "armadillo.h"
using namespace jmx_types;

// Fix issues with Matlab's LAPACK/BLAS libs on Unix
#if !defined(_WIN32)
    #define dgemv dgemv_
    #define sgemv sgemv_
#endif



		/********************     **********     ********************/
		/********************     **********     ********************/



void usage()
{
	jmx::println( "[avg] = sliding_dot( signals, weights, wstep=1, wburn=0 )" );
	jmx::println( "where:" );
	jmx::println( "\t signals is a nxp double matrix with timecourses in column" );
	jmx::println( "\t weights is a column of weights for elements in each sliding window\n" );
}

// ------------------------------------------------------------------------

/**
 * Extract Mex inputs using JMX and wrap them using Armadillo containers.
 */
template <class T>
void arma_extract_input_matrix( const mxArray *in, arma::Mat<T>& out, bool copymem = false )
{
    auto in_jmx = jmx::get_matrix<T>(in);
	out = arma::Mat<T>( const_cast<T*>(in_jmx.memptr()), in_jmx.nr, in_jmx.nc, copymem );
}

template <class T, class U>
void arma_extract_input_vector( const mxArray *in, U& out, bool copymem = false )
{
    auto in_jmx = jmx::get_vector<T>(in);
	out = U( const_cast<T*>(in_jmx.memptr()), in_jmx.n, copymem );
}

// ------------------------------------------------------------------------

template <class T>
void compute_sliding_dot( jmx::Arguments& args, index_t wstep, index_t wburn )
{
	// extract signals
	arma::Mat<T> signals;
	arma_extract_input_matrix<T>( args.in[0], signals );

	// extract weights
	arma::Row<T> weights;
	arma_extract_input_vector<T>( args.in[1], weights );

	const index_t nt   = signals.n_rows;
	const index_t ns   = signals.n_cols;
	const index_t wlen = weights.n_elem;

	// configure sliding window
	SlidingWindow swin;
	JMX_ASSERT( swin.configure( nt, wlen, wstep, wburn ), "Couldn't configure sliding window." );
	const index_t nw = swin.nw();

	// create outputs
	auto jmx_dot = args.mkmat<T>( 0, nw, ns );
	arma::Mat<T> arma_dot( jmx_dot.memptr(), nw, ns, false );

	// iterate on each coefficient of the matrix
	for ( swin.reset(); swin.valid(); ++swin )
		arma_dot.row(swin.cw()) = weights * signals.submat( swin.first(), 0, swin.last(), ns-1 );
}

// ------------------------------------------------------------------------

void mexFunction(
	int nargout, mxArray *out[],
	int nargin, const mxArray *in[] )
{
	auto args = jmx::Arguments( nargout, out, nargin, in );
	args.verify( 2, 1, usage );

	// Sliding-window parameters
	index_t wstep = args.getnum<index_t>(2,1);;
	index_t wburn = args.getnum<index_t>(3,0);;

	// Type-dependent computation
	switch ( mxGetClassID(in[0]) )
	{
		case mxDOUBLE_CLASS:
			compute_sliding_dot<double>( args, wstep, wburn );
			break;

		case mxSINGLE_CLASS:
			compute_sliding_dot<float>( args, wstep, wburn );
			break;

		default:
			JMX_WARN( "Unsupported input type '%s'.", mxGetClassName(in[0]) );
			break;
	}
}
