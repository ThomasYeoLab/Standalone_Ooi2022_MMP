function [h,p] = wheel( centre, Nelm, radii, angle, Npts )
%
% [h,p] = dk.ui.wheel( centre, nelem, radii=[0.9,1], angle=[0,2*pi], npts=10 )
%
% Draw a circular ring patch at specified centre, with specified radii and 
% between specified angles. The ring-arc is split into Nelm cells, though 
% all of them belong to the same Patch object.
%
% To change the colour of each cell in the arc, call:
%
%   set( h, 'FaceVertexCData', color ), where color: 
%
%       <N,1> vector => interpolates colour in current colormap
%       <N,3> matrix => specify colour explicitly for each cell
%
% INPUTS:
%
%  centre  1x2 coord of centre
%    Nelm  number of cells in the ring-arg
%   radii  [inner, outer] radii
%          DEFAULT: [0.9,1]
%   angle  [start,end] in RADIANS. Decreasing range is ok.
%          DEFAULT: [0,2*pi]
%    Npts  Number of points for each arc of each cell.
%          DEFAULT: 10
%
% OUTPUTS:
%
%   h   Patch object.
%   p   Anchor points inside the wheel for each element.
%
% JH

    if nargin < 5, Npts = 10; end
    if nargin < 4, angle = [0,2*pi]; end
    if nargin < 3, radii = [0.9,1]; end
    
    % check inputs
    assert( dk.is.integer(Npts) && Npts > 0, ...
        'Npts should be int > 0.' );
    assert( dk.is.integer(Nelm) && Nelm > 0, ...
        'Nelm should be int > 0.' );
    assert( numel(angle) == 2 && abs(diff(angle)) > 0, ...
        'Angle should be 1x2 vector in radians.' );
    assert( numel(radii) == 2 && diff(radii) > 0 && all(radii >= 0), ...
        'Radii should be 1x2 non-negative ascending.' );
    assert( numel(centre) == 2, ...
        'Centre should be 1x2 coordinate vector.' );
    
    % unpack / process
    Rin = radii(1);
    Rout = radii(2);
    
    angle = linspace( angle(1), angle(2), Nelm+1 );
    
    % compute coordinates of polygons
    x = zeros(2*Npts+1,Nelm);
    y = zeros(2*Npts+1,Nelm);
    p = zeros(Nelm,2);
    
    for i = 1:Nelm
        a = linspace( angle(i), angle(i+1), Npts );
        x(:,i) = centre(1) + [ Rin*cos(a), Rout*cos(fliplr(a)), Rin*cos(a(1)) ]';
        y(:,i) = centre(2) + [ Rin*sin(a), Rout*sin(fliplr(a)), Rin*sin(a(1)) ]';
        
        b = a(fix( Npts / 2 ));
        p(i,:) = Rin * [ cos(b), sin(b) ];
    end
    
    h = patch( x, y, ones(Nelm,1) );

end