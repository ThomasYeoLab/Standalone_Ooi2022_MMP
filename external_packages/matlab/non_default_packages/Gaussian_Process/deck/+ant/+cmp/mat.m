function val = mat(a, b, method, varargin)
%
% val = ant.cmp.mat( a, b, method, params... )
%
% Compare two matrices using different measures:
%
%   riemann     (prc=50)
%   jh,jman     (prc=50, alpha=2)
%
% The higher prc (between 1 and 99), the fewer principal components are considered.
% The higher alpha (>= 1), the more sensitive to small differences.
%
%
% Comparing lower/upper triangular values as vector is possible, using
% method names prefixed with 'lt-' or 'ut-'. For instance, 'lt-corr' 
% computes the correlation between lower-triangular values.
%
% See also: ant.cmp.vec
%   
% JH

    assert( dk.is.square(a) && dk.is.square(b), 'Inputs should be square matrices' );
    n = size(a,1);
    assert( size(b,1) == n, 'Size mismatch between inputs.' );
    
    % compare them
    switch lower(method)
        
        case {'riemann','rieman'}
            a = laplacian(a);
            b = laplacian(b);
            x = dk.getopt( varargin, 'prc', 50 );
            
            % generalised eivecs
            [~,d] = eig(a,b);
            
            % filter principal percentile
            d = abs(diag(d));
            t = max( eps, prctile(d,x.prc) );
            d = d( d > t );
            
            assert( all(d > eps), 'Eigenvalues are too small.' );
            val = log(d);
            val = sqrt(dot(val,val));
            
        case {'jh','jman'}
            a = laplacian(a);
            b = laplacian(b);
            x = dk.getopt( varargin, 'prc', 50, 'alpha', 2 );
            
            % generalised eivecs
            [v,d] = eig(a,b);
            
            % eivec magnitude, and associated eival
            m = sqrt(dot(v,conj(v),1));
            d = abs(diag(d));
            
            % filter principal percentile
            t = max( eps, prctile(d,x.prc) );
            f = d > t;
            d = d(f);
            m = m(f);
            
            val = 1 + power( abs(log(d)), 1/x.alpha );
            val = sum( m(:) ./ val ) / sum(m);
            
        otherwise
            
            % try comparing as vectors
            switch lower(method(1:3))
                case 'lt-'
                    val = ant.cmp.vec( ant.mat.vtril(a), ant.mat.vtril(b), method(4:end), varargin{:} );
                case 'ut-'
                    val = ant.cmp.vec( ant.mat.vtriu(a), ant.mat.vtriu(b), method(4:end), varargin{:} );
                otherwise
                    error( 'Unknown method: %s', method );
            end
            
    end
    
end

function x = laplacian(x)
    x = ant.mat.setdiag(x,0);
    x = diag(sum(x,1)) - x;
end
