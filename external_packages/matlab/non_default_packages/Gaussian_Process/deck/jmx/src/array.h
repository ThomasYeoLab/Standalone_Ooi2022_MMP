#ifndef JMX_ARRAY_H_INCLUDED
#define JMX_ARRAY_H_INCLUDED

//==================================================
// @title        array.h
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

#include "memory.h"
#include <type_traits>
#include <algorithm>

// ------------------------------------------------------------------------

namespace jmx {

    template <class T, class M >
    struct Array
    {
        static_assert( !std::is_const<T>::value, "Data type cannot be const." );
        using value_type = typename M::value_type;

        M mem;
        virtual void clear() =0;
        virtual index_t ndims() const =0;

        inline value_type* memptr() const { return mem.data; }
        inline index_t memlen() const { return mem.size; }

        inline index_t numel() const { return memlen(); }
        inline void free() { mem.free(); clear(); }
        inline value_type& operator[] ( index_t k ) const { return mem.data[k]; }
    };
    
    // ----------  =====  ----------
    
    template <class T, class M = CppMemory<T> >
    struct Vector : public Array<T,M>
    {
        using value_type = typename M::value_type;
        index_t n;

        Vector()
            { clear(); }
        Vector( index_t len )
            { alloc(len); }
        Vector( value_type *ptr, index_t len )
            { assign(ptr,len); }

        inline index_t ndims() const { return 1; }
        inline index_t length() const { return n; }

        inline void clear()
            { this->mem.clear(); n = 0; }
        inline void assign( value_type *ptr, index_t len )
            { this->mem.assign(ptr,len); n=len; }
        inline void alloc( index_t len )
            { this->mem.alloc(len); n=len; }
    };

    template <class T> using Vector_ro = Vector<T, ReadOnlyMemory<T> >;
    template <class T> using Vector_mx = Vector<T, MatlabMemory<T> >;

    // ----------  =====  ----------

    template <class T, class M = CppMemory<T> >
    struct Matrix : public Array<T,M>
    {
        using value_type = typename M::value_type;
        index_t nr, nc;

        Matrix()
            { clear(); }
        Matrix( index_t nrows, index_t ncols )
            { alloc(nrows,ncols); }
        Matrix( value_type *ptr, index_t nrows, index_t ncols )
            { assign(ptr,nrows,ncols); }

        inline index_t ndims() const { return 2; }
        inline index_t nrows() const { return nr; }
        inline index_t ncols() const { return nc; }

        inline void clear()
            { this->mem.clear(); nr = nc = 0; }
        inline void assign( value_type *ptr, index_t nrows, index_t ncols )
            { this->mem.assign(ptr,nrows*ncols); nr=nrows; nc=ncols; }
        inline void alloc( index_t nrows, index_t ncols )
            { this->mem.alloc(nrows*ncols); nr=nrows; nc=ncols; }

        inline value_type& operator() ( index_t r, index_t c ) const
            { return this->mem[ r + nr*c ]; }
    };

    template <class T> using Matrix_ro = Matrix<T, ReadOnlyMemory<T> >;
    template <class T> using Matrix_mx = Matrix<T, MatlabMemory<T> >;

    // ----------  =====  ----------

    template <class T, class M = CppMemory<T> >
    struct Volume : public Array<T,M>
    {
        using value_type = typename M::value_type;
        index_t nr, nc, ns;

        Volume()
            { clear(); }
        Volume( index_t nrows, index_t ncols, index_t nslabs )
            { alloc(nrows,ncols,nslabs); }
        Volume( value_type *ptr, index_t nrows, index_t ncols, index_t nslabs )
            { assign(ptr,nrows,ncols,nslabs); }

        inline index_t ndims() const { return 3; }
        inline index_t nrows() const { return nr; }
        inline index_t ncols() const { return nc; }
        inline index_t nslabs() const { return ns; }
        inline index_t nslices() const { return ns; }

        inline void clear()
            { this->mem.clear(); nr = nc = ns = 0; }
        inline void assign( value_type *ptr, index_t nrows, index_t ncols, index_t nslabs )
            { this->mem.assign(ptr,nrows*ncols*nslabs); nr=nrows; nc=ncols; ns=nslabs; }
        inline void alloc( index_t nrows, index_t ncols, index_t nslabs )
            { this->mem.alloc(nrows*ncols*nslabs); nr=nrows; nc=ncols; ns=nslabs; }

        inline value_type& operator() ( index_t r, index_t c, index_t s ) const
            { return this->mem[ r + nr*c + nr*nc*s ]; }
    };

    template <class T> using Volume_ro = Volume<T, ReadOnlyMemory<T> >;
    template <class T> using Volume_mx = Volume<T, MatlabMemory<T> >;

}

#endif
