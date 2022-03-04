classdef Format < handle
    
    properties (SetAccess=private)
        shapepfx
        numericfmt
        boolalpha
        col2row
        emptycell
        
        depth
        tabsize
        
        enc
        ind
        nl
        sp
    end
    
    methods
        
        function self=Format(varargin)
            self.configure(varargin{:});
        end
        
        function self=configure(self,varargin)
                        
            % default options
            opt.shapeprefix    = '_';
            opt.numericformat  = '%g';
            opt.boolalpha      = true;
            opt.col2row        = true;
            opt.emptycell      = '[[]]';
            opt.tabsize        = 4;
            opt.compact        = false;
            opt.depth          = 0;
            
            % inputs override defaults
            n = numel(varargin)/2;
            for i = 1:n
                f = lower(varargin{2*i-1});
                opt.(f) = varargin{2*i};
            end
            
            % validate
            string   = @(x) ischar(x) && isrow(x) && ~isempty(x);
            positive = @(x) isscalar(x) && isnumeric(x) && (x >= 0);
            boolean  = @(x) isscalar(x) && islogical(x);
            
            assert( string(opt.shapeprefix) && string(opt.numericformat) && string(opt.emptycell), ...
                'ShapePrefix, NumericFormat and EmptyCell should be strings.' );
            assert( boolean(opt.boolalpha) && boolean(opt.col2row) && boolean(opt.compact), ...
                'Col2Row, BoolAlpha and Compact should be logicals.' );
            assert( positive(opt.tabsize) && positive(opt.depth), ...
                'TabSize and Depth should be positive scalars.' );
            
            % process internal properties
            if opt.boolalpha
                %self.boolalpha = {'False','True'};
                self.boolalpha = {'false','true'};
            else
                self.boolalpha = {'0','1'};
            end
            
            self.shapepfx   = opt.shapeprefix;
            self.numericfmt = opt.numericformat;
            self.col2row    = opt.col2row;
            self.emptycell  = opt.emptycell;
            
            % set encoding
            enc_src = {'\\','\"','\/','\a','\b','\f','\n','\r','\t','\v'};
            enc_dst = strrep( enc_src, '\', '\\' );
            
            self.enc.numeric = @(x) sprintf(self.numericfmt,x);
            self.enc.char    = @(x) ['"' regexprep(x,enc_src,enc_dst) '"'];
            
            % set tabsize and depth
            if opt.compact
                opt.tabsize = 0;
            end
            self.set_tabsize(opt.tabsize);
            self.set_depth(opt.depth);
            
        end
        
        function self=set_tabsize(self,tabsize)
            self.tabsize=max(0,tabsize);
            if tabsize > 0
                self.nl=sprintf('\n');
                self.sp=' ';
            else
                self.nl='';
                self.sp='';
            end
        end
        function self=set_compact(self)
            self.set_tabsize(0);
        end
        
        function self=set_depth(self,depth)
            self.depth=max(0,depth);
            if self.tabsize > 0
                self.ind=repmat( ' ', 1, depth*self.tabsize );
            else
                self.ind='';
            end
        end
        function self=tab(self)
            self.set_depth(self.depth+1);
        end
        function self=untab(self)
            self.set_depth(self.depth-1);
        end
        
    end
    
end