
int set_field( mxArray *mxs, index_t index, const char *field, mxArray *value )
{
    JMX_ASSERT( mxs, "Null pointer." );
    JMX_ASSERT( mxIsStruct(mxs), "Input is not a struct." );

    // try to find the corresponding field
    int fnum = mxGetFieldNumber( mxs, field );

    // the field exists, check if there is something there
    if ( fnum >= 0 )
    {
        mxArray *fval = mxGetFieldByNumber( mxs, index, fnum );

        // there is something, so delete it first
        if ( fval ) mxDestroyArray( fval );
    }
    else // the field doesn't exist, so create it
    {
        fnum = mxAddField( mxs, field );
    }

    // set the value now
    mxSetField( mxs, index, field, value );

    return fnum;
}

int set_cell( mxArray *mxc, index_t index, mxArray *value )
{
    JMX_ASSERT( mxc, "Null pointer." );
    JMX_ASSERT( mxIsCell(mxc), "Input is not a cell." );

    mxSetCell( mxc, index, value );
    return 0; // mxSetCell doesn't return a status...
}

int set_variable( MATFile *mtf, const char *name, mxArray *value )
{
    JMX_ASSERT( mtf, "Null pointer." );
    return matPutVariable( mtf, name, value );
}
