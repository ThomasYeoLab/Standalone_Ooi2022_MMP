classdef TFSpectrum < handle
%
% ant.dsp.TFSpectrum( tfs )
% ant.dsp.TFSpectrum( tfs1, tfs2, ... )
%
% Collection of TFSeries objects.
%
% See also: ant.dsp.TFSeries
%
% JH

    properties
        sig
    end
    
    properties (Transient,Dependent)
        ns, nf, ismultiband;
    end
    
    methods
        
        function self = TFSpectrum(varargin)
            self.clear();
            if nargin > 0
                self.assign(varargin{:});
            end
        end
        
        function clear(self)
            self.sig = {};
        end
        
         % dependent properties
        function n = get.nf(self), n = numel(self.sig); end
        
        function n = get.ns(self)
            if self.nf
                n = self.sig{1}.ns;
            else
                n = 0;
            end
        end
        
        function y = get.ismultiband(self)
            if self.nf
                y = self.sig{1}.isband;
            else
                y = false;
            end
        end
        
        % time/frequency info
        function s = signal(self,k)
            s = self.sig{k}; 
        end
        function t = tframe(self) 
            t = dk.mapfun( @(x) x.tframe, self.sig, false );
        end
        function f = freq(self)
            f = dk.mapfun( @(x) x.freq, self.sig, ~self.ismultiband );
        end
        function f = cenfrq(self)
            f = dk.mapfun( @(x) x.cenfrq, self.sig, true );
        end
        function x = dt(self)
            x = dk.mapfun( @(x) x.dt, self.sig, true );
        end
        function x = fs(self)
            x = dk.mapfun( @(x) x.fs, self.sig, true );
        end
        
        % assign spectral signals
        function self = assign(self,varargin)
            
            % get input
            input = dk.wrap(varargin);
            
            % clear contents if empty
            if isempty(input)
                self.clear();
                return
            end
            
            % check inputs
            assert( all(cellfun( @(x) isa(x,'ant.dsp.TFSeries'), input )), ...
                'Input should be a cell of TFSeries objects.' );
            
            % sanity checks
            chk = dk.mapfun( @(x) [x.time(1), x.ns, numel(x.freq)], input, false );
            chk = vertcat(chk{:});
            chk = diff(chk,1,1) == 0;
            assert( all(chk(:)), 'Shape or time-course mismatch between inputs.' );
            
            % assign input
            n = numel(input);
            self.sig = reshape( input, [1 n] );
            
        end
        
    end
    
    %------------------
    % I/O
    %------------------
    methods
        
        function x = serialise(self)
            x.version = '0.1';
            x.sig = self.sig;
        end
        
        function self = unserialise(self,x)
            if ischar(x), x=dk.load(x); end
            switch x.version
            case '0.1'
                self.sig = x.sig;
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
            dk.print('[ant.dsp.TFSpectrum] Loading file "%s"...',filename);
            self.unserialise(filename);
        end
        
    end
    methods (Static)
        
        function x = loadobj(in)
            if isstruct(in)
                x = ant.dsp.TFSpectrum();
                x.unserialise(in);
            else
                warning('Unknown serialised Aggregate format.');
                x = in;
            end
        end
        
    end
    
    %------------------
    % ANALYSIS
    %------------------
    methods
        
        % burn-in
        function burn(self,tlen)
            n = self.nf;
            for i = 1:n
                self.sig{i}.burn(tlen);
            end
        end
        
        % return logical mask for signals matching input frequency band (1x2 vector)
        function match = band_match(self,b)
            f = self.freq;
            if self.ismultiband
                match = cellfun( @(x) dk.call(2,@ant.util.band_overlap,x,b), f ) > 0.95;
            else
                match = (f >= b(1)) & (f <= b(2));
            end
        end
        
        % return only signals matching input frequency band (or modify current object)
        function obj = band_select(self,b)
            match = self.band_match(b);
            if nargout == 0
                self.sig = self.sig(match);
            else
                obj = ant.dsp.TFSpectrum(self.sig(match));
            end
        end
        
        % return band names with specified format
        function name = band_names(self,varargin)
            assert( self.ismultiband, 'This method is for multiband spectra only.' );
            name = ant.util.band2name( self.freq, varargin{:} );
        end
        
        % estimate common timecourse across signals
        function t = common_tc(self,fs)
            t = self.tframe;
            t = vertcat(t{:});
            t = [max(t(:,1)), min(t(:,2))];
            t = transpose(t(1):1/fs:t(2));
        end
        
        % resample property on common timecourse across signals:
        %
        %   psd
        %   amplitude
        %   magnitude
        %   phase
        %   ifreq
        %   phase_offset
        %   synchrony
        %
        function [p,t,f] = property(self,name,fs,red)
            
            if nargin < 4, red = @(x) x; end
            name = lower(name);
            
            % output timepoints
            t = self.common_tc(fs);
            f = self.freq;
            
            % iterate on each signal to interpolate the PSD
            n = self.nf;
            p = cell(1,n);
            for k = 1:n
                [sp,st] = feval( name, self.sig{k} );
                p{k} = ant.ts.resample( red(sp), st, t );
            end
            
        end
        
        % efficiently average property across signals
        function [p,t,c] = xfpropavg(self,name,fs) 
            
            [q,t] = self.property(name,fs);
            
            % don't concatenate it in 3D (not memory efficient)
            n = numel(q);
            p = q{1}/n; % time x signal
            c = 1:size(p,2);
            
            for k = 2:n
                p = p + q{k}/n;
            end
            
        end
        function [p,t,f] = xcpropavg(self,name,fs)
            [p,t,f] = self.property( name, fs, @(x) mean(x,2) );
            p = horzcat(p{:});
        end
        
        % efficiently average magnitude/phase across signals
        function [m,p,t] = xfsigavg(self,fs)
            
            n = self.nf;
            t = self.common_tc(fs);
            fun = @(x) ant.ts.resample( x.vals, x.time, t )/n;
            
            s = fun( self.sig{1} );
            for k = 2:n
                s = s + fun( self.sig{k} );
            end
            
            m = abs(s);
            p = angle(s);
            
        end
        
        % PSD statistics on an adaptive sliding window
        function stat = psdstat( self, varargin )
            
            n = self.nf;
            stat = cell(1,n);
            
            for k = 1:n
                
                % average PSD within each window
                [p,~,w] = self.sig{k}.adaptive_psd( @(x) mean(x,1), varargin{:} );
                
                % PSD stats across windows for each channel
                p = ant.stat.summary( p, 1 );
                p.swin = w;
                p.freq = self.sig{k}.freq;
                stat{k} = p;
                
            end
            
            % convert to struct-array
            stat = [stat{:}];
            
        end
        
    end
    
    %------------------
    % PLOTTING
    %------------------
    methods
        
        % cross-channel property plot
        function [t,f,p] = xcplot(self,name,fs,varargin)
            
            % average property across channels for each frequency
            [p,t,f] = self.xcpropavg(name,fs);
            
            % line-plot for multiband, image for wavelet analysis
            if self.ismultiband
                bname = ant.util.band2name(f);
                plot( t, p );
                xlabel('Time (sec)'); ylabel(name); legend(bname{:}); 
            else
                ant.img.show( {t,f,p}, 'xlabel', 'Time (sec)', 'ylabel', 'Frequency (Hz)', ...
                    'clabel', name, varargin{:} );
            end
            
        end
        function xcdist(self,varargin)
            assert( nargin==3, 'Expected {name,fs} or {p,f}.' );
            if ischar(varargin{1})
                [p,~,f] = self.xcpropavg( varargin{:} );
            else
                p = varargin{1};
                f = varargin{2};
            end
            if self.ismultiband
                bname = ant.util.band2name(f);
                dk.ui.violin(p,'label',bname); 
                %xlabel('Frequency Band (Hz)'); 
            else
                dk.ui.violin(p,'label',f); 
                xlabel('Frequency (Hz)'); axis tight;
            end
        end
        
        % cross-frequency property plot
        function [t,c,p] = xfplot(self,name,fs,varargin)
            
            % if used with positive properties, set 'positive', true
            [p,t,c] = self.xfpropavg(name,fs);
            ant.img.show( {t,c,p}, 'xlabel', 'Time (sec)', 'ylabel', 'Channel', ...
                'clabel', name, varargin{:} );
            
        end
        function xfdist(self,varargin)
            assert( nargin==3, 'Expected {name,fs} or {p,c}.' );
            if ischar(varargin{1})
                [p,~,c] = self.xfpropavg( varargin{:} );
            else
                p = varargin{1};
                c = varargin{2};
            end
            dk.ui.violin(p,'label',c); 
            xlabel('Channel'); axis tight;
        end
        
    end
    
end

