classdef Mapping < dk.priv.GrowingContainer
%
% Storage for associating multidimensional coordinates with multivariate data and metadata.
% The storage is allocated and grown automatically to avoid reallocating the arrays too often.
%
%
% ------------------------------
% ## Construction
% 
%   Constructor arguments are forwarded to:
%       reset( ndim, nvar, bsize=100 )
%
%   This method allocates:
%       arrays of NaNs for x and y, 
%       struct array with no fields for meta
%       all-false vector for used
%
%   The block size can be modified manually after construction.
%
%
% ------------------------------
% ## Storage and usage
%
%   The coordinate data is stored in the rows of x  (nmax x ndim).
%   The associated data is stored in the rows of y  (nmax x nvar).
%   The associated metadata is stored in meta as a struct.
%   
%   A data-point is identified by an index k, which corresponds to:
%       a row in x and y, 
%       and a struct in meta.
%   All data associated with a data-point k can be accessed with data(k), which returns three
%   outputs [x,y,meta]. If k is a vector, then the outputs are matrices and struct-arrays.
%   This is useful if you often use x, y and the metadata together; otherwise it is faster to
%   access individual properties directly.
%
%   Properties can be accessed anytime for reading.
%   Particular rows/fields can be edited manually, but DO NOT overwrite fieldnames or the meta
%   member itself. 
%
%   New data-points can be added one by one using the method: 
%       add( x, y, 'Field1',Value1, 'Field2',...)
%   Only x and y are required, the field/value input correspond to metadata.
%   The fieldnames are case-sensitive, and are common to all entries: setting a field 'foo' for 
%   any data-point will cause every other data-point to have a field with the same name.
%   New field names can be set dynamically during usage.
%   When adding a data-point as above, omitted fields are assigned the value [] by default.
%
%   Existing data points can be removed using:
%       rem( k )
%   where k can be a vector of indices.
%   This simply marks those points as unused and does not actually remove them from storage.
%   Indices are preserved when removing points, BUT NOT when using compress().
%   Method compress() actually removes unused points, and re-indexes the points.
%   Use the method find() in order to get all indices currently in use.
%   
%   Multiple entries can be added at once using the method addn() instead, but in
%   that case, only x and y can be assigned (i.e. no metadata). The metadata should
%   then be set manually using
%       meta(index).field = value                               % field-by-field assignment
%       meta(index) = structure                                 % requires all fields to be set
%       meta(index) = dk.struct.merge( meta(index), structure ) % ensures all fields are set
%   or in bulk using 
%       assign( indices, field, value )
%   
%   Finally, all points in-use can be iterated using the method: iter( @callback )
%   The callback should be a function-handle accepting the following inputs:
%       callback( k:index, x:row, y:row, meta:struct )
%   It does not need to return an output, BUT IF IT DOES NOT, you should not collect an output 
%   from the function iter (this will cause an error). 
%   If it does return something, the output is a cell of same length as the number of points 
%   IN USE (that is, the indices in the output cell do not necessarily correspond 
%   to the indices of the points within the instance!). The corresponding indices are returned 
%   as the second output.
%   
%
% See also: dk.priv.GrowingContainer
%
% JH

    properties
        x           % nmax x npts matrix
        y           % nmax x nvar matrix
        meta        % struct-array of metadata
    end
    
    properties (Transient,Dependent)
        npts        % number of points in use
        ndim        % number of columns in x
        nvar        % number of columns in y
    end
    
    % dependent
    methods
        
        function n = get.npts(self), n = self.count; end
        function n = get.ndim(self), n = size(self.x,2); end
        function n = get.nvar(self), n = size(self.y,2); end
        
    end
    
    % main
    methods
        
        function self = Mapping(varargin)
            self.clear();
            if nargin == 1 && isstruct(varargin{1})
                self.unserialise(varargin{1});
            elseif nargin > 1
                self.reset(varargin{:});
            end
        end
        
        function clear(self)
            self.gcClear();
            self.x = [];
            self.y = [];
            self.meta = structcol(0);
        end
        
        % initialise container
        function reset(self,nd,nv,b)
            if nargin < 4, b=100; end
            
            self.gcInit(b);
            self.x = nan( b, nd );
            self.y = nan( b, nv );
            self.meta = structcol(b);
        end
        
        % assign and access
        function k = add(self,x,y,varargin)
            n = size(x,1);
            assert( ismatrix(x) && size(x,2)==self.ndim, 'Bad x.' );
            assert( ismatrix(y) && size(y,2)==self.nvar && size(y,1)==n, 'Bad y.' );
            
            k = self.gcAdd(n);
            self.x(k,:) = x;
            self.y(k,:) = y;
            self.assign(k,varargin{:});
        end
        function [x,y,m] = data(self,k)
            self.chkind(k);
            x = self.x(k,:);
            y = self.y(k,:);
            m = self.meta(k);
        end
        
        % bulk assign of metadata field by copying the value
        function self = assign(self,k,varargin)
            if nargin > 2 && ~isempty(k)
                
                self.chkind(k);
                v = dk.c2s(varargin{:});
                f = fieldnames(v);
                n = numel(f);
                for i = 1:n
                    [self.meta(k).(f{i})] = dk.deal(v.(f{i}));
                end
                
            end
        end
        
        % iterate valid rows
        function [out,idx] = iter(self,callback,idx)
            if nargin < 3, idx = self.find(); end
            ni = numel(idx);
            
            if nargout > 0
                out = cell(1,ni);
                for i = 1:ni
                    k = idx(i);
                    out{i} = callback( k, self.x(k,:), self.y(k,:), self.meta(k) );
                end
            else
                for i = 1:ni
                    k = idx(i);
                    callback( k, self.x(k,:), self.y(k,:), self.meta(k) );
                end
            end
        end
        
    end
    
    % abastract methods
    methods (Hidden)
        
        function childAlloc(self,n)
            nd = self.ndim;
            nv = self.nvar;
            nm = self.capacity;
            
            self.x = vertcat(self.x, nan(n,nd));
            self.y = vertcat(self.y, nan(n,nv));
            self.meta(nm+n) = dk.struct.make( fieldnames(self.meta) );
        end
        
        function childCompress(self,id,remap)
            self.x = self.x(id,:);
            self.y = self.y(id,:);
            self.meta = self.meta(id);
        end
        
    end
    
    % i/o
    methods
        
        function s=serialise(self,file)
            s = self.gcToStruct();
            s.x = self.x;
            s.y = self.y;
            s.meta = self.meta;
            s.version = '0.2';
            if nargin > 1, dk.save(file,s); end
        end
        
        function self=unserialise(self,s)
        if ischar(s), s=load(s); end
        switch s.version
            case {'0.1','0.2'}
                self.x = s.x;
                self.y = s.y;
                self.meta = s.meta;
                self.gcFromStruct(s);
                
            otherwise
                error('Unknown version: %s',s.version);
        end
        end
        
    end
    
end

% Create a nx1 empty struct-array.
function s = structcol(n)
    s = repmat( struct(), n, 1 );
end

