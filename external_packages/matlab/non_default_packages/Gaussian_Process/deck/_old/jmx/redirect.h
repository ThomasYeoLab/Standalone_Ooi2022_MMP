#ifndef REDIRECT_H_INCLUDED
#define REDIRECT_H_INCLUDED

//==================================================
// @title        redirect.h
// @author       Jonathan Hadida
// @contact      Jhadida [at] fmrib.ox.ac.uk
//==================================================

#include "mex.h"

#include <streambuf>
#include <iostream>
#include <cstdio>
#include <memory>



		/********************     **********     ********************/
		/********************     **********     ********************/



namespace sa {

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

class mexPrintf_output
	: public std::streambuf
{
protected:

	virtual inline std::streamsize xsputn( const char* s, std::streamsize n )
		{ mexPrintf("%.*s", n, s); return n; }

	virtual inline int overflow( int c = EOF )
		{ if (c != EOF) mexPrintf("%.1s", &c); return 1; }
};

// ------------------------------------------------------------------------

template <class B = mexPrintf_output>
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
		{ std::cout.rdbuf( m_backup ); }
};

// ------------------------------------------------------------------------

inline void cout_redirect( bool do_it = true )
{
	static std::unique_ptr< coutRedirection<mexPrintf_output> > r;

	if ( do_it && !r )
		r.reset( new coutRedirection<mexPrintf_output>() );

	if ( !do_it )
		r.reset();
}

} // end namespace
#endif 