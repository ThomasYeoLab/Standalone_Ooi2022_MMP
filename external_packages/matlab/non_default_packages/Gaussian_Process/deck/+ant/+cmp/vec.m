function val = vec( a, b, method )
%
% val = ant.cmp.vec( a, b, method )
%
% Compare two vectors using different measures:
%
%   sad
%   mad
%   ssd
%   rmsd
%   cos
%   cov
%   cor,corr
%
% Output is a scalar.
%
% See also: ant.cmp.mat
%
% JH

    assert( isvector(a) && isvector(b), 'Inputs should be vectors' );
    n = numel(a);
    assert( numel(b) == n, 'Size mismatch between inputs.' );
    
    % compare them
    switch lower(method)
        
        case 'sad'
            val = abs(a-b);
            val = sum(val);
        
        case 'mad'
            val = abs(a-b);
            val = sum(val)/n;
            
        case 'ssd'
            val = a-b;
            val = cdot(val,val);
            
        case 'rmsd'
            val = a-b;
            val = sqrt(cdot(val,val)/n);
            
        case 'cos'
            na = sqrt(cdot(a,a));
            nb = sqrt(cdot(b,b));
            val = dot(a,b) / (na*nb);
            
        case 'cov'
            val = cdot( demean(a), demean(b) )/(n-1);
            
        case {'cor','corr'}
            val = cdot( normalise(a), normalise(b) )/(n-1);
            
        otherwise
            error( 'Unknown metric: %s', method );
            
    end

end

function d = cdot(a,b)
    d = dot(a,conj(b));
end

function [y,m] = demean(x)
    m = sum(x)/numel(x);
    y = x-m;
end

function [y,m,s] = normalise(x)
    n = numel(x);
    m = sum(x)/n;
    y = x-m;
    s = sqrt(cdot(y,y)/(n-1));
    y = y/max(eps,s);
end
