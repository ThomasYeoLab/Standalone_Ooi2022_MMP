function out = mapfun( fun, val, unif )
%
% out = dk.mapfun( fun, val, unif=false )
%
% Use cellfun or arrayfun depending on the type of input (struct treated as arrays).
% Fine not to collect output (in which case no need for fun to return anything).
%
% See also: dk.struct.kvfun
% 
% JH

    if nargin < 3, unif=false; end

    out = [];
    if iscell(val)
        if nargout > 0
            out = cellfun( fun, val, 'UniformOutput', unif );
        else
            cellfun( fun, val, 'UniformOutput', unif );
        end
    else
        if nargout > 0
            out = arrayfun( fun, val, 'UniformOutput', unif );
        else
            arrayfun( fun, val, 'UniformOutput', unif );
        end
    end
    
% Slower version.
%     varargout = cell(1,nargout);
%     if iscell(val)
%         [varargout{:}] = cellfun( fun, val, 'UniformOutput', unif );
%     else
%         [varargout{:}] = arrayfun( fun, val, 'UniformOutput', unif );
%     end
    
% Old version.
% Branching as above is much faster than using function handles.
%
%     if iscell(val)
%         map = @cellfun;
%     %elseif isscalar(val) && isstruct(val)
%     %    map = @structfun;
%     else
%         map = @arrayfun;
%     end
%     
%     if nargout == 0
%         map( fun, val, 'UniformOutput', unif );
%     else
%         out = map( fun, val, 'UniformOutput', unif );
%     end

end