function cmd = jmx_compile( files, options, varargin )
%
% cmd = jmx_compile( files, options, settings... )
%
% Compile C++ files using Mex.
%
% 
% FILES
% -----
%  
%   Either a string or a cell of strings.
%   If a file depends on other files, then needs to be a cellstr with object files last.
%
%
% OPTIONS
% -------
%
%   mex         true   -c         Whether the target source file is a Mex-file.
%                                 I.e. it should have a mexFunction() instead of a main().
%
%   dry         false  -n         Dry-run mode (will not actually compile target files if true).
%   cpp11       true              Set appropriate compiler flags for the C++11 standard.
%   cpp14       false             Idem for the C++14 standard.
%   cpp17       false             Idem for the C++17 standard.
%   mwlapack    false             Setup paths/libs to use Matlab's BLAS/LAPACK.
%   arma        false             Setup paths/libs to use Armadillo.
%   jmx         true              Setup paths/libs to use JMX.
%
%   index32     <auto>            Newer versions of Matlab use 64-bits indices (-largeArrayDims).
%                                 Set to true to use 32-bits legacy indexing (-compatibleArrayDims).
%
%   autojmx     true              If jmx==true, add JMX binary to files list.
%                                 Set to false to specify JMX object manually.
%
%   outdir      pwd    -outdir    The folder in which to put the compiled object.
%   outfile     ''     -ouput     The name of the compiled file.
%   mexopts     ''     -f         Path to an .xml file with custom Mex options.
%
% See the documentation of mex for the following options:
%
%   optimise    true   -O
%   debug       false  -g
%   verbose     false  -v
%   silent      false  -silent
%
%
% SETTINGS
% --------
% 
%   flag                CXXFLAGS    Compiler flags
%   def                 -D          Code flags
%   undef               -U
%   lib                 -l          Library name
%   lpath               -L          Linking path
%   ipath               -I          Include path
%
%
% NOTE:
%
% Repeated settings are overwritten from right to left (i.e. only the last one is considered).
% To specify multiple settings, use cells instead.
%
% For example, to define multiple flags:
%   jmx_compile( ... 'def', {'FOO=5', 'BAR'} )
%
%
% JH

    % process inputs
    if nargin < 2 || isempty(options), options = struct(); end

    files = wrap_cell(files);
    filetest = @(f) any( exist(f,'file') == [2,7] );
    
    assert( iscellstr(files), 'Files ($1) should be a string or cell-string.' );
    
    % JH: dont do this, too inconvenient
    %assert( all(cellfun( filetest, files )), ...
    %    'One or several files not found (please use absolute paths).' );
    
    T = parse_options(options, fileparts(files{1})); % default output dir with target file
    S = parse_settings(varargin{:});
    
    % apply side-effects
    std = 98;
    if T.cpp11, std = 11; end
    if T.cpp14, std = 14; end
    if T.cpp17, std = 17; end
    switch std
        case 11
            S = append(S,'flag','-std=c++11');
        case 14
            S = append(S,'flag','-std=c++14');
        case 17
            S = append(S,'flag','-std=c++17');
    end
    
    if T.jmx
        if T.index32
            S = append(S,'def','JMX_32BIT');
        else
            S = append(S,'def','JMX_64BIT');
        end
        if T.autojmx
            files{end+1} = jmx_path('inc','jmx.o');
        end
    end
    if T.jmx || T.arma 
        S = append(S,'ipath',jmx_path('inc'));
        S = append(S,'lib','ut');
    end
    if T.arma 
        S = append(S,'lib','mwlapack'); % provided by Matlab
        S = append(S,'lib','mwblas');
    end
    [F,D,U,L,l,I] = process_settings(S);
    
    % build command
    cmd = {};
    
    if T.index32
        cmd{end+1} = '-compatibleArrayDims';
    else
        cmd{end+1} = '-largeArrayDims';
    end
    
    if ~T.mex,      cmd{end+1} = '-c'; end
    if T.optimise,  cmd{end+1} = '-O'; end
    if T.debug,     cmd{end+1} = '-g'; end
    if T.dry,       cmd{end+1} = '-n'; end
    if T.verbose,   cmd{end+1} = '-v'; end
    if T.silent,    cmd{end+1} = '-silent'; end
    
    if ~isempty(T.mexopts)
        assert( filetest(T.mexopts), 'Mex options file not found.' );
        cmd{end+1} = '-f';
        cmd{end+1} = addquotes(T.mexopts);
    end
    if ~isempty(T.outdir)
        assert( filetest(T.outdir), 'Output folder not found.' );
        cmd{end+1} = '-outdir';
        cmd{end+1} = addquotes(T.outdir);
    end
    if ~isempty(T.outfile)
        cmd{end+1} = '-output';
        cmd{end+1} = addquotes(T.outfile);
    end
    
    files = dk.mapfun( @addquotes, files, false );
    cmd = horzcat( cmd, F, D, U, L, l, I );
    cmd = cmd(cellfun( @(x) ~isempty(x), cmd ));
    cmd = horzcat( cmd, files );

    disp(['mex ' strjoin(cmd)]);
    mex(cmd{:});
    
