classdef Tree < handle
    
    properties
        node
        bsize
    end

    properties (SetAccess = protected)
        last
    end
    
    properties (Transient,Dependent)
        n_nodes, n_leaves, n_parents;
        sparsity, capacity;
    end
    
    % dependent properties
    methods
        function v=valid(self) % quick function to find valid nodes
            v=[self.node.depth] > 0;
        end
        
        function n=get.n_nodes(self)
            n=sum(self.valid());
        end
        function n=get.n_leaves(self)
            n=sum(self.valid() & [self.node.is_leaf]);
        end
        function n=get.n_parents(self)
            n=sum(self.valid() & ~[self.node.is_leaf]);
        end
        
        function s=get.sparsity(self)
            s = 1 - self.last / self.n_nodes;
        end
        function n=get.capacity(self)
            n = numel(self.node) - self.last;
        end
    end
    
    % i/o
    methods
        
        function s=serialise(self,file)
            s.version = '0.2';
            s.node = dk.mapfun( @(n) n.serialise(), self.node, false );
            s.last = self.last;
            s.bsize = self.bsize;
            if nargin > 1, save(file,'-v7','-struct','s'); end
        end
        
        function self=unserialise(self,s)
        if ischar(s), s=load(s); end
        self.node = dk.mapfun( @(n) dk.obj.Node(n), s.node, false );
        self.node = [self.node{:}];
        switch s.version
            case '0.1'
                self.last = numel(self.node);
                self.bsize = 100;
            case '0.2'
                self.last = s.last;
                self.bsize = s.bsize;
            otherwise
                error('Unknown version: %s',s.version);
        end
        end
        
        function same=compare(self,other)
            same = dk.compare( self.serialise(), other.serialise() );
        end
        
    end
    
    % setup
    methods
        
        function self = Tree(varargin)
            self.reset(varargin{:});
        end
        
        function self=reset(self,varargin)
            % initialise storage
            self.node = [];
            self.bsize = 100;
            self.alloc(self.bsize);
            
            % set root node
            self.node = dk.obj.Node(1,1,varargin{:});
            self.last = 1;
        end
        
        % allocate storage for additional nodes
        % NOTE: this relies on dk.obj.Node() to be invalid by default
        function alloc(self,n)
            assert( n > 0, 'Allocation size should be positive.' );
            if isempty(self.node)
                self.node = repmat( dk.obj.Node(), 1, n );
            else
                self.node(end+n) = dk.obj.Node();
            end
        end
        
        % remove deleted nodes and re-index the tree
        function self=cleanup(self)
            
            depth = [self.node.depth];
            valid = depth > 0;
            
            % check gaps in depth (this should not happen)
            count = accumarray( 1+depth(:), 1 );
            assert( all(count(2:end) > 0), 'Bug during removal.' );
            
            % remap valid indices, and sort by depth
            [~,order] = sort(depth(valid));
            old2new = zeros(size(self.node));
            old2new(valid) = order;
            
            self.node = self.node(valid);
            n = numel(self.node);
            for i = 1:n
                self.node(i).remap( old2new );
            end
            self.last = n;
            
        end
        
    end
    
    % main
    methods
        
        % shape of the tree
        function [depth,width] = shape(self)
            depth = nonzeros([self.node.depth]);
            width = accumarray( depth(:), 1 );
            depth = max(depth);
        end
        
        % add/remove single node
        function k=add_node(self,p,varargin)
            assert( self.node(p).is_valid, 'Invalid parent' );
            
            k = self.last+1;
            d = self.node(p).depth+1;
            if k > numel(self.node)
                self.alloc(self.bsize);
            end
            
            self.node(k) = dk.obj.Node(d,p,varargin{:});
            self.node(p).add_child(k);
            self.last = k;
        end
        function self=rem_node(self,k)
            assert( isscalar(k), 'This method removes one node at a time, use rem_nodes instead.' );
            assert( k > 1, 'Cannot remove the root, use reset() instead.' );
            
            % cannot remove node from array without screwing up indices
            % to free up memory, use cleanup
            self.parent(k).rem_child(k);
            c = self.node(k).children;
            for i = 1:length(c)
                self.rem_node(c(i));
            end
            self.node(k).clear();
        end
        
        % add n children to node p, and return their indices
        function k=add_nodes(self,p,n)
            k = zeros(1,n);
            e = self.last + n;
            while e > numel(self.node)
                self.alloc(self.bsize);
            end
            for i = 1:n
                k(i) = self.add_node(p);
            end
            self.last = k(end);
        end
        
        % remove nodes by index
        function rem_nodes(self,k)
            for i = 1:numel(k)
                self.rem_node(k(i));
            end
        end
        
        % set/get node property
        % val should either be iterable or scalar
        % returns indices of valid nodes
        function k = set_prop(self,name,val)
            k = find(self.valid());
            n = numel(k);
            if n > 1 && isscalar(val)
                val = dk.mapfun( @(x) val, 1:n, false ); % make a cell
            end
            for i = 1:n
                self.node(k(i)).data.(name) = dk.getelem(val,i); 
            end
        end
        function [val,idx] = get_prop(self,name,unif)
            if nargin < 3, unif=false; end
            idx = find(self.valid());
            val = dk.mapfun( @(k) self.node(k).data.(name), idx, unif );
        end
        
        % proxy for node properties
        function N=root(self)
            N=self.node(1);
        end
        function p=parent(self,k)
            p=self.node( self.node(k).parent );
        end
        function N=children(self,k)
            N=self.node( self.node(k).children );
        end
        
        function [L,N] = levels(self)
        % 
        % [L,N] = levels(self)
        %
        % Group nodes by level, and return a cell with indices for each level.
        % If second output is collected, it contains a cell of node-arrays.
        % 
        % JH
        
            depth = [self.node.depth];
            valid = find([self.node.is_valid]);
            
            [depth,order] = sort(depth(valid),'ascend');
            valid = valid(order);
            stride = [find(diff(depth)==1), numel(depth)];
            
            n = numel(stride);
            L = cell(1,n);
            e = 0;
            for i = 1:n
                b = e+1;
                e = stride(i);
                L{i} = valid(b:e);
            end
            
            if nargout > 1
                N = dk.mapfun( @(ind) self.node(ind), L, false );
            end
        end
        
        function N = level(self,D)
        %
        % N = level(self,D)
        %
        % Get a struct-array of nodes at a given depth.
        %
        % JH
        
            N = self.node( [self.node.depth] == D );
        end
        
        function [C,N] = descent(self,k)
        %
        % C = descent(self,k)
        %
        % List of node indices for all nodes descending from node k.
        % If second output is requested, then the function returns a vector
        % with the corresponding nodes.
        %
        % JH
        
            C = {};
            t = self.node(k).children;
            
            while ~isempty(t)
                C{end+1} = t; %#ok
                t = [ self.node(t).children ];
            end
            
            C = [C{:}];
            if nargout > 1
                N = self.node(C);
            end

        end
        
        % iteration on valid nodes
        function [out,idx] = iter(self,callback)
        %
        % [out,idx] = iter(callback)
        %
        % Iterate on valid nodes, and call callback function with arguments (index,node).
        % Callback needs not return anything if output is not collected.
        % Otherwise, cell of outputs is collected.
        % Second output corresponds to node indices.
        %
        % JH
            
            idx = find(self.valid());
            if nargout == 0
                dk.mapfun( @(k) callback(k, self.node(k)), idx );
            else
                out = dk.mapfun( @(k) callback(k, self.node(k)), idx, false );
            end
            
        end
        
        
        % traversal methods
        function bfs(self,callback,cur)
        %
        % bfs(self,callback)
        %
        % Breadth-first traversal methods.
        % Note that the order of traversal is not guaranteed.
        % The callback function is called as follows:
        %
        %   callback( node_index, node )
        %
        
            if nargin < 3, cur = 1; end
            next = cell(size(cur));
            for i = 1:length(cur)
                curnode = self.node(cur(i));
                callback(cur(i), curnode);
                next{i} = curnode.children;
            end
            next = unique(horzcat( next{:} ));
            if ~isempty(next)
                self.bfs( callback, next );
            end
        end
        function dfs(self,callback,cur)
        %
        % dfs(self,callback)
        %
        % Depth-first traversal methods.
        % Note that the order of traversal is not guaranteed.
        % The callback function is called as follows:
        %
        %   callback( node_index, node )
        %
        
            if nargin < 3, cur=1; end
            assert( isscalar(cur), 'Expected a single node.' );
            curnode = self.node(cur);
            callback(cur, curnode);
            next = curnode.children;
            for i = 1:length(next)
                self.dfs( callback, next(i) );
            end
        end
        
        function print(self,fid)
        %
        % print(self,fid)
        %
        % Print to file (or console by default).
        % Each line has one of the two following format:
        %
        %   ParentID>NodeID [Depth] : NChildren children, NFields data-fields
        %   #NodeID [Depth] : DELETED
        % 
        %JH
        
            if nargin < 2, fid=1; end
            N = self.n_nodes;
            for i = 1:N 
                Ni = self.node(i);
                if Ni.is_valid
                    fprintf( fid, '%d>%d [%d] : %d children, %d data-fields\n', ...
                        Ni.parent, i, Ni.depth, numel(Ni.children), numel(Ni.fields) );
                else
                    fprintf( fid, '#%d [%d] : DELETED\n', i, Ni.depth );
                end
            end
        end
        
        function gobj = plot_tree(self,varargin)
        %
        % gobj = plot( varargin )
        %
        % Draw the tree.
        %
        % Options:
        %
        %      Newfig  Open new figure to draw.
        %             >Default: true
        %        Link  Link options (cf Line properties)
        %             >Default: {} (none)
        %      Height  Function of width and depth giving the height of links.
        %              Should generally be a decreasing function of depth.
        %              Can also be scalar or array.
        %             >Default: @(w,d) w(1) ./ sqrt(1:d)
        %      Sepfun  Function of the depth adding width to separate branches
        %             >Default: @(x)x/10 or @(x)zeros(size(x))
        %     Balance  Balancing flag (children reordering)
        %             >Default: true
        %    NodeSize  RELATIVE size of the node (between 0 and 1)
        %             >Default: 0.5
        %   NodeColor  Face-color of the node
        %             >Default: hsv colormap
        %    NodeEdge  Colour of the edges
        %             >Default: 'k'
        %     ToolTip  Function handle to be called by datacursormode
        %             >Default: shows "id: NodeID"
        %      Radial  Flag to draw the tree with radial geometry
        %             >Default: false
        %
        % JH
        
            gobj = dk.priv.plot_tree(self,varargin{:});
        
        end
        
    end
    
end
