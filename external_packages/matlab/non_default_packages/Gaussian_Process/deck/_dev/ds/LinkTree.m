classdef LinkTree < dk.priv.TreeBase
%
% Tree implementation deriving from dk.priv.TreeBase, using linked-lists
% to make node removal and child-listing operations more efficient.
%
% The columns of the storage are:
%   parent
%   depth
%   nchildren
%   child
%   sibling
%
% ----------------------------------------------------------------------
% See also: dk.priv.TreeBase
%
% JH

    properties (Constant)
        type = 'tree';
    end

    methods

        function self = LinkTree(varargin)
            self.clear();
            switch nargin
                case 0 % nothing to do
                case 1
                    arg = varargin{1};
                    if dk.is.string(arg)
                        self.unserialise(arg);
                    else
                        self.reset(arg);
                    end
                otherwise
                    self.reset(varargin{:});
            end
        end

        % initialise container
        function reset(self,props,bsize)
            
            if nargin < 2, props={}; end
            if nargin < 3, bsize=100; end
            colnames = {'parent','depth','nchildren','child','sibling'};
            
            if isstruct(props)
                self.store = dk.ds.DataArray( colnames, fieldnames(props), bsize );
                self.store.add( [0,1,0,0,0], props );
            else
                self.store = dk.ds.DataArray( colnames, props, bsize );
                self.store.add( [0,1,0,0,0] );
            end
            
        end
        
        % compress storage and reindex the tree
        function remap = compress(self,res)
            if nargin < 2, res = self.store.bsize; end
            remap = self.store.compress();
            remap = [0; remap(:)];
            self.store.data(:,[1,4,5]) = remap(1+self.store.data(:,[1,4,5]));
            self.store.reserve(res);
        end
        
        % struct-array nodes (p:parent, d:depth, c:children, nc:#children)
        function [n,m] = get_node(self,k,with_children) % works with k vector
            if nargin < 3, with_children=false; end
            if nargout > 1
                [d,m] = self.store.getboth(k);
            else
                d = self.store.row(k);
            end
            n = cell2struct( num2cell(d), {'p','d','nc'}, 2 );

            if with_children
                [n.c] = dk.deal(self.children(k,false));
            end
        end

        % works with p vector, nc is the number of children
        function k = add_node(self,p,nc) 
            
            np = numel(p);
            u = unique(p);
            assert( all(self.is_valid(u)), 'Invalid parent node.' );
            assert( numel(u)==numel(p), 'Duplicate parent index not allowed.' );
            
            if nargin < 3
                nc = ones(np,1); 
            else
                nc = nc(:);
            end

            nk = sum(nc);
            x = zeros(nk,5);
            k = self.store.book(nk);
            L = self.last_child_(p);
            D = self.depth(p) + 1;
            e = 0;
            for i = 1:np
                
                n = nc(i);
                b = e+1;
                e = e+n;
                
                x(b:e,1) = p(i);
                x(b:e,2) = D(i);
                x(b:e-1,5) = k(b+1:e);
                
                if L(i)==0
                    self.store.data(p(i),4) = k(b);
                else
                    self.store.data(L(i),5) = k(b);
                end
                
            end
            self.store.data(k,:) = x;
            self.store.data(p,3) = self.store.data(p,3) + nc; % add to parent count
            
        end

        % 
        function r = rem_node(self,k)
            k = k(:)';
            assert( all(k > 1), 'The root (index 1) cannot be removed.' );
            assert( all(self.is_valid(k)), 'Invalid node index.' );

            p = self.parent(k);
            o = self.offspring(k,false);
            r = [horzcat(o{:}), k];
            if isempty(k), return; end

            self.store.rem(r);
            self.store.data(p,3) = self.store.data(p,3) - 1; % subtract from parent count
        end
        
    end
    
    % utilities
    methods (Hidden)
        
        function L = last_child_(self,k)
            n = numel(k);
            L = self.store.data(k,4); % child
            
            for i = 1:n
                s = L(i);
                while s > 0
                    L(i) = s;
                    s = self.store.data(s,5); % next sibling
                end
            end
        end
        
        function c = children_(self,k)
            assert( isscalar(k), 'One node at a time.' );
            n = self.store.data(k,3); % nchildren
            c = zeros(1,n);
            
            c(1) = self.store.data(k,4); % child
            for i = 2:n
                c(i) = self.store.data( c(i-1), 5 ); % sibling
            end
        end
        
        
        
    end
    
    % implementation of abstract methods
    methods

        function c = children(self,k,unwrap)
            if nargin < 3, unwrap=true; end

            n = numel(k);
            if n > log(1+self.nn)
                c = self.all_children();
                c = c(k);
            else
                c = cell(1,n);
                for i = 1:n
                    % valid nodes whose parent is k(i)
                    c{i} = find(self.store.used & (self.store.data(:,1) == k(i)));
                end
            end
            if unwrap && n==1, c = c{1}; end
        end
        
        function [c,k] = all_children(self)
            [p,k] = self.all_parents();
            c = dk.grouplabel( p(2:end), max(k) ); % root has no parent
            c = dk.mapfun( @(i) k(i+1)', c(k), false ); % remap indices, i+1 because excluded root
        end

        function s = siblings(self,k,unwrap)
            if nargin < 3, unwrap=true; end
            
            s = self.children(self.parent(k),false); % list children of parents
            n = numel(s);

            rems = @(x,y) x( x ~= y );
            for i = 1:n
                s{i} = rems( s{i}, k(i) ); % remove self
            end
            if unwrap && n==1, s = s{1}; end
        end

        function o = offspring(self,k,unwrap)
        %
        % Most efficient given storage, but pretty slow...
        
            if nargin < 3, unwrap=true; end

            n = numel(k);
            N = self.nchildren(k);
            h = self.height();
            o = cell(1,n);

            if all(N == 0), return; end
            C = self.all_children();

            for i = 1:n
                t = cell(1,h);
                t{1} = C{k(i)};
                for j = 2:h
                    t{j} = horzcat(C{t{j-1}});
                    if isempty(t{j}), break; end
                end
                o{i} = horzcat(t{:});
            end
            if unwrap && n==1, o = o{1}; end
        end

    end

end
