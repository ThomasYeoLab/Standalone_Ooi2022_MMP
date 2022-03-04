classdef List < handle
% 
% A simple non-optimized and non-exhaustive version of Python lists.
%
% Contact: jhadida [at] fmrib.ox.ac.uk
    
    properties (SetAccess = protected)
        list = {};
    end
    
    properties (Dependent)
        len;
    end
    
    methods
        
        function self = List( list )
            self.clear();
            if nargin > 0
                self.assign(list); 
            end
        end
        
        % Remove all contents
        function clear(self)
            self.list = {};
        end
        function l = clone(self)
            l = dk.obj.List(self.list);
        end
        
        % Number of elements
        function l = get.len(self)
            l = length(self.list);
        end
        function b = empty(self)
            b = self.len == 0;
        end
        
        % Get element
        function e = get(self,i)
            e = self.list{i};
        end
        
        % Add elements
        function self = assign(self,l)
            self.list = l;
        end
        function self = append(self,e)
            self.list = [ self.list, e ];
        end
        function self = prepend(self,e)
            self.list = [ e, self.list ];
        end
        
        % Remove the first instance of an element
        function self = remove(self,e)
            
            b = true(1,self.len);
            b( self.find(e) ) = false;
            
            self.list = self.list(b);
        end
        
        % Remove all instances of an element
        function self = remove_all(self,e)
            b = self.find_all(e);
            self.list = self.list(~b);
        end
        
        % Remove duplicates
        function self = remove_duplicates(self)
            self.list = unique(self.list,'stable');
        end
        
        % Find the first element that matches
        function b = has(self,e)
            b = ismember(e,self.list);
        end
        function i = find(self,e)
            [~,i] = ismember(e,self.list);
        end
        
        % Find all matches
        function b = find_all(self,e)
            b = ismember(self.list,e);
        end
        
        % Count the number of matches
        function c = count(self,e)
            c = sum(self.find_all(e));
        end
        
        % Apply function to all elements and return the result
        function out = map(self,fhandle,uniform)
            if nargin < 3, uniform=false; end
            out = cellfun( fhandle, self.list, 'UniformOutput', uniform );
        end
        
        % Apply function to all elements and overwrite internal list
        function self = apply(self,fhandle)
            self.list = cellfun( fhandle, self.list, 'UniformOutput', false );
        end
        
    end
    
end
