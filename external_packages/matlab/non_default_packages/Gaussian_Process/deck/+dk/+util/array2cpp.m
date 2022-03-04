function array2cpp( values, fmt, width )
%
% Print all input values as a comma-separated list of elements formatted using input 'fmt'.
% The width specifies the number of formated values per line.

    if nargin < 3, width = 10; end

    n = numel(values);
    fprintf(['{ ' fmt], values(1));
    for i = 2:n
        
        if mod(i,width) == 1
            fprintf([',\n  ' fmt], values(i));
        else
            fprintf([', ' fmt], values(i));
        end
        
    end
    fprintf(' };\n');

end