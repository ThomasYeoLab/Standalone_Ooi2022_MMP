classdef File < handle
%
% Class for general-purpose management of Matlab file handles.
% The storage is minimal (just the handle ID), but the class implements useful functionality such as:
%   - handle state (open/close/error)
%   - path-related information (name,folder,size,extension, etc)
%   - reading carret position
%
% Note that the handle is automatically closed on destruction of a File object.
% TODO: test what happens if several objects reference the same handle, and one gets destroyed.
%
% Contact: jhadida [at] fmrib.ox.ac.uk


    properties (SetAccess = private)
        id = NaN;
    end
    
    properties (Dependent = true)
        fullname;
        dirname;
        filename;
        extension;
    end
    
    methods
        
        % Constructor
        function self = File()
        end
        
        % Destructor
        function delete(self)
            self.close();
        end
        
        % Open new file
        function open(self,fname,varargin)
            self.close();
            self.id = fopen( fname, varargin{:} );
        end
        
        % Close current file, if any
        function close(self)
            if self.is_open()
                fclose( self.id ); 
                self.id = NaN;
            end
        end
        
    end
    
    % File info
    methods
        
        function str = get.fullname(self)
            str = ''; 
            if self.is_open()
                str = fopen( self.id );
            end
        end
        
        function i = info(self)
            i = dir( self.fullname );
        end
        
        function [directory,name,ext] = filepath(self)
            [directory,name,ext] = fileparts( self.fullname );
        end
        
        function str = get.dirname(self)
            str = self.filepath();
        end
        
        function str = get.filename(self)
            [~,str] = self.filepath();
        end
        
        function str = get.extension(self)
            [~,~,str] = self.filepath();
        end
        
    end
    
    % File ops
    methods
        
        function status = seek(self,pos,offset)
            if nargin < 3, offset = -1; end
            status = fseek( self.id, pos, offset );
        end
        
        function pos = tell(self)
            pos = ftell( self.id );
        end
        
    end
    
    % Tests
    methods
    
        function yes = is_open(self)
            yes = ~isnan(self.id) && self.id >= 3;
        end
        
        function yes = is_eof(self)
            yes = feof( self.id );
        end
        
        function msg = last_error(self)
            msg = ferror( self.id );
        end
        
    end
    
end
