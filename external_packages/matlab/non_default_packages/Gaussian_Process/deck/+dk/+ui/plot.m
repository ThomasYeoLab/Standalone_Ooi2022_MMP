function h = plot(x,varargin)
%
% h = dk.ui.plot(x,varargin)
%
% Call plot or plot3 with the columns of input x.
% Additional inputs are taken as chart line properties.
%
% x: Nx2 or Nx3 matrix
% 
% JH

    switch size(x,2)
        case 2
            h = plot( x(:,1), x(:,2), varargin{:} );
        case 3
            h = plot3( x(:,1), x(:,2), x(:,3), varargin{:} );
        otherwise
            error('Bad input size.');
    end
    
end