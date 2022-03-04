#ifndef JMX_COMMON_H_INCLUDED
#define JMX_COMMON_H_INCLUDED

//==================================================
// @title        common.h
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

#include "mex.h"
#include "mat.h"

#include <cstdio>
#include <cstdlib>
#include <cstdint>

#include <string>
#include <limits>
#include <utility>
#include <stdexcept>
#include <type_traits>
#include <initializer_list>

// ------------------------------------------------------------------------

// Assertions
static char jhm_msgbuf[JMX_MSGBUF_SIZE];

#define JMX_THROW( msg, args... ) \
    { sprintf( jhm_msgbuf, "::JMX-Exception:: " msg "\n", ##args ); throw std::runtime_error(jhm_msgbuf); }
#define JMX_WARN( msg, args... ) \
    { sprintf( jhm_msgbuf, "::JMX-Warning:: " msg "\n", ##args ); mexWarnMsgTxt(jhm_msgbuf); }

// exception by default
#define JMX_REJECT( cdt, msg, args... ) { if (cdt) JMX_THROW(msg,##args) }
#define JMX_ASSERT( cdt, msg, args... ) JMX_REJECT(!(cdt),msg,##args)

// warning
#define JMX_WREJECT( cdt, msg, args... ) { if (cdt) JMX_WARN(msg,##args) }
#define JMX_WASSERT( cdt, msg, args... ) JMX_WREJECT(!(cdt),msg,##args)

// return value
#define JMX_WREJECT_R( cdt, val, msg, args... ) { if (cdt) { JMX_WARN(msg,##args) return (val); } }
#define JMX_WASSERT_R( cdt, val, msg, args... ) JMX_WREJECT_R(!(cdt),val,msg,##args)

// return false
#define JMX_WREJECT_RF( cdt, msg, args... ) JMX_WREJECT_R((cdt),false,msg,##args)
#define JMX_WASSERT_RF( cdt, msg, args... ) JMX_WASSERT_R((cdt),false,msg,##args)

// ------------------------------------------------------------------------

// Detect keyboard interruptions with utIsInterruptPending()
// NOTE: requires compiling with -lut
#ifdef __cplusplus
    extern "C" bool utIsInterruptPending();
#else
    extern bool utIsInterruptPending();
#endif

namespace jmx_types {

    // short alias for initializer lists
    template <class T>
    using inilst = std::initializer_list<T>;

    // map Matlab types
    using index_t = mwIndex;
    using integ_t = mwSignedIndex;
    using real_t  = double;

    template <int C>
    struct mex2cpp
    {
        typedef void type;
    };

    template <> struct mex2cpp<mxLOGICAL_CLASS> { typedef bool type; };
    template <> struct mex2cpp<   mxINT8_CLASS> { typedef int8_t type; };
    template <> struct mex2cpp<  mxUINT8_CLASS> { typedef uint8_t type; };
    template <> struct mex2cpp<  mxINT16_CLASS> { typedef int16_t type; };
    template <> struct mex2cpp< mxUINT16_CLASS> { typedef uint16_t type; };
    template <> struct mex2cpp<  mxINT32_CLASS> { typedef int32_t type; };
    template <> struct mex2cpp< mxUINT32_CLASS> { typedef uint32_t type; };
    template <> struct mex2cpp<  mxINT64_CLASS> { typedef int64_t type; };
    template <> struct mex2cpp< mxUINT64_CLASS> { typedef uint64_t type; };
    template <> struct mex2cpp< mxSINGLE_CLASS> { typedef float type; };
    template <> struct mex2cpp< mxDOUBLE_CLASS> { typedef double type; };

    template <class T>
    struct cpp2mex
    {
        static const mxClassID classid;
    };
}

namespace jmx {

    using namespace jmx_types;
    
    // ----------  =====  ----------
    
    // Convenient printing functions
    template <typename ...Args>
    inline void print( const std::string& fmt, Args&&... args ) {
        mexPrintf( fmt.c_str(), std::forward<Args>(args)... );
    }

    template <typename ...Args>
    void println( std::string fmt, Args&&... args )
    {
        fmt += "\n"; 
        mexPrintf( fmt.c_str(), std::forward<Args>(args)... );
    }

    // force printing to console
    inline void flush_console() {
        // static mxArray *t = mxCreateDoubleScalar(std::numeric_limits<double>::epsilon());
        mexCallMATLAB(0, NULL, 0, NULL, "drawnow");
        // mexCallMATLAB(0, NULL, 1, &t, "pause");
    }

    // more intuitive alias
    inline bool interruption_pending() {
        return utIsInterruptPending();
    }
    
    // ----------  =====  ----------
    
    // see: https://stackoverflow.com/a/43205818/472610

    template <int M, class T, class = T>
    struct is_compatible 
        : std::false_type {};

    template <int M, class T>
    struct is_compatible<M, T, decltype(static_cast<T>( std::declval< mex2cpp<M>::type >() ))> 
        : std::true_type {};

    template <class T>
    inline bool isCompatible( const mxArray *ms ) {
        
        switch (mxGetClassID(ms))
        {
            case mxLOGICAL_CLASS:
                return std::is_same<bool,T>::value;

            case mxINT8_CLASS:
                return std::is_same<int8_t,T>::value;
            case mxINT16_CLASS:
                return std::is_same<int16_t,T>::value;
            case mxINT32_CLASS:
                return std::is_same<int32_t,T>::value;
            case mxINT64_CLASS:
                return std::is_same<int64_t,T>::value;

            case mxUINT8_CLASS:
                return std::is_same<uint8_t,T>::value;
            case mxUINT16_CLASS:
                return std::is_same<uint16_t,T>::value;
            case mxUINT32_CLASS:
                return std::is_same<uint32_t,T>::value;
            case mxUINT64_CLASS:
                return std::is_same<uint64_t,T>::value;

            case mxSINGLE_CLASS:
                return std::is_same<float,T>::value;
            case mxDOUBLE_CLASS:
                return std::is_same<double,T>::value;

            default:
                JMX_WARN( "Unknown class name: %s", mxGetClassName(ms) );
                return false;
        }
    }
    
    // ----------  =====  ----------
    
    inline bool isNumberLike( const mxArray *ms ) {
        return (mxIsNumeric(ms) || mxIsLogical(ms)) && !mxIsComplex(ms);
    }

}

#endif
