function [c,o] = matlab(n)
% 
% c = matlab( n=7, reorder=false )
%
% Default Matlab colors in 2016+
%
% See also: dk.cmap.jh 
%
% JH

    c = [ ... Default Matlab palette
             0    0.4470    0.7410 ; ...
        0.8500    0.3250    0.0980 ; ...
        0.9290    0.6940    0.1250 ; ...
        0.4940    0.1840    0.5560 ; ...
        0.4660    0.6740    0.1880 ; ...
        0.3010    0.7450    0.9330 ; ...
        0.6350    0.0780    0.1840   ...
    ];

    % reordering from purple/blue to orange/red
    o = [7 2 3 5 6 1 4];

    if nargin > 0
        c = interp1( (1:7)', c, linspace(1,7,n)' );
    end
    if nargout == 0, dk.cmap.show(c); end

end