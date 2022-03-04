classdef Signal < handle
%
% Abstract base class for time-series like objects.
%

    properties (Abstract)
        time;
        vals;
    end
    
    properties (Transient,Dependent)
        n_times, n_signals; % long names
        tspan, tframe;
    end
    
    properties (Transient,Dependent,Hidden)
        nt, ns;
    end
    
    methods (Abstract)
        
        ts = mask_k(~,tidx);
        ts = mask_s(~,sidx);
        
    end
    
    %-----------------
    % Shape properties
    %-----------------
    methods
        
        function y = is_empty(self), y = self.nt == 0; end
        function y = is_real(self), y = isreal(self.vals); end
        function y = is_complex(self), y = ~self.is_real(); end
        function y = is_forward(self), y = self.time(end) > self.time(1); end
        function y = is_backward(self), y = ~self.is_forward(); end
        
        % Dimensions
        function n = get.nt(self), n = size(self.time,1); end % num of timesteps
        function n = get.ns(self), n = size(self.vals,2); end % num of signals
        
        function n = get.n_times  (self), n = self.nt; end
        function n = get.n_signals(self), n = self.ns; end
        
        function Dt = get.tspan(self), Dt = abs(self.time(end) - self.time(1)); end
        function Dt = get.tframe(self), Dt = [self.time(1), self.time(end)]; end
        
    end
    
    
    %--------------------
    % Sampling properties
    %--------------------
    methods
        
        % Analytic if all timesteps are greater than epsilon
        function [yes,dif] = is_analytic(self)
            dif = diff(self.time);
            dif = sign(dif(1)) * dif;
            yes = all( dif > eps );
        end
        
        % Arithmetic if all timesteps are almost equal
        function [yes,dt] = is_arithmetic(self,rtol)
            if nargin < 2, rtol = 1e-6; end
            [yes,dt] = ant.priv.is_arithmetic(self.time,rtol);
        end
        
        % Sampling rate
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
        
        % Number of timesteps corresponding to time-length
        function n = numsteps(self,tlen,check)
            if nargin < 3, check=false; end
            n = round( tlen / self.dt(check) );
        end
        
        % Adapt input dt to fit an integer number of steps in current time-interval
        % Output dt is smaller or equal to input dt
        function [dt,nsteps] = closest_dt(self,dt)
            nsteps = ceil( self.tspan ./ dt );
            dt = self.tspan ./ max(1,nsteps - 1);
        end
        
        function [fs,nsteps] = closest_fs(self,fs)
            [dt,nsteps] = self.closest_dt(1./fs);
            fs = 1./dt;
        end
        
    end
    
    
    %--------------------- 
    % Time/channel masking
    %---------------------
    methods (Hidden)
        
        % convert indices to logical masks
        function m = tidx2mask(self,m)
            if isnumeric(m)
                k = m;
                m = false(self.nt,1);
                m(k) = true;
            end
        end
        function m = tidx2mask_inv(self,k)
            if islogical(k)
                m = ~k;
            else
                m = true(self.nt,1);
                m(k) = false;
            end
        end
        
        function m = sidx2mask(self,m)
            if isnumeric(m)
                k = m;
                m = false(1,self.ns);
                m(k) = true;
            end
        end
        function m = sidx2mask_inv(self,k)
            if islogical(k)
                m = ~k;
            else
                m = true(1,self.ns);
                m(k) = false;
            end
        end
        
        % logical time masks
        function m = tmask_lt(self,cut,rel)
            if nargin < 3, rel=false; end
            if rel, cut = self.time(1) + cut; end
            assert( cut>=self.time(1) && cut<=self.time(end), 'Timepoint out of frame.' );
            m = self.time < cut; 
        end
        function m = tmask_gt(self,cut,rel)
            if nargin < 3, rel=false; end
            if rel, cut = self.time(1) + cut; end
            assert( cut>=self.time(1) && cut<=self.time(end), 'Timepoint out of frame.' );
            m = self.time > cut; 
        end
        
        function m = tmask_leq(self,varargin), m = ~self.tmask_gt(varargin{:}); end
        function m = tmask_geq(self,varargin), m = ~self.tmask_lt(varargin{:}); end
        
    end
    methods
        
        % Relying on abstract methods
        function ts = xmask_k(self,tidx)
            m = self.tidx2mask_inv(tidx);
            if nargout == 0
                self.mask_k(m);
            else
                ts = self.mask_k(m);
            end
        end
        
        function ts = xmask_s(self,sidx)
            m = self.sidx2mask_inv(sidx);
            if nargout == 0
                self.mask_s(m);
            else
                ts = self.mask_s(m);
            end
        end
        
        function ts = mask_t(self,tstart,tend)
            m = self.tmask_geq(tstart) & self.tmask_leq(tend);
            if nargout == 0
                self.mask_k(m);
            else
                ts = self.mask_k(m);
            end
        end
        
        function ts = xmask_t(self,tstart,tend)
            m = self.tmask_lt(tstart) | self.tmask_gt(tend);
            if nargout == 0
                self.mask_k(m);
            else
                ts = self.mask_k(m);
            end
        end
        
        % Remove the k first/last samples
        function ts = pop_front(self,k)
            if nargout == 0
                self.xmask_k(1:k);
            else
                ts = self.xmask_k(1:k);
            end
        end
        function ts = pop_back(self,k)
            k = self.nt-k;
            if nargout == 0
                self.mask_k(1:k);
            else
                ts = self.mask_k(1:k);
            end
        end
        function ts = from_k(self,k)
            if nargout == 0
                self.mask_k(k:self.nt);
            else
                ts = self.mask_k(k:self.nt);
            end
        end
        function ts = until_k(self,k)
            if nargout == 0
                self.mask_k(1:k);
            else
                ts = self.mask_k(1:k);
            end
        end
        function ts = between_k(self,kfirst,klast)
            if nargout == 0
                self.mask_k(kfirst:klast);
            else
                ts = self.mask_k(kfirst:klast);
            end
        end
        
        % Remove timepoints after/before a certain time
        function ts = from(self,tval,rel)
            if nargin < 3, rel=false; end
            m = self.tmask_geq(tval,rel);
            if nargout == 0
                self.mask_k(m);
            else
                ts = self.mask_k(m);
            end
        end
        function ts = after(self,tval,rel)
            if nargin < 3, rel=false; end
            m = self.tmask_gt(tval,rel);
            if nargout == 0
                self.mask_k(m);
            else
                ts = self.mask_k(m);
            end
        end
        function ts = before(self,tval,rel)
            if nargin < 3, rel=false; end
            m = self.tmask_lt(tval,rel);
            if nargout == 0
                self.mask_k(m);
            else
                ts = self.mask_k(m);
            end
        end
        function ts = until(self,tval,rel)
            if nargin < 3, rel=false; end
            m = self.tmask_leq(tval,rel);
            if nargout == 0
                self.mask_k(m);
            else
                ts = self.mask_k(m);
            end
        end
        function ts = between(self,tstart,tend)
            if nargout == 0
                self.mask_t(tstart,tend);
            else
                ts = self.mask_t(tstart,tend);
            end
        end
        
        % for added convenience
        function ts = window(self,tstart,tlen,rel)
            if nargin < 4, rel=false; end
            if rel, tstart = self.time(1) + tstart; end
            tend = tstart + tlen;
            if nargout == 0
                self.between( tstart, tend );
            else
                ts = self.between( tstart, tend );
            end
        end
        function ts = burn(self,tlen)
            if nargout == 0
                self.from(tlen,true);
            else
                ts = self.from(tlen,true);
            end
        end
        
        % Aliases for signal selection
        function ts = select(self,k)
            if nargout == 0
                self.mask_s(k);
            else
                ts = self.mask_s(k);
            end
        end
        function ts = exclude(self,k)
            if nargout == 0
                self.xmask_s(k);
            else
                ts = self.xmask_s(k);
            end
        end
        
        % pop_front             pop_front
        % pop_back              pop_back
        % rem_before            after
        % rem_after             before
        % select_signals        select
        % select_times          mask_k
        % remove_signals        exclude
        % remove_times          xmask_k
        % window                between_k
        % time_window           between
        % burn                  burn
        
    end
    
end