classdef DataArray < dk.priv.GrowingContainer
%
% DataArray objects store matrix data with fixed number of columns, optionally accessible by name,
% as well as a struct-array to store data-fields associated with each row.
%
%
% ------------------------------
% ## Storage
%
%   Data is stored in a matrix with the specified number of columns.
%   This matrix usually has more rows than needed, in order to allow for efficient push operations.
%
%   By default, rows are allocated by block as needed (see GrowingContainer).
%   For example, if more memory is needed is order to push rows, a new block of size bsize is allocated.
%
%   If the number of rows needed is unknown, set a generous block-size (typically in the range 100-1000).
%   The default is 100.
%
%   If you have a reliable upper-bound on the number of rows:
%     - set a rather small block-size at construction time, e.g. obj.bsize = max(10, fix(n/100));
%     - allocate the desired number of rows in advance with obj.reserve(n)
%
%
% ------------------------------
% ## Usage
%
% Construction
%
%   D = dk.ds.DataArray(varargin)
%       -> reset( ncols, bsize=100 )
%       -> reset( colnames, bsize=100 )
%       -> unserialise( filename )
%
% Adding/removing points
%
%   k = D.add( x, Field/Value )     possible to add multiple points
%                                   with values either vec or cell
%
%   D.rem(k)                        possible to remove multiple points
%   remap = D.compress()            compress storage, newidx = remap(oldidx)
%
% Easy-access
%
%       dget    Get data value(s) manually
%       dset    Set data value(s) manually
%       row     Get one or several data rows
%       col     Get one or several data columns for all used rows
%       mget    Get meta-data for a set of rows
%       mfield  Get meta-data field for all used rows
%
%   Note that these methods are provided for convenience (and they can resolve a column name),
%   but for better performance, you should access the properties/data directly.
%
% Column names
%
%   D.setnames( names )             correct number of names expected
%   c = D.colnum( name )            invalid names cause key error
%
% Metadata
%
%   D.assign( k, Field/Value )      possible to set multiple indices
%                                   with values either cell or vec
%   D.rmfield( names )              remove fields for all points
%
%
% See also: dk.priv.GrowingContainer
%
% JH

    properties
        data
        meta
        name
    end

    properties (Transient,Dependent)
        nrows
        ncols
        numel
    end
    
    % dependent + state
    methods
        
        function n = get.nrows(self), n = self.count; end
        function n = get.ncols(self), n = size(self.data,2); end
        function n = get.numel(self), n = self.nrows * self.ncols; end
        
        % overload parent
        function y = isempty(self)
            y = self.numel() == 0;
        end
        
        % check row/column indices
        function chksub(self,r,c)
            assert( all(self.used(r(:))), 'Invalid row indices' );
            if nargin > 2
                assert( all(dk.num.between(c(:),1,self.ncols)), 'Column index out of bounds.' );
            end
        end
        
    end

    % main
    methods

        function self = DataArray(varargin)
            self.clear();
            switch nargin
                case 0 % nothing to do
                case 1
                    arg = varargin{1};
                    if dk.is.string(arg) || dk.is.struct(arg,'version')
                        self.unserialise(arg);
                    else
                        self.reset(arg);
                    end
                otherwise
                    self.reset(varargin{:});
            end
        end
        
        function clear(self)
            self.gcClear();
            self.data = [];
            self.meta = structcol(0,{});
            self.name = structcol(0,{});
        end

        % initialise container
        function reset(self,c,m,b)
        %
        % reset( matrix, metafields, bsize )
        % reset( numcols, metafields, bsize )
        % reset( colnames, metafields, bsize )
        %
        % defaults: metafields={}, bsize=100
        % 
        
            if nargin < 3, m={}; end
            if nargin < 4, b=100; end
            
            assert( iscellstr(m), 'Expected a cell of property names.' );
            
            self.gcInit(b);
            self.meta = structcol(b,m);
            self.name = structcol(0,{});
            
            if iscellstr(c)
                self.data = nan(b,numel(c));
                self.setnames(c);
                
            elseif isscalar(c)
                self.data = nan(b,c);
                
            else
                assert( ismatrix(c), 'Bad input.' );
                self.data = nan(b,size(c,2));
                self.add(c);
                
            end
            
        end

        % set column names (expects correct number of strings)
        function setnames(self,varargin)
            if nargin == 2 && iscellstr(varargin{1})
                names = varargin{1};
            else
                names = varargin;
            end
            if isempty(names)
                self.name = structcol(0,{});
            else
                assert( iscellstr(names) && numel(names) == self.ncols, 'Bad input.' );
                self.name = cell2struct( num2cell(1:self.ncols), names, 2 );
            end
        end

        % bulk assign of metadata field by copying the value
        function self = assign(self,k,varargin)
            if nargin < 2 || isempty(k), return; end
            
            self.chksub(k);
            v = dk.c2s(varargin{:});
            f = fieldnames(v);
            n = numel(f);
            for i = 1:n
                [self.meta(k).(f{i})] = dk.deal(v.(f{i}));
            end
        end

        % add entries
        function k = add(self,x,varargin)
            assert( ismatrix(x) && size(x,2) == self.ncols, 'Bad number of columns.' );
            n = size(x,1);
            k = self.gcAdd(n);
            self.data(k,:) = x;
            self.assign(k,varargin{:});
        end
        
        % remove metadata fields
        function rmfield(self,varargin)
            assert( nargin > 1, 'Fields need to be specified.' );
            if iscellstr(varargin{1})
                fields = varargin{1};
            else
                fields = varargin;
            end
            assert( iscellstr(fields), 'Expected list of fieldnames.' );
            self.meta = rmfield(self.meta, fields);
        end

    end
    
    % access
    methods
        
        % NOTE:
        % For all methods below, both scalar and vector indices work.
        % However, name resolution requires single name only.
        
