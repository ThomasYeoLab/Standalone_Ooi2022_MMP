#ifndef JMX_GETTERS_H_INCLUDED
#define JMX_GETTERS_H_INCLUDED

//==================================================
// @title        getters.h
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

#include <string>

// ------------------------------------------------------------------------

namespace jmx {    

    template <class T>
    T get_scalar( const mxArray *ms )
    {
        JMX_ASSERT( ms, "Null pointer." );
        JMX_ASSERT( isNumberLike(ms) && (mxGetNumberOfElements(ms) == 1),
            "Input should be a numeric scalar." );

        return static_cast<T>(mxGetScalar(ms));
    }

    std::string get_string( const mxArray *ms );

    // ----------  =====  ----------
    
    template <class T, class M = ReadOnlyMemory<T> >
    Vector<T,M> get_vector( const mxArray *ms )
    {
        JMX_ASSERT( ms, "Null pointer." );
        JMX_ASSERT( isNumberLike(ms), "Bad input type." );
        JMX_ASSERT( isCompatible<T>(ms), "Incompatible types." );
        JMX_ASSERT( mxGetNumberOfDimensions(ms)==2, "Not a vector." );

        index_t nr = mxGetM(ms);
        index_t nc = mxGetN(ms);

        if ( nr*nc == 0 ) {
            // empty vector
            return Vector<T,M>( static_cast<T*>(mxGetData(ms)), 0 );
        }
        else if ( nr < nc )
        {
            JMX_ASSERT( (nr==1) && (nc>1), "Not a vector." );
            return Vector<T,M>( static_cast<T*>(mxGetData(ms)), nc );
        }
        else
        {
            JMX_ASSERT( (nc==1) && (nr>1), "Not a vector." );
            return Vector<T,M>( static_cast<T*>(mxGetData(ms)), nr );
        }
    }

    template <class T, class M = ReadOnlyMemory<T> >
    Matrix<T,M> get_matrix( const mxArray *ms )
    {
        JMX_ASSERT( ms, "Null pointer." );
        JMX_ASSERT( isNumberLike(ms), "Bad input type." );
        JMX_ASSERT( isCompatible<T>(ms), "Incompatible types." );
        JMX_ASSERT( mxGetNumberOfDimensions(ms)==2, "Not a matrix." );
        return Matrix<T,M>( static_cast<T*>(mxGetData(ms)), mxGetM(ms), mxGetN(ms) );
    }

    template <class T, class M = ReadOnlyMemory<T> >
    Volume<T,M> get_volume( const mxArray *ms )
    {
        JMX_ASSERT( ms, "Null pointer." );
        JMX_ASSERT( isNumberLike(ms), "Bad input type." );
        JMX_ASSERT( isCompatible<T>(ms), "Incompatible types." );
        JMX_ASSERT( mxGetNumberOfDimensions(ms)==3, "Not a volume." );
        const index_t *size = mxGetDimensions(ms);
        return Volume<T,M>( static_cast<T*>(mxGetData(ms)), size[0], size[1], size[2] );
    }
    
    // ----------  =====  ----------
    
    template <class T, class M = MatlabMemory<T> >
    Vector<T,M> get_vector_rw( const mxArray *ms ) { return get_vector<T,M>(ms); }

    template <class T, class M = MatlabMemory<T> >
    Matrix<T,M> get_matrix_rw( const mxArray *ms ) { return get_matrix<T,M>(ms); }

    template <class T, class M = MatlabMemory<T> >
    Volume<T,M> get_volume_rw( const mxArray *ms ) { return get_volume<T,M>(ms); }

    // ----------  =====  ----------

    // forward declarations (see forward.h)
    Cell get_cell( const mxArray *ms );
    Struct get_struct( const mxArray *ms, index_t index=0 ); 

}

#endif
