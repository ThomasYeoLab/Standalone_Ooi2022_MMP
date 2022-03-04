classdef SlidingWindow < handle
    
    properties
        ts; 
        wsize, wburn, wstep;
    end
    properties (Transient,Hidden,SetAccess=private)
        curw;
    end
    properties (Transient,Dependent)
        nwin, index;
    end
    
    methods
        
        function self = SlidingWindow(varargin)
            self.clear();
            if nargin > 0
                self.assign(varargin{:});
            end
        end
        
        % Clear contents
        function clear(self)
            self.ts    = ant.TimeSeries();
            self.curw  = 0;
            self.wsize = 0;
            self.wburn = 0;
            self.wstep = 0;
        end
        
        % Total number of windows given current timeseries and params
        function n = get.nwin(self)
            n = 1 + floor( (self.ts.nt - (self.wburn+self.wsize)) / self.wstep );
        end
        
        % Index of the current window in [1..nwin]
        function n = get.index(self)
            n = self.curw+1;
        end
        
        % Indices of first and last element in window k, with k in [1..nwin]
        function varargout = frame(self,k)
            if nargin < 2, k = self.index; end
            
            f = 1+self.wburn + (k(:)-1)*self.wstep;
            l = f + self.wsize-1;
            
            if nargout == 1
                varargout = {[f,l]};
            else
                varargout = {f,l};
            end
        end
        
        % Configure the window length, step and burn in parameters
        function assign(self,ts,swin,convert)
            
            if nargin < 4, convert = true; end
            
            % parse time-series
            % assert( isa(ts,'ant.TimeSeries'), 'Bad input.' );
            self.ts = ts;
            
            % convert to number of timesteps
            if convert
                [W,S,B] = ant.priv.win_time2steps(ts,swin);
            else
                [W,S,B] = dk.deal(swin);
            end
            
            % check
            assert( S > 0,  'Window step should be positive.' );
            assert( B >= 0, 'Burn-in should be non-negative.' );
            assert( (B + W) <= self.ts.nt, ...
                'Burn-in time and window-length are unfeasible given the time-series length.' );
            
            % assign
            self.wsize = W;
            self.wstep = S;
            self.wburn = B;
            
            self.reset();
        end
        
    end
    
    %-------------------
    % Sliding methods
    %-------------------
    methods
                
        % Is the current window valid?
        function v = valid(self)
            v = self.wstep > 0 && self.curw >= 0 && self.curw < self.nwin;
        end
        
        % Restart iteration
        function reset(self)
            self.curw = 0;
        end
        
        % Move n window(s) forward/backward by steps of self.wstep
        function slide_forward(self,n)
            if nargin < 2, n = 1; end
            self.curw = self.curw + n;
        end
        
        function slide_backward(self,n)
            if nargin < 2, n = 1; end
            self.curw = self.curw - n;
        end
        
        % Return the times corresp. to the current window
        function t = time(self)
            [f,l] = self.frame;
            t = self.ts.time(f:l);
        end
        
        % Return the values corresp. to the current window
        function v = vals(self,k)
            if nargin < 2, k=1:self.ts.ns; end
            [f,l] = self.frame;
            v = self.ts.vals(f:l,k);
        end
        
        % Get a timeseries object corresp. to the current window
        function tsobj = get_timeseries(self)
            tsobj = ant.TimeSeries( self.time(), self.vals() );
        end
        
    end
    
end
