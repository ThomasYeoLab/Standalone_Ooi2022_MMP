function h = datamatrix( dmat, rows, cols, varargin )
%
% h = dk.ui.datamatrix( dmat, rows, cols, varargin )
%
% Display input matrix M with imagesc, overlayed with a grid separating each element.
% Returns handle to image (not grid lines).
% 
%
% INPUTS:
%
%   dmat    The data matrix.
%
%   rows    Tick labels
%   cols    Numeric inputs are converted to string using num2str.
%
%   ...     Additional inputs are taken as arguments for the grid
%           Default: { 'k-', 'LineWidth', 1 }
%
% EXAMPLE:
%
%   figure; dk.ui.datamatrix( rand(3,4), {'foo','bar','baz'}, 1:4, 'c--' );
%
% JH
    
    [nr,nc] = size(dmat);
    assert( numel(rows)==nr, 'Bad row labels.' );
    assert( numel(cols)==nc, 'Bad col labels.' );
    
    % show image
    centre = @(v) (v(1:end-1) + v(2:end))/2;
    
    %xb = linspace( 0, 1, nc );
    xe = linspace( 0, 1, nc+1 );
    xc = centre(xe);
    
    %yb = linspace( 0, 1, nr );
    ye = linspace( 0, 1, nr+1 );
    yc = centre(ye);
    
    h = imagesc( xc, yc, dmat );
    
    % draw the grid
    if nargin < 4
        gargs = { 'k-', 'LineWidth', 1 };
    else
        gargs = dk.wrap(varargin);
    end
    
    hold on;
    for i = 1:nc+1
        plot( xe(i)*[1,1], [0,1], gargs{:} ); 
    end
    for i = 1:nr+1
        plot( [0,1], ye(i)*[1,1], gargs{:} ); 
    end
    hold off;
    
    % tick labels
    if isnumeric(rows), rows = dk.mapfun( @num2str, rows, false ); end
    if isnumeric(cols), cols = dk.mapfun( @num2str, cols, false ); end
    set( gca, 'xtick', xc, 'xticklabel', cols, 'ytick', yc, 'yticklabel', rows );
    
end


% OLD RESIZING
%
%
%   size    Desired size for display.
%           Specifying [x,0] or [0,x] determines the size automatically.
%           Default: 
%               - at least 400px for smallest side, OR 
%               - at most 1000px for largest side.
%
%
%     % force ncols >= nrows
%     if nr > nc
%         [nr,nc] = dk.forward(nc,nr);
%         rev = true;
%     else
%         rev = false;
%     end
%     rho = nc / nr;
% 
%     % default image-size
%     if nargin < 4 || isempty(msize)
%         if rho <= 5/2
%             msize = round(400*[1,rho]);
%         else
%             msize = round(1000*[1/rho,1]);
%         end
%     end
%     
%     % unspecified sizes
%     if any(msize == 0)
%         if rev, msize = fliplr(msize); end
%         if msize(1)==0, msize(1)=msize(2)/rho; end
%         if msize(2)==0, msize(2)=rho*msize(1); end
%     end
%     
%     % check size
%     assert( all(msize > 0), 'Bad size.' );
%     if rev
%         [nr,nc] = dk.forward(nc,nr);
%         msize = fliplr(msize); 
%     end
%     dmat = imresize( dmat, msize, 'nearest' );