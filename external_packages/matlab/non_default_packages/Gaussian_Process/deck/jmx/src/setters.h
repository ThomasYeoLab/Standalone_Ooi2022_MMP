#ifndef JMX_SETTERS_H_INCLUDED
#define JMX_SETTERS_H_INCLUDED

//==================================================
// @title        setters.h
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

// ------------------------------------------------------------------------

namespace jmx {

    int set_field( mxArray *mxs, index_t index, const char *field, mxArray *value );

    inline int set_field( mxArray *mxs, const char *field, mxArray *value ) { 
        return set_field( mxs, 0, field, value ); 
    }

    int set_cell( mxArray *mxc, index_t index, mxArray *value );
    int set_variable( MATFile *mtf, const char *name, mxArray *value );

}

#endif
