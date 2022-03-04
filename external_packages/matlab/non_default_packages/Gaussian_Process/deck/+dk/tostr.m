function s = tostr( v, fmt )
%
% s = dk.tostr( v, fmt )
%
% Convert input to string representation.
% Second input is used to print numeric values.
%
% Inputs can be arrays (logical or numeric), in which case they should be 
% printed in a way that can be copy-pasted in the console to define a new 
% variable.
%
% If input is a cell, then to_string is called on each element and the function
% returns a cellstring.
%
% If you want more control over the string representation of arrays, cell arrays 
% and even tables, check out dk.util.array2str.
%
% JH

    if nargin < 2, fmt = []; end

    % Input is a string, do nothing
    if ischar(v)
        s = v;
    
    % Input is numeric
    elseif isnumeric(v)
        switch numel(v)
            case 0
                s = '';
            case 1
                if ischar(fmt)
                    s = sprintf( v, fmt );
                else
                    s = num2str( v );
                end
            otherwise
                s = dk.util.array2str( v, [], 'num', fmt );
        end
        
    % Input is logical
    elseif islogical(v)
        switch numel(v)
            case 0
                s = '';
            case 1
                switch fmt
                    case {'yn','ny'}
                        s = {'yes','no'};
                    case {'bin','digit','%d'}
                        s = {'0','1'};
                    otherwise
                        s = {'false','true'};
                end
                s = s{1+v};
            otherwise
                s = dk.util.array2str( double(v), [], 'num', '%d' );
        end
        
    % Input is a cell, apply to each element (returns a cell of strings)
    elseif iscell(v)
        s = dk.mapfun( @(x) dk.tostr(x,fmt), v, false );

    % Convert tables to string
    elseif istable(v)
        s = dk.util.array2str( v, [], 'num', fmt );
        
    % Other unsupported cases
    else
        error( 'Dont know how to convert value to string.' );
    end

end
