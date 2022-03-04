classdef Cell < dk.priv.GrowingContainer
%
% Efficient implementation of a "growing cell" with memory block-allocation.
%
% See also: dk.priv.GrowingContainer
%
% JH

    properties
        data
    end
    
    properties (Transient,Dependent)
        numel
    end
    
    % main
    methods
        
        function self = Cell(varargin)
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
            self.data = {};
        end
        
        function n = get.numel(self), n = numel(self.data); end
        
        % initialise container
        function reset(self,b)
            if nargin < 2, b=100; end
            self.gcInit(b);
            self.data = cell(1,b);
        end
        
        % assignment
        function k = append(self,varargin)
            n = numel(varargin);
            k = self.gcAdd(n);
            self.data(k) = varargin;
        end
        
        function k = extend(self,arg)
            k = self.append(arg{:});
        end
        
    end
    
    % abastract methods
    methods (Hidden)
        
        function childAlloc(self,n)
            self.data = horzcat(self.data, cell(1,n));
        end
        
        function childCompress(self,id,remap)
            self.data = self.data(id);
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

