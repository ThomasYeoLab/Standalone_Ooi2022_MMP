function h = scatter(x,varargin)
%
% h = dk.ui.scatter(x,varargin)
%
% Call scatter or scatter3 with the columns of input x.
% Additional inputs are taken as scatter properties.
%
% x: Nx2 or Nx3 matrix
% 
% JH

    switch size(x,2)
        case 2
            h = scatter( x(:,1), x(:,2), varargin{:} );
        case 3
            h = scatter3( x(:,1), x(:,2), x(:,3), varargin{:} );
        otherwise
            error('Bad input size.');
    end
    
end