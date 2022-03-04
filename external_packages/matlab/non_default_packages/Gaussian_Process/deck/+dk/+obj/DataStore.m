classdef DataStore < handle
%
% dk.obj.DataStore()
%
% Bind to a folder on the file-system, and load/save from it, find patterns, etc.
% You can get more information about particular functions by typing:
%   help dk.obj.DataStore.NAME_OF_FUNCTION
% 
% Construction:
%   assign, clear
%
% Load/save:
%   load, save
%
% Other:
%   exists, find
%
% JH

    properties
        folder; % the folder bound to the datastore
    end
    
    methods
        
        function self = DataStore(varargin)
            self.clear();
            if nargin > 0
                self.assign(varargin{:});
            end
        end
        
        function clear(self)
            self.folder = [];
        end
                
        function assign(self,folder,create)
        %
        % assign(self,folder,create=false)
        %
        % Binds input folder to datastore instance.
        % Input folder is resolved (follow symlinks) beforehand.
        % If create=false, and folder does not already exist, an error is thrown.
        % No issue if create=true and folder already exists.
        % 
        
            if nargin < 3, create=false; end
            
            folder = dk.fs.realpath(folder);
            if create && ~dk.fs.isdir(folder)
                dk.assert( mkdir(folder), '[dk.Datastore] Could not create folder "%s".', folder );
                dk.info('[dk.Datastore] Created folder "%s".',folder);
            end
            
            dk.assert( dk.fs.isdir(folder), '[dk.Datastore] Folder "%s" not found.', folder );
            self.folder = folder;
        end
        
        function f = file(self,varargin)
        % Full path to file (extension MUST be set manually)
            f = fullfile(varargin{:});
            if f(1) ~= filesep
                f = fullfile(self.folder,f);
            end
        end
        
        function f = matfile(self,varargin)
        % Full path to MAT file with extension
            f = dk.str.xset( self.file(varargin{:}), 'mat' );
        end
        
        function y = exists(self,varargin)
        % Check whether relative path exists
            y = dk.fs.isfile( self.file(varargin{:}) );
        end
        
        function f = find(self,varargin)
        % Find pattern in folder
            f = dir(fullfile( self.folder, varargin{:} ));
        end
        
        function move(self,src,dst)
        %
        % Move file
        %
            
            src = self.file(src);
            dst = self.file(dst);
            
            dk.reject( dk.fs.isfile(dst), 'Destination already exists.' );
            movefile( src, dst );
        end
        
        function remove(self,name)
        %
        % Remove file
        
            name = self.file(name);
            if dk.fs.isfile(name)
                delete(name);
            else
                warning( 'File not found: %s', name );
            end
        end
        
        function f = save(self,name,varargin)
        %
        % save(self,name,varargin)
        %
        % Save input to f = self.matfile(name).
        % Input can either be a struct, or a key/value list.
        % MAT file is saved with -v7 option.
        %
            
            dk.reject( isempty(self.folder), '[dk.Datastore] Folder is not set.' );
            
            % set MAT filename
            f = self.matfile(name);
            dk.reject('w', dk.fs.isfile(f), '[dk.Datastore] File "%s" will be overwritten.', f );
            
            % parse input to be saved
            if nargin == 3 && isstruct(varargin{1})
                % either a structure
                data = varargin{1};
            else
                % or key/value pairs
                data = dk.c2s( varargin{:} );
            end
            
            % save data
            dk.info('[dk.Datastore] Saving to "%s"...',f);
            dk.save( f, data );
            
        end
        
        function varargout = load(self,name,varargin)
        %
        % load(self,name,varargin)
        %
        % Load self.matfile(name) from the storage folder.
        % Specific variables can be retrieved by specifying them in input.
        % If the fieldname does not exist, the default value is [].
        %
        % Several outputs possible:
        %
        %   x = load('myfile.mat','foo'); % x=foo
        %   x = load('myfile.mat','foo','bar'); % x=struct({foo,bar})
        %   [x,y] = load('myfile.mat','foo','bar'); % x=foo and y=bar
        %   [x,y] = load('myfile.mat','foo','bar','baz'); % x=foo and y=bar
        %
            
            dk.reject( isempty(self.folder), '[dk.Datastore] Folder is not set.' );
            
            % load data
            name = self.matfile(name);
            dk.info('[dk.Datastore] Loading from "%s"...',name);
            
            varargout = cell(1,nargout);
            [varargout{:}] = dk.load(name,varargin{:});
            
        end
        
    end
    
end
