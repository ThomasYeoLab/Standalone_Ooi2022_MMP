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
            self.list  = dk.obj.List();
        end
        
        % Get the number of elements in the list
        function n = get.len(self)
            n = self.list.len;
        end
        
        % Check whether l is presently in the list
        function yes = has(self,l)
            yes = self.list.has(l);
        end
        
        % Sanitise directory names
        function l = sanitise(self,l)
            
            if ischar(l)
                l = fullfile(l,filesep); % force ending slash
                l = l(1:end-1); % remove it
            else
                n = numel(l);
                for i = 1:n
                    l{i} = self.sanitise(l{i});
                end
            end
        end
        
        % Check it exists before adding stuff
        function ok = check(self,l)
            
            ok = true;
            if ischar(l)
                if ~dk.fs.isdir(l)
                    warning( '[dk.env] "%s" is not a valid directory, operation aborted.', l );
                    ok = false;
                end
            else
                n = numel(l);
                for i = 1:n
                    ok = ok && self.check( l{i} );
                end
            end
        end
        
        % Append, prepend, remove
        function append(self,x,no_duplicate)
            
            if nargin < 3, no_duplicate=true; end
            
            if ischar(x)
                x = self.sanitise(x);
                if self.check(x) && ~(no_duplicate && self.has(x))
                    self.list.append(x);
                end
            else
                n = numel(x);
                for i = 1:n
                    self.append(x{i},no_duplicate);
                end
            end
        end
        function prepend(self,x,no_duplicate)
            
            if nargin < 3, no_duplicate=true; end
            
            if ischar(x)
                x = self.sanitise(x);
                if self.check(x) && ~(no_duplicate && self.has(x))
                    self.list.prepend(x);
                end
            else
                n = numel(x);
                for i = 1:n
                    self.prepend(x{i},no_duplicate);
                end
            end
        end
        function remove(self,x)
            self.list.remove_all(x);
        end
        
    end
    
end
