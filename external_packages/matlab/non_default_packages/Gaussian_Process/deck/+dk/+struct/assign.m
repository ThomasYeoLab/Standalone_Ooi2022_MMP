function s = assign(s,varargin)
%
% s = dk.struct.assign(s,varargin)
% s = dk.struct.assign(s,idx,varargin)
%
% Assign field(s) of struct-array.
% Arguments should be field/value pairs.
%
% If indices are specified (with idx), then value can be a vector or cell 
% with as many elements as there are of indices. Otherwise it can be a vector
% or cell with as many elements as there are of structure.
% 
% JH

    if dk.is.even(nargin)
        idx = varargin{1};
        arg = varargin(2:end);
    else
        idx = 1:numel(s);
        arg = varargin;
    end
    
    assert( isvector(idx) && ~isempty(idx) && all(idx >= 1 & idx <= numel(s)), 'Bad indices.' );
    assert( iscellstr(arg(1:2:end)), 'Bad fieldnames.' );
    
    n = numel(arg);
    for i = 1:2:n
        [s(idx).(arg{i})] = dk.deal(arg{i+1});
    end
    
end