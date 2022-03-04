classdef Spectrum < handle
   
    methods (Abstract)
        
        proxy_frq(self); % frequency vector (nf x 1)
        proxy_nsp(self); % normalised spectral power (nf x ns)
        
    end
    
    methods
        
        % frequency masks
        function m = fmask_lt(self,cut), m = self.proxy_frq < cut; end
        function m = fmask_gt(self,cut), m = self.proxy_frq > cut; end

        function m = fmask_leq(self,cut), m = ~self.fmask_gt(cut); end
        function m = fmask_geq(self,cut), m = ~self.fmask_lt(cut); end

        function m = fmask_pass(self,band)
            m = self.fmask_geq(band(1)) & self.fmask_leq(band(2));
        end
        function m = fmask_stop(self,band)
            m = self.fmask_lt(band(1)) | self.fmask_gt(band(2));
        end
        
        % Frequency of largest amplitude for each signal
        function m = frequency_modes(self)
            [~,m] = max( self.proxy_nsp(), [], 1 );
            f = self.proxy_frq();
            m = dk.torow(f(m));
        end

        % First frequency for which the cumulative power exceeds p % (for each signal)
        function c = power_cut(self,p)
            assert( all(p > 0 & p <= 1), 'Percentage should be in (0,1].' );
            
            % Normalised cumulative spectral power
            G = cumsum(self.proxy_nsp(),1);
            G = dk.bsx.rdiv( G, G(end,:) );
            f = self.proxy_frq();
            
            [nf,ns] = size(G);
            np = numel(p);
            
            c = zeros(np,ns);
            for i = 1:ns
            for j = 1:np        
                k = find( G(:,i) >= p(j), 1, 'first' );
                assert( ~isempty(k), '[bug] Could not find normalised power threshold.' );
                c(j,i) = f(k);
            end
            end
            
        end

        % For each channel, find the frequency band corresponding to the cumulative
        % power band [g_lo, g_hi] %  (default: [1, 99] %).
        function [flo,fhi] = power_band( self, glo, ghi )
            
            if nargin < 2, glo = .01; end
            if nargin < 3, ghi = .99; end
            assert( all(dk.is.number(glo,ghi)), 'Inputs should be scalars.' );
            
            fcut = self.power_cut([glo,ghi]);
            flo  = fcut(1,:);
            fhi  = fcut(2,:);
            
        end
        
        % return the minimum lowest frequency and the maximum highest frequency
        % if the difference between the two is less than 1, then we return an 
        % interval of 1Hz centered around lo+hi/2 
        function [lo,hi] = global_power_band(self,varargin)
            
            [lo,hi] = self.power_band(varargin{:});
            lo = min(lo);
            hi = max(hi);
            
            if hi-lo < 1
                avg = (lo+hi)/2;
                lo  = avg - 1/2;
                hi  = avg + 1/2;
            end
            
        end

        % For each channel, return a normalised power score for the given frequency bands.
        % For example, the score of [0,fnyquist] is 1 (for real signals). The score of any 
        % other band is proportional to the amount of power concentrated in this band for 
        % each signal.
        function score = power_score(self,varargin)

            P = self.proxy_nsp();
            nb = nargin-1;
            ns = size(P,2);

            score = zeros(nb,ns);
            sumP = @(m) sum( P(m,:), 1 );

            for i = 1:nb
                [~,b] = ant.priv.filter_parse(varargin{i});
                s     = 0;
                switch numel(b)
                    case 1
                        if b < 0
                            s = sumP(self.fmask_lt(-b));
                        else
                            s = sumP(self.fmask_geq(b));
                        end
                    case 2
                        if any( b < 0 )
                            s = sumP(self.fmask_stop(-b));
                        else
                            s = sumP(self.fmask_pass( b));
                        end
                end
                score(i,:) = s;
            end

        end

        % EEG "power-bands".
        % For each channel, the outputs give the ratio of power concentrated in
        % the delta, theta, alpha, beta and gamma band respectively.
        % Note that the ratios sum to 1 for each channel, but the average of the
        % ratios across channels may not sum to 1.
        function [d,t,a,b,g] = eeg_power_scores(self)

            scores = self.power_score( 'delta', 'theta', 'alpha', 'beta', 'gamma' );

            d = scores(1,:); % delta
            t = scores(2,:); % theta
            a = scores(3,:); % alpha
            b = scores(4,:); % beta
            g = scores(5,:); % gamma

        end
        
    end
    
end
