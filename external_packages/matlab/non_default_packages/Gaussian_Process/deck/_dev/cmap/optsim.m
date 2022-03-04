function c = optsim( smat )
%
% c = optsim( smat )
% 
% Optimised colormap based on similarity matrix.
% Uses spectral reordering to permute HSV colours.
%
% JH

    assert( dk.is.squarepos(smat,false), 'Input matrix should have non-negative entries.' );

    % normalise by self-similarity
    %self = diag(smat);
    %assert( all(self > eps), 'Self-similarities should be positive.' );
    
    %self = dk.bsx.leq(smat,self);
    %assert( all(self(:)), 'Similarity matrix should be diagonally dominant.' );

    % use spectral ordering to permute HSV colors
    tr = diag(sqrt( 1./sum(smat,1) ));
    tc = diag(sqrt( 1./sum(smat,2) ));
    
    [U,~,V] = svd(tc * smat * tr);
    %[~,r] = sort(tc * U(:,2));
    [~,r] = sort(tr * V(:,2));
    
    % use order to permute HSV colors
    n = numel(r);
    c(r,:) = hsv(n);
    
end