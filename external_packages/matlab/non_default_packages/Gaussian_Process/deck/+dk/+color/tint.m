function c = tint( c, w )
%
% c = dk.color.tint( c, w=0.5 )
%
% Apply desired tint.
%
% JH

    if nargin < 2, w=0.5; end
    c = dk.color.proc( c, [1 1 1], w );
    
end
