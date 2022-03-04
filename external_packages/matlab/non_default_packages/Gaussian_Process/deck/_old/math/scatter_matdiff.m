function s = scatter_matdiff( A, B )
%
% Experimental scatter plot showing localised differences between two matrices.
% The scatter bandwidth depends on the range of values within the input matrices, 
% while the color of the dots indicates the location within these matrices.
%
% JH

    assert( ismatrix(A) && ismatrix(B), 'A and B should be matrices.' );
    assert( all(size(A) == size(B)), 'Both input matrices should be the same size.' );

    figure('name','Color-plot visualisation of matrix difference.');
    
    [nr,nc] = size(A);
    [r,c]   = ndgrid( 1:nr, 1:nc );
    
    n = max(nr,nc);
    A = A(:);
    B = B(:);
    
    s = scatter( A, B, [], c(:) - r(:) );
    a = s.Parent; a.Color = 0.2*[1 1 1];
    
    colormap( a, dk.ui.cmap.tap(2*n,true) );
    
    b=colorbar; 
    b.Label.FontSize=12;
    b.Label.String='Under (blue) to over (red) diagonal';
    
end
