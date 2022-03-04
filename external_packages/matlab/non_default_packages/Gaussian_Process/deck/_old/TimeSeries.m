classdef TimeSeries < handle
% Time-units in SECONDS.
% Rows of vals correspond to observations, columns to variables.
%   ie, each column is a different signal/channel/variable.
    
    properties
        time;
        vals;
    end
    properties (Transient,Dependent)
        n_times, n_signals; % long names
        tspan; % time-span
    end
    properties (Transient,Dependent,Hidden)
        nt, ns; % short names
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
        
        function y = is_empty(self), y = self.nt == 0; end
        function y = is_real (self), y = isreal(self.vals); end
        
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
        
        % Dimensions
        function n = get.nt(self), n = size(self.time,1); end % num of timesteps
        function n = get.ns(self), n = size(self.vals,2); end % num of signals
        
        function n = get.n_times  (self), n = self.nt; end
        function n = get.n_signals(self), n = self.ns; end
        
        function Dt = timespan(self)
            Dt = self.time(end) - self.time(1);
        end
        function tf = timeframe(self)
            tf = [self.t_start, self.t_end];
        end
        
        function Dt = get.tspan(self), Dt = self.timespan(); end
        function t = t_start(self), t = self.time(1); end
        function t = t_end(self), t = self.time(end); end
        
        function [vmin,vmax] = extrema(self)
            [vmin,vmax] = ant.stat.extrema(self.vals(:));
        end
        
        % Assign members
        function assign(self,varargin)
            
            switch nargin
                case 2
                    if ischar(varargin{1})
                        self.unserialise(varargin{1});
                        return;
                    else %isstruct(varargin{1}) || isa(varargin{1},'ant.TimeSeries')
                        t = varargin{1}.time;
                        v = varargin{1}.vals;
                    end
                case 3
                    t = varargin{1};
                    v = varargin{2};
                otherwise
                    error('Expected one (structure with fields time, vals) or two (time and value arrays) inputs.');
            end
            
            [v,t] = dk.formatmv(v,t);
            assert( numel(t) > 1, 'There should be more than one time-point.' );
            assert( isnumeric(v), 'Values should be numeric.' );
            
            self.time = t(:);
            self.vals = v;
        end
        
        % Cast values to a different type
        function cast(self,type)
            self.vals = cast( self.vals, type );
        end
        
        % Return members as a struct or struct-array
        function out = to_struct(self,as_array)
            
            if nargin < 2, as_array=false; end
            if as_array
                out = dk.struct.repeat( {'time','vals'}, 1, self.ns );
                for i = 1:self.ns
                    out(i).time = self.time;
                    out(i).vals = sels.vals(:,i);
                end
            else
                out = struct( 'time', self.time, 'vals', self.vals );
            end
            
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
        
        % sampling rate
        function dt = dt(self,check)
            if nargin < 2, check=false; end
            if check
                [chk,dt] = self.is_arithmetic();
                assert( chk, 'Timestep is not regular.' );
            else
                dt = abs(self.time(2)-self.time(1));
            end
        end
        
        function fs = fs(self,check)
            if nargin < 2, check=false; end
            fs = 1/self.dt(check);
        end
        
        function n = numsteps(self,t,check)
            if nargin < 3, check=false; end
            n = round( t / self.dt(check) );
        end
        
        % Analytic if all timesteps are greater than epsilon
        function [yes,dt] = is_analytic(self)
            dt = diff(self.time);
            dt = sign(dt(1)) * dt;
            yes = all( dt > eps );
        end
        
        % Arithmetic if all timesteps are almost equal
        function [yes,dt] = is_arithmetic(self,rtol)
            if nargin < 2, rtol = 1e-6; end
            [yes,dt] = self.is_analytic();
            dt = mean(dt);
            yes = yes && max(dt)/dt <= 1+rtol;
        end
        
        % Find dt that fits an integer number of steps in the current time-interval.
        % Output dt is smaller or equal to input dt.
        function [dt,nsteps] = closest_dt(self,dt)
            nsteps = ceil( self.tspan / dt );
            dt     = self.tspan / (nsteps - 1);
        end
        
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
        
        % Interpolate at given timestep (can be useful for fast upsampling)
        function ts = interpolate_dt(self,dt,method)
            if nargin < 3, method = 'pchip'; end
            
            query_t = self.time(1) : dt : self.time(end);
            if nargout == 0
                self.interpolate(query_t,method);
            else
                ts = self.interpolate(query_t,method);
            end
        end
        
        % Resample at a given sampling frequency
        %
        % NOTE: 
        % Matlab's resample function is not great, try using this method only when the time-series 
        % is not arithmetically sampled. Otherwise use upsample/downsample instead.
        %
        function ts = resample(self,fs,method)
            if nargin < 3, method = 'pchip'; end

            [new_vals,new_time] = ant.ts.resample( self.vals, self.time, fs, method );
            if nargout == 0
                self.vals = new_vals;
                self.time = new_time;
            else
                ts = ant.TimeSeries( new_time, new_vals );
            end
        end
        
        % Resample to a given number of points
        function ts = resample_n(self,n,method)
            if nargin < 3, method = 'pchip'; end
            
            fs = (n-1) / self.tspan;
            if nargout == 0
                self.resample(fs,method);
            else
                ts = self.resample(fs,method);
            end
        end
        
        % Specific methods to up/downsample
        function ts = upsample(self,varargin)
            [new_vals,new_time] = ant.ts.upsample( self.vals, self.time, varargin{:} );
            if nargout == 0
                self.vals = new_vals;
                self.time = new_time;
            else
                ts = ant.TimeSeries( new_time, new_vals );
            end
        end
        function ts = downsample(self,varargin)
            [new_vals,new_time] = ant.ts.downsample( self.vals, self.time, varargin{:} );
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
        function s = sdev(self), s = nanstd ( self.vals, [], 1 ); end
        function s = std (self), s = self.sdev;  end
        function v = var (self), v = var( self.vals, [], 1, 'omitnan' );  end
        
        % Time masks
        function m = tmask_lt(self,cut), m = self.time < cut; end
        function m = tmask_gt(self,cut), m = self.time > cut; end
        
        function m = tmask_leq(self,cut), m = self.time <= cut; end
        function m = tmask_geq(self,cut), m = self.time >= cut; end
        
        % Remove the k first/last samples
        function ts = pop_front(self,k)
            if nargout == 0
                self.remove_times(1:k);
            else
                ts = self.remove_times(1:k);
            end
        end
        function ts = pop_back(self,k)
            k = self.nt-k;
            if nargout == 0
                self.select_times(1:k);
            else
                ts = self.select_times(1:k);
            end
        end
        
        % Remove timepoints after/before a certain time
        function ts = rem_before(self,tval)
            m = self.tmask_lt(tval);
            if nargout == 0
                self.remove_times(m);
            else
                ts = self.remove_times(m);
            end
        end
        function ts = rem_after(self,tval)
            m = self.tmask_gt(tval);
            if nargout == 0
                self.remove_times(m);
            else
                ts = self.remove_times(m);
            end
        end
        
        % Select a subset of signals or timepoints (in-place if no output)
        function ts = select_signals(self,sel)
            if nargout == 0
                self.vals = self.vals(:,sel);
            else
                ts = ant.TimeSeries( self.time, self.vals(:,sel) );
            end
        end
        function ts = select_times(self,sel)
            if nargout == 0
                self.time = self.time(sel);
                self.vals = self.vals(sel,:);
            else
                ts = ant.TimeSeries( self.time(sel), self.vals(sel,:) );
            end
        end
        
        % Remove a subset of signals or timepoints (in-place if no output)
        function ts = remove_signals(self,sel)
            if islogical(sel)
                sel = ~sel;
            else
                sel = setdiff( 1:self.ns, sel );
            end
            if nargout == 0
                self.select_signals(sel);
            else
                ts = self.select_signals(sel);
            end
        end
        function ts = remove_times(self,sel)
            if islogical(sel)
                sel = ~sel;
            else
                sel = setdiff( 1:self.nt, sel );
            end
            if nargout == 0
                self.select_times(sel);
            else
                ts = self.select_times(sel);
            end
        end
        
        % Reorder signals
        function ts = reorder(self,order)
            assert( dk.num.isperm(order), '[ant.TimeSeries] Expected a permutation in input.' );
            if nargout == 0
                self.vals = self.vals(:,order);
            else
                ts = ant.TimeSeries( self.time, self.vals(:,order) );
            end
        end
        
        % Time-window
        function ts = window(self,kfirst,klast)
            m = kfirst:klast;
            if nargout == 0
                self.select_times(m);
            else
                ts = self.select_times(m);
            end
        end
        function ts = time_window(self,tstart,tend)
            m = self.tmask_geq(tstart) & self.tmask_leq(tend);
            if nargout == 0
                self.select_times(m);
            else
                ts = self.select_times(m);
            end
        end
        
        % Burn a certain amount of time at the start
        function ts = burn(self,duration)
            assert( duration > 0, 'Durations should be positive.' );
            assert( duration < self.timespan, 'Duration is longer than the timecourse!' );
            
            m = self.tmask_lt( self.time(1) + duration );
            if nargout == 0
                self.remove_times(m);
            else
                ts = self.remove_times(m);
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
            v = dk.bsx.rdiv( v, self.std );
            
            ts = make_output( nargout, self, v );
        end
        
        % Re-reference the cross-signal average with respect to a subset of signals.
        % Note: adapted from FieldTrip
        function ts = rereference(self,ref)
            
            if nargin < 2, ref = 1:self.ns; end
            ref = dk.torow(ref);
            mu  = nanmean( self.vals(:,ref), 2 );
            v   = dk.bsx.sub( self.vals, mu );
            ts  = make_output( nargout, self, v );
        end
        
        % Smooth time-courses using median filter
        function ts = smooth(self,order)
            if nargin < 2, order = 3; end % this is Matlab's default
            ts = make_output( nargout, self, medfilt1( self.vals, order ) );
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
        
        % Denoise by regressing out a reference time-course
        % Note: adapted from FieldTrip
        function ts = denoise(self,ref)
            
            if isa(ref,'ant.TimeSeries'), ref=ref.vals; end
            
            % demean both
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
        
        % Compute the numerical derivative of the signal
        function ts = derive(self)
            [ari,dt] = self.is_arithmetic();
            assert( ari, 'Cannot differentiate irregular time-series.' );
            v = ant.ts.diff( self.vals, 1/dt );
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
            ncols = fix( fs*self.timespan() );
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
