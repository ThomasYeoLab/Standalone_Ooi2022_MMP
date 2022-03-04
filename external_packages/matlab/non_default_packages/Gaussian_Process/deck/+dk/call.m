function varargout = call( outperm, func, varargin )
%
% ... = dk.call( outperm, func, varargin )
%
%   Call function handle with specified argument, and return selected outputs.
%   
%   outperm: (partial) permutation of outputs
%   func: function handle
%   
% JH

    n = max(outperm);
    varargout = cell(1,n);
    [varargout{:}] = func(varargin{:});
    varargout = varargout(outperm);

end