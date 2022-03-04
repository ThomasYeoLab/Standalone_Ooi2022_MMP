
//==================================================
// @title        sliding_window.cpp
// @author       Jonathan Hadida
// @contact      Jhadida [at] fmrib.ox.ac.uk
//==================================================

#include "sliding_window.h"



		/********************     **********     ********************/
		/********************     **********     ********************/



void SlidingWindow::clear()
{
	m_ntpts = m_wsize = m_wstep = m_wburn = 0;
	m_index = m_curw = 0;
}

// ------------------------------------------------------------------------

bool SlidingWindow::configure( index_t signal_size, index_t wsize, index_t wstep, index_t wburn )
{
	JMX_WASSERT_RF( wsize > 0, "Window size should be posiive." );
	JMX_WASSERT_RF( wstep > 0, "Window step should be positive." );
	JMX_WASSERT_RF( (wburn + wsize) <= signal_size, "Window parameters incompatible with number of timepoints." );

	m_ntpts = signal_size;
	m_wsize = wsize;
	m_wstep = wstep;
	m_wburn = wburn;

	m_index = 0;
	m_curw  = 0;

	return true;
}
