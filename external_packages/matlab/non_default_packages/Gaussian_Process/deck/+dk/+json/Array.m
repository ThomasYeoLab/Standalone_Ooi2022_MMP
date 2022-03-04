classdef Array < handle
    
    properties (SetAccess = private)
        items
    end
    
    properties (Dependent)
        len
    end
    
    methods
        
        function self = Array()
            self.clear();
        end
        
        function clear(self)
            self.items = {};
        end
        
        function n = get.len(self)
            n = numel(self.items);
        end
        
        function self = append(self,item)
            self.items{end+1} = item;
        end
        
    end
    
end