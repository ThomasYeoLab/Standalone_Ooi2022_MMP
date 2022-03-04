#ifndef JMX_REDIRECT_H_INCLUDED
#define JMX_REDIRECT_H_INCLUDED

//==================================================
// @title        redirect.h
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

#include <memory>
#include <iostream>
#include <streambuf>

// ------------------------------------------------------------------------

/**
 * These classes allow to redirect the standard output std::cout to the Matlab console.
 * They essentially replace the stream buffer of std::cout with a custom buffer.
 *
 * To enable the redirection _temporarily_, you just need to instanciate an object of
 * type sa::coutRedirection at the beginning of the scope in your code.
 *
 * If you want to redirect _permanently_ (until the end of execution), you can call
 * sa::cout_redirect() at the beginning of your main. Note that there is no way to 
 * restore the standard output after that.
 */
namespace jmx {

    class mexPrintf_ostream: public std::streambuf
    {
    protected:

        virtual inline std::streamsize xsputn( const char* s, std::streamsize n )
            { mexPrintf("%.*s", n, s); return n; }

        virtual inline int overflow( int c = EOF )
            { if (c != EOF) mexPrintf("%.1s", &c); return 1; }
    };

    class mexWarnMsgIdAndTxt_ostream: public std::streambuf
    {
    protected:

        virtual inline std::streamsize xsputn( const char* s, std::streamsize n )
            { mexWarnMsgIdAndTxt("JMX::Error", "%.*s", n, s); return n; }

        virtual inline int overflow( int c = EOF )
            { if (c != EOF) mexPrintf("%.1s", &c); return 1; }
    };

    // ------------------------------------------------------------------------

    template <class B = mexPrintf_ostream>
    class coutRedirection
    {
    public:

        typedef B buffer_type;

        coutRedirection()
            { enable(); }
        ~coutRedirection()
            { disable(); }

    protected:

        std::streambuf *m_backup;
        buffer_type m_buf;

        inline void enable()
            { m_backup = std::cout.rdbuf( &m_buf ); }
        inline void disable()
            { flush_console(); std::cout.rdbuf( m_backup ); }
    };

    template <class B = mexWarnMsgIdAndTxt_ostream>
    class cerrRedirection
    {
    public:

        typedef B buffer_type;

        cerrRedirection()
            { enable(); }
        ~cerrRedirection()
            { disable(); }

    protected:

        std::streambuf *m_backup;
        buffer_type m_buf;

        inline void enable()
            { m_backup = std::cerr.rdbuf( &m_buf ); }
        inline void disable()
            { flush_console(); std::cerr.rdbuf( m_backup ); }
    };

    // ------------------------------------------------------------------------

    void cout_redirect( bool status=true );
    void cerr_redirect( bool status=true );

}

#endif
