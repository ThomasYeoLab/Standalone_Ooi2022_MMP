classdef Object < handle
    
    properties (SetAccess = private)
        fields
        values
    end
    
    properties (Dependent)
        nfields
    end
    
    methods
        
        function self = Object()
            self.clear();
        end
        
        function clear(self)
            self.fields = {};
            self.values = {};
        end
        
        function n = get.nfields(self)
            n = numel(self.fields);
        end
        
        function y = empty(self)
            y = self.nfields==0;
        end
        
        function self = add_field(self,field,value)
            self.fields{end+1} = field;
            self.values{end+1} = value;
        end
        
    end
    
end