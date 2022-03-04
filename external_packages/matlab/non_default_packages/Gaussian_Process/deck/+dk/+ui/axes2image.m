function I = axes2image( haxes, fname, varargin )
%
% I = dk.ui.axes2image( haxes, fname='', varargin )
%
% Take a snapshot of an axes handle (haxes), and store it as an image.
% If a filename is specified, the image is saved on disk.
% Additional inputs, if any, are redirected to imresize.
%
% JH

    if nargin < 2, fname = ''; end

    F = getframe(haxes);
    I = frame2im(F);
    
    if nargin > 2
        I = imresize( I, varargin{:} );
    end
    if ~isempty(fname)
        imwrite( I, fname );
    end

end
