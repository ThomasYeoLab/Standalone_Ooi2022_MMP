
void cout_redirect( bool status )
{
    static std::unique_ptr< coutRedirection<mexPrintf_ostream> > r;

    if ( status && !r )
        r.reset( new coutRedirection<mexPrintf_ostream>() );

    if ( !status )
        r.reset();
}

void cerr_redirect( bool status )
{
    static std::unique_ptr< cerrRedirection<mexWarnMsgIdAndTxt_ostream> > r;

    if ( status && !r )
        r.reset( new cerrRedirection<mexWarnMsgIdAndTxt_ostream>() );

    if ( !status )
        r.reset();
}
