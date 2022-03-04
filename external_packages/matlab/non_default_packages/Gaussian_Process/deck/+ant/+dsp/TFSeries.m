classdef TFSeries < ant.priv.Signal
%
% ant.dsp.TFSeries( time, vals, freq, pnorm=1 )
%
% Time-frequency objects store the spectral contents (typically complex-valued) produced
% by time-frequency analysis, for instance:
%   ant.dsp.wavelet
%   ant.dsp.hilbert
%
% The properties are:
%    time  Vector of timepoints
%    vals  Complex-valued matrix with spectrum for each time-course
%    freq  Either a scalar (wavelet) or a 1x2 band vector (hilbert)
%   pnorm  Normalisation scalar used to compute power density
% 
%
% Methods available fall into several categories:
%
%       FORMAT: cartesian, polar
%    TRANSFORM: resample, filter, smooth
%   PROPERTIES: psd, amplitude, magnitude, phase, dphase, phase_offset, synchrony
%
% See comments for more details about how to call these various methods.
%
% JH

    properties
        time;
        vals;
        freq;
        pnorm;
    end
    
    properties (Transient,Dependent)
        cenfrq, isband;
    end
    
    methods
        
        function self = TFSeries(varargin)
            self.clear();
            switch nargin 
                case 0 % nothing to do
                case 1
                    self.unserialise(varargin{1});
                otherwise
                    self.assign(varargin{:});
            end
        end
        
        function clear(self)
            self.time = [];
            self.vals = [];
            self.freq = [];
            self.pnorm = 1;
        end
        
        function s = clone(self)
            s = ant.dsp.TFSeries( self.time, self.vals, self.freq, self.pnorm );
        end
        
        
        % Dependent properties
        function f = get.cenfrq(self), f = mean(self.freq); end
        function y = get.isband(self), y = numel(self.freq)==2; end
        
        
        % Assignment from time-series
        function self = assign(self,time,vals,freq,pnorm)
            
            if nargin < 5, pnorm=1; end
            
            [vals,time] = dk.formatmv(vals,time,'vertical');
            assert( ~isreal(vals), 'This class is for complex-valued signals representing time-resolved spectra.' );
            assert( numel(freq)<=2 && all(freq > eps), 'Frequency(-band) should be positive.' );
            assert( isscalar(pnorm) && pnorm > eps, 'Power norm should be positive scalar.' );
            
            self.time = time;
            self.vals = vals;
            self.freq = freq;
            self.pnorm = pnorm;
            
        end
        
    end
    
    %------------------
    % I/O
    %
    %   serialise()
    %   unserialise(s)
    %
    %   save(filename)
    %   load(filename)
    %
    % Also implements: savobj, loadobj
    %
    %------------------
    methods
        
        function [p,n] = get_props(self)
            p = {'time','vals','freq','pnorm'};
            n = numel(p);
        end
        
        function x = serialise(self)
            x.version = '0.1';
            [p,n] = self.get_props();
            for i = 1:n
                x.(p{i}) = self.(p{i});
            end
        end
        
        function self = unserialise(self,x)
            if ischar(x), x=dk.load(x); end
            switch x.version
            case '0.1'
                [p,n] = self.get_props();
                for i = 1:n
                    self.(p{i}) = x.(p{i});
                end
            end
        end
        
        function self = save(self,filename)
            x = self.serialise();
            dk.savehd( filename, x );
        end
        function x = saveobj(self)
            x = self.serialise();
        end
        
        function self = load(self,filename)
            dk.print('[ant.dsp.TFSeries] Loading file "%s"...',filename);
            self.unserialise(filename);
        end
        
    end
    methods (Static)
        
        function x = loadobj(in)
            if isstruct(in)
                x = ant.dsp.TFSeries(in);
            else
                warning('Unknown serialised Signal format.');
                x = in;
            end
        end
        
    end
    
    %------------------
    % TRANSFORM
    %
    %   cartesian()
    %   polar()
    %   smooth( polar=true )
    %   resample( fs )
    %   magfilt( -10 )
    %
    %------------------
    methods
        
        % implement inherited masking
        function ts = mask_k(self,tidx)
            m = self.tidx2mask(tidx);
            if nargout == 0
                self.time = self.time(m);
                self.vals = self.vals(m,:);
            else
                ts = ant.dsp.TFSeries( self.time(m), self.vals(m,:), self.freq, self.pnorm );
            end
        end
        
        function ts = mask_s(self,sidx)
            m = self.sidx2mask(sidx);
            if nargout == 0
                self.vals = self.vals(:,m);
            else
                ts = ant.dsp.TFSeries( self.time, self.vals(:,m), self.freq, self.pnorm );
            end
        end
        
        % Reorder signals
        function ts = reorder(self,order)
            assert( dk.num.isperm(order), '[ant.dsp.TFSeries] Expected a permutation in input.' );
            if nargout == 0
                self.vals = self.vals(:,order);
            else
                ts = ant.dsp.TFSeries( self.time, self.vals(:,order), self.freq, self.pnorm );
            end
        end
        
        function [x,y,t] = cartesian(self)
        %
        % [x,y,t] = cartesian()
        %
        
            x = real(self.vals);
            y = imag(self.vals);
            t = self.time;
        end
        
        function [m,p,t] = polar(self)
        %
        % [m,p,t] = polar()
        %
        
            m = abs(self.vals);
            p = angle(self.vals);
            t = self.time;
        end
        
        function self = smooth(self,varargin)
        %
        % self = smooth( varargin )
        %
        % Use Matlab's smooth function to smooth the spectral time-courses.
        % Additional arguments are forwarded to smooth.
        %
        % See also: ant.ts.smooth
        %
        
            self.vals = ant.ts.smooth( self.vals, self.time, varargin{:} );
            
        end
        
        function self = resample(self,fs,tol)
        %
        % resample( fs, tol=0.1 )
        %
        % Use ant.priv.(down|up)sample_ssig to resample the complex time-courses.
        % Tolerance is used to prevent resampling if current sampling frequency is close enough.
        %
        
            if nargin < 3, tol=0.1; end
            curfs = self.fs;
            
            if abs(fs - curfs) <= tol
                dk.info( '[ant.dsp.TFSeries:resample] Already at the required sampling rate.' );
            elseif fs <= curfs
                [self.time,self.vals] = ant.priv.ansig_downsample( self.time, self.vals, fs );
            else
                [self.time,self.vals] = ant.priv.ansig_upsample( self.time, self.vals, fs );
            end
            
        end
        
        function self = magfilt(self,varargin)
        %
        % self = magfilt( string, options... )
        % self = magfilt( numeric, options... )
        % self = magfilt( struct, options... )
        %
        % Filter the magnitude of the spectral time-courses.
        % Arguments are forwarded to nst.dsp.do.filter
        %
            
            mag = nst.dsp.TimeSeries( self.time, abs(self.vals) );
            mag = nst.dsp.do.filter(mag,varargin{:});
            phi = angle(self.vals);
            
            self.vals = mag.vals .* exp( 1i*phi );
            
        end
        
    end
    
    
    %------------------
    % FEATURES
    %
    %   Format [x,t] = property( idx )
    %       psd
    %       amplitude
    %       magnitude
    %       phase
    %       ifreq
    %       phase_offset
    %       synchrony
    %
    %------------------
    methods
        
        % features
        function [p,t] = psd(self,tidx)
            if nargin < 2, tidx=1:self.nt; end
            t = self.time(tidx);
            p = self.vals(tidx,:);
            p = p .* conj(p) / self.pnorm;
        end
        
        function [a,t] = amplitude(self,tidx)
            if nargin < 2, tidx=1:self.nt; end
            [a,t] = self.psd(tidx);
            a = sqrt(a);
        end
        
        function [m,t] = magnitude(self,tidx)
            if nargin < 2, tidx=1:self.nt; end
            m = abs(self.vals(tidx,:));
            t = self.time(tidx);
        end
        
        function [p,t] = phase(self,tidx)
            if nargin < 2, tidx=1:self.nt; end
            t = self.time(tidx);
            p = angle(self.vals(tidx,:));
        end
        
        % instantaneous frequency estimate (normalised derivative of the phase)
        function [f,t] = ifreq(self,tidx)
            if nargin < 2, tidx=1:self.nt; end
            [f,t] = self.phase(tidx);
            h = t(2)-t(1);
            f = ant.priv.phase2freq(f,1/h);
        end
        
        % at each timepoint, difference with the average phase across TCs
        function [o,t] = phase_offset(self,tidx)
            if nargin < 2, tidx=1:self.nt; end
            [o,t] = self.phase(tidx);
            o = dk.bsx.sub( o, mean(o,2) );
            o = atan2( cos(o), sin(o) );
        end
        
        function [s,t] = synchrony(self,tidx)
            if nargin < 2, tidx=1:self.nt; end
            [s,t] = self.phase(tidx);
            s = abs(mean( exp( 1i*s ), 2 ));
        end
        
    end
    
    %------------------
    % SLIDING
    %
    %   Format [x,t] = sliding_property( reduce, [len,step,burn] )
    %       sliding_psd
    %       sliding_amplitude
    %       sliding_magnitude
    %       sliding_phase
    %       sliding_synchrony
    %
    %     If reduce=[], it defaults to @(t) mean(t,1).
    %     The function is invoked with the output of self.property( tidx ).
    %
    %
    %   Format [x,t,w] = adaptive_property( reduce, nosc, burn=0, ovr=0.5 )
    %       adaptive_psd
    %       adaptive_amplitude
    %       adaptive_magnitude
    %       adaptive_phase
    %       adaptive_synchrony
    %
    %   See also summary method below.
    %
    %------------------
    methods
        
        function [p,t] = sliding_prop(self,name,rfun,swin)
            if isempty(rfun), rfun=@(x) mean(x,1); end
            assert( isa(rfun,'function_handle'), 'Expected function handle in input.' );
            [p,t] = ant.dsp.slidingfun( @(~,ti,te) rfun(self.(name)(ti:te)), self, swin );
            p = vertcat(p{:}); % Nwin x Nsig
        end
        
        function [p,t] = sliding_psd(self,varargin)
            [p,t] = self.sliding_prop('psd',varargin{:});
        end
        function [a,t] = sliding_amplitude(self,varargin)
            [a,t] = self.sliding_prop('amplitude',varargin{:});
        end
        function [a,t] = sliding_magnitude(self,varargin)
            [a,t] = self.sliding_prop('magnitude',varargin{:});
        end
        function [p,t] = sliding_phase(self,varargin)
            [p,t] = self.sliding_prop('phase',varargin{:});
        end
        function [s,t] = sliding_synchrony(self,varargin)
            [s,t] = self.sliding_prop('synchrony',varargin{:});
        end
        
        % varargin = nosc[cycles], burn[sec], ovr[ratio] (cf adaptive_win)
        function [x,t,w] = adaptive_prop(self,name,rfun,varargin)
            w = ant.priv.win_adaptive(self.cenfrq,varargin{:});
            [x,t] = self.sliding_prop(name,rfun,w);
        end
        
        function [p,t,w] = adaptive_psd(self,varargin)
            [p,t,w] = self.adaptive_prop('psd',varargin{:});
        end
        function [a,t,w] = adaptive_amplitude(self,varargin)
            [a,t,w] = self.adaptive_prop('amplitude',varargin{:});
        end
        function [m,t,w] = adaptive_magnitude(self,varargin)
            [m,t,w] = self.adaptive_prop('magnitude',varargin{:});
        end
        function [p,t,w] = adaptive_phase(self,varargin)
            [p,t,w] = self.adaptive_prop('phase',varargin{:});
        end
        function [s,t,w] = adaptive_synchrony(self,varargin)
            [s,t,w] = self.adaptive_prop('synchrony',varargin{:});
        end
        
        % plot spectrogram
        function plot(self,varargin)
            
            [p,t] = self.psd();
            f = self.freq;
            
            % line-plot for multiband, image for wavelet analysis
            if self.isband
                plot( t, p );
                xlabel(xlab); ylabel('PSD'); 
                dk.ui.title('PSD in band [%.0f - %.0f] Hz',f(1),f(2));
            else
                plot( t, p );
                xlabel(xlab); ylabel('PSD'); 
                dk.ui.title('PSD at %.0f Hz',f);
            end
            
        end
        
    end
    
end
