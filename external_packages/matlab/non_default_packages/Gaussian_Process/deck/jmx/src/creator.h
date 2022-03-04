#ifndef JMX_CREATOR_H_INCLUDED
#define JMX_CREATOR_H_INCLUDED

//==================================================
// @title        creator.h
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

#include <string>

// ------------------------------------------------------------------------

namespace jmx {
    
    template <class Key>
    struct Creator
    {
        using key_t = Key;
        using ptr_t = mxArray*;

        // methods to be defined
        // the pointer returned should be val (to be wrapped)
        virtual ptr_t _creator_assign( key_t k, ptr_t val ) =0;

        // forward declarations (see forward.h)
        Cell mkcell( key_t k, index_t len );
        Struct mkstruct( key_t k, inilst<const char*> fields, index_t nr, index_t nc );
        Struct mkstruct( key_t k, inilst<const char*> fields );
        
        Struct mkstruct( key_t k, index_t nr, index_t nc );
        Struct mkstruct( key_t k );

        // ----------  =====  ----------

        // void setters
        inline ptr_t mkbool( key_t k, bool val )
            { return _creator_assign(k, make_logical(val)); }

        inline ptr_t mkstr( key_t k, const std::string& val )
            { return _creator_assign(k, make_string(val)); }

        template <class T = real_t>
        inline ptr_t mknum( key_t k, const T& val )
            { return _creator_assign(k, make_scalar<T>(val)); }


        // setters with access
        template <class T = real_t>
        inline Vector_mx<T> mkvec( key_t k, index_t len, bool col=false ) { 
            ptr_t pk = _creator_assign(k, make_vector( len, col, cpp2mex<T>::classid )); 
            return Vector_mx<T>( static_cast<T*>(mxGetData(pk)), len );
        }

        template <class T = real_t>
        inline Matrix_mx<T> mkmat( key_t k, index_t nr, index_t nc ) {
            ptr_t pk = _creator_assign(k, make_matrix( nr, nc, cpp2mex<T>::classid )); 
            return Matrix_mx<T>( static_cast<T*>(mxGetData(pk)), nr, nc );
        }

        template <class T = real_t>
        inline Volume_mx<T> mkvol( key_t k, index_t nr, index_t nc, index_t ns ) {
            ptr_t pk = _creator_assign(k, make_volume( nr, nc, cpp2mex<T>::classid )); 
            return Volume_mx<T>( static_cast<T*>(mxGetData(pk)), nr, nc, ns );
        }
        
    };

}

#endif
