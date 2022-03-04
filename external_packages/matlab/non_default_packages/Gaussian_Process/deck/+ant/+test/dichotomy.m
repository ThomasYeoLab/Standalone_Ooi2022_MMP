function [best,step] = dichotomy( value, range, varargin )
%
% [best,step] = dk.test.dichotomy( value, range, varargin )
%
% Default range is value + [-1,1]
% Additional inputs are forwarded to ant.math.dichotomy
%
% See also: ant.math.dichotomy
%
% JH

    if nargin == 0
        
        [b,s] = dk.test.dichotomy( pi );
        dk.test.assert( abs(b-pi) <= s, 'T1: ok', 'T1: value not found' );
        
        [b,s] = dk.test.dichotomy( pi, [1,0], 1e-3, 3*[1,1] );
        dk.test.assert( abs(b-pi) <= s, 'T2-1: ok', 'T2-1: value not found' );
        dk.test.assert( s < 1e-3, 'T2-2: ok', 'T2-2: precision not achieved' );
                
        try
            dk.test.dichotomy( pi, [1,0], 1e-3 );
            error( 'T3: call should not have succeeded.' );
        catch
            dk.print( 'T3: ok' );
        end
        
        return;
        
    end


    if nargin < 2, range = value + [-1,1]; end
    assert( dk.is.number(value), 'Search value should be a number.' );
    
    [best,step] = ant.math.dichotomy( @(x) value > x, range, varargin{:} );

end
