function S = symindex( n, nodiag, post )
%
% S = ant.mat.symindex( n, nodiag=false, post='diag0' )
%
% nxn symmetric matrix like
%
%  1  2  3  4  5
%  2  6  7  8  9
%  3  7 10 11 12
%  4  8 11 13 14
%  5  9 12 14 15
%
% Post-processing options when nodiag=true:
%   diag0   set diagonal to 0 (default)
%   diag1   set diagonal to 1
%   ltval   extract lower-triangular values
%   utval   extract upper-triangular values
%
% NOTE:
%   If nodiag=true, the diagonal is 0 by default, so indices cannot be used directly!
%
% JH
    
    if nargin < 2, nodiag = false; end
    if nargin < 3, post = ''; end

    if nodiag
        
        M = tril( true(n), -1 );
        S = zeros(n);
        S(M) = 1:( n*(n-1)/2 );
        S = S + S'; 
        
        switch lower(post)
            case 'diag0'
                % nothing to do
            case 'diag1'
                S = S + eye(n);
            case {'vtril','ltval'}
                S = S(M);
            case {'ltril','utval'}
                S = S(M');
            otherwise
                error( 'Unknown post-processing: %s', post );
        end
        
    else
        
        M = tril( true(n), 0 );
        S = zeros(n);
        S(M) = 1:( n*(n+1)/2 );
        S = S + S' - diag(diag(S));
        
    end
    
end
