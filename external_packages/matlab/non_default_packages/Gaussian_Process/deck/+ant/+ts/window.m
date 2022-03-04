function [w,h] = window( name, len, varargin )
%
% [win,handle] = ant.ts.window( name, len, varargin )
%
% List of available windows in Matlab.
% If inputs and outputs are omitted, the function displays all windows in a figure.
%
% JH

    if nargin*nargout == 0
        show_all(); return
    end

    switch lower(name)

        case 'barthann'
            h = @barthannwin;
        case 'bartlett'
            h = @bartlett;
        case 'blackman'
            h = @blackman;
        case 'blackmanharris'
            h = @blackmanharris;
        case 'bohman'
            h = @bohmanwin;
        case {'cheby','chebyshev'}
            h = @chebwin;
        case {'gauss','gaussian'}
            h = @gausswin;
        case 'hamming'
            h = @hamming;
        case 'hann'    
            h = @hann;
        case 'hanning'
            h = @hanning;
        case 'kaiser'
            h = @kaiser;
        case 'nuttall'
            h = @nuttallwin;
        case 'parzen'
            h = @parzenwin;
        case {'rect','rectangle'}
            h = @rectwin;
        case {'triang','triangle'}
            h = @triang;
        case 'tukey'
            h = @tukeywin;
            
        otherwise 
            error('Unknown window "%s".',name);

    end
    
    w = h( len, varargin{:} );
    
end

function show_all()

    names = { ...
        'barthann', 'bartlett', 'blackman', 'blackmanharris', 'bohman', 'cheby', ...
        'gauss', 'hamming', 'hann', 'hanning', 'kaiser', 'nuttall', 'parzen', 'tukey'
    };

    L = 100;
    n = numel(names);
    x = linspace(0,1,L);
    
    [h,w] = dk.gridfit(n);

    figure;
    for i = 1:n
        subplot(h,w,i); name = names{i};
        plot( x, ant.ts.window(name,L) ); title(name);
    end

end
