classdef Tree < dk.priv.TreeBase
%
% Tree implementation deriving from dk.priv.TreeBase. This is a fairly
% generic implementation, with few assumptions; nodes can be added or
% removed in any order, and the storage+indexing can be compacted.
%
% The columns of the storage are:
%   parent
%   depth
%   nchildren
%
% Most operations are as efficient as expected, except:
%   list children       O(n)
%   list offspring      O(n log(n))
%   remove node         O(n log(n))
% where these operations are for a single node, and n is the total
% number of nodes.
%
% Traversal methods are non-recursive.
%
% ----------------------------------------------------------------------
% ## Usage
%
% Construction
%
%   T = dk.ds.Tree()                           default root node
%   T = dk.ds.Tree( props=struct, bsize=100 )  setting the root props
%   T = dk.ds.Tree( filename )                 unserialise file
%
% Tree logic
%
%   indices()       valid node IDs              (vec)
%   depth()         tree depth                  (scalar)
%   shape()         width at each level         (vec)
%   levels()        group node IDs by level     (cell)
%
%   parent(id)      if of parent node
%   depth(id)       depth of current node (>= 1)
%   nchildren(id)   number of children
%
%   children  ( id, unwrap=true )        accept multiple ids
%   offspring ( id, unwrap=true )        inefficient ops O( n log n )
%   siblings  ( id, unwrap=true )        return cell
%
%   all_parents()   all node parents     (cell)
%   all_depths()    all node depths      (vec)
%   all_children()  all node children    (cell)
%   all_nchildren() all node #children   (vec)
%
% Node logic
%
%   [node,prop] = get_node( id, children=false )   return struct-arrays
%   id = add_node( parent, Name/Value )
%   removed = rem_node( id )                       remove offspring too
%
%   p = get_props( id )                            struct with all props
%   set_props( id, Name/Value )                    merge with existing
%   rem_props( Names... )                          from all nodes
%
%
% ----------------------------------------------------------------------
% See also: dk.priv.TreeBase
%
% JH

    properties (Constant)
        type = 'tree';
    end

    methods

        function self = Tree(varargin)
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
            colnames = {'parent','depth','nchildren'};
            
            if isstruct(props)
                self.store = dk.ds.DataArray( colnames, fieldnames(props), bsize );
                self.store.add( [0,1,0], props );
            else
                self.store = dk.ds.DataArray( colnames, props, bsize );
                self.store.add( [0,1,0] );
            end
            
        end
        
        % compress storage and reindex the tree
        function remap = compress(self,res)
            if nargin < 2, res = self.store.bsize; end
            remap = self.store.compress();
            remap = [0; remap(:)];
            self.store.data(:,1) = remap(1+self.store.data(:,1));
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

        function k = add_node(self,p,varargin) % works with p vector
            n = numel(p);
            [u,~,c] = unique(p(:));
            c = accumarray(c,1);
            assert( all(self.is_valid(p)), 'Invalid parent node.' );

            x = [p(:), self.depth(p)+1, zeros(n,1)];
            k = self.store.add( x, varargin{:} );
            self.store.data(u,3) = self.store.data(u,3) + c; % add to parent count
        end

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
