function compile_cpp( comp, varargin )
    
    comp.mex_file = false;
    dk.mex.compile( comp, varargin{:} );

end
