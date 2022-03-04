function output = array2str( values, format, varargin )
%
% output = dk.util.array2str( values, format, varargin )
%
% values  2d array or cell, or table of values
% format  One of: matlab, latex or markdown (default is matlab)
%
% Additional arguments (key/value pairs):
%
%   num   Numerical format (default '%g')
%   row   Row names (cellstring)
%   col   Column names (cellstring)
%
% JH

    if nargin < 2 || isempty(format), format='default'; end

    % parse options
    opt = dk.obj.kwArgs( varargin{:} );

        format   = lower(format); % format of the string output
        numFmt   = opt.get( 'num', [] ); % format used to print numeric values
        rowNames = opt.get( 'row', {} );
        colNames = opt.get( 'col', {} );
    
    % Parse values into a cell
    if isnumeric(values) || islogical(values) || iscell(values)
        
        assert( ismatrix(values), 'Sorry, multidimensional arrays are not supported.' );
        V = dk.mapfun( @(x) dk.tostr(x,numFmt), values, false );
        
    elseif istable(values)
        
        rowNames = values.Properties.RowNames;
        colNames = values.Properties.VariableNames;
        output   = dk.util.array2str( table2array(values), format, ...
            'row', rowNames, 'col', colNames, 'num', numFmt );
        return;
        
    else
        error('Unknown array format.');
    end
    
    % Dimensions
    [nr,nc] = size(V);
    
    % Add columns
    if ~isempty(colNames)
        switch format
            case {'matlab','latex','tex','default'}
                V = vertcat( reshape(colNames,[1,nc]), V );
                rowpad = { '' };
            case {'markdown','md'}
                V = vertcat( reshape(colNames,[1,nc]), dk.mapfun( @(x) '--', 1:nc, false ), V );
                rowpad = { ''; '--' };
            otherwise
                error('Unknown format: %s', format);
        end
    end
    
    % Add rows
    if ~isempty(rowNames)
        rowNames = reshape(rowNames,[nr,1]);
        if ~isempty(colNames)
            rowNames = vertcat( rowpad, rowNames );
        end
        V = horzcat( rowNames, V );
    end
    
    % Update dimensions
    [nr,nc] = size(V);
    
    % Set separators depending on the format
    switch format
        
        case {'matlab','default'}
            sep.beg = ' ';
            sep.val = ', ';
            sep.row = '; ';
            
        case {'latex','tex'}
            sep.beg = ' ';
            sep.val = ' & ';
            sep.row = ' \\';
            
        case {'markdown','md'}
            sep.beg = ' | ';
            sep.val = ' | ';
            sep.row = ' | ';
            
        otherwise
            error('Unknown format: %s', format);
            
    end
    
    % Allocate output string
    widths = cellfun(@length,V);
    colwid = max(widths,[],1);
    
    stride = colwid + length(sep.val);
    stride = 1+length(sep.beg)+[0,cumsum(stride)];
    stride(end) = stride(end) + length(sep.row)-length(sep.val);
    
    output = repmat( ' ', [nr,stride(end)] );
    
    % Fill columns one by one
    output(:,1:length(sep.beg) ) = repmat( sep.beg, [nr,1] );
    output(:,(end-length(sep.row)):(end-1) ) = repmat( sep.row, [nr,1] );
    
    for c = 1:nc
        for r = 1:nr
            w = widths(r,c);
            output( r, stride(c)+(0:w-1) ) = V{r,c};
        end
        
        if c < nc
            output(:,(stride(c)+colwid(c)):(stride(c+1)-1) ) = repmat( sep.val, [nr,1] );
        end
    end
    
    % Last edit
    switch format
        case {'matlab','default'}
            output(1,1) = '[';
            output(end,end-2) = ']';
    end
    
    % print to console if no output
    if nargout == 0, disp(output); end

end
