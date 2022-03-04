
void MAT::clear() 
{
    if (mfile) matClose(mfile);

    mfile = nullptr;
    AbstractMapping::clear();
}

bool MAT::open( const char *name, const char *mode )
{
    clear();
    JMX_ASSERT( name, "Null filename." );

    MATFile *mf = matOpen( name, mode );
    JMX_ASSERT( mf, "Error opening file: %s", name );

    int nf = 0;
    const char **fnames = (const char**) matGetDir( mf, &nf );

    mfile = mf;
    this->m_fields.resize(nf);

    for ( int f = 0; f < nf; ++f ) {
        this->m_fields[f] = fnames[f];
        this->m_fmap[ this->m_fields[f] ] = matGetVariable( mf, fnames[f] );
    }

    return true;
}

// ------------------------------------------------------------------------

void Struct::clear()
{
    mstruct = nullptr;
    AbstractMapping::clear();
}

bool Struct::wrap( const mxArray* ms, index_t index )
{
    clear();
    JMX_ASSERT( ms, "Null pointer." );
    JMX_ASSERT( mxIsStruct(ms), "Input is not a structure." );
    mstruct = ms;

    const index_t nf = mxGetNumberOfFields(ms);
    this->m_fields.resize(nf);

    for ( index_t f = 0; f < nf; ++f ) {
        this->m_fields[f] = mxGetFieldNameByNumber(ms,f);
        this->m_fmap[ this->m_fields[f] ] = mxGetFieldByNumber(ms,index,f);
    }

    return true;
}

Struct& Struct::select( index_t k )
{
    const index_t nf = nfields();
    JMX_ASSERT( k < numel(), "Index out of bounds." )

    for ( index_t f = 0; f < nf; ++f )
        this->m_fmap[ this->m_fields[f] ] = mxGetFieldByNumber(mstruct,k,f);

    return *this;
}

// ------------------------------------------------------------------------

void Cell::wrap( const mxArray *ms ) 
{
    JMX_ASSERT( ms, "Null pointer." )
    JMX_ASSERT( mxIsCell(ms), "Input is not a cell." )
    mcell = ms;

    int nc = mxGetNumberOfElements(ms);
    JMX_WREJECT( mxGetNumberOfDimensions(ms) > 1, 
        "Multi-dimensional cells are not supported; wrapping input as vector-cell instead." )
}
