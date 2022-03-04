
void AbstractMapping::clear() 
{
    m_fields.clear();
    m_fmap.clear();
}

bool AbstractMapping::has_any( const inilst<const char*>& names ) const
{
    for ( auto& name: names )
        if ( has_field(name) )
            return true;

    return false;
}

bool AbstractMapping::has_fields ( const inilst<const char*>& names ) const
{
    for ( auto& name: names ) 
        if ( !has_field(name) ) {
            println( "Field '%s' doesn't exist.", name );
            return false;
        }
    return true;
}
