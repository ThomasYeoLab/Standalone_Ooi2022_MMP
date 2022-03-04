classdef Grid < handle
%
% Regular 2d grid spanning arbitrary intervals in X and Y.
% 
% Defines common operations needed on a grid, such as:
%   function evaluation
%   point binning
%   coordinate normalisation
%   drawing as image
%   drawing as surface
%
% JH

    properties (Hidden,SetAccess = private)
        rx
        ry
    end
    
    properties (Transient,Dependent)
        lo, up
        nx, dx
        ny, dy
    end
    
    properties (Transient,Dependent,Hidden)
        wx, xb
        wy, yb
    end
    
    methods
        
        function self = Grid(varargin)
            self.assign(varargin{:});
        end
        
        function self = assign(self,xdom,ydom,n)
            if nargin < 3, ydom=xdom; end
            if nargin < 4, n=80; end
            
            self.rx = procdom(xdom,n);
            self.ry = procdom(ydom,n);
        end
        
        % dependent properties
        function n = get.nx(self), n = numel(self.rx); end
        function n = get.ny(self), n = numel(self.ry); end
        
        function d = get.dx(self), d = self.rx(2) - self.rx(1); end
        function d = get.dy(self), d = self.ry(2) - self.ry(1); end
        
        function w = get.wx(self), w = self.rx(end) - self.rx(1); end
        function w = get.wy(self), w = self.ry(end) - self.ry(1); end
        
        function b = get.xb(self), b = self.rx([1,end]); end
        function b = get.yb(self), b = self.ry([1,end]); end
        
        function b = get.lo(self), b = [self.rx(1), self.ry(1)]; end
        function b = get.up(self), b = [self.rx(end), self.ry(end)]; end
        
        % normalise coordinates within domain
        function y = normalise(self,x)
            y = bsxfun( @minus, x, self.lo );
            y = bsxfun( @rdivide, y, [self.wx, self.wy] );
        end
        
        function y = denormalise(self,x)
            y = bsxfun( @times, x, [self.wx, self.wy] );
            y = bsxfun( @plus, y, self.lo );
        end
        
        function y = contains(self,x,strict)
            if nargin < 3, strict=false; end
            if strict
                f = @(z,lo,up) (z > lo) & (z < up);
            else
                f = @(z,lo,up) (z >= lo) & (z <= up);
            end
            y = f(x(:,1),self.rx(1),self.rx(end)) & f(x(:,2),self.ry(1),self.ry(end));
        end
        
        % grid points
        function [gx,gy] = mesh(self)
            [gx,gy] = meshgrid( self.rx, self.ry );
        end
        
        function x = coord(self,norm)
            if nargin < 2, norm=false; end
            [gx,gy] = self.mesh();
            x = [gx(:),gy(:)];
            if norm, x = self.normalise(x); end
        end
        
        function x = rand(self,n)
            x = self.denormalise(rand(n,2));
        end
        
        function s = size(self)
            s = [ self.ny, self.nx ];
        end
        
        function n = numel(self)
            n = self.ny * self.nx;
        end
        
        function x = reshape(self,x)
            s = self.size();
            if any(size(x) ~= s) && numel(x)==prod(s)
                x = reshape(x,s);
            end
        end
        
        % evaluate function at or between points
        function [M,xq] = eval(self,fun,unif)
            if nargin < 3, unif=true; end
            [gx,gy] = meshgrid(self.rx, self.ry);
            xq = [gx(:),gy(:)];
            try
                M = fun(xq);
            catch
                n = size(xq,1);
                M = dk.mapfun( @(i) fun(xq(i,:)), (1:n)', unif );
            end
            M = self.reshape(M);
        end
        
        function [M,xq] = evalctr(self,fun,unif)
            if nargin < 3, unif=true; end
            [gx,gy] = meshgrid( ...
                self.rx(1:end-1) + self.dx, ...
                self.ry(1:end-1) + self.dy );
            xq = [gx(:),gy(:)];
            try
                M = fun(xq);
            catch
                n = size(xq,1);
                M = dk.mapfun( @(i) fun(xq(i,:)), (1:n)', unif );
            end
        end
        
        % Note
        %
        % These functions reverse the order of coordinates:
        %   (x,y) => (col,row) = (j,i)
        function k = ind(self,x,varargin)
            [i,j] = self.sub(x,varargin{:});
            k = sub2ind( self.size(), i, j );
        end
        
        function [i,j] = sub(self,x,bfun)
            if nargin < 3, bfun = @floor; end
            j = 1 + bfun( (x(:,1) - self.rx(1)) / self.dx );
            i = 1 + bfun( (x(:,2) - self.ry(1)) / self.dy );
        end
        
        % show image defined at grid points
        function h = image(self,img,ca)
            if nargin < 3, ca='auto'; end
            img = self.reshape(img);
            h = imagesc( self.ry(:), self.rx, img );
            set(gca,'ydir','normal'); caxis(ca);
        end
        
        % show surface at grid points
        function h = surface(self,z,c,ca,varargin)
            if nargin < 3 || isempty(c), c=z; end
            if nargin < 4 || isempty(ca), ca='auto'; end
            [x,y] = meshgrid( self.rx, self.ry );
            z = self.reshape(z);
            c = self.reshape(c);
            h = surf( x, y, z, c, varargin{:} );
            axis vis3d tight; grid on; caxis(ca); colorbar;
        end
        
    end
    
end

function g = procdom( dom, n )
    if numel(dom) > 2
        n = dom(3);
    end
    g = linspace( dom(1), dom(2), n );
end
