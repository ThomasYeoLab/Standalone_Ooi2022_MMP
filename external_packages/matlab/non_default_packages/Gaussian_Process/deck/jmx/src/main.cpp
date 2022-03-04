
//==================================================
// @title        J.H. Mex Library
// @author       Jonathan Hadida
// @contact      Jhadida87 [at] gmail
//==================================================

#include "main.h"

// ------------------------------------------------------------------------

namespace jmx_types {

    template<> const mxClassID cpp2mex<bool>::classid      = mxLOGICAL_CLASS;
    template<> const mxClassID cpp2mex<int8_t>::classid    = mxINT8_CLASS;
    template<> const mxClassID cpp2mex<uint8_t>::classid   = mxUINT8_CLASS;
    template<> const mxClassID cpp2mex<int16_t>::classid   = mxINT16_CLASS;
    template<> const mxClassID cpp2mex<uint16_t>::classid  = mxUINT16_CLASS;
    template<> const mxClassID cpp2mex<int32_t>::classid   = mxINT32_CLASS;
    template<> const mxClassID cpp2mex<uint32_t>::classid  = mxUINT32_CLASS;
    template<> const mxClassID cpp2mex<int64_t>::classid   = mxINT64_CLASS;
    template<> const mxClassID cpp2mex<uint64_t>::classid  = mxUINT64_CLASS;
    template<> const mxClassID cpp2mex<float>::classid     = mxSINGLE_CLASS;
    template<> const mxClassID cpp2mex<double>::classid    = mxDOUBLE_CLASS;
    
}

// ------------------------------------------------------------------------

namespace jmx {

    #include "redirect.cpp"
    #include "setters.cpp"
    #include "getters.cpp"
    #include "mapping.cpp"
    #include "container.cpp"
    
}
