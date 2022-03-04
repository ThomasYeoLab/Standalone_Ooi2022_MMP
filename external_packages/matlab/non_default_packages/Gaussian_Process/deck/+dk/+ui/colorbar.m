function [fig,h] = colorbar( range, label, varargin )
%
% [fig,h] = dk.ui.colorbar( range, label, varargin )
%
% THIS IS NOT A REPLACEMENT FOR MATLAB'S colorbar FUNCTION!
% It creates a colorbar from scratch, for bettter control of the appearance, for paper figures.
%
% Open a new figure with a colorbar in specified range and label.
% Outputs handles to figure, and a structure with handles to colorbar image and text label.
%
% Example:
%   dk.ui.colorbar( [-3 7], 'This is a label', ...
%       'orient', 'h', 'reverse', true, 'txtopt', {'FontSize',25}, 'cmap', dk.cmap.wjet );
%
% INPUTS:
%     range  1x2 vector specifying the extents of the colorbar.
%     label  The text label to be placed near the colorbar.
%
% OPTIONS:
%
%    orient  Orientation of the colorbar: 'horz' or 'vert' (default: 'vert').
%   reverse  Change the relative position of label and colorbar (default: false).
%      cmap  Colormap, either string or nx3 array of RGB colors (default: 'jet').
%    length  Number of points in the colorbar (default: 128).
%    txtopt  Cell of options for the text label (default: {}). 
%            See 'doc text' for details.
%      dims  Dimensions in normalised units (0,1):
%               [TextSize ImageSize Separation Margin]
%            Note: 
%               - TextSize + ImageSize should be <= 0.8 (space for labels)
%               - Dimensions do not need to sum to 1
%               - Default is [25,30,5,3] / 100
%
% JH

    % parse options
    opt = dk.obj.kwArgs(varargin{:});
    
        orient = opt.get( 'orient', 'vertical' );
        reverse = opt.get( 'reverse', false );
        cmap = opt.get( 'cmap', 'jet' );
        len = opt.get( 'length', 128 );
        txtopt = opt.get( 'txtopt', {} );
        if isempty(label)
            default_d = [0 35 15 3]/100;
        else
            default_d = [25 30 5 3]/100;
        end
        d = opt.get( 'dims', default_d );
        s = opt.get( 'size', [] );
        
    % these guys control how close/far the text label is from the colorbar
    tsz = d(1);
    isz = d(2);
    sep = d(3);
    mar = d(4);
    
    csz = 1 - 2*mar;
    off = 1 - (isz+tsz+sep);
    
    tlo = 0.2;
    thi = 0.5;
        
    % open new figure
    fig=figure('units','normalized'); colormap(cmap);
    
    % work out the position of things
    switch lower(orient)
        
        case {'vertical','vert','v'}
            
            x = 0;
            y = linspace(range(1),range(2),len);
            if reverse
                
                hi = axes( 'Position', [ (mar+tsz+sep) mar isz csz ] );
                oi = imagesc( hi, x, y, (1:len)' );
                hi.YAxisLocation = 'right';
                
                if ~isempty(label)
                    ht = axes( 'Position', [ mar mar tsz csz ], 'Visible', 'off' );
                    ot = text( ht, thi, 0.5, label, 'Rotation', +90, 'HorizontalAlignment', 'center', txtopt{:} );
                end
                
            else
                
                hi = axes( 'Position', [ off mar isz csz ] );
                oi = imagesc( hi, x, y, (1:len)' );
                
                if ~isempty(label)
                    ht = axes( 'Position', [ (off+isz+sep) mar tsz csz ], 'Visible', 'off' );
                    ot = text( ht, tlo, 0.5, label, 'Rotation', -90, 'HorizontalAlignment', 'center', txtopt{:} );
                end
                
            end
            hi.XTick = [];
            hi.YDir = 'normal';
            box(hi,'off');
            
            % default figure size
            if isempty(s), s = [700 200]; end
            
        case {'horizontal','horz','h'}
            
            x = linspace(range(1),range(2),len);
            y = 0;
            
            if reverse
                
                hi = axes( 'Position', [ mar (mar+tsz+sep) csz isz ] );
                oi = imagesc( hi, x, y, (1:len) );
                hi.XAxisLocation = 'top';
                
                if ~isempty(label)
                    ht = axes( 'Position', [ mar mar csz tsz ], 'Visible', 'off' );
                    ot = text( ht, 0.5, thi, label, 'HorizontalAlignment', 'center', txtopt{:} );
                end
                
            else
                
                hi = axes( 'Position', [ mar off csz isz ] );
                oi = imagesc( hi, x, y, (1:len) );
                
                if ~isempty(label)
                    ht = axes( 'Position', [ mar (off+isz+sep) csz tsz ], 'Visible', 'off' );
                    ot = text( ht, 0.5, tlo, label, 'HorizontalAlignment', 'center', txtopt{:} );
                end
                
            end
            hi.YTick = [];
            box(hi,'off');
            
            % default figure size
            if isempty(s), s = [200 700]; end
            
        otherwise
            error('Unknown orientation: %s',orient);
        
    end
    
    if isempty(label)
        ht = nan;
        ot = nan;
    end
    
    % save handles in figure UserData
    h.text.axis = ht;
    h.text.handle = ot;
    h.image.axis = hi;
    h.image.handle = oi;
    fig.UserData = h;
    dk.fig.resize(fig,s);

end