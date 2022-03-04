classdef MVAR < handle
%
% Fit MVAR models, and generate data from them.
%

    properties
        order
        intercept
        coefmat
        noise
        fsamp
    end

    methods

        function self = MVAR(varargin)
            self.clear();
            if nargin > 0
                self.fit(varargin{:});
            end
        end

        function clear(self)
            self.order = 0;
            self.intercept = [];
            self.coefmat = [];
            self.noise = [];
            self.fsamp = 0;
        end

        function [self,ts] = fit(self,ts,pmin,pmax,fac)
            if nargin < 4, pmax=pmin; end
            if nargin < 5, fac=20; end

            [ts,m,fs] = ant.priv.mvar_prep(ts,0.99,fac);
            [w,A,C] = ant.priv.mvar_fit( ts.vals, pmin, pmax, 'zero' );
            
            self.order = size(A,2)/size(A,1);
            self.intercept = w + m(:);
            self.coefmat = A;
            self.noise = C;
            self.fsamp = fs;
        end

        function ts = gen(self,tlen,fs)
            if nargin < 3, fs = self.fsamp; end
            
            t = 0 : (1/fs) : tlen;
            v = ant.priv.mvar_sim( self.intercept, self.coefmat, self.noise, numel(t) );
            ts = ant.TimeSeries( t, v );
        end

    end
    
end
