#ifndef JMX_FORWARD_H_INCLUDED
#define JMX_FORWARD_H_INCLUDED

namespace jmx {

    /**
     * The following definitions were forwarded from files:
     *      getters.h
     *      extractor.h
     *      creator.h
     * 
     * to allow mappable types (see mapping.h/Abstract) to implement
     * the Extractor / Creator interfaces. Since Struct is a mappable
     * type itself, the following functions/methods could not be implemented
     * before its full definition.
     * 
     * This is a bit of a mind-bending inheritance dependency; 
     * it's not pretty, but it works.
     */
    
    inline Struct get_struct( const mxArray *ms, index_t index ) {
        return Struct(ms, index);
    }

    template <class K>
    inline Struct Extractor<K>::getstruct( key_t k, index_t i ) const
        { return get_struct( _extractor_get(k), i ); }

    template <class K>
    inline Struct Creator<K>::mkstruct( key_t k, index_t nr, index_t nc ) {
        return Struct( _creator_assign(k, make_struct(nr,nc)) );
    }

    template <class K>
    inline Struct Creator<K>::mkstruct( key_t k )
        { return mkstruct(k,1,1); }

    template <class K>
    inline Struct Creator<K>::mkstruct( key_t k, inilst<const char*> fields, index_t nr, index_t nc ) {
        return Struct( _creator_assign(k, make_struct( fields, nr, nc )) );
    }

    template <class K>
    inline Struct Creator<K>::mkstruct( key_t k, inilst<const char*> fields )
        { return mkstruct(k,fields,1,1); }
    
    // ------------------------------------------------------------------------
    
    inline Cell get_cell( const mxArray *ms ) {
        return Cell(ms);
    }

    template <class K>
    inline Cell Extractor<K>::getcell( key_t k ) const
        { return get_cell(_extractor_get(k)); }

    template <class K>
    inline Cell Creator<K>::mkcell( key_t k, index_t len ) {
        return Cell( _creator_assign(k, make_cell( len )) );
    }

}

#endif