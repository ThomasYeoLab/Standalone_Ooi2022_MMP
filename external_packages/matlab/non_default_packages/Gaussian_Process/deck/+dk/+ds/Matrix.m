classdef Matrix < dk.priv.GrowingContainer
%
% Efficient implementation of a "growing matrix" with memory block-allocation.
%
% Number of columns cannot be modified after construction: 
%   reset( ncols, bsize=100 )
%   reset( init_rows, bsize=100 )
%
% New rows can be added at the bottom of the matrix using:
%   add( rows )
% 
% Rows can also be removed, although this simply marks them as unused.
% Unused rows are removed from the container when using:
%   remap = compress()
%
% which leads to a re-indexing: newidx = remap(oldidx).
%
%
% See also: dk.priv.GrowingContainer
%
% JH

    properties
        data
    end
    
    properties (Transient,Dependent)
        nrows
        ncols
        numel
    end
    
    % dependent
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
        
        function self = Matrix(varargin)
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
        end
        
        % initialise container
        function reset(self,x,b)
        %
        % reset( matrix, bsize )
        % reset( numcols, bsize )
        %
        % defaults: bsize=100
        %
        
            if nargin < 3, b=100; end
            self.gcInit(b);
            if isscalar(x)
                self.data = nan(b,x);
            else
                assert( ismatrix(x), 'Bad input.' );
                self.data = nan(b,size(x,2));
                self.add(x);
            end
            
        end
        
        % assign and access
        function k = add(self,x)
            n = size(x,1);
            assert( ismatrix(x) && size(x,2)==self.ncols, 'Bad input.' );
            
            k = self.gcAdd(n);
            self.data(k,:) = x;
        end
        
%         % experimental overload of subsref operator
%         function varargout = subsref(self,s)
%             varargout = cell(1,max(1,nargout));
%             switch s(1).type
%                 case '.' 
%                     [varargout{:}] = builtin('subsref',self,s); % obj.prop
%                 case '()'
%                     [varargout{:}] = subsref(self.data,s); % obj(...) => obj.data(...)
%                 case '{}'
%                     error( 'No {} operator available.' );
%             end
%         end
%         function self = subsasgn(self,s,v)
%             switch s(1).type
%                 case '.' 
%                     self = builtin('subsasgn',self,s,v); % obj.prop = val
%                 case '()'
%                     self.data = subsasgn(self.data,s,v); % obj(...) => obj.data(...) = val
%                 case '{}'
%                     error( 'No {} operator available.' );
%             end
%         end
        
        % iterate valid rows
        function [out,idx] = iter(self,callback,idx)
            if nargin < 3, idx = self.find(); end
            ni = numel(idx);
            
            if nargout > 0
                out = cell(1,ni);
                for i = 1:ni
                    k = idx(i);
                    out{i} = callback( k, self.data(k,:) );
                end
            else
                for i = 1:ni
                    k = idx(i);
                    callback( k, self.data(k,:) );
                end
            end
        end
        
    end
    
    % abastract methods
    methods (Hidden)
        
        function childAlloc(self,n)
            self.data = vertcat(self.data, nan(n,self.ncols));
        end
        
        function childCompress(self,id,remap)
            self.data = self.data(id,:);
        end
        
    end
    
    % i/o
    methods
        
        function s=serialise(self,file)
            s = self.gcToStruct();
            s.data = self.data;
            s.version = '0.1';
            if nargin > 1, dk.save(file,s); end
        end
        
        function self=unserialise(self,s)
        if ischar(s), s=load(s); end
        switch s.version
            case '0.1'
                self.data = s.data;
                self.gcFromStruct(s);
                
            otherwise
                error('Unknown version: %s',s.version);
        end
        end
        
    end
    
end