end

function out = parse_options(in,filedir)

    % set defaults
    out.outdir  = filedir;
    out.outfile = '';
    out.mexopts = '';
    
    out.mex = true;
    out.dry = false;
    
    out.jmx = true;
    out.arma = false;
    out.cpp11 = true;
    out.cpp14 = false;
    out.cpp17 = false;
    out.autojmx = true;

    % detect integer width
    out.index32 = dk.env.is32bits();

    out.optimise = true;
    out.verbose = false;
    out.silent = false;
    out.debug = false;
    
    % overwrite defaults
    f = fieldnames(in);
    n = numel(f);
    for i = 1:n
        dk.assert( isfield(out,f{i}), 'Unknown option: %s', f{i} );
        out.(f{i}) = in.(f{i});
    end
    
    % deal with spelling variants
    if isfield(out,'optimize')
        assert( ~isfield(in,'optimise'), 'Conflicting spelling of "optimise".' );
        out.optimise = out.optimize;
    end

end

function c = wrap_cell(varargin)
    if nargin == 1 && iscell(varargin{1})
        c = varargin{1};
    else
        c = varargin;
    end
end

function x = append(x,f,v)
    if isfield(x,f)
        x.(f){end+1} = v;
    else
        x.(f) = {v};
    end
end

function x = addquotes(x)
    x = strtrim(x);
    if ~isempty(x) && x(1) ~= '"'
        x = ['"' x '"'];
    end
end

function s = parse_settings(varargin)

    % turn input into k/v cell
    args = dk.wrap(varargin);
    n = numel(args);
    if n==1 
        args = dk.s2c(args{1});
        n = numel(args);
    end
    
    % check number of elements
    assert( mod(n,2) == 0, 'Inputs should be Name/Value pairs.' );
    n = n/2;
    
    % assign settings
    s = struct();
    for i = 1:n
        name  = args{2*i-1};
        value = wrap_cell(args{2*i});
        assert( iscellstr(value) && ~isempty(value), 'Expected a non-empty cell of strings.' );
        
        switch lower(name)
            case {'flag'}
                s.flag = value;
            case {'lnk','link'}
                s.link = value;
            case {'def','define'}
                s.def = value;
            case {'undef','undefine'}
                s.undef = value;
            case {'lib','library'}
                s.lib = value;
            case {'lpath','ldpath'}
                s.lpath = value;
            case {'ipath','inc','incpath'}
                s.ipath = value;
            otherwise
                error('Unknown setting: %s', name);
        end
    end
    
end

function [flag, def, undef, lpath, lib, ipath] = process_settings(s)
    
    prefix = @(c,p) cellfun( @(s) [p s], unique(c), 'UniformOutput', false );

    if isfield(s,'flag')
        flag = {['CXXFLAGS="$CXXFLAGS ' strjoin(s.flag) '"']};
    else
        flag = {};
    end
    
    if isfield(s,'def')
        def = prefix( s.def, '-D' );
    else
        def = {};
    end
    
    if isfield(s,'undef')
        undef = prefix( s.undef, '-U' );
    else
        undef = {};
    end
    
    if isfield(s,'lpath')
        lpath = cellfun( @addquotes, s.lpath, 'UniformOutput', false );
        lpath = prefix( lpath, '-L' );
    else
        lpath = {};
    end

    if isfield(s,'lib')
        lib = prefix( s.lib, '-l' );
    else
        lib = {};
    end
    
    if isfield(s,'ipath')
        ipath = cellfun( @addquotes, s.ipath, 'UniformOutput', false );
        ipath = prefix( ipath, '-I' );
    else
        ipath = {};
    end

end
