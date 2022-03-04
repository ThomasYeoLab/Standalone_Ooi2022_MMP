function S = col2sym( C, nodiag )
%
% S = ant.mat.col2sym( C, nodiag=false )
%
% This is the inverse function of ant.mat.sym2col.
%
% See also: ant.mat.sym2col
%
% JH

    assert( ismatrix(C), 'Expected a matrix in input.' );
    if nargin < 2, nodiag = false; end

    m = size(C,1);
    s = size(C,2);
    
    if nodiag
        n = (1+sqrt(1+8*m))/2;
    else
        n = (sqrt(1+8*m)-1)/2;
    end
    assert( abs(n - floor(n)) < 1e-6, 'Bad number of rows in input.' );
    
    S = zeros(n,n,s,class(C));
    I = ant.mat.symindex(n,nodiag,'diag1');
    
    for i = 1:s
        M = C(:,i);
        M = M(I);
        if nodiag, M = ant.mat.setdiag(M,0); end
        S(:,:,i) = M;
    end
    
end
