#ifndef SLIDING_WINDOW_H_INCLUDED
#define SLIDING_WINDOW_H_INCLUDED

//==================================================
// @title        sliding_window.h
// @author       Jonathan Hadida
// @contact      Jhadida [at] fmrib.ox.ac.uk
//==================================================

#include "jmx.h"
#include <algorithm>
using namespace jmx_types;



		/********************     **********     ********************/
		/********************     **********     ********************/



/**
 * A simple left-aligned, valid-only, forward-sliding window.
 */
struct SlidingWindow
{
public:

	typedef SlidingWindow self;

	SlidingWindow()
		{ clear(); }

	void clear();
	bool configure( index_t signal_size, index_t wlen, index_t wstep =1, index_t wburn =0 );

	// Number of windows and index of current window
	inline index_t nw() const { return 1 + (m_ntpts - (m_wburn+m_wsize))/m_wstep; }
	inline index_t cw() const { return m_curw; }

	// Index of first and last element in window w
	inline index_t first () const { return first (cw()); }
	inline index_t last  () const { return last  (cw()); }
	//
	inline index_t first ( index_t w ) const { return m_wburn + w*m_wstep; }
	inline index_t last  ( index_t w ) const { return first(w) + m_wsize-1; }


	//-------------------------------------------------------------
	// Sliding methods
	//-------------------------------------------------------------

	// Reset the window while preserving the config
	inline void reset() { m_curw = 0; }

	// Is the sliding window valid?
	inline bool    empty() const { return m_wsize == 0; }
	inline bool    valid() const { return (m_wstep > 0) && (cw() < nw()); }
	inline operator bool() const { return valid() && !empty(); }

	// Slide forward/backward
	inline self& operator +=( index_t n ) { m_curw += n; return *this; }
	inline self& operator -=( index_t n ) { m_curw -= std::min( n, m_curw ); return *this; }

	inline self& operator ++() { return operator+=(1); }
	inline self& operator --() { return operator-=(1); }

private:

	index_t m_ntpts, m_wsize, m_wstep, m_wburn;
	index_t m_index, m_curw;
};

#endif
