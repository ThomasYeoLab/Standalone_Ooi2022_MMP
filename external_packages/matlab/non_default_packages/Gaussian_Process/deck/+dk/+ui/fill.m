function h = fill(x,c,varargin)
%
% h = dk.ui.fill(x,c,varargin)
%
% Call fill or fill3 with the columns of input x, and colour c.
% Additional inputs are taken as patch properties.
%
% x: Nx2 or Nx3 matrix
% c: string or 1x3 rgb vector
% 
% JH

    switch size(x,2)
        case 2
            h = fill( x(:,1), x(:,2), c, varargin{:} );
        case 3
            h = fill3( x(:,1), x(:,2), x(:,3), c, varargin{:} );
        otherwise
            error('Bad input size.');
    end
    
end