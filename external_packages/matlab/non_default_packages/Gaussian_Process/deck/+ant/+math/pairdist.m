function D = pairdist( A, B, metric )
%
% D = ant.math.pairdist( A, B, metric )
%
% Compute pairwise distances between points A and B with a map/reduce logic.
% Both A and B should be p x d matrices with one point in each row, ie:
%   - p is the number of points
%   - d is the number of dimensions
%
% Metric defaults to Euclidean norm, ie metric=struct(map=square, reduce=sqrt).
%
% JH

    if nargin < 3
        metric.map = @(x)(x.^2);
        metric.red = @(x)(sqrt(x));
    end
    
    if nargin < 2 || isempty(B)
        B = A;
    end
    
    assert( ismatrix(A) && ismatrix(B), 'A and B should be matrices.' );
    assert( size(A,2) == size(B,2), 'A and B should have the same number of dimensions.' );
    
    na = size(A,1);
    nb = size(B,1);
    nd = size(A,2);
    D  = zeros(na,nb);
    
    for d = 1:nd
        D = D + metric.map(ant.math.pairdiff( A(:,d), B(:,d) ));
    end
    
    D = metric.red(D);
    
end
