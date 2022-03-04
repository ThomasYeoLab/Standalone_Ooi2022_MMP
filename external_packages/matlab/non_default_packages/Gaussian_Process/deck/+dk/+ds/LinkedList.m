classdef LinkedList < dk.priv.GrowingContainer
%
% Implementation of doubly-linked list with front/back elements.
%
% JH 

    properties
        data
        link
        
        front
        back
    end
    
    properties (Transient,Dependent)
        numel
    end
    
    % dependent
    methods
        function n = get.numel(self), n = self.count; end
        
        function i = prev(self,k)
            i = self.data(k,1);
        end
        function i = next(self,k)
            i = self.data(k,2);
        end
        
        function y = isempty(self)
            y = self.numel() == 0;
        end 
    end
    
    % main
    methods
        
        function self = LinkedList(varargin)
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
            self.data = cell(0,1);
            self.link = zeros(0,2);
            
            self.front = 0;
            self.back = 0;
        end
        
        function reset(self,bsize)
            if nargin < 2, bsize=100; end
            
            self.gcInit(bsize);
            self.data = cell(bsize,1);
            self.link = zeros(bsize,2);
        end
        
        % get value stored at specific index
        function v = val(self,k)
            self.chkind(k);
            v = self.data(k);
            if isscalar(k)
                v = v{1};
            end
        end
        
        % chains and connected components
        function c = conncomp(self)
            
            % index of all set elements
            u = int8(self.used);
            c = {};
            
            % find chains
            while any(u)
                
                % anchor
                a = find(u,1,'first');
                u(a) = 2;
                
                % backward
                t = a;
                b = self.link(a,1);
                while b>0 && u(b)==1
                    u(b) = 2;
                    if self.link(b,2) ~= t
                        error('Bad link {%d -> %d}', b, t);
                    end
                    t = b;
                    b = self.link(b,1);
                end
                
                % forward
                t = a;
                f = self.link(a,2);
                while f>0 && u(f)==1
                    u(f) = 2;
                    if self.link(f,1) ~= t
                        error('Bad link {%d -> %d}', t, f);
                    end
                    t = f;
                    f = self.link(f,2);
                end
                
                % create new chain
                k = find(u==2);
                c{end+1} = k;
                u(k) = 0;
                
            end
            
        end
        
        % append data to the back of the chain
        function k = append(self,v)
            if self.back > 0
                k = self.insert_after(self.back,v);
            else
                k = self.gcAdd(1);
                self.data{k} = v;
                self.front = k;
            end
            self.back = k;
        end
        
        % prepend data at the front of the chain
        function k = prepend(self,v)
            if self.front > 0
                k = self.insert_before(self.front,v);
            else
                k = self.gcAdd(1);
                self.data{k} = v;
                self.back = k;
            end
            self.front = k;
        end
        
        % insert elements before/after existing ones
        function k = insert_after(self,i,v)
            assert( isscalar(i) && self.used(i), 'Bad index' );
            
            k = self.gcAdd(1);
            self.data{k} = v;
            
            next = self.link(i,2);
            self.link(k,1) = i;
            self.link(k,2) = next;
            self.link(i,2) = k;
            
            if next > 0
                self.link(next,1) = k;
            end
        end
        
        function k = insert_before(self,i,v)
            assert( isscalar(i) && self.used(i), 'Bad index' );
            
            k = self.gcAdd(1);
            self.data{k} = v;
            
            prev = self.link(i,1);
            self.link(k,1) = prev;
            self.link(k,2) = i;
            self.link(i,1) = k;
            
            if prev > 0
                self.link(prev,2) = k;
            end
        end
        
        % find chain of indices from specified element
        function k = chain(self,s,n)
            if nargin < 2, s = self.front; end
            if nargin < 3, n = self.count; end
            
            k = zeros(1,n);
            while s > 0 && n > 0
                k(n) = s;
                n = n-1;
                s = self.link(s,2);
            end
            k = fliplr(k(n+1:end));
        end
        
        % iterate from front to back
        function out = iter(self,callback,s,n)
            if nargin < 4, n = self.count; end
            if nargin < 3, s = self.front; end
            
            k = self.chain(s,n);
            n = numel(k);
            if nargout > 0
                out = cell(1,n);
                for i = 1:n
                    out{i} = callback( k(i), self.data{k(i)} );
                end
            else
                for i = 1:n
                    callback( k(i), self.data{k(i)} );
                end
            end
        end
        
    end
    
    % inherited methods
    methods (Hidden)

        function childAlloc(self,n)
            self.data = vertcat(self.data, cell(n,1));
            self.link = vertcat(self.link, zeros(n,2));
        end

        function childCompress(self,id,remap)
            self.data = self.data(id);
            self.link = remap(self.link(id,:));
        end
        
        function childRemove(self,k)
            n = numel(k);
            for i = 1:n
                prev = self.link(k(i),1);
                next = self.link(k(i),2);

                if prev > 0
                    self.link( prev, 2 ) = next;
                end
                if next > 0
                    self.link( next, 1 ) = prev;
                end
            end
        end

    end
    
    % i/o
    methods
        
        function s=serialise(self,file)
            s.version = '0.1';
            s.type = 'linkedlist';
            
            s.data = self.data;
            s.link = self.link;
            s.front = self.front;
            s.back = self.back;
            
            if nargin > 1, dk.save(file,s); end
        end

        function self=unserialise(self,s)
        if ischar(s), s=load(s); end
        dk.assert( strcmpi(s.type,'linkedlist'), 'Unexpected type: %s', s.type );
        switch s.version
            case '0.1'
                self.data = s.data;
                self.link = s.link;
                self.front = s.front;
                self.back = s.back;
            otherwise
                error('Unknown version: %s',s.version);
        end
        end
        
    end
    
end
