#ifndef JMX_CONTAINER_H_INCLUDED
#define JMX_CONTAINER_H_INCLUDED

namespace jmx {

    class MAT : public AbstractMapping
    {
    public:

        MAT() 
            : mfile(nullptr)
            { clear(); }
        MAT( const char *name, const char *mode = "r" ) 
            : mfile(nullptr)
            { open(name); }

        ~MAT() { clear(); }

        void clear();
        bool open( const char *name, const char *mode = "r" );

        inline bool valid() const { return mfile; }
        inline const MATFile* mx() const { return mfile; }

        inline int set_value( const char *name, mxArray *value ) {
            m_fmap[name] = value;
            return set_variable( mfile, name, value );
        }

    private:

        MATFile *mfile;
    };

    // ----------  =====  ----------

    class Struct : public AbstractMapping
    {
    public:

        Struct()
            { clear(); }
        Struct( const mxArray* ms, index_t index = 0 )
            { wrap(ms,index); }

        void clear();
        bool wrap( const mxArray* ms, index_t index = 0 );
        inline const mxArray* mx() const { return mstruct; }

        inline int set_value( const char *name, mxArray *value ) {
            m_fmap[name] = value;
            return set_field( const_cast<mxArray*>(mstruct), name, value );
        }

        // for struct-arrays
        Struct& select( index_t k );

        inline Struct& select( index_t r, index_t c ) {
            JMX_ASSERT( is_matrix(), "Struct-array is not 2d." )
            return select( r + nrows()*c );
        }

        inline bool is_scalar() const { return numel()==1; }
        inline bool is_matrix() const { return ndims()==2; }
        inline bool is_array() const { return numel() > 1; }

        inline index_t  nfields () const { return mxGetNumberOfFields(mstruct); }
        inline index_t  numel   () const { return mxGetNumberOfElements(mstruct); }
        inline index_t  ndims   () const { return mxGetNumberOfDimensions(mstruct); }
        inline index_t  nrows   () const { return mxGetM(mstruct); }
        inline index_t  ncols   () const { return mxGetN(mstruct); }
        inline bool     empty   () const { return numel() == 0; }
        inline bool     valid   () const { return mstruct && mxIsStruct(mstruct); }
        inline operator bool    () const { return valid() && !empty(); }

    private:

        const mxArray *mstruct;
    };
    
    // ------------------------------------------------------------------------
    
    class Cell 
        : public Creator<index_t>, public Extractor<index_t>
    {
    public:

        Cell()
            { clear(); }
        Cell( const mxArray *ms )
            { wrap(ms); }

        inline void clear()
            { mcell = nullptr; }

        void wrap( const mxArray *ms );
        inline const mxArray* mx() const { return mcell; }
            
        inline index_t  numel () const { return mxGetNumberOfElements(mcell); }
        inline bool     empty () const { return numel() == 0; }
        inline bool     valid () const { return mcell && mxIsCell(mcell); }
        inline operator bool  () const { return valid() && !empty(); }

        inline mxArray* operator[] ( index_t index ) const { return get_value(index); }
        inline mxArray* get_value  ( index_t index ) const { return mxGetCell(mcell, index); }

        inline int set_value( index_t index, mxArray *value ) const {
            return set_cell( const_cast<mxArray*>(mcell), index, value );
        }

        // extractor/creator interface
        using key_t = Extractor<index_t>::key_t;
        using inptr_t = Extractor<index_t>::ptr_t;
        using outptr_t = Creator<index_t>::ptr_t;

        inline bool _extractor_valid_key( key_t k ) const { return k < numel(); }
        inline inptr_t _extractor_get( key_t k ) const { return get_value(k); }
        inline outptr_t _creator_assign( key_t k, outptr_t val ) { set_value(k,val); return val; }

    private: 

        const mxArray *mcell;
    };

}

#endif