classdef SystemPath < dk.env.AbstractManager
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
        
        function self = SystemPath()
            self.clear();
            self.reload();
        end
        
        function commit(self)
           setenv( 'PATH', strjoin( self.list, pathsep )); 
        end
        
        function self = reload(self)
            self.list = strsplit( getenv('PATH'), pathsep );
        end
        
    end
    
end
