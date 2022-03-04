classdef Array < handle
%
% Very simple handle class wrapping around Matlab matrices.
% This is useful if you want to pass a matrix around without copying it (eg to implement memory pools).
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    properties (SetAccess = public)
        data;
    end
    
    properties (Dependent=true)
        dims, nrows, ncols, nelem;
    end
    
    methods
        
        function self = Array( varargin )
            if nargin == 0
                self.clear();
            else
                self.create(varargin{:});
            end
        end
        
        function d = get.dims (self), d = size(self.data); end
        function n = get.nrows(self), n = size(self.data,1); end
        function n = get.ncols(self), n = size(self.data,2); end
        function n = get.nelem(self), n = numel(self.data); end
        
        function clear(self)
            self.data = [];
        end
        
        function a = clone(self)
            a = dk.obj.Array();
            a.data = self.data; % NOTE: this doesn't work with handle objects
        end
        
        function create(self,dims,val)
            if nargin < 3, val = double(0); end
            self.data = repmat(val,dims);
        end
        
    end
    
end
