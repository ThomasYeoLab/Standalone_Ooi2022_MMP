classdef Graph < handle
%
% Directed multi-graph container with edge-list storage.
%
% JH

    properties (Hidden)
        m_node    % DataArray, Nx2: degree, edge0
        m_edge    % Matrix, Mx2: dest, next
    end
    
    properties (Transient,Dependent)
        n_nodes;
        n_edges;
    end
    
    % dependent + state
    methods
        
        function n = get.n_nodes(self), n = self.m_node.count; end
        function n = get.n_edges(self), n = self.m_edge.count; end
        
        function check_node(self,k)
            self.m_node.chkind(k);
        end
        
        function check_edge(self,k)
            self.m_edge.chkind(k);
        end
        
    end
    
    % main
    methods
        
        function self = Graph(varargin)
            self.reset();
            switch nargin
                case 0 % nothing to do
                case 1
                    arg = varargin{1};
                    if iscellstr(arg)
                        self.reset(arg);
                    else
                        self.unserialise(arg);
                    end
                otherwise
                    self.reset(varargin{:});
            end
        end
        
        function reset(self,nodeprop,edgeprop,bsize)
            if nargin < 2, nodeprop = {}; end
            if nargin < 3, edgeprop = {}; end
            if nargin < 4, bsize = 100; end
            
            self.m_node = dk.ds.DataArray( {'degree','edge0'}, nodeprop, bsize );
            self.m_edge = dk.ds.DataArray( {'dest','next'}, edgeprop, bsize );
        end
        
        function p = nodedata(self,k)
            self.m_node.chkind(k);
            p = self.m_node.meta(k);
        end
        
        function p = edgedata(self,k)
            self.m_node.chkind(k);
            p = self.m_edge.meta(k);
        end
        
    end
    
    % graph methods
    methods
        
        function d = degree(self,k)
            self.check_node(k);
            d = self.m_node.data(k,1);
        end
        
        % get edges for a specific node
        function n = edges(self,k)
            d = self.degree(k);
            m = numel(k);
            n = cell(1,m);
            
            for i = 1:m
                n{i} = zeros(d(i),2);
                e = self.m_node.data(k(i),2);
                for j = 1:d(i)
                    n{i}(j,:) = [e, self.m_edge.data(e,1)];
                    e = self.m_edge.data(e,2);
                end
            end
        end
        
        function n = neighbours(self,k)
            n = dk.mapfun( @(x) x(:,2), self.edges(k), false );
        end
        
        % test whether two nodes are linked
        function y = islink(self,src,dst,undir)
            if nargin < 4, undir=false; end
            
            % number of edges to test
            n = numel(src);
            assert( numel(dst)==n, 'Size mismatch' );
            y = false(n,1);
            
            % iterate over edges to test them
            
        end
        
        % create new link between nodes
        function k = link(self,src,dst,undir)
        end
        
        % remove edge by node-pair
        function unlink(self,src,dst,undir)
        end
        
        % remove edge by index
        function rmlink(self,k)
        end
        
        % new node
        function k = newnode(self,varargin)
            k = self.newnodes(1,varargin{:});
        end
        function k = newnodes(self,n,varargin)
            k = self.m_node.add( zeros(n,2), varargin{:} );
        end
        
    end
    
    % utilities
    methods (Hidden)
        
        
        
    end
    
    % i/o
    methods
        
        function s = serialise(self,file)
        end
        
        function unserialise(self,s)
        end
        
        function same = compare(self,other)
            same = dk.compare( self.serialise(), other.serialise() );
        end
        
    end
    
end
