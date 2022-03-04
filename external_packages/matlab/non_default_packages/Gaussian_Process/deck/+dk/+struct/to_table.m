function T = to_table( s, r )
%
% T = dk.struct.to_table( s, r=[] )
%
% Convert struct-array to table, with variable names corresponding to fieldnames.
% Structure fields correspond to columns. Optionally specify row names.
%
% Example:
%
% s = dk.struct.array( ...
%     'FirstName', {'Frank','Douglas','Edward','Zoey'}, ...
%     'LastName', {'Underwood','Stamper','Meechum','Barnes'} ...
% );
% dk.struct.to_table(s)
%
% JH

    f = fieldnames(s);
    n = numel(f);
    m = numel(s);
    T = cell(1,n);

    for i = 1:n
        T{i} = reshape( {s.(f{i})}, m, 1 );
    end
    T = [T,{'VariableNames',f}];
    if nargin > 1
        T = [T,{'RowNames',r}];
    end
    T = table(T{:});

end
