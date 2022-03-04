classdef InputFile < handle & dk.fs.File
%
% A derived class from File with a specialised interface for reading.
% The typical reading methods are implemented (line by line, split lines and manual scanning).
%
% Contact: jhadida [at] fmrib.ox.ac.uk


    methods
        
        % Constructor
        function self = InputFile( name, perm, varargin )
        if nargin > 0
            
            if nargin < 2, perm = 'r'; end
            self.open( name, perm, varargin{:} );
        end
        end
        
        % Read next line
        function str = readline(self,remove_newlines)
            
            if nargin < 2, remove_newlines = true; end
            
            if remove_newlines
                str = fgetl( self.id );
            else
                str = fgets( self.id );
            end
        end
        
        % Read all lines at once
        function lines = readlines(self)
            txt   = fread( self.id, '*char' );
            lines = regexp( txt, '[\n]+', 'split' );
        end
        
        % Read formated input
        function tok = scan(self,varargin)
            tok = fscanf( self.id, varargin{:} );
        end
        
    end
    
end
