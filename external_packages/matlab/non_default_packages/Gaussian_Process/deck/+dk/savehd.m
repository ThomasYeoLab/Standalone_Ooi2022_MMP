function savehd( fname, varargin )
%
% Helper function to save HF5 files:
%   - saves with -v7.3 (HDF5) binary format without compression;
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
% See also: dk.save, dk.c2s
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
    save( fname, '-struct', 'data', '-nocompression', '-v7.3' );

end