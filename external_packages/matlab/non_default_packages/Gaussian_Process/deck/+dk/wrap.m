function out = wrap(varargin)
%
% out = wrap(varargin)
%
% Output a cell wrapping the inputs.
% If input is a cell, then output is the input.
% Nested scalar cells are unwrapped.
%
% JH

    out = varargin;
    while numel(out)==1 && iscell(out{1})
        out = out{1};
    end
    
end