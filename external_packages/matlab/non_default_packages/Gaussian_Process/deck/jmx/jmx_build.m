function jmx_build(varargin)
%
% jmx_build(varargin)
% 
% Build the JMX binaries.
% Settings can be supplied (see jmx_compile for help).
%
% See also: jmx_compile, jmx
%
% JH

    opt.mex = false;
    opt.cpp11 = true;
    opt.optimise = true;
    
    jmx_compile( jmx_path('src/main.cpp'), opt, 'lib', 'ut', varargin{:} );
    movefile( jmx_path('src/main.o'), jmx_path('inc/jmx.o') );
    
end