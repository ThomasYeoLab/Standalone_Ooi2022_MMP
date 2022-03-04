function varargout = load( fname, varargin )
%
% Helper function to load MAT files:
%
%   1. Simplest form, returns a struct:
%       data = dk.load(filename);   
%
%   2. Filter only desired variables (although everything is loaded):
%       data = dk.load(filename, 'field1', 'field2', ...);
%
%   3. Load individual variables
%       [value1, value2, ...] = dk.load(filename, 'field1', 'fiedl2', ...);
%
% NOTE:
%   When requesting specific fields, fields not found are assigned the value [].
%
% JH

    % load data
    data = load(dk.str.xset( fname, 'mat' ));
    
    if nargin > 1
        % extract specific variables
        data = dk.mapfun( @(f) dk.struct.get( data, f, [] ), varargin, false );

        % more than one field required, but only one output: return a structure
        if nargout <= 1 && nargin > 2
            varargout = {cell2struct( data, varargin, 2 )};
        else
            varargout = data;
        end
    else
        % return the whole structure
        varargout = {data};
    end

end