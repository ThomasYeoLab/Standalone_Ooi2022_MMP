function val = cols( a, b, method )
%
% val = ant.cmp.cols( a, b, method )
%
% Compare two sets of column vectors using different measures:
%
%   sad
%   mad
%   ssd
%   rmsd
%   cos
%   cov
%   cor,corr
%
% Output is a 1xC vector where C is the number of columns.
%
% See also: ant.cmp.vec, ant.cmp.mat
%
% JH

    assert( ismatrix(a) && ismatrix(b), 'Bad inputs' );
    sa = size(a);
    sb = size(b);
    assert( all(sa > 1) && all(sa == sb), 'Inputs should be matrices of the same size.' );
    
    n = size(a,1);
    
    % compare them
    switch lower(method)
        
        case 'sad'
            val = abs(a-b);
            val = sum(val,1);
        
        case 'mad'
            val = abs(a-b);
            val = sum(val,1)/n;
            
        case 'ssd'
            val = a-b;
            val = cdot(val,val);
            
        case 'rmsd'
            val = a-b;
            val = sqrt(cdot(val,val)/n);
            
        case 'cos'
            val = col(a,b);
            
        case 'cov'
            val = cdot( demean(a), demean(b) )/(n-1);
            
        case {'cor','corr'}
            val = cos( demean(a), demean(b) );
            
        otherwise
            error( 'Unknown metric: %s', method );
            
    end

end

function d = cdot(a,b)
    d = dot(a,conj(b),1);
end

function c = cos(a,b)
    na = sqrt(cdot(a,a));
    nb = sqrt(cdot(b,b));
    c = dot(a,b,1) ./ max( na.*nb, eps );
end

function [y,m] = demean(x)
    m = sum(x,1)/size(x,1);
    y = bsxfun(@minus,x,m);
end
