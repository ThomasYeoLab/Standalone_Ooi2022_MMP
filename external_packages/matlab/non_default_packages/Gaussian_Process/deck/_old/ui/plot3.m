function p = plot3( varargin )
%
% p = dk.ui.plot( x, y, z, options.. )
% p = dk.ui.plot( X, options.. )
%
% Simple proxy method that accepts nx3 arrays for 3d plots.
%
% JH
    
    is_nmat = @(x) ismatrix(x) && isnumeric(x);
    is_nby3 = @(x) is_nmat(x) && size(x,2) == 3;
    
    % if the three first outputs are numeric matrices, call plot3 normally
    if (nargin >= 3) && is_nmat(varargin{1}) && is_nmat(varargin{2}) && is_nmat(varargin{3})
        
        p = plot3( varargin{:} );
    else
        
        % otherwise the first input must be nx3
        assert( is_nby3(varargin{1}), 'Expected a nx3 matrix in input.' );
        
        points = varargin{1};
        opts   = varargin(2:end);
        
        p = plot3( points(:,1), points(:,2), points(:,3), opts{:} );
    end

end
