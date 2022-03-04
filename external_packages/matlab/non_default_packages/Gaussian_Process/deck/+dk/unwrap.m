function out = unwrap(varargin)
%
% out = unwrap(varargin)
%
% Extract value from input cell, as long as it has a single element.
% If input is not a cell, then output is the input.
%
% JH

    out = varargin;
    while iscell(out) && numel(out)==1
        out = out{1};
    end
    
end