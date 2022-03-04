classdef Caret < handle
    
    properties
        str
        pos
        
        shapepfx
        structcell
    end
    
    properties (Dependent)
        len
        cur
        rem
    end
    
    methods
        
        function self = Caret(text,varargin)
            self.str = text(:);
            self.pos = 1;
            self.configure(varargin{:});
        end
        
        % options
        function self=configure(self,varargin)
            
            % default options
            opt.shapeprefix = '_';
            opt.structcell  = false;
            
            % inputs override defaults
            n = numel(varargin)/2;
            for i = 1:n
                f = lower(varargin{2*i-1});
                opt.(f) = varargin{2*i};
            end
            
            % validate
            string = @(x) ischar(x) && isrow(x) && ~isempty(x);
            boolean  = @(x) isscalar(x) && islogical(x);
            
            assert( string(opt.shapeprefix), 'ShapePrefix should be a string.' );
            assert( boolean(opt.structcell), 'StructCell should be logical.' );
            
            % assign
            self.shapepfx   = opt.shapeprefix;
            self.structcell = opt.structcell;
            
        end
        
        % current character
        function c=get.cur(self)
            c=self.str(self.pos);
        end
        
        % total length
        function n=get.len(self)
            n=length(self.str);
        end
        function n=get.rem(self)
            n=self.len-self.pos;
        end
        
        % return true if the position is at the last character
        function y=eos(self)
            y = self.pos >= self.len;
        end
        
        % substring of length L from current position
        function s=sub(self,L)
            L = min(L-1,self.len-self.pos);
            s = self.str( self.pos:(self.pos+L) )';
        end
        function [s,k]=fbsub(self,L)
            b = max( self.pos-L, 1 );
            e = min( self.pos+L, self.len );
            s = self.str( b:e )';
            k = self.pos-b+1;
        end
        
        % increment position by k characters
        function self=inc(self,k)
            if nargin < 2, k=1; end
            self.pos = self.pos+k;
        end
        
        % skip characters until next non-space
        function self=skipspaces(self,s)
            if nargin < 2, s=10; end
            
            if isspace(self.cur)
                f = @(x) sum(cumprod(isspace(x)));
                k = f(self.sub(s));
                while k > 0
                    self.inc(k); 
                    k = f(self.sub(s));
                end
            end
        end
        
    end
    
end