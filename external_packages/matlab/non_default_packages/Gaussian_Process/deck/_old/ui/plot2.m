function p = plot2( varargin )
%
% p = dk.ui.plot( x, y, options.. )
% p = dk.ui.plot( X, options.. )
%
% Simple proxy method that accepts nx3 arrays for 2d plots.
%
% JH
    
    is_nmat = @(x) ismatrix(x) && isnumeric(x);
    is_nby2 = @(x) ismatrix(x) && size(x,2) == 2;
    
    % if the three first outputs are numeric matrices, call plot3 normally
    if (nargin >= 2) && is_nmat(varargin{1}) && is_nmat(varargin{2})
        
        p = plot( varargin{:} );
    else
        
        % otherwise the first input must be nx3
        assert( is_nby2(varargin{1}), 'Expected a nx2 matrix in input.' );
        
        points = varargin{1};
        opts   = varargin(2:end);
        
        p = plot( points(:,1), points(:,2), opts{:} );
    end

end
