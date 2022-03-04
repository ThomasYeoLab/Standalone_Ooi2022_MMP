classdef Reference < handle
%
% Very simple reference wrapper.

    properties
        data;
    end
    
    methods
        
        function self = Reference(value)
            self.data = value;
        end
        
        function n = numel(self)
            n = numel(self.data); 
        end
        function n = size(self,k)
            n = size(self.data);
            if nargin > 1, n = n(k); end
        end
        function n = end(self,k,n)
            n = size(self.data,k);
        end
        
        function out = subsref(self,varargin)
            out = subsref( self.data, varargin{:} );
        end
        
        function self = subsasgn(self,varargin)
            self.data = subsasgn( self.data, varargin{:} );
        end
        
        function disp(self)
            disp(self.data);
        end
        function d = dereference(self)
            d = self.data;
        end
        function d = extract(self)
            d = self.data;
        end
        
    end
    
end
