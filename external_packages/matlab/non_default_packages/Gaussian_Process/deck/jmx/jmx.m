function cmd = jmx( files, options, varargin )
%
% cmd = jmx( files, options, varargin )
%
% Compile a Mex file using the JMX library.
% Essentially calls jmx_compile with:
%   - including jmx.o object as dependency;
%   - and setting the jmx option.
%
%
% files:    path to Mex file
%           or a cell starting with path to Mex file, followed by object files
%
% options + additional inputs: see jmx_compile for help
%
% See also: jmx_compile
%
% JH

    if nargin < 2, options=struct(); end

    % check input
    if ~iscell(files)
        files = {files};
    end
    assert( iscellstr(files), 'Bad files list.' );
    
    % force jmx option
    options.jmx = true;
    
    % build JMX if needed
    objfile = jmx_path('inc/jmx.o');
    if exist(objfile,'file') ~= 2
        jmx_build();
    end
    
    % call jmx_compile
    cmd = jmx_compile( files, options, varargin{:} );

end