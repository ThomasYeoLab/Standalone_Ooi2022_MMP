function [y,ty] = smooth( x, tx, varargin )
%
% [y,ty] = ant.ts.smooth( x, tx, ... )
%
%   Wrapper for Matlab's smooth function, accepting complex-valued inputs.
%   All options are forwarded to smooth.
%
%
% See also: smooth
%
% JH

    [x,tx] = dk.formatmv(x,tx,'vertical');
    
    % use timepoints only if input is not arithmetically sampled
    ari = ant.priv.is_arithmetic(tx);
    ty = tx;
    
    % smoothing function
    if isreal(x)
        
        if ari
            y = smooth( x, varargin{:} );
        else
            y = smooth( tx, x, varargin{:} );
        end
        
    else
        
        phi = angle(x);
        if ari
            mag = smooth( abs(x), varargin{:} );
            cp = smooth( cos(phi), varargin{:} );
            sp = smooth( sin(phi), varargin{:} );
            y = mag .* (cp + 1i*sp);
        else
            mag = smooth( tx, abs(x), varargin{:} );
            cp = smooth( tx, cos(phi), varargin{:} );
            sp = smooth( tx, sin(phi), varargin{:} );
            y = mag .* (cp + 1i*sp);
        end
        
    end

end