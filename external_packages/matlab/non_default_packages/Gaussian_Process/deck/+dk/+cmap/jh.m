function c = jh(n,varargin)
 %
 % c = dk.cmap.jh(n=7)
 %
 % My own colormap, based on Matlab's 2016+ defaults.
 %
 % Goes from blue to red, through green.
 % Behaves "well" for values of n<7.
 %
 % See also: dk.cmap.matlab
 %
 % JH
 
    c = [ ...
        0.0780    0.1840    0.6350 ; ...
             0    0.4470    0.7410 ; ...
        0.3010    0.7450    0.9330 ; ...
        0.4660    0.6740    0.1880 ; ...
        0.9290    0.6940    0.1250 ; ...
        0.8500    0.3250    0.0980 ; ...
        0.6350    0.0780    0.1840 ; ...
     ];

    if nargin > 0
    switch n
        case 1
            c = c(2,:);
        case 2
            c = c([2,7],:);
        case 3
            c = c([2,5,7],:);
        case 4
            c = c([2,5,4,7],:);
            %c = c([5,4,7,2],:);
        case 5
            c = c([2,4,5,6,7],:);
        case 6
            c = c([1,2,4,5,6,7],:);
        case 7
            % nothing to do
        otherwise
            c = interp1( (1:7)', c, linspace(1,7,n)' );
    end
    end
    
    if nargout == 0, dk.cmap.show(c); end

end