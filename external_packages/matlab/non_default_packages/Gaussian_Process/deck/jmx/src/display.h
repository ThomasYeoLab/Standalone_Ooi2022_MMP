#ifndef JMX_DISPLAY_H_INCLUDED
#define JMX_DISPLAY_H_INCLUDED

//==================================================
// @title        display.h
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

#include <type_traits>
#include <stdexcept>
#include <iostream>
#include <iomanip>

// ------------------------------------------------------------------------

namespace jmx {

    inline unsigned& disp_intw() {
        static unsigned n = 4;
        return n;
    }

    inline unsigned& disp_floatw() {
        static unsigned n = 9;
        return n;
    }

    inline unsigned& disp_prec() {
        static unsigned n = 3;
        return n;
    }

    inline void disp_intw( unsigned n ) { disp_intw()=n; }
    inline void disp_floatw( unsigned n ) { disp_floatw()=n; }
    inline void disp_prec( unsigned n ) { disp_prec()=n; }
    
    // ----------  =====  ----------
    
    template <class T>
    typename std::enable_if< 
        std::is_floating_point<T>::value, 
        std::ostream& 
    >::type disp( std::ostream& os, T x ) {
        return os 
            << std::fixed 
            << std::setw(disp_floatw()) 
            << std::setprecision(disp_prec())
            << x;
    }

    template <class T>
    typename std::enable_if< 
        std::is_integral<T>::value, 
        std::ostream& 
    >::type disp( std::ostream& os, T x ) {
        return os 
            << std::fixed 
            << std::setw(disp_intw()) 
            << x;
    }    

    inline std::ostream& disp( std::ostream& os, bool x ) {
        static const char *b2s[2] = { "False", " True" };
        return os << b2s[x];
    }
    
    // ----------  =====  ----------
    
    template <class T, class M>
    std::ostream& operator<< ( std::ostream& os, const Vector<T,M>& vec )
    {
        const index_t n = vec.length();
        os << "[Vector " << n << "]: ";
        for ( index_t k=0; k < n; k++ ) 
            disp<T>(os,vec[k]) << ", ";
        return os << "\b\b \n";
    }

    template <class T, class M>
    std::ostream& operator<< ( std::ostream& os, const Matrix<T,M>& mat )
    {
        const index_t nr = mat.nrows();
        const index_t nc = mat.ncols();

        os << "[Matrix " << nr << "x" << nc << "]:";
        for ( index_t r=0; r < nr; ++r ) {
            os << "\n\t";
            for ( index_t c=0; c < nc; ++c ) 
                disp<T>(os,mat(r,c)) << ", ";
            os << "\b\b ";
        }
        return os << "\n";
    }

    template <class T, class M>
    std::ostream& operator<< ( std::ostream &os, const Volume<T,M>& vol ) 
    {
        const index_t nr = vol.nrows();
        const index_t nc = vol.ncols();
        const index_t ns = vol.nslabs();

        os << "[Volume " << nr << "x" << nc << "x" << ns << "]:";
        for ( index_t s=0; s < ns; ++s ) {
            os << "\n---------- slab " << s;
            for ( index_t r=0; r < nr; ++r ) {
                os << "\n\t";
                for ( index_t c=0; c < nc; ++c ) 
                    disp<T>(os,vol(r,c,s)) << ", ";
                os << "\b\b ";
            }
        }
        return os << "\n";
    }

    std::ostream operator<< ( std::ostream& os, const Struct& x );
    std::ostream operator<< ( std::ostream& os, const MAT& x );
    std::ostream operator<< ( std::ostream& os, const Cell& x );
}

#endif
