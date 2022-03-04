function c = rdb2( n, signed )
%
% c = rdb2( n=64, signed=false )
%
% Variation on the rwb2 colormap with a dark centre instead of white.
% 
% See also: dk.cmap.rwb2
%
% JH

    if nargin < 1, n = 64; end
    if nargin < 2, signed = false; end
    
    method = 'linear';
    w = [0.9,0.5,0.2,0.5,0.9];
    r = dk.color.palette(hsv2rgb([0,.9,.8]),w);
    b = dk.color.palette(hsv2rgb([.6,.9,.8]),w);
    g = 0.1*[1 1 1];
    t = [0,.33,.66,1];
    
    if signed
        if mod(n,2)==0, n=n+1; end
        C = [ ...
            -t(4), b.darker; ...
            -t(3), b.normal; ...
            -t(2), b.lighter; ...
            -t(1), g; ...
            +t(2), r.lighter; ...
            +t(3), r.normal; ...
            +t(4), r.darker ...
        ];
        x = linspace(-1,1,n)';
    else
        C = [ ...
            -t(1), g; ...
            +t(2), r.lighter; ...
            +t(3), r.normal; ...
            +t(4), r.darker  ...
        ];
        x = linspace(0,1,n)';
    end

    c = interp1( C(:,1), C(:,2:4), x, method );
    if nargout == 0, dk.cmap.show(c); end

end
