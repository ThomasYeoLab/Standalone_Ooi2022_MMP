function compile_mex( comp, varargin )

    if nargin == 1 && ischar(comp)
        dk.mex.compile( dk.mex.compiler(), comp );
    else
        comp.mex_file = true;
        dk.mex.compile( comp, varargin{:} );
    end
    
end