%         % experimental overload of subsref/subsasgn operator
%         function varargout = subsref(self,s)
%             varargout = cell(1,max(1,nargout));
%             switch s(1).type
%                 case '.' 
%                     [varargout{:}] = builtin('subsref',self,s); % obj.prop
%                 case '()'
%                     [varargout{:}] = subsref(self.data,s); % obj(...) => obj.data(...)
%                 case '{}'
%                     s(1).type = '()';
%                     [varargout{:}] = subsref(self.meta,s); % obj{...} => obj.meta(...)
%             end
%         end
%         function self = subsasgn(self,s,v)
%             switch s(1).type
%                 case '.' 
%                     self = builtin('subasgn',self,s,v); % obj.prop = val
%                 case '()'
%                     self.data = subsasgn(self.data,s,v); % obj(...) => obj.data(...) = val
%                 case '{}'
%                     s(1).type = '()';
%                     [subsref(self.meta,s)] = dk.deal(v); %#ok obj{...} => obj.meta(...) = val
%             end
%         end
        
        % get column index from column name
        function c = colnum(self,name)
            c = self.name.(name);
        end

        % get row(s) by index
        function x = row(self,k)
            self.chksub(k);
            x = self.data(k,:);
        end

        % get column(s) by index or name
        function x = col(self,k)
            if ischar(k), k=self.name.(k); end
            x = self.data(self.used,k);
        end
        
        % get meta-data for a given (set of) row(s)
        function x = mget(self,k)
            self.chksub(k);
            x = self.meta(k);
        end

        % get field by name
        function x = mfield(self,n)
            x = { self.meta(self.used).(n) };
        end
        
        % get element(s) by index (single column by name ok)
        function x = dget(self,r,c)
            if ischar(c), c=self.name.(c); end
            self.chksub(r);
            x = self.data(r,c);
        end

        % set element(s) by index (single column by name ok)
        function dset(self,r,c,x)
            if ischar(c), c=self.name.(c); end
            self.chksub(r,c);
            self.data(r,c) = x;
        end
        
        % short for calling row and mget (row and metadata) for given row indices
        function [d,m] = getboth(self,k)
            d = self.row(k);
            m = self.mget(k);
        end

    end

    % abstract methods
    methods (Hidden)

        function childAlloc(self,n)
            self.data = vertcat(self.data, nan(n,self.ncols));
            self.meta(self.capacity) = dk.struct.make(fieldnames(self.meta));
        end

        function childCompress(self,id,remap)
            self.data = self.data(id,:);
            self.meta = self.meta(id);
        end

    end

    % i/o
    methods

        function s = serialise(self,file)
            s = self.gcToStruct();
            s.data = self.data;
            s.meta = self.meta;
            s.name = self.name;
            s.version = '0.2';
            if nargin > 1, dk.save(file,s); end
        end

        function self = unserialise(self,s)
        if ischar(s), s=load(s); end
        switch s.version
            case '0.1'
                self.data = s.data;
                self.meta = s.meta;
                self.gcFromStruct(s);
                if isempty(s.name_k)
                    self.name = structcol(0,{});
                else
                    self.name = cell2struct( s.name_v, s.name_k, 2 );
                end
                
            case '0.2'
                self.data = s.data;
                self.meta = s.meta;
                self.name = s.name;
                self.gcFromStruct(s);

            otherwise
                error('Unknown version: %s',s.version);
        end
        end

    end

end

% Create a nx1 empty struct-array.
function s = structcol(n,fields)
    s = dk.struct.repeat( fields, n, 1 );
end
