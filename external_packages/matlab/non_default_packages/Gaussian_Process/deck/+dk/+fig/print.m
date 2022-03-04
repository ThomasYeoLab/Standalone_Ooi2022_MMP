function varargout = print(varargin)
% Saves an image file using 'print'
%
% This is useful to quickly save things inside a loop. It provides more
% control than saveas() because it allows the resolution in dpi to be set.
% 300dpi is sufficient for a high resolution tiff for inclusion in papers
%
% Usage:
%   dk.fig.print('test') - save current figure as 'test.png' to the desktop
%   dk.fig.print('test.ext') - save current figure to the desktop with format specified by ext
%   dk.fig.print(h,'test') - first argument can be a figure handle
%   dk.fig.print(h,'test_%d',1) - additional arguments are used for string replacement
%
% RA

    % First, set the figure to have the same output dimension in the file
    % as it does on the screen
    if ishandle(varargin{1})
        fhandle = varargin{1};
        varargin = varargin(2:end);
    else
        fhandle = gcf;
    end

    fname = varargin{1};

    % Perform optional string substitution
    if length(varargin) > 1
        fname = sprintf(fname,varargin{2:end});
    end

    [pathstr,fname,ext] = fileparts(fname);

    if isempty(pathstr)
        if isunix()
            pathstr = '~/Desktop';
        else
            pathstr = '%UserProfile%\Desktop';
        end
    end

    if isempty(ext)
        ext = '.png';
    end

    output_fname = fullfile(pathstr,[fname ext]);

    ppm_original = get(fhandle,'PaperPositionMode');
    set(fhandle,'PaperPositionMode','auto');
    orig_renderer = get(fhandle,'Renderer');

    switch ext
        case '.eps'
            if strcmp(get(fhandle,'Renderer'),'opengl')
                set(fhandle,'Renderer','painters');
            end
            print(fhandle,'-r300','-depsc',output_fname);
        case {'.jpg','.jpeg'} 
            print(fhandle,'-r300','-djpeg',output_fname);
        case {'.tif','.tiff'}
            print(fhandle,'-r300','-dtiff',output_fname);
        case {'.pdf'}       
            print(fhandle,'-r300','-dpdf',output_fname);
        case {'.png'} 
            print(fhandle,'-r400','-dpng',output_fname);
        otherwise
            error('Unknown extension format: %s',ext);
    end

    fprintf(1,'Image saved to %s\n',output_fname);

    set(fhandle,'PaperPositionMode',ppm_original);
    set(fhandle,'Renderer',orig_renderer);

    if nargout > 0
        varargout{1} = output_fname;
    end
    
end
