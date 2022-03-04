function val = self( a, method )
%
% val = ant.cmp.self( a, method )
%
% Pairwise comparison of a's COLUMNS using different measures:
%
%   sad
%   mad
%   ssd
%   rmsd
%   cos
%   cov
%   cor,corr
%
% NOTE;
% If a is n x p, output is a p x p hermitian matrix.
%
% See also: ant.cmp.vec, ant.cmp.mat
%
% JH

    assert( ismatrix(a), 'Input should be a matrix.' );
    [n,p] = size(a);
    
    % compare them
    switch lower(method)
        
        case 'sad'
            val = sad(a);
        
        case 'mad'
            val = sad(a)/n;
            
        case 'ssd'
            val = sad(a);
            val = val .* val;
            
        case 'rmsd'
            val = sad(a);
            val = val .* val;
            val = sqrt(val/n);
            
        case 'cos'
            val = cos(a);
            
        case 'cov'
            a = demean(a);
            val = (a' * a)/(n-1);
            
        case {'cor','corr'}
            a = demean(a);
            val = cos(a);
            
        otherwise
            error( 'Unknown metric: %s', method );
            
    end

end

function d = sad(x)
    n = size(x,2);
    d = zeros(n);
    for i = 1:n-1
        t = bsxfun( @minus, x(:,i), x(:,i+1:end) );
        t = sum(abs(t),1);
        d(i,i+1:end) = t;
        d(i+1:end,i) = t';
    end
end

function c = cos(x)
    c = x' * x;
    d = max( sqrt(diag(c)), sqrt(eps) );
    c = c ./ (d * d');
end

function [y,m] = demean(x)
    m = sum(x,1)/size(x,1);
    y = bsxfun(@minus,x,m);
end
