classdef Path < dk.env.AbstractManager
%
% Class for managing the general system path.
% 
% Use "reload" to set the internal state of this Matlab object from the system's environment variable.
% Use "commit" to overwrite the system's environment variable with the internal state of this object.
%
% SEE ALSO: AbstractManager
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    methods
        
        function self = Path()
            self.clear();
            self.reload();
        end
        
        function commit(self)
           path(strjoin( self.list, pathsep )); 
        end
        
        function self = reload(self)
            self.list = strsplit( path, pathsep );
        end
        
    end
    
end
