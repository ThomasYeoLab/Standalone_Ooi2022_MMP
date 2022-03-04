function [bsize,scale] = bytesize( in, in_bytes )
%
% [bsize,scale] = dk.bytesize( in, in_bytes=true )
%
% Return the size of the input variable in bytes or bits.
% Print to console if no output is collected.
%
% See also: dk.util.bytefmt
%
% JH

    w = whos('in');
        
    % in bytes by default, otherwise convert to bits
    if nargin < 2, in_bytes=true; end
    if in_bytes
        b = w.bytes; 
        s = 'B';
    else
        b = 8*w.bytes; 
        s = 'b';
    end
    
    if nargout == 0
        dk.util.bytefmt( b, s );
    else
        [bsize,scale] = dk.util.bytefmt( b, s );
    end

end
