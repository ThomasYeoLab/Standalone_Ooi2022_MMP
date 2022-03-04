function c = tone( c, w )
%
% c = dk.color.tone( c, w=0.5 )
%
% Apply desired tone.
%
% JH

    if nargin < 2, w=0.5; end
    c = dk.color.proc( c, 0.5*[1 1 1], w );

end
