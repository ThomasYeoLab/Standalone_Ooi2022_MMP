function names = list( dirname, hidden )
%
% names = list( dirname, hidden=false )
%
% List everything in dirname, except names beginning with a dot (hidden).
% If hidden is true, include hidden folder but exclude . and ..
%
% JH

    if nargin < 1 || isempty(dirname), dirname=pwd; end
    if nargin < 2, hidden=false; end
    
    if hidden
        names = dk.fs.match( dirname, '.*' );
    else
        names = dk.fs.match( dirname, '^[^\.].*' );
    end

end
