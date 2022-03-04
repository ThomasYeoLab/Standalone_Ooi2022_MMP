
std::string get_string( const mxArray *ms ) 
{
    JMX_ASSERT( ms, "Null pointer." );
    JMX_ASSERT( mxIsChar(ms), "Input is not a string." );

    std::string val;
    val.resize( mxGetNumberOfElements(ms) );
    mxGetString( ms, &val[0], val.size()+1 );
    return val;
}
