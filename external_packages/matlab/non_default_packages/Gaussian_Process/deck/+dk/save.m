function save( fname, varargin )
%
% Helper function to save MAT files:
%   - saves with -v7 binary MAT format;
%   - no append mode.
%
% USAGE:
%
%   1. Direct save of scalar structures:
%       dk.save( fname, data ); % where data is a scalar struct
%
%   2. Structured save:
%       dk.save( fname, 'field1', value1, 'field2', value2, ... );
%
%
% See also: dk.c2s, dk.savehd
%
% JH

    if nargin == 2
        
        % expect a scalar struct
        data = varargin{1};
        assert( dk.is.struct(data), 'Single input should be a scalar struct.' );
    else
        
        % convert to scalar struct
        data = dk.c2s( varargin{:} );
    end
    
    fname = dk.str.xset( fname, 'mat' );
    save( fname, '-struct', 'data', '-v7' );

end