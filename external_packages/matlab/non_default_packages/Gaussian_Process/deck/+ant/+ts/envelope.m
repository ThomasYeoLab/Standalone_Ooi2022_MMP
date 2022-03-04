function [lo,up] = envelope( x, thr )
%
% [lo,up] = ant.ts.envelope( x, thresh=std(x)/1e5 )
%
% Lower and upper envelope interpolation using PCHIP.
% Works fine even if input has no extremum.
%
% Theshold can be used to ignore extrema with small differences.
%
% NOTE: this is NOT the Hilbert envelope!
%
% See also: ant.ts.extrema
%
% JH

    if nargin < 2, thr=std(x,[],1)/1e5; end
    
    assert( ismatrix(x), 'Expected input time-series as TxN matrix.' );
    [nt,ns] = size(x);
    if isscalar(thr), thr=thr*ones(1,ns); end
    
    % allocate output
    lo = zeros(nt,ns);
    up = zeros(nt,ns);
    t = transpose(1:nt);
    
    for i = 1:ns
    
        xi = x(:,i);
        
        % local extrema
        [lmin,lmax] = ant.ts.extrema( xi, thr(i) );

        % padded interpolation is more stable at the boundaries
        lo(:,i) = padded_interp(lmin,xi,t);
        up(:,i) = padded_interp(lmax,xi,t);
        
    end
    
end

function p = padded_interp(k,x,t)
    % NOTE
    %
    % Because this is tied to the emd.local_extrema implementation, we know that:
    %   - k is not empty
    %   - if k has more than 1 index, then it does not contain the first and last points
    %
    n = numel(x);
    if numel(k) == 1
        p = x(k) * ones(n,1);
    else
        v = x(k([ 1, 1:end, end ]));
        k = [ 1; k; n ];
        p = interp1( k, v, t, 'pchip' );
    end
end
