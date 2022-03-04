function Ynew = interp_field( Xold, Yold, Xnew, type )
% Ynew = interp_field( Xold, Yold, Xnew, type )
%
% Inputs:
%   Xold are the points at which the vector field F takes the values Yold = F(Xold)
%   Xnew are the points where the force field needs to be interpolated
%   type is either 'euclidean' (default) or 'Mahalanobis'.
%
% Constraints:
%   Xold and Yold should both have n rows (# of observations).
%   Xold and Xnew should both have d columns (# of dimensions).
%
% Output:
%   Ynew are the interpolated values of F(Xnew).

    d    = size(Xold,2);
    Nold = size(Xold,1);
    Nnew = size(Xnew,1);
    
    if nargin < 4, type='euclidean'; end

    assert( ismatrix(Xold) && ismatrix(Xnew) && ismatrix(Yold), 'Xold, Yold and Xnew should be matrices.');
    assert( size(Xnew) == d, 'Points in Xnew and Xold should have the same dimension.' );
    assert( size(Yold,1) == Nold, 'Yold should have the same number of values than Xold.' );
    
    % Compute linear interpolants
    switch lower(type)
        case 'euclidean'
            
            % d_ij = || Xnew(i,:) - Xold(j,:) ||_2
            % a_ij = (max_k(d_ik) - d_ij) / sum_k(d_ik)
            
            I = ant.math.pairdist( Xnew, Xold );
            I = bsxfun( @minus, max(I,[],2), I );
            I = bsxfun( @rdivide, I, sum(I,2) );
            
        case 'mahalanobis'
            
            % d_ij = Xnew(i,:) - Xold(j,:)
            % m_ij = exp( - d_ij * S^{-1} * d_ij' );
            % a_ij = m_ij / sum_k( m_ik )
            
            S = cov(Xold);
            I = zeros( Nnew*Nold, d );
            
            for i = 1:d
                I(:,i) = dk.tocol(ant.math.pairdiff( Xnew(:,i), Xold(:,i) ));
            end
            
            I = sum( (I / S) .* I, 2);
            I = exp( - reshape( I, [Nnew, Nold] ) ); % "affinity"
            I = bsxfun( @rdivide, I, sum(I,2) ); % normalize
    end
    
    % Iterpolate
    Ynew = I * Yold;
    
end
