function [eivec,eival] = eigen( M, k )
%
% [eivec,eival] = eigen( M, k )
%
% Eigen decomposition with output sorted by magnitude (decreasing absolute eigenvalue).
% If k is specified, then only the k principal eival/vec are output.
%
% This differs from eigs because the output is guaranteed to be sorted.
% Eigenvectors are normalised (2-norm).
%
% JH

% doesn't seem to always give the same results...
%
%     if nargin > 1
%         [eivec,eival] = eigs(M,k);
%     else
%         [eivec,eival] = eig(M);
%     end
    
    [eivec,eival] = eig(M);

    eival = diag(eival);
    [~,order] = sort( abs(eival), 'descend' );
    eival = eival(order);
    eivec = eivec(:,order); % reorder columns

    if nargin > 1
        eival = eival(1:k);
        eivec = eivec(:,1:k);
    end
    
end