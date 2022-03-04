#ifndef JMX_MAKERS_H_INCLUDED
#define JMX_MAKERS_H_INCLUDED

//==================================================
// @title        makers.h
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

#include <string>

// ------------------------------------------------------------------------

namespace jmx {

    template <class T>
    inline mxArray* make_scalar( const T& val ) {
        return mxCreateDoubleScalar(static_cast<double>(val));
    }

    inline mxArray* make_logical( bool val ) {
        return mxCreateLogicalScalar(val);
    }

    inline mxArray* make_string( const std::string& val ) {
        return mxCreateString( val.c_str() );
    }

    inline mxArray* make_matrix( index_t nr, index_t nc, mxClassID classid=mxDOUBLE_CLASS ) {
        return mxCreateNumericMatrix( nr, nc, classid, mxREAL );
    }

    inline mxArray* make_vector( index_t len, bool column=false, mxClassID classid=mxDOUBLE_CLASS )
    {
        if (column)
            return make_matrix( len, 1, classid );
        else
            return make_matrix( 1, len, classid );
    }

    inline mxArray* make_volume( index_t nr, index_t nc, index_t ns, mxClassID classid=mxDOUBLE_CLASS ) {
        index_t size[3] = {nr,nc,ns};
        return mxCreateNumericArray( 3, size, classid, mxREAL );
    }

    inline mxArray* make_cell( index_t nc ) {
        return mxCreateCellMatrix( 1, nc );
    }

    inline mxArray* make_struct( index_t nrows=1, index_t ncols=1 ) { 
        return mxCreateStructMatrix( nrows, ncols, 0, nullptr ); 
    }

    inline mxArray* make_struct( const char *fields[], index_t nfields, index_t nrows=1, index_t ncols=1 ) { 
        return mxCreateStructMatrix( nrows, ncols, nfields, (const char**) fields ); 
    }

    inline mxArray* make_struct( inilst<const char*> fields, index_t nrows=1, index_t ncols=1 ) {
        return mxCreateStructMatrix( nrows, ncols, fields.size(), const_cast<const char**>(fields.begin()) );
    }

}

#endif
