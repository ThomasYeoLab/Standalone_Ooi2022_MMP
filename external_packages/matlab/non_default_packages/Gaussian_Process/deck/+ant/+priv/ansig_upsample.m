function varargout = ansig_upsample( varargin )
%
% [time,mag,phi] = ant.priv.ansig_upsample( time, mag, phi, fs )
% [time,vals] = ant.priv.ansig_upsample( time, vals, fs )
%
% Upsample the magnitude and phase of any time-resolved spectral signal.
%
% JH

    fun = @ant.ts.upsample;
    switch nargin
        case 3 % complex input
            time = varargin{1};
            fs   = varargin{3};
            assert( ~isreal(varargin{2}), 'Expected a complex-valued time-series.' );
            
            switch ant.priv.meth_resample()
            
                case 'real/imaginary'
                
                [outV,outT] = fun( real(varargin{2}), time, fs );
                outV = outV + 1i*fun( imag(varargin{2}), time, fs );
                varargout = {outT, outV};
            
                case 'modulus/argument'
                
                % resample magnitude/angle
                [mag,outT] = fun( abs(varargin{2}), time, fs );
                phi = angle(varargin{2});
                cp = fun( cos(phi), time, fs );
                sp = fun( sin(phi), time, fs );
                varargout = {outT,mag.*(cp + 1i*sp)};
                
                otherwise
                error( '[bug] Unknown resampling method.' );
            end
            
        case 4
            time = varargin{1};
            fs   = varargin{4};
            
            [mag,outT] = fun( varargin{2}, time, fs );
            cp = fun( cos(varargin{3}), time, fs );
            sp = fun( sin(varargin{3}), time, fs );
            
            varargout = {outT,mag,atan2(sp,cp)};
    end
    
end
