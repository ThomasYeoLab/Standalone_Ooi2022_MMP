function [y, ty] = resample( x, tx, fs, method )
%
% [y,ty] = ant.ts.resample( x, tx, fs=[], method=pchip )
%
%   Wrapper for Matlab's resample function, accepting complex-valued inputs.
%   We demean/remean the input and use non-extrapolating method (pchip) by default.
%   Note that if input fs is empty, this method resamples the input at equally spaced points.
%
%
% See also: resample
%
% JH

    if nargin < 4, method = 'pchip'; end
    if nargin < 3, fs = []; end
    
    [x,tx] = dk.formatmv(x,tx,'vertical');
    if isreal(x)

        m = mean(x,1);
        x = dk.bsx.sub(x,m);
        
        if isempty(fs)
            
            % resample at equally-spaced points
            [y,ty] = resample( x, tx, method );
            
        elseif isscalar(fs)
            
            % resample at given sampling rate
            [y,ty] = resample( x, tx, fs, method );
            
        else
            
            % interpret fs as query timepoints
            qt = fs(:); 
            dt = prctile( diff(qt), 10 ); % smaller steps bring the rate up
            [y,ty] = resample( x, tx, 1/dt, method );
            
            % Matlab didn't care about requested timepoints, interpolate manually
            if numel(qt) ~= numel(ty) || any( abs(qt-ty) > eps )
                y  = interp1( ty, y, qt, method );
                ty = qt;
            end
            
        end
        y = dk.bsx.add(y,m);
        
    else
        
        % Note: magnitude/angle is better than real/imaginary resampling
        switch ant.priv.meth_resample()
        
            case 'real/imaginary'
            
            [y,ty] = ant.ts.resample( real(x), tx, fs, method );
            y = y + 1i*ant.ts.resample( imag(x), tx, fs, method );
            
            case 'modulus/argument'
            
            [y,ty] = ant.ts.resample( abs(x), tx, fs, method );

            a = angle(x);
            ca = ant.ts.resample( cos(a), tx, fs, method );
            sa = ant.ts.resample( sin(a), tx, fs, method );

            y = y .* ( ca + 1i*sa );
            
            otherwise
            error( '[bug] Unknown resampling method.' );
        end
        
    end

    % Matlab extrapolates apparently..
    if ty(end) > tx(end)
        m  = ty <= tx(end);
        ty = ty(m);
        y  = y(m,:);
    end
    
end
