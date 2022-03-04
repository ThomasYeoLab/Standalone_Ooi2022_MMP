function val = cross( a, b, method )
%
% val = ant.cmp.cross( a, b, method )
%
% Cross-comparison of a and b's COLUMNS using different measures:
%
%   sad
%   mad
%   ssd
%   rmsd
%   cos
%   cov
%   cor,corr
%
% If a has Na columns, and b has Nb columns, the output is a Na x Nb matrix,
% where element (i,j) = comparison( a(:,i), b(:,j) ).
%
% See also: ant.cmp.vec, ant.cmp.mat, ant.cmp.cols
%
% JH

    assert( ismatrix(a) && ismatrix(b), 'Bad inputs' );
    [m,na] = size(a);
    [p,nb] = size(b);
    assert( m==p, 'Inputs should be matrices with the same number of rows.' );
    
    val = zeros(na,nb);
    one = ones(1,nb);
    for i = 1:na
        val(i,:) = ant.cmp.cols( a(:,i)*one, b, method );
    end

end