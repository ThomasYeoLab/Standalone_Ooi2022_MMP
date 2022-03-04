function p = palette( c, w )
%
% p = palette( c, w=[0.8, 0.2, 0.2, 0.2, 0.8] )
%
% Create palette from input color.
% Output struct with fields:
%
%       Name    Transform 
%
%    darkest    shade(w(1))
%     darker    shade(w(2))
%     grayer    tone(w(3))
%     normal    -
%    lighter    tint(w(4))
%   lightest    tint(w(5))
% 
% See: https://www.viget.com/articles/tints-tones-shades
%
% JH
    
    if isscalar(c), c=hsv2rgb([c 1 1]); end
    if ischar(c), c=dk.color.hex2rgb(c); end
    assert( dk.is.rgb(c,1), 'Expected RGB color or hue in input.' );
    
    if nargin < 2, w=[0.8,0.2,0.2,0.2,0.8]; end
    
    p.darkest = dk.color.shade(c,w(1));
    p.darker = dk.color.shade(c,w(2));
    p.grayer = dk.color.tone(c,w(3));
    p.normal = c;
    p.lighter = dk.color.tint(c,w(4));
    p.lightest = dk.color.tint(c,w(5));
    
    % show palette if no output
    if nargout == 0
        figure;
        im = ones(75,100);
        f = fieldnames(p);
        im = dk.mapfun( @(ff) dk.bsx.mul(reshape(p.(ff),[1,1,3]),im), f, false );
        imshow(vertcat(im{:}));
    end

end
