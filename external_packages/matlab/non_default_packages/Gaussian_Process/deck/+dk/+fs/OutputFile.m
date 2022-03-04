classdef OutputFile < handle & dk.fs.File
%
% A derived class from File with a specialised interface for writing.
% The functionalities implemented include:
%   - line-by-line writing
%   - character delimited contents
%   - formated output
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    methods
        
        % Constructor
        function self = OutputFile( name, perm, varargin )
        if nargin > 0
            
            if nargin < 2, perm = 'a'; end
            self.open( name, perm, varargin{:} );
        end
        end
        
        % Simple write method
        function write(self,txt)
            fwrite( self.id, txt );
        end
        
        % Formated print
        function printf(self,format,varargin)
            fprintf( self.id, format, varargin{:} );
        end
        
        % Formated print of values
        function printv(self,format,vals)
            fprintf( self.id, format, vals(:) );
        end
        
        % Write comma-separated values
        function write_csv(self,format,vals)
            self.printv( sprintf('%s, ',format), vals );
        end
        
        % Print line
        function println(self,line)
            fprintf( self.id, '%s\n', line );
        end
        function write_line(self,line)
            self.println(line);
        end
        
        % Write lines
        function write_lines(self,lines)
            self.join(lines);
        end
        
        % Join lines with delimiter
        function join(self,lines,sep)
            if nargin < 3, sep = '\n'; end
            fwrite( self.id, strjoin(lines,sep) );
        end
        
    end
    
end
