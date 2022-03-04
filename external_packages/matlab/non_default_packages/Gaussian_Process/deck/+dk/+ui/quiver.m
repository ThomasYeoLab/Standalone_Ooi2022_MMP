function h = quiver(x,v,varargin)
%
% h = dk.ui.quiver(x,v,varargin)
%
% Call quiver or quiver3 with the columns of input matrices.
% Additional inputs are taken as quiver chart properties.
%
% x: Nx2 or Nx3 matrix
% v: Nx2 or Nx3 matrix
% 
% JH

    switch size(x,2)
        case 2
            h = quiver( x(:,1), x(:,2), v(:,1), v(:,2), varargin{:} );
        case 3
            h = quiver3( x(:,1), x(:,2), x(:,3), v(:,1), v(:,2), v(:,3), varargin{:} );
        otherwise
            error('Bad input size.');
    end
    
end