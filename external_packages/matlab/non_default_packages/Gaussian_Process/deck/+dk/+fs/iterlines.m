function out = iterlines( file, callback, skipempty )
%
% out = dk.fs.iterlines( file, callback, skipempty )
%
% Iterate over trimmed lines of input file, invoking callback function with:
%   callback( linenum, linetxt )
%
% Empty lines are skipped by default.
% Callback should return an output, which is collected into a cell-array, and returned.
%
% JH

    if nargin < 3, skipempty=true; end

    out = {};
    
    fh = fopen( file, 'r' );
    try
        line = fgetl(fh);
        count = 1;
        while ischar(line)
            line = strtrim(line);
            if ~skipempty || ~isempty(line)
                out{count} = callback(count,line);
            end
            line = fgetl(fh);
            count = count + 1;
        end
    catch err 
        warning( 'Something went wrong when reading file "%s":\n%s', file, err.message );
    end
    fclose(fh);

end