classdef AbstractManager < handle
%
% Abstract class used to manage paths strings, implementing basic operations such as:
%   - directory name sanitization
%   - directory existence check
%   - append/prepend/remove
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    properties (SetAccess = public)
        list;
    end
    properties (Dependent=true)
        len;
    end
    
    methods (Abstract)
        reload(self);
        commit(self);
    end
    
    methods
        
        % Clear the list
        function clear(self)
            self.list = {};
        end
        
        % Get the number of elements in the list
        function n = get.len(self)
            n = numel(self.list);
        end
        
        % Check whether l is presently in the list
        function yes = has(self,l)
            yes = ismember(self.list,l);
        end
        
        % Keep only those paths in l that are not already in the list
        function l = filter(self,l)
            l = setdiff(l,self.list);
        end
        
        % Sanitise directory names
        function l = sanitise(self,l)
            
            if ischar(l)
                % remove trailing slash
                l = fullfile(l,filesep);
                l = l(1:end-1);
            else
                l = dk.mapfun( @self.sanitise, l, false );
            end
        end
        
        % Check it exists before adding stuff
        function ok = check(self,l)
            
            ok = true;
            if ischar(l)
                if ~dk.fs.isdir(l)
                    warning( '[dk.env] "%s" is not a valid directory, will be ignored.', l );
                    ok = false;
                end
            else
                ok = cellfun( @self.check, l );
            end
        end
        
        % Append, prepend, remove
        function self = append(self,x)
            
            x = self.sanitise(x);
            if ischar(x), x = {x}; end
            x = x(self.check(x));
            assert(iscellstr(x));
            
            self.list = union( self.list, x, 'stable' );
            
        end
        function self = prepend(self,x)
            
            x = self.sanitise(x);
            if ischar(x), x = {x}; end
            x = x(self.check(x));
            assert(iscellstr(x));
            
            self.list = union( x, self.list, 'stable' );
            
        end
        function self = remove(self,x)
            occ = ismember( self.list, x );
            self.list = self.list(~occ);
        end
        
    end
    
end
