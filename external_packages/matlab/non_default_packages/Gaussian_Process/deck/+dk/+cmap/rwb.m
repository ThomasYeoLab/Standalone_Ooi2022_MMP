function c = rwb( n, signed )
%
% c = rwb( n=64, signed=false )
%
% Basic red-white-blue colormap.
% Default number of colors is 64, from white to red.
%
% In the unsigned case, the values go from white to red.
% In the signed case, the negative part is from blue to red.
%
% See also: dk.cmap.rwb2
%
% JH

    if nargin < 1, n = 64; end
    if nargin < 2, signed = false; end
    
    method = 'linear';
    w = [0.9,0.6,0.2,0.2,0.9];
    r = dk.color.palette(0,w);
    b = dk.color.palette(0.6,w);
    g = 0.9*[1 1 1];
    
    t = [0,.10,.45,.65,1];
    
    if signed
        if mod(n,2)==0, n=n+1; end
        C = [ ...
            -t(5), b.darker; ...
            -t(4), b.normal; ...
            -t(3), b.lighter; ...
            -t(2), b.lightest; ...
            -t(1), g; ...
            +t(2), r.lightest; ...
            +t(3), r.lighter; ...
            +t(4), r.normal; ...
            +t(5), r.darker ...
        ];
        x = linspace(-1,1,n)';
    else
        C = [ ...
            -t(1), g; ...
            +t(2), r.lightest; ...
            +t(3), r.lighter; ...
            +t(4), r.normal; ...
            +t(5), r.darker  ...
        ];
        x = linspace(0,1,n)';
    end

    c = interp1( C(:,1), C(:,2:4), x, method );
    if nargout == 0, dk.cmap.show(c); end

end
