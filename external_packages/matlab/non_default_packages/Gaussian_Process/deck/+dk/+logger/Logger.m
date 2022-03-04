classdef Logger < handle
%
% Simple logging implementation, heavily inspired by:
%   https://github.com/optimizers/logging4matlab
%
% Logging levels are:
%   all
%   trace
%   debug
%   info
%   warning
%   error
%   critical
%   off
%
% To activate file-backup, use setFile(filename).
%
% Config options are:
%
%   fileLevel
%   consoleLevel
%       Control logging level.
%       DEFAULT: info
%
%   nodate
%       Do not show date-info when printing to console.
%       DEFAULT: false
%
%   lvlchar
%       Show only a single char to indicate log-level in console.
%       DEFAULT: false
%
%   stdepth
%       Systematic offset for stack-depth.
%       DEFAULT: 1
%
% JH

    properties (Constant)
        
        LEVEL = struct( ...
            'all',      1, ...
            'trace',    2, ...
            'debug',    3, ...
            'info',     4, ...
            'warning',  5, ...
            'error',    6, ...
            'critical', 7, ...
            'off',      8 ...
        );
        
    end
    
    properties 
        fileLevel
        consoleLevel
        
        nodate
        lvlchar
        stdepth
    end
    
    properties (SetAccess = private)
        name
        file
        datefmt
        
        backup % backup state to be used with saveState/resetState
    end
    
    % -----------------------------------------------------------------------------------------
    % management method
    % -----------------------------------------------------------------------------------------
    methods
        
        function self = Logger(varargin)
            self.reset(varargin{:});
        end
        
        function self = reset(self,name,varargin)
            assert( ischar(name) && ~isempty(name), 'Name should be a string.' );
            opt = dk.getopt( varargin, ...
                'file', [], 'flevel', 'info', 'clevel', 'info', ...
                'nodate', false, 'lvlchar', false, 'stdepth', 1, ...
                'datefmt', 'yyyy-mm-dd HH:MM:SS.FFF' ...
            );
            
            % internals
            self.name = name;
            self.file = struct('path', opt.file, 'id', -1);
            self.datefmt = opt.datefmt;
            
            % options
            self.nodate = opt.nodate;
            self.lvlchar = opt.lvlchar;
            self.stdepth = opt.stdepth;
            
            % set log levels
            self.fileLevel = opt.flevel;
            self.consoleLevel = opt.clevel;
            
            % clear previous backups
            self.backup = [];
            
            % open file if any
            self.open();
        end
        
        % log level
        function set.fileLevel(self,val)
            val = lower(val);
            assert( isfield(self.LEVEL,val), 'Invalid level.' );
            self.fileLevel = val;
        end
        
        function set.consoleLevel(self,val)
            val = lower(val);
            assert( isfield(self.LEVEL,val), 'Invalid level.' );
            self.consoleLevel = val;
        end
        
        function y = ignoreLogging(self)
            y = strcmp(self.fileLevel,'off') && strcmp(self.consoleLevel,'off');
        end
        
        % state
        function b = saveState(self)
            f = {'fileLevel', 'consoleLevel', 'nodate', 'lvlchar', 'stdepth'};
            n = numel(f);
            
            b = struct();
            for i = 1:n
                b.(f{i}) = self.(f{i});
            end
            self.backup = b;
        end
        
        function self = resetState(self,b)
            f = {'fileLevel', 'consoleLevel', 'nodate', 'lvlchar', 'stdepth'};
            n = numel(f);
            
            if nargin < 2
                b = self.backup;
            else
                self.backup = b;
            end
            assert( dk.is.struct(b,f), 'Bad state.' );
            for i = 1:n
                self.(f{i}) = b.(f{i});
            end
        end
        
        % depth
        function self = incDepth(self,k)
            if nargin < 2, k=1; end
            self.stdepth = self.stdepth + k;
        end
        function self = decDepth(self,k)
            if nargin < 2, k=1; end
            self.stdepth = self.stdepth - k;
        end
        
        % file
        function y = hasFile(self)
            y = ~isempty(self.file.path);
        end
        
        function y = isFileOpen(self)
            y = self.hasFile() && (self.file.id > -1);
        end
        
        function self = setFile(self,fpath)
            self.open(fpath);
        end
        
    end
    
    % -----------------------------------------------------------------------------------------
    % logging methods
    % -----------------------------------------------------------------------------------------
    methods
        
        function self = trace(self, varargin)
            self.write('t', self.stdepth, varargin{:});
        end

        function self = debug(self, varargin)
            self.write('d', self.stdepth, varargin{:});
        end

        function self = info(self, varargin)
            self.write('i', self.stdepth, varargin{:});
        end

        function self = warn(self, varargin)
            self.write('w', self.stdepth, varargin{:});
        end

        function self = error(self, varargin)
            self.write('e', self.stdepth, varargin{:});
        end

        function self = critical(self, varargin)
            self.write('c', self.stdepth, varargin{:});
        end
        
        function suc = assert(self, chan, cdt, varargin)
            assert( nargin >= 3, 'At least two inputs required.' );
            try
                lvl = self.match_level(chan);
                lvl = lvl(1);
                msg = sprintf(varargin{:});
            catch
                lvl = 'e';
                msg = sprintf(cdt,varargin{:});
                cdt = chan;
            end
            
            suc = all(logical(cdt));
            if ~suc
                self.write(lvl, self.stdepth, msg);
            end
        end
        
        function suc = reject(self, chan, cdt, varargin)
            assert( nargin >= 3, 'At least two inputs required.' );
            try
                lvl = self.match_level(chan);
                lvl = lvl(1);
                msg = sprintf(varargin{:});
            catch
                lvl = 'e';
                msg = sprintf(cdt,varargin{:});
                cdt = chan;
            end
            
            suc = ~any(logical(cdt));
            if ~suc
                self.write(lvl, self.stdepth, msg);
            end
        end

    end

    methods (Hidden)
        
        % open/close log file
        function self = open(self,fpath)
            if nargin < 2
                fpath=self.file.path; 
            end
            self.close();
            if isempty(fpath)
                self.file.path = [];
                self.file.id = -1;
            else
                self.file.path = fpath;
                self.file.id = fopen(fpath,'a');
            end
        end
        
        function self = close(self)
            if self.isFileOpen()
                fclose(self.file.id);
                self.file.id = -1;
            end
        end
        
        % determine level from input string
        function [level,num] = match_level(self,level)
            assert( ischar(level), 'Input should be a string.' );
            switch lower(level)
                case {'a','all'}
                    level = 'all';
                case {'t','trace'}
                    level = 'trace';
                case {'d','dbg','debug'}
                    level = 'debug';
                case {'i','info'}
                    level = 'info';
                case {'w','warn','warning'}
                    level = 'warning';
                case {'e','err','error'}
                    level = 'error';
                case {'c','critical'}
                    level = 'critical';
                otherwise
                    error( 'Unknown level: "%s"', level );
            end
            num = self.LEVEL.(level);
        end
        
        % generic logging function
        function write(self,level,depth,message,varargin)
            
            % early cancelling
            if self.ignoreLogging()
                return;
            end
            
            % process inputs
            [level,levelnum] = self.match_level(level);
            if isempty(depth), depth=self.stdepth; end
            
            % get caller info
            depth = depth + 2;
            [dbs,~] = dbstack('-completenames');
            if length(dbs) >= depth
                dbs = dbs(depth:end);
                caller = arrayfun( @stack2caller, dbs, 'UniformOutput', false );
                caller = strjoin( caller, '; ' );
            else
                dbs = dbs(end);
                caller = 'Console';
            end
            
            % build log line
            mstr = sprintf( message, varargin{:} );
            dlen = length( self.datefmt );
            dstr = datestr( now(), self.datefmt );
            dstr = sprintf( ['%-' num2str(dlen) 's'], dstr );
            
            lstr = upper(level); 
            if self.lvlchar
                lstr = lstr(1);
            else
                lstr = sprintf( '%-8s', lstr );
            end
            
            % write to file
            if self.isFileOpen() && self.LEVEL.(self.fileLevel) <= levelnum
                logline = sprintf( '%s %s [%s] %s', dstr, lstr, caller, mstr );
                fprintf( self.file.id, '%s\n', logline );
            end
            
            % write to console
            if self.LEVEL.(self.consoleLevel) <= levelnum
                if self.nodate
                    logline = sprintf( '%s [%s] %s', lstr, caller, mstr );
                else
                    logline = sprintf( '%s %s [%s] %s', dstr, lstr, caller, mstr );
                end
                % impossible to print in yellow, so print warnings in red too
                if levelnum >= self.LEVEL.warning
                    fprintf( 2, '%s\n', logline );
                else
                    fprintf( '%s\n', logline );
                end
            end
            
            % take action
            switch level
                case 'error'
                    ME = MException( ...
                        'deck:Logger:error', ...
                        sprintf('(Triggered in logger: %s)', self.name) ...
                    );
                    throwAsCaller(ME);
                case 'critical'
                    fprintf( 2, 'Critical error triggered in logger: %s\n', self.name ); 
                    exit(1);
            end
            
        end
        
    end
    
end

function c = stack2caller(s)
%
% Find out whether the file is inside a module or classpath, and
% format the caller name accordingly.
%

    f = strsplit( s.file, filesep );
    n = numel(f);
    c = cell(1,n);
    
    % special case with nested functions
    fp = dk.str.xrem( f{end} );
    sp = strsplit( s.name, '.' );
    if strcmpi( sp{1}, fp )
        
        % works well with class-methods
        c{1} = strrep( s.name, '.', '@' );
        
    elseif dk.str.startswith( sp{1}, '@(' )
        
        % works well with function handles
        c{1} = [ fp '@(lambda)' ];
        
    else
        
        % build custom path
        c{1} = [ fp '/' strjoin(sp,'@') ];
    end
    
    % iterate path segments
    for i = 2:n
        ci = f{n-i+1};
        if ci(1)=='+' || ci(1)=='@'
            c{i} = [ ci(2:end) '.' ];
        else
            break;
        end
    end
    
    % concatenate
    c = fliplr(c);
    c = horzcat( c{:}, ':', num2str(s.line) );
    
end