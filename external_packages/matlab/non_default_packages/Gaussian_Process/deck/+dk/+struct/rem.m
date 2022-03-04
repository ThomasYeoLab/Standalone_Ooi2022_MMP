function s = rem( s, varargin )
%
% s = dk.struct.rem( s, varargin )
%
% Remove field(s) from structure or struct-array if the field exists.
% Do not throw an error if (any of) the field(s) does not exist.
%
% JH

    if nargin == 2 && iscellstr(varargin{1})
        f = intersect( fieldnames(s), varargin{1} );
    else
        f = intersect( fieldnames(s), varargin );
    end
    try
        s = rmfield(s,f);
    catch
        % do nothing
    end

end
