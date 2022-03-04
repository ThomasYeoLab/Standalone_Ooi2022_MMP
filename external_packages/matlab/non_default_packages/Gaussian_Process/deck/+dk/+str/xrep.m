function s = xrep( s, e, n )
%
% str = dk.str.xrep( str, ext, n=1 )
%
% Replace extension in string.
% See dk.str.xrem and dk.str.xset for more details.
% By default, only the part after the last dot is replaced (ie, n=1).
% If the extension to replace contains several dots, set n to a higher value.
%
% Example:
% dk.str.xrep( '/path/to/foo.bar.nii.gz', 'mat', 2 ) % foo.bar.mat
%
% JH

    if nargin < 3, n = 1; end
    s = dk.str.xset( dk.str.xrem(s,n), e );

end
