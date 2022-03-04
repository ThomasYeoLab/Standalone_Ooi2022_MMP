classdef GeoData_NNS < handle
%
% dk.obj.GeoData_NNS
%
% Nearest-neighbour search on data associated with spatial coordinates.
% This is currently not a dynamical structure (ie, not suitable for streams).
%
% Initialisation:
%   obj.init( coord, data ) where
%       coord   Npts x Ndim matrix
%        data   1 x Npts cell or matrix
%
% Find nearest neighbour with:
%   [idx,dst] = find( x, tol=1e-12 )
%   
% Get data associated with nearest-neighbour with:
%   [data,idx] = get_data( x, tol=1e-12 )
%
% JH

    properties
        coord 
        data
        access
        nns
    end
    
    properties (Transient,Dependent)
        npts, ndim
    end
    
    methods
        
        function self = GeoData_NNS(varargin)
            if nargin > 0
                self.init(varargin{:});
            end
        end
        
        function n = get.npts(self), n = numel(self.data); end
        function n = get.ndim(self), n = size(self.coord,2); end
        
        function init(self,coord,data)
        %
        % init(coord,data)
        %
        % (Re-)initialise object with specified points and associated data.
        %
        % coord  Npts x Ndim matrix of coordinates
        %  data  1xNpts cell or vector
        %
            
            assert( numel(data)==size(coord,1), 'Bad input size.' );
            
            self.coord = coord;
            self.data = data;
            self.nns = createns( coord );
            
            % keep track of data access
            self.access = false(1,self.npts);
            
        end
        
        function [idx,dst] = find(self,x,tol)
        %
        % [idx,dst] = find(x,tol=1e-12)
        %
        % Index of closest point if its distance is within tolerance, otherwise 0.
        %
        
            if nargin < 3, tol=1e-12; end
            
            [idx,dst] = self.nns.knnsearch(x,'K',1);
            idx = idx .* (dst <= tol);
            
        end
        
        function [y,idx] = get_data(self,x,tol)
        %
        % [y,idx] = get_data(x,tol)
        %
        % Get data associated with nearest neighbour, and throw error if nothing is found.
        %
            
            if nargin < 3, tol=1e-12; end
        
            idx = self.find(x,tol);
            assert( all(idx > 0), 'Nearest neighbour distance above limit threshold.' );
            
            self.access(idx) = true;
            y = dk.getelem(self.data, idx);
            
        end
        
    end
    
end