function c = mix( c1, c2, w )
%
% c = dk.color.mix( c1, c2, w=0.5 )
%
% Mix input colors with weight w.
%
% JH

    if nargin < 3, w=0.5; end
    assert( dk.is.rgb(c1) && dk.is.rgb(c2), 'Expected RGB colors in input.' );
    c = dk.bsx.add( (1-w)*c1, w*c2 );

end
