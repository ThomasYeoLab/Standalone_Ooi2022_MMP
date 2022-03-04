classdef TreeBase < handle
%
% Abstract base class for tree implementations, using a dk.ds.DataArray as storage.
% See below for methods to be implemented in derived classes.
%
%
% ----------------------------------------------------------------------
% ## Inheritance
%
% This implementation requires derived classes to define the following columns:
%   parent      (cf. parent, all_parents, ancestor)
%   depth       (cf. depth, all_depths, height)
%   nchildren   (cf. nchildren, all_nchildren)
%
% If these are not defined in the derived classes, then the methods listed above 
% should be overloaded.
%
% Furthermore, the list of abstract methods to be implemented is:
%
%   reset()
%   remap = compress()
%   [node,prop] = get_node( nid[] )
%   
%   cell = siblings( nid[] )
%   cell = children( nid[] )
%   cell = offspring( nid[] )
%   [cell,pid] = all_children( nid[] )
%
%
% ----------------------------------------------------------------------
% ## Usage
%
% Data-structure
%
%   T.serialise( output_file )
%   T.compress( reserve )
%
% Tree logic
%
%   indices()       valid node IDs              (vec)
%   depth()         tree depth                  (scalar)
%   shape()         width at each level         (vec)
%   levels()        group node IDs by level     (cell)
%
%   parent(id)      node props (efficient)
%   depth(id)       accept multiple ids
%
%   children  ( id, unwrap=true )        accept multiple ids
%   offspring ( id, unwrap=true )        inefficient ops O( n log n )
%   siblings  ( id, unwrap=true )        return cell
%
%   all_parents()   all node parents     (cell)
%   all_depths()    all node depths      (vec)
%   all_children()  all node children    (cell)
%
% Node logic
%
%   [node,prop] = get_node(id)           return struct-arrays
%
%   p = get_props( id )                  struct with all props
%   set_props( id, Name/Value )          merge with existing
%   rem_props( Names... )                from all nodes
%
% Traversal
%
%   iter( callback )
%   dfs ( callback )     with callback( id, node, props )
%   bfs ( callback )
%
%
% JH

    properties (SetAccess=protected, Hidden)
        store
    end

    properties (Transient, Dependent)
        n_nodes
        n_leaves
        n_parents
        sparsity
    end
    properties (Transient, Dependent, Hidden)
        nn, nl, np
    end

    properties (Abstract,Constant)
        type
    end

    
    methods (Abstract)

        % rootprops is either:
        %   a cell of property names, or 
        %   a struct of properties
        reset(self,rootprops,bsize);

        % re-index the tree to remove unused nodes
        remap = compress(self,res);

        % struct-array nodes (p:parent, d:depth, nc:#children)
        [n,p] = get_node(self,k)

        s = siblings(self,k);
        c = children(self,k);
        [c,k] = all_children(self);
        o = offspring(self,k);

    end
    
    % dependent + state
    methods
        
        function n = get.nn(self), n = self.store.count; end
        function n = get.np(self), n = nnz(self.all_nchildren()); end
        function n = get.nl(self), n = self.nn - self.np; end

        function n = get.n_nodes(self), n = self.nn; end
        function n = get.n_leaves(self), n = self.nl; end
        function n = get.n_parents(self), n = self.np; end

        function s = get.sparsity(self), s = self.store.sparsity; end
        function r = isready(self), r = self.nn > 0; end
        
        % indices of valid nodes
        function [k,r] = indices(self)
            k = self.store.find();
            if nargout > 1
                r(k) = 1:numel(k); % reverse mapping
            end
        end
        
        % a node is a leaf if it has no children
        function y = is_leaf(self,k)
            y = self.nchildren(k) == 0;
        end
        
        % check storage index
        function y = is_valid(self,k)
            y = self.store.used(k);
        end
        
        % check that all input indices correspond to valid nodes
        function chkind(self,k)
            assert( all(self.store.used(k)), 'Invalid node indices.' );
        end
        
    end

    % main
    methods

        function clear(self)
            self.store = dk.ds.DataArray();
        end

        function gobj = plot(self,varargin)
        %
        % Plot tree;
        %   - classic and radial available
        %   - customise nodes and edges
        %   - customise data-tip
        %   - many other options
        %
        % See also: dk.priv.draw_tree

            gobj = dk.priv.draw_tree( self, varargin{:} );
        end

        function print(self,varargin)
        %
        % Display tree in console, or write to file.
        %
        % See also: dk.priv.disp_tree

            dk.priv.disp_tree( self, varargin{:} );
        end
        
        % parent 
        function p = parent(self,k)
            p = self.store.dget(k,'parent');
        end
        function [p,k] = all_parents(self)
            p = self.store.col('parent');
            if nargout > 1, k = self.indices(); end
        end
        
        % get ancestor of depth d
        function a = ancestor(self,k,d)
            assert( all(self.is_valid(k)) && d >= 1, 'Bad input' );
            assert( all(self.depth(k) > d), 'Node depths should all be > d' );
            while d > 0
                a = self.store.dget(k,'parent');
                k = a;
                d = d-1;
            end
        end
        
        
        % number of children
        function n = nchildren(self,k)
            n = self.store.dget(k,'nchildren');
        end
        function [n,k] = all_nchildren(self)
            n = self.store.col('nchildren');
            if nargout > 1, k = self.indices(); end
        end

        
        % node depth (counted from 1 at the root)
        function d = depth(self,k)
            d = self.store.dget(k,'depth');
        end
        function [d,k] = all_depths(self)
            d = self.store.col('depth');
            if nargout > 1, k = self.indices(); end
        end
        
        % tree height = max node depth
        function h = height(self)
            h = max(self.store.col('depth'));
        end

        
        % tree properties
        function [width,depth] = shape(self)
            depth = self.all_depths();          % depth of each node
            width = accumarray( depth(:), 1 );  % width at each depth
            depth = max(depth);                 % depth of the tree
        end

        function L = levels(self)
            [d,k] = self.all_depths();
            L = dk.grouplabel(d);
            L = dk.mapfun( @(i) k(i), L, false );
        end


        % node access
        function [n,m] = root(self,varargin)
            [n,m] = self.get_node(1,varargin{:});
        end
        
        function k = leaves(self)
            [n,k] = self.all_nchildren();
            k = k(n == 0);
        end

        function p = get_props(self,k)
            p = self.store.mget(k);
        end
        function set_props(self,k,varargin)
            self.store.assign(k,varargin{:});
        end
        function rem_props(self,varargin)
            self.store.rmfield(varargin{:});
        end

    end

    % traversal methods
    methods

        % iterate nodes (undefined order)
        function [out,id] = iter(self,callback)
            id = self.indices();
            if nargout == 0
                dk.mapfun( @(k) callback(k, self.get_node(k), self.get_props(k)), id );
            else
                out = dk.mapfun( @(k) callback(k, self.get_node(k), self.get_props(k)), id, false );
            end
        end

        % see: https://stackoverflow.com/a/51124171/472610
        %
        % These implementations are reasonably efficient without assumptions about the
        % type of tree; they can be overridden in derived classes if needed.

        function x = bfs(self,callback,start)
            if nargin < 3, start=1; end

            C = self.all_children();
            N = self.nn;
            S = zeros(1,N);
            [~,r] = self.indices();
            o = nargout > 0;
            if o, x = cell(1,N); end

            S(1) = start;
            cur = 1;
            last = 1;
            while cur <= last
                id = S(cur);
                if o
                    x{id} = callback( id, self.get_node(id), self.get_props(id) );
                else
                    callback( id, self.get_node(id), self.get_props(id) );
                end
                n = numel(C{r(id)});
                S( last + (1:n) ) = C{r(id)};
                last = last + n;
                cur = cur + 1;
            end
        end

        function x = dfs(self,callback,start)
            if nargin < 3, start=1; end

            C = self.all_children();
            N = self.nn;
            S = zeros(1,N);
            [~,r] = self.indices();
            o = nargout > 0;
            if o, x = cell(1,N); end

            S(1) = start;
            cur = 1;
            while cur > 0
                id = S(cur);
                if o
                    x{id} = callback( id, self.get_node(id), self.get_props(id) );
                else
                    callback( id, self.get_node(id), self.get_props(id) );
                end
                n = numel(C{r(id)});
                S( cur-1 + (1:n) ) = fliplr(C{r(id)});
                cur = cur-1 + n;
            end
        end

    end
    
    % i/o
    methods

        function s=serialise(self,file)
            s.version = '0.1';
            s.type = self.type;
            s.store = self.store.serialise();
            if nargin > 1, dk.save(file,s); end
        end

        function self=unserialise(self,s)
        if ischar(s), s=load(s); end
        dk.assert( strcmpi(s.type,self.type), 'Type mismatch: %s != %s', s.type, self.type );
        switch s.version
            case '0.1'
                self.store = dk.ds.DataArray(s.store);
            otherwise
                error('Unknown version: %s',s.version);
        end
        end

        function same=compare(self,other)
            same = dk.compare( self.serialise(), other.serialise() );
        end

    end
    
end
