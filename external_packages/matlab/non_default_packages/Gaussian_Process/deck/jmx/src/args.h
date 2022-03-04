#ifndef JMX_ARGS_H_INCLUDED
#define JMX_ARGS_H_INCLUDED

//==================================================
// @title        args.h
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

#include <iostream>
#include <functional>

// ------------------------------------------------------------------------

namespace jmx {

    /**
     * Simple vector wrapper, which returns nullptr outside of its range.
     * This is to avoid segfaults in Mex functions.
     */
    struct _mxInput
    {
        using val_t = const mxArray*;
        val_t *ptr;
        const index_t len;

        _mxInput( val_t ptr[], index_t len )
            : ptr(ptr), len(len) {}
        
        inline val_t operator[] ( index_t k ) const
            { return (k < len) ? ptr[k] : nullptr; }
    };

    struct _mxOutput
    {
        using val_t = mxArray*;
        val_t *ptr;
        const index_t len;

        _mxOutput( val_t ptr[], index_t len )
            : ptr(ptr), len(len) 
        {
            for ( index_t k = 0; k < len; ++k )
                ptr[k] = nullptr;
        }
        
        inline val_t operator[] ( index_t k ) const
        { 
            JMX_ASSERT( k < len, "Failed to access uncollected output." ); 
            return ptr[k];
        }

        inline val_t assign( index_t k, val_t val )
        {
            JMX_ASSERT( k < len, "Failed to assign uncollected output." ); 
            JMX_ASSERT( !ptr[k], "Cannot overwrite existing output." ); 
            return ptr[k] = val;
        }
    };
    
    struct Arguments 
        : public Creator<index_t>, public Extractor<index_t>
    {
        _mxOutput out;
        _mxInput in;

        using key_t = Extractor<index_t>::key_t;
        using inptr_t = Extractor<index_t>::ptr_t;
        using outptr_t = Creator<index_t>::ptr_t;

        // implement abstract methods
        inline bool _extractor_valid_key( key_t k ) const { return k < in.len; }
        inline inptr_t _extractor_get( key_t k ) const { return in[k]; }
        inline outptr_t _creator_assign( key_t k, outptr_t val ) { return out.assign(k,val); }
        
        // ----------  =====  ----------
        
        Arguments( 
            int nargout, mxArray *out[],
            int nargin, const mxArray *in[]
        ) : in(in,nargin), out(out,nargout) {}

        inline void verify( index_t inmin, index_t outmin ) {
            if ( in.len < inmin || out.len < outmin ) {
                std::cerr << "Expected at least " << inmin << " input(s) but got " << in.len << std::endl;
                std::cerr << "Expected at least " << outmin << " output(s) but got " << out.len << std::endl;
                JMX_THROW( "Bad i/o." );
            }
        }

        inline void verify( index_t inmin, index_t outmin, std::function<void()> usage ) {
            if ( in.len < inmin || out.len < outmin ) {
                usage();
                JMX_THROW( "Bad i/o; see usage above." );
            }
        }
    };

}

#endif
