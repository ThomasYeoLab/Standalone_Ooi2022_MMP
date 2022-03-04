classdef Library < dk.env.AbstractManager
%
% Class for managing the dynamic library path.
% 
% Use "reload" to set the internal state of this Matlab object from the system's environment variable.
% Use "commit" to overwrite the system's environment variable with the internal state of this object.
%
% SEE ALSO: AbstractManager
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    methods
        
        function self = Library()
            self.clear();
            self.reload();
        end
        
        function n = name(self)
            n = dk.env.ld_name('library');
        end
        
        function commit(self)
           setenv( self.name, strjoin( self.list, pathsep )); 
        end
        
        function self = reload(self)
            self.list = strsplit( getenv(self.name), pathsep );
        end
        
    end
    
end
