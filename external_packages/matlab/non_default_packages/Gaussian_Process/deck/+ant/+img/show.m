function [h,crange] = show( img, varargin )
%
% [h,crange] = ant.img.show( img, varargin )
%
% Display an image, with many options.
%
% Input img should be either a matrix, or a cell {x,y,img}.
% In the second case, the image is automatically resampled, if x or y is not arithmetic.
%
%
% Color options:
%
%   crange          Manually specify the color-range
%                   1x2 vector [lower,upper]
%
%   ctype           Specify range-type (see dk.num.range)
%                   One of: pos, neg, bisym, manual
%
%   cmap            Specify colormap, either:
%                       - as name (see dk.cmap.*)
%                       - as Nx3 RGB matrix
%
%   grid            If specified, the border of the pixels is shown.
%                   Should be a cell of properties forwarded to plot.
%
% Axes options:
%   
%   subplot         Show image in subplot of current figure.
%                   Expects a 1x3 CELL array.
%
%   title           Set title and labels for image.
%   xlabel          clabel is for the colorbar.
%   ylabel
%   clabel
%
%   rmticks         Remove ticks or colorbar.
%   rmbar           Default: no ticks if xlabel & ylabel are empty.
%
% Density options:
%   
%   maxwidth        Maximum width or height allowed for image display.
%   maxheight       Any excess causes image to be resampled (bicubic).
%   
%
% See also: dk.num.range, ant.img.resample
%
% JH
    
    % parse inputs
    opt = dk.obj.kwArgs( varargin{:} );
    
    crange     = opt.get('crange',     [] );
    ctype      = opt.get('ctype',      '' );
    cmap_raw   = opt.get('cmap',       'bgr' );
    gridopt    = opt.get('grid',       {} );
    
    title_str  = opt.get('title',      '' );
    label_x    = opt.get('xlabel',     '' );
    label_y    = opt.get('ylabel',     '' );
    label_c    = opt.get('clabel',     '' );
    rm_ticks   = opt.get('rmticks',    isempty(label_x) && isempty(label_y) );
    rm_bar     = opt.get('rmbar',      false );
    subpos     = opt.get('subplot',    {} );
    
    maxwidth   = opt.get('maxwidth',   75000 );
    maxheight  = opt.get('maxheight',  10000 );
    maxsize    = [ maxheight, maxwidth ];
    
    if ischar(cmap_raw)
        cmap_unsigned = eval(sprintf('dk.cmap.%s(128,false)', cmap_raw));
        cmap_signed   = eval(sprintf('dk.cmap.%s(256,true)',  cmap_raw));
    else
        cmap_unsigned = [];
        cmap_signed   = [];
    end
    if isempty(ctype) 
        if opt.get('positive',false)
            ctype = 'pos';
        elseif opt.get('negative',false)
            ctype = 'neg';
        else
            ctype = 'auto';
        end
%         if ~isempty(crange)
%             ctype = 'manual';
%         else
%             ctype = 'auto';
%         end
    end
    
    % subplot if asked
    if ~isempty(subpos)
        subplot(subpos{:});
    end
    
    % plot image
    if isstruct(img)
        img = {img.x, img.y, img.z};
    end
    if iscell(img)
        
        % x and y axes are given
        [x,y,img] = ant.img.resample( img{1}, img{2}, img{3}, 'cubic' );
        
        % resize image if needed
        img = check_size( img, maxsize );
        
        % if image was resized, adapt x and y
        [nr,nc] = size(img);
        ny = numel(y); if nr ~= ny, y = interp1( linspace(0,1,ny), y, linspace(0,1,nr) ); end
        nx = numel(x); if nc ~= nx, x = interp1( linspace(0,1,nx), x, linspace(0,1,nc) ); end
        
        % draw image
        h = imagesc(x,y,img); set(gca,'YDir','normal');
        
        % round values for display
        %x = dk.num.trunc( x(get(gca,'xtick')), 3 );
        %y = dk.num.trunc( y(get(gca,'ytick')), 3 );
        
        %set( gca, 'xticklabel', dk.mapfun(@num2str,x,false) );
        %set( gca, 'yticklabel', dk.mapfun(@num2str,y,false) );
        
    else
        img = check_size( img, maxsize );
        [x,y] = size(img);
        x = 1:x;
        y = 1:y;
        h = imagesc(img); 
    end
    
    % draw grid
    if ~isempty(gridopt)
        if islogical(gridopt)
            gridopt = 'k-';
        end
        if ~iscell(gridopt)
            gridopt = {gridopt};
        end
        drawgrid(x,y,gridopt{:});
    end
    
    % remove ticks
    if rm_ticks
        set(gca,'xtick',[],'ytick',[]);
    else
        xlabel(label_x);
        ylabel(label_y);
    end
    
    % color range
    [crange,ctype] = dk.num.range( img, ctype, crange );
    
    % set color-scale
    switch lower(ctype)
        case {'neg','negative'}
            cmap = flipud(cmap_unsigned);
        case {'ctr','sym'}
            cmap = cmap_signed;
        case {'bool','gray'}
            cmap = gray(64);
        otherwise
            cmap = cmap_unsigned;
    end
    
    % override colormap if specified manually
    if ischar(cmap_raw)
        colormap( gca, cmap );
    else
        colormap( gca, cmap_raw );
    end
    caxis( crange ); 
    
    % remaining options
    cb = colorbar(gca); 
    if ~isempty(label_c)
        cb.Label.String = label_c; 
    end
    if rm_bar || islogical(img)
        cb.Visible = 'off'; 
    end
    title(title_str);
    
end

function img = check_size(img,maxsize)

    imgsize = size(img);
    if any( imgsize(1:2) > maxsize )
        warning( 'Input image is too large and will be resized for display.' );
        imgsize(1:2) = maxsize;
        img = imresize( img, imgsize, 'bicubic' );
    end
    
end

function drawgrid(x,y,varargin)

    % number of lines
    nx = numel(x)+1;
    ny = numel(y)+1;
    
    % grid step
    dx = mean(diff(x));
    dy = mean(diff(y));
    
    % adjust to start
    x = x - dx/2;
    y = y - dy/2;
    
    % bounds
    bx = x(1) + [0, nx*dx];
    by = y(1) + [0, ny*dy];
    
    hold on;
    
    % draw lines
    for i = 1:nx
        plot( x(i)*[1,1], by, varargin{:} );
    end
    for i = 1:ny
        plot( bx, y(i)*[1,1], varargin{:} );
    end
    
    hold off;
end
