function c = shade( c, w )
%
% c = dk.color.shade( c, w=0.5 )
%
% Apply desired shade.
%
% JH

    if nargin < 2, w=0.5; end
    c = dk.color.proc( c, [0 0 0], w );

end
