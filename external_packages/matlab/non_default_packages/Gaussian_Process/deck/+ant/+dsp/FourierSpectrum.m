classdef FourierSpectrum < ant.priv.Spectrum
%
% Compute power spectral density using various methods (Fourier, Welch, Multi-taper).
% This class is used mainly for display.
%
%
% USAGE
% -----
%
%   ant.dsp.FourierSpectrum( ts, method, options... ).plot( ... )
%
% where
%   methods: fourier, welch, multitaper
%   options: 
%          fourier: no options
%            welch: window-length (tspan/4), overlap (0.5)
%       multitaper: n-windows (4)
%
%
% See also: pwelch, pmtm, ant.ts.fourier, ant.dsp.FourierTransform
%
% JH

    properties (SetAccess = private)
        ts;
        frq;
        psd;
    end

    properties (Transient,Dependent)
        nf, ns, df;
    end

    methods

        function self = FourierSpectrum(varargin)
            self.clear();
            if nargin > 0
                self.assign(varargin{:});
            end
        end

        function clear(self)
            self.ts  = ant.TimeSeries();
            self.frq = [];
            self.psd = [];
        end

        function self = copy(self,other)
            self.ts  = other.ts;
            self.frq = other.frq;
            self.psd = other.psd;
        end

        function sp = clone(self)
            sp = ant.dsp.FourierSpectrum().copy(self);
        end

        
        % Dependent properties
        function n = get.nf(self), n = numel(self.frq); end % num of frequencies (single-sided)
        function n = get.ns(self), n = size(self.psd,2); end % num of signals
        function f = get.df(self), f = self.frq(2)-self.frq(1); end % frequency step

        
        % Assign from time-series
        function assign(self,ts,method,varargin)

            if nargin < 3 || isempty(method)
                method = 'fourier';
            end
            if iscell(method)
                method   = method{1};
                varargin = method(2:end);
            end

            if ~ts.is_arithmetic()
                warning('Input time-series is not uniformly sampled, resampling before transform.');
                ts = ts.make_arithmetic();
            end

            switch lower(method)

                case 'fourier'
                    self.spectrum_fourier(ts,varargin{:});

                case {'welch','pwelch'}
                    self.spectrum_welch(ts,varargin{:});

                case {'multitaper','pmtm'}
                    self.spectrum_multitaper(ts,varargin{:});

                otherwise
                    error('Unknown estimation method "%s".',method);

            end

        end
        
        
        % Inherited from parent
        function f = proxy_frq(self)
            f = self.frq;
        end

        function p = proxy_nsp(self)
            p = self.psd;
            p = bsxfun( @rdivide, p, sum(p,1) );
        end


        function fig = plot(self,varargin)
        %
        % Plot spectral density as distribution plot across channels (using dk.ui.prctile).
        %
        % OPTIONS:
        %       style  Either: normal, log
        %              DEFAULT: normal
        %
        %     prctile  1x2 array specifying the extend of the fill-area.
        %              DEFAULT: [25,75]/100
        %
        %   power_cut  Trim the x-axis (frequency) when reaching the corresponding cumulative power.
        %              DEFAULT: 0.99
        %
        %        flim  Specify the frequency extents manually (overrides power_cut).
        %              DEFAULT: []
        %
        % JH

            % options parsing
            [opt,fig] = self.parse_plot_options(varargin{:});
            
            % preproc
            lo = round(100*opt.prctile(1));
            hi = round(100*opt.prctile(2));

            % draw the thing
            dk.ui.prctile( self.frq, self.psd, lo, hi );
            xlabel('Frequency (Hz)'); ylabel('PSD'); xlim(opt.flim);
            switch lower(opt.style)

                case 'normal'
                    % nothing todo
                case 'loglog'
                    set( gca, 'xscale', 'log', 'yscale', 'log' );
                    
                case 'log'
                    set( gca, 'yscale', 'log' );

                case 'db'
                    disp('Sorry, not implemented yet.');

            end
            
            % set the title
            Tstr = sprintf( 'Spectral Density (avg mode %.2f Hz)', mean(self.frequency_modes()) );
            switch self.ns
                case 1
                    % add nothing
                case {2,3}
                    Tstr = sprintf( '%s [blue: median]', Tstr );
                otherwise
                    Tstr = sprintf( '%s [blue: median, red: prctile %d/%d%%]', Tstr, lo, hi );
            end
            title( Tstr );

        end
        
        function [fig,out] = plotimg(self,varargin)
        %
        % Instead of showing PSDs as distribution plot, show as an image.
        %
        % JH
        
            [opt,fig] = self.parse_plot_options(varargin{:});
        
            out.x = self.frq;
            out.z = self.psd';
            out.y = 1:size(out.z,1);
            
            ant.img.show( out, 'positive', true, ...
                'xlabel', 'Frequency (Hz)', 'ylabel', 'Signal', 'clabel', 'PSD' );
            xlim( opt.flim );
        
        end

    end

    methods (Hidden)

        function spectrum_fourier(self,ts)

            [self.frq,dfc] = ant.ts.fourier( preproc(ts), ts.fs );
            self.psd = abs(dfc).^2 / self.df;

        end

        function spectrum_welch(self,ts,wlen,overlap)

            if nargin < 4, overlap = 0.5; end
            if nargin < 3, wlen = ts.tspan / 4; end

            assert( overlap >= 0 && overlap < 1, 'Bad overlap percentage.' );
            assert( 0 < wlen && wlen < ts.tspan, 'Bad window length.' );

            wsiz = 1+ts.numsteps(wlen); % window size (integer)
            novr = floor(wsiz*overlap); % noverlap
            win  = tukeywin(wsiz); % sliding window

            [self.psd,self.frq] = pwelch( preproc(ts), win, novr, [], info.fs );

        end

        function spectrum_multitaper(self,ts,nw)

            if nargin < 3, nw = 4; end % Matlab's default

            [self.psd,self.frq] = pmtm( preproc(ts), nw, [], ts.fs );

        end
        
        function [out,fig] = parse_plot_options( self, varargin )

            opt = dk.obj.kwArgs(varargin{:});

                opt_style   = opt.get('style','normal');
                opt_parent  = opt.get('parent',nan);
                opt_prctile = opt.get('prctile',[0.25,0.75]);
                opt_pcut    = opt.get('power_cut',0.99);
                opt_flim    = opt.get('flim',[]); % overrides the above power_cut option

            assert( ischar(opt_style) && ismember(lower(opt_style),{'normal','log','db'}), 'Invalid style.' );
            assert( isscalar(opt_parent), 'Invalid parent.' );
            assert( numel(opt_prctile)==2 && all( (opt_prctile>0) & (opt_prctile<1) ), 'Invalid percentiles.' );
            assert( isscalar(opt_pcut) && opt_pcut>0 && opt_pcut <= 1, 'Invalid power cut.' );
            assert( isempty(opt_flim) || numel(opt_flim)==2, 'Bad frequency limits.' );

            % default frequency limits using power cut
            if isempty(opt_flim)
                opt_flim = [0, max(self.power_cut(opt_pcut))];
            end

            % pack options
            out.style = opt_style;
            out.prctile = opt_prctile;
            out.flim = opt_flim;

            % create figure if needed
            if ~ishandle(opt_parent)
                fig = figure('name','Spectral Density Plot');
            else
                fig = gcf; axes(opt_parent);
            end

        end

    end

end

function vals = preproc(ts)
    vals = bsxfun( @minus, ts.vals, ts.mean );
    %vals = detrend( ts.vals );
end
