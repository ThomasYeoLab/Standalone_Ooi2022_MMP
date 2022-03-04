classdef BinaryTree < dk.priv.TreeBase
%
% Memory-efficient implementation of Binary Search Tree.
%
% The columns are:
%   key
%   parent
%   depth
%   left
%   right
% 
% JH
    

    properties (Constant)
        type = 'binaryTree';
    end
    
    % utilities
    methods (Hidden)
        
        function k = left(self,k)
            k = self.store.dget(k,4);
        end
        function k = right(self,k)
            k = self.store.dget(k,5);
        end
        
    end
    
    % overload
    methods
        
        % number of children
        function n = nchildren(self,k)
            n = sum(self.store.dget(k,4:5),2);
        end
        function [n,k] = all_nchildren(self)
            n = sum(self.store.col(4:5),2);
            if nargout > 1, k = self.indices(); end
        end
        
        function reset(self,bsize)
            if nargin < 2, bsize=100; end
            colnames = {'key','parent','depth','left','right'};
            self.store = dk.ds.DataArray( colnames, {}, bsize );
        end
        
        function remap = compress(self,res)
            if nargin < 2, res = self.store.bsize; end
            remap = self.store.compress();
            remap = [0; remap(:)]; % allow parent/eldest to be 0
            self.store.data(:,[2,4,5]) = remap(1+self.store.data(:,[2,4,5]));
            self.store.reserve(res);
        end
        
        % struct-array nodes (k:key, p:parent, d:depth, l:left, r:right)
        function [n,p] = get_node(self,k)
            if nargin > 1
                [d,p] = self.store.getboth(k);
            else
                d = self.store.row(k);
            end
            n = cell2struct( num2cell(d), {'k','p','d','l','r'}, 2 );
        end
        
        % children
        function c = children(self,k,unwrap)
            if nargin < 3, unwrap=true; end
            self.chkind(k);
            c = dk.mapfun( @(ki) nonzeros(self.store.data(ki,4:5)), k, false );
            if unwrap && isscalar(c), c=c{1}; end
        end
        function [c,k] = all_children(self)
            k = self.indices();
            c = self.children( k, false );
        end

        % siblings
        function s = siblings(self,k,unwrap)
            if nargin < 3, unwrap=true; end
            self.chkind(k);
            notr = @(x,r) x( x>0 & x~=r );
            p = self.store.dget(k,'parent');
            n = numel(p);
            s = dk.mapfun( @(i) notr( self.store.data(p(i),4:5), k(i) ), 1:n, false );
            if unwrap && n==1, s=s{1}; end
        end

        % offspring
        function o = offspring(self,k,unwrap)
            if nargin < 3, unwrap=true; end

            n = numel(k);
            h = self.height();
            o = cell(1,n);
            x = cell(1,h);
            C = self.children(k);

            for i = 1:n
                ci = C{i};
                di = 0;
                while ~isempty(ci)
                    di = di+1;
                    x{di} = ci;
                    ci = nonzeros(self.store.data(ci,4:5));
                end
                o{i} = [x{1:di}];
            end
            if unwrap && n==1, o=o{1}; end
        end
        
    end
    
    methods
        
        % see: https://stackoverflow.com/a/51124171/472610
        %
        % More efficient traversal methods, given storage.

        function x = bfs(self,callback,start)
            if nargin < 3, start=1; end

            N = self.nn;
            o = nargout > 0;
            if o, x = cell(1,N); end

            S = start;
            while ~isempty(S)
                n = numel(S);
                for i = 1:n
                    si = S(i);
                    if o
                        x{si} = callback( si, self.get_node(si), self.get_props(si) );
                    else
                        callback( si, self.get_node(si), self.get_props(si) );
                    end
                end
                S = nonzeros(self.store.data( S, 4:5 ));
            end
        end

        function x = dfs(self,callback,start)
            if nargin < 3, start=1; end

            N = self.nn;
            S = zeros(1,N);
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
                c = nonzeros(self.store.data(id,4:5));
                n = numel(c);
                S( cur-1 + (1:n) ) = fliplr(c);
                cur = cur-1 + n;
            end
        end
        
    end
    
end