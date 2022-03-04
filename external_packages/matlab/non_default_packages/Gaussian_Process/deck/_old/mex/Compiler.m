classdef Compiler < handle
% 
% dk.obj.Compiler()
%
% A very useful class to compile C++ libraries and Mex files using the function mex.
% Most relevant options are available as public attributes, and methods allow to:
%   - define/undefine macros
%   - add/remove libraries or include paths
%
% Options set as properties:
%     out_name  -output out_name
%      out_dir  -outdir out_dir
%     opt_file  -f opt_file
%    use_cpp0x  CXXFLAGS="$CXXFLAGS -std=c++0x"
% use_64b_size  -compatibleArrayDims / -largeArrayDims
%     mex_file  -c
%      dry_run  -n
%     optimize  -O
%        debug  -g
%      verbose  -v
%       silent  -silent
%
% Methods for flags, defines, includes, etc:
%   flag: to be included in CXXFLAGS
%   -D  (un)define
%   -l  (add|rem)_lib
%   -L  (add|rem)_inc
%   -I  (add|rem)_lib_path
%
%
% To compile a typical application:
%   set all desired options, flags, etc
%   set all files (start with the .cxx and then .o if any)
%   make sure you set mex_file=true if you want to produce a Mex file
%   run build() to update the internal state
%   run print() to show the command built
%   run compile() to do it
%
% JH

    properties (SetAccess = public)
        
        % out_dir, out_name: specify output names
        % opt_file: full path to a custom mexopts.sh
        out_dir, out_name, opt_file;
        
        % use_64b_size: use uint64_t types for matrix indexing (cf -largeArrayDims)
        % use_cpp0x: define compiler option -std=c++0x
        use_64b_size, use_cpp0x;
        
        % if true,  compilation produces a Mex-file
        % if false, option -c is used, producing an ordinary object file
        mex_file;
        
        % compilation mode
        dry_run, optimize, debug;
        
        % console output
        verbose, silent;
        
    end
    
    properties (SetAccess = protected)
        
        command, files;
        def, undef, flags;
        lpath, ipath, lib;
        
    end
    
    
    methods
        
        function self = Compiler()
            self.reset();
        end
        
        function self=default_settings(self)
            
            self.out_dir       = pwd;
            self.out_name      = '';
            self.opt_file      = '';

            self.mex_file      = true;
            self.optimize      = false;
            self.dry_run       = false;
            self.verbose       = false;
            self.use_cpp0x     = false;
            self.silent        = false;
            self.debug         = false;
            
            % detect integer width
            self.use_64b_size = dk.env.is64bits();
            
        end
        
        function self=reset(self)
            
            self.default_settings();

            self.command       = dk.obj.List();
            self.def           = struct();
            self.undef         = dk.obj.List();
            self.flags         = dk.obj.List();
            self.files         = dk.obj.List();
            self.lpath         = dk.obj.List();
            self.ipath         = dk.obj.List();
            self.lib           = dk.obj.List();
            
        end
        
        function self=build(self)
            
            self.command.clear();
            
            % Mex version
            if self.use_64b_size
                self.command.append('-largeArrayDims');
            else
                self.command.append('-compatibleArrayDims');
            end
            
            % C++11
            if self.use_cpp0x
                self.flag('-std=c++0x');
            end
            
            % Options
            if ~self.mex_file, self.command.append('-c'); end
            if  self.optimize, self.command.append('-O'); end
            if  self.debug,    self.command.append('-g'); end
            if  self.dry_run,  self.command.append('-n'); end
            if  self.verbose,  self.command.append('-v'); end
            if  self.silent,   self.command.append('-silent'); end
            
            % Specify custom option file
            if ~isempty(self.opt_file)
                self.command.append('-f');
                self.command.append(addquotes(self.opt_file));
            end
            
            % Add out dir/name
            if ~isempty(self.out_dir)
                self.command.append('-outdir');
                self.command.append(addquotes(self.out_dir));
            end
            if ~isempty(self.out_name)
                self.command.append('-output');
                self.command.append(addquotes(self.out_name));
            end
            
            % Remove duplicates
            self.flags  .remove_duplicates();
            self.undef  .remove_duplicates();
            self.lpath  .remove_duplicates();
            self.lib    .remove_duplicates();
            self.ipath  .remove_duplicates();
            self.files  .remove_duplicates();
            
            % Flags
            if self.flags.len
                self.command.append([ 'CXXFLAGS="$CXXFLAGS ' strjoin(self.flags.list) '"' ]);
            end
            
            % Defines
            f = fieldnames(self.def);
            for i = 1:length(f)
                v = self.def.(f{i});
                if isempty(v)
                    self.command.append(['-D' f{i}]);
                else
                    self.command.append(['-D' f{i} '=' v ]);
                end
            end
            
            % Undefines
            for i = 1:self.undef.len
                self.command.append(['-U' self.undef.list{i}]);
            end
            
            % Add libraries
            for i = 1:self.lpath.len
                self.command.append(['-L' addquotes(self.lpath.list{i})]);
            end
            for i = 1:self.lib.len
                self.command.append(['-l' self.lib.list{i}]);
            end
            
            % Add includes
            for i = 1:self.ipath.len
                self.command.append(['-I' addquotes(self.ipath.list{i})]);
            end
            
            % Add files
            for i = 1:self.files.len
                self.command.append(addquotes( self.files.list{i} ));
            end
            
        end
        
        function self=print(self)
            self.build();
            disp(['mex ' strjoin(self.command.list)]);
        end
        
        function self=compile(self)
            self.build();
            mex( self.command.list{:} );
        end
        
    end
    
    methods
        
        % Add/remove files to compile
        function self=add_file(self,f)
            self.files.append(f);
        end
        function self=rem_file(self,f)
            self.files.remove_all(f);
        end
        function self=rem_files(self)
            self.files.clear();
        end
        
        % Add compiler flag
        function self=flag(self,f)
            self.flags.append(f);
        end
        
        % Add/remove defines
        function self=define(self,name,val)
            if nargin<3, val=''; end
            assert( ischar(name) && ischar(val), ...
                'name and value should be strings.' );
            
            self.def.(name) = val;
        end
        function self=undefine(self,name)
           self.undef.append( name ); 
        end
        
        % Add/remove library paths
        function self=add_lib_path(self,lp)
            self.lpath.append(lp);
        end
        function self=rem_lib_path(self,lp)
            self.lpath.remove_all(lp);
        end
        
        % Add/remove libraries
        function self=add_lib(self,l)
            self.lib.append(l);
        end
        function self=rem_lib(self,l)
            self.lib.remove_all(l);
        end
        
        % Add/remove includes
        function self=add_inc(self,ip)
            self.ipath.append(ip);
        end
        function self=rem_inc(self,ip)
            self.ipath.remove_all(ip);
        end
        
    end
    
end

function x = addquotes(x)
    x = strtrim(x);
    if ~isempty(x) && x(1) ~= '"'
        x = ['"' x '"'];
    end
end
