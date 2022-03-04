classdef TimeSeries < ant.priv.Signal
% Time-units in SECONDS.
% Rows of vals correspond to observations, columns to variables.
%   ie, each column is a different signal/channel/variable.
    
    properties
        time;
        vals;
    end
    
    %-------------------
    % Instance methods
    %-------------------
    methods
        
        % Constructor
        function self = TimeSeries(varargin)
        if nargin > 0
            self.assign(varargin{:});
        end
        end
        
        % Clear
        function clear(self)
            self.time = [];
            self.vals = [];
        end
        
        % Copy
        function copy(self,ts)
            self.time = ts.time;
            self.vals = ts.vals;
        end
        
        % Clone
        function ts = clone(self)
            ts = ant.TimeSeries();
            ts.copy( self );
        end
        
        % Cast values to a different type
        function cast(self,type)
            self.vals = cast( self.vals, type );
        end
        
        % Comparison
        function eq = equals(self,other,thresh)
            if nargin < 3, thresh=eps; end
            eq = max(abs( self.vals(:) - other.vals(:) )) <= thresh;
        end
        
        % Concatenation
        function ts = horzcat(self,varargin)
            ts = dk.mapfun( @(x) x.vals, varargin, false );
            ts = ant.TimeSeries( self.time, horzcat(self.vals,ts{:}) );
        end
        
        function ts = vertcat(self,varargin)
            t = dk.mapfun( @(x) x.time, varargin, false );
            v = dk.mapfun( @(x) x.vals, varargin, false );
            
            ts = ant.TimeSeries( vertcat( self.time, t{:} ), vertcat( self.vals, v{:} ) );
            dk.assert('w', ts.is_analytic(), 'The concatenated time-series is not analytic!' );
        end
        
        function self = assign( self, varargin )

            switch nargin
                case 2
                    if ischar(varargin{1})
                        % load from file
                        self.unserialise(varargin{1});
                        return;
                    else
                        % assume that input has fields time/vals
                        t = varargin{1}.time;
                        v = varargin{1}.vals;
                    end
                case 3
                    t = varargin{1};
                    v = varargin{2};
                otherwise
                    error('Expected one or two inputs.');
            end

            [v,t] = dk.formatmv(v,t,'vertical');
            assert( numel(t) > 1, 'There should be more than one time-point.' );
            assert( isnumeric(v), 'Values should be numeric.' );

            self.time = t;
            self.vals = v;

        end
        
    end
    
    
    %--------
    % I/O
    %--------
    methods    
        
        function x = serialise(self,filename)
            x.version = '1.0';
            x.data    = [ self.time, self.vals ];
            if nargin > 1
                dk.save( filename, x );
            end
        end
        
        function self = unserialise(self,x)
            if ischar(x), x = load(x); end
            switch x.version
                case '1.0'
                    self.time = real(x.data(:,1));
                    self.vals = x.data(:,2:end);
            end
        end 
        
        function ts = saveobj(self)
            ts = self.serialise();
        end
        
        function self = save(self,filename)
            self.serialise(filename);
        end
        
    end
    methods (Static)
        
        function ts = loadobj(in)
            if isstruct(in)
                ts = ant.TimeSeries();
                ts.unserialise(in);
            else
                warning('Unknown serialised TimeSeries format.');
                ts = in;
            end
        end
        
        function ts = load(filename)
            ts = ant.TimeSeries(filename);
        end
        
    end
    
    
    %-------------------
    % Resampling methods
    %-------------------
    methods
        
        % Resample the time-courses using Matlab's function resample
        function ts = make_arithmetic(self)
            [new_vals,new_time] = ant.ts.resample( self.vals, self.time );
            if nargout == 0
                self.vals = new_vals;
                self.time = new_time;
            else
                ts = ant.TimeSeries( new_time, new_vals );
            end
        end
        
        % Interpolate at given timepoints
        function ts = interpolate(self,query_t,method)
            if nargin < 3, method = 'pchip'; end
            
            query_t  = query_t(:);
            new_vals = interp1( self.time, self.vals, query_t, method );
            if nargout == 0
                self.vals = new_vals;
                self.time = query_t;
            else
                ts = ant.TimeSeries( query_t, new_vals );
            end
        end
        
        % Resample at a given sampling frequency
        function ts = resample(self,fs,tol)
            
            if nargin < 3, tol=0.1; end
            curfs = self.fs;
            
            if abs(fs - curfs) <= tol
                dk.info( '[ant.TimeSeries:resample] Already at the required sampling rate.' );
                return;
            elseif fs <= curfs
                [new_vals,new_time] = ant.ts.downsample( self.vals, self.time, fs );
            else
                [new_vals,new_time] = ant.ts.upsample( self.vals, self.time, fs );
            end
            
            if nargout == 0
                self.time = new_time;
                self.vals = new_vals;
            else
                ts = ant.TimeSeries( new_time, new_vals );
            end
            
        end
        
        % Resample to a given number of points
        function ts = resample_n(self,n)
            fs = (n-1) / self.tspan;
            if nargout == 0
                self.resample(fs);
            else
                ts = self.resample(fs);
            end
        end
        
        % NOTE: 
        % Matlab's resample function is not great, try using this method only when the time-series 
        % is not arithmetically sampled.
        %
        function ts = resample_fir(self,fs)
            [new_vals,new_time] = ant.ts.resample( self.vals, self.time, fs );
            if nargout == 0
                self.vals = new_vals;
                self.time = new_time;
            else
                ts = ant.TimeSeries( new_time, new_vals );
            end
        end
        function ts = downsample_iir(self,fs)
            [new_vals,new_time] = ant.ts.decimate( self.vals, self.time, fs );
            if nargout == 0
                self.vals = new_vals;
                self.time = new_time;
            else
                ts = ant.TimeSeries( new_time, new_vals );
            end
        end
        
    end
    
    
    %------------------------------------
    % Summary methods + structure manip
    %------------------------------------
    methods
        
        % Implement inherited masking
        function ts = mask_k(self,tidx)
            m = self.tidx2mask(tidx);
            if nargout == 0
                self.time = self.time(m);
                self.vals = self.vals(m,:);
            else
                ts = ant.TimeSeries( self.time(m), self.vals(m,:) );
            end
        end
        
        function ts = mask_s(self,sidx)
            m = self.sidx2mask(sidx);
            if nargout == 0
                self.vals = self.vals(:,m);
            else
                ts = ant.TimeSeries( self.time, self.vals(:,m) );
            end
        end
        
        % Average timecourse
        function ts = average(self)
            ts = ant.TimeSeries( self.time, nanmean(self.vals,2) );
        end
        
        % Energy
        function e = energy(self)
            e = nansum( self.vals .* conj(self.vals), 1 );
        end
        
        % RMS norm
        function r = rms(self)
            r = sqrt(nanmean( self.vals .* conj(self.vals), 1 ));
        end
        
        % Mean and sdev
        function m = mean(self), m = nanmean( self.vals, 1 ); end
        function s = sdev(self), s = nanstd( self.vals, [], 1 ); end
        function s = std(self), s = self.sdev;  end
        function v = var(self), v = var( self.vals, [], 1, 'omitnan' );  end
        
        % Reorder signals
        function ts = reorder(self,order)
            assert( dk.num.isperm(order), '[ant.TimeSeries] Expected a permutation in input.' );
            if nargout == 0
                self.vals = self.vals(:,order);
            else
                ts = ant.TimeSeries( self.time, self.vals(:,order) );
            end
        end
        
    end
    
    
    %-------------------------
    % Value-changing methods
    %-------------------------
    methods
        
        % Apply function to values
        function ts = apply(self,fun)
            ts = make_output( nargout, self, fun(self.vals) );
        end
        
        % Subtract the time-average from each signal (in-place if no output)
        function ts = demean(self)
            ts = make_output( nargout, self, dk.bsx.sub( self.vals, self.mean ) );
        end
        
        % (x - mu) / sigma (in-place if no output)
        function ts = normalise(self)
            v = dk.bsx.sub( self.vals, self.mean );
            v = dk.bsx.rdiv( v, max(eps,self.std) );
            
            ts = make_output( nargout, self, v );
        end
        
        % Compute the numerical derivative of the signal
        function ts = derive(self)
            v = ant.ts.diff( self.vals, self.fs(true) );
            ts = make_output( nargout, self, v );
        end
        
        % Smooth time-courses 
        function ts = smooth(self,varargin)
            ts = make_output( nargout, self, ant.ts.smooth( self.vals, self.time, varargin{:} ) );
        end
        
        % Regress an input time-course out of the current time-series
        function ts = regress(self,x)
            
            if isa(x,'ant.TimeSeries'), x=x.vals; end
            
            [xr,xc] = size(x);
            assert( (xr == self.nt) && (xc == 1), 'Bad input size.' );
            ts = make_output( nargout, self, self.vals - x*(x\self.vals) );
        end
        
        % Partial timecourses: for each signal, regress the others from it
        function ts = partial(self)
            
            v = self.vals;
            n = self.ns;
            
            for i = 1:n
                ts_i = self.vals(:,i);
                ts_r = self.vals(:,setdiff(1:n,i));
                
                v(:,i) = ts_i - ts_r * (ts_r \ ts_i);
            end
            
            ts = make_output( nargout, self, v );
        end
        
        % Re-reference the cross-signal average with respect to a subset of signals
        % Note: adapted from FieldTrip
        function ts = recentre(self,ref)
            
            if nargin < 2, ref = 1:self.ns; end
            ref = dk.torow(ref);
            mu  = nanmean( self.vals(:,ref), 2 );
            v   = dk.bsx.sub( self.vals, mu );
            ts  = make_output( nargout, self, v );
        end
        
        % Denoise by regressing out a reference time-course
        % Note: adapted from FieldTrip
        function ts = denoise(self,ref)
            
            if isa(ref,'ant.TimeSeries'), ref=ref.vals; end
            
            % recentre both
            ref = dk.bsx.sub( ref, mean(ref,2) );
            dat = dk.bsx.sub( self.vals, mean(self.vals,2) );
            
            mixcov = transpose(dat) * ref;
            refcov = transpose(ref) * ref;
            
            w  = pinv(refcov) * transpose(mixcov); % regression weights
            v  = self.vals - ref*w;
            ts = make_output( nargout, self, v );
        end
        
        % Regress the best affine fit
        function ts = detrend(self,varargin)
            ts = make_output( nargout, self, detrend(self.vals,varargin{:}) );
        end
        
        % Remove polynomial trend from time-courses
        % Note: adapted from FieldTrip
        function ts = poly_detrend(self,order)
            
            if nargin < 2, order = 1; end % affine by default
            
            x = bsxfun( @power, self.time, 0:order );
            c = inv( x' * x ); % keep using inverse despite warning
            b = c * x' * self.vals; %#ok
            v = self.vals - x*b;
            
            ts = make_output( nargout, self, v );
        end
        
    end
    
    
    %-------------------
    % Plotting methods
    %-------------------
    methods
        
        % Line plot (ok for a few signals)
        function h = plot_lines(self,varargin)
            h = plot( self.time', self.vals', varargin{:} );
        end
        
        % Line plot with average tc on top
        function [hl,hm] = plot_mlines(self)
            hl = plot( self.time', self.vals', '-', 'LineWidth', 0.3 ); hold on;
            hm = plot( self.time', nanmean(self.vals,2)', 'k-', 'Linewidth', 4 ); hold off;
        end
        
        % Image plot (for lots of signals)
        function h = plot_image(self,varargin)
            h = ant.img.show( {self.time, 1:self.ns, self.vals}, 'xlabel', 'Time (sec)', varargin{:} ); 
        end
        
        % Value distribution plot
        function [D,t,v] = plot_vald(self,fs,nbins,varargin)
            if nargin < 3 || isempty(nbins), nbins=100; end
            ncols = fix( fs*self.tspan );
            [D,t,v] = ant.ui.ts2image( self, 1, nbins, ncols );
            D = dk.bsx.rdiv( D, max(1,sum(D,1)) ); % normalise
            ant.img.show( {t,v,D}, varargin{:} );
        end
        
    end
    
end

function out = make_output( narg, ts, vals )

    if narg == 0
        ts.vals = vals;
        out = ts;
    else
        out = ant.TimeSeries( ts.time, vals );
    end

end
