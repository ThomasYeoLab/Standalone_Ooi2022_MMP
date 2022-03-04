function [y, ty] = decimate( x, tx, fs, order )
%
% [y,ty] = ant.ts.decimate( x, tx, fs, order=8 )
%
%   Wrapper for Matlab's decimate function (downsampling only), accepting complex-valued 
%   inputs. We demean/remean the input and use IIR filtering method.
%   Order should be less than 13.
%
%
% See also: decimate
%
% JH

    if nargin < 4, order=8; end % Matlab's default
    
    [x,tx] = dk.formatmv(x,tx,'vertical');
    if isreal(x)
        
        % decimation ratio
        r = (tx(2)-tx(1)) * fs;
    
        assert( isscalar(fs), 'This function does not accept query timepoints.' );
        assert( r > eps, 'Requested sampling frequency is too low.' );
        assert( r <= 1, 'This function is for downsampling only.' );
        assert( order < 13, 'Order should be less than 13.' ); % see documentation

        % do the decimation
        m = mean(x,1);
        x = dk.bsx.sub(x,m);
        
        y = decimate( x, 1/r, order );
        y = dk.bsx.add(y,m);
        
        ny = numel(y);
        ty = tx(1) + (0:ny-1)/fs;
        
    else
        
        switch ant.priv.meth_resample()
            
            case 'real/imaginary'
            
            [y,ty] = ant.ts.decimate( real(x), tx, fs, order );
            y = y + 1i*ant.ts.decimate( imag(x), tx, fs, order );
            
            case 'modulus/argument'
            
            [y,ty] = ant.ts.resample( abs(x), tx, fs, order );

            a = angle(x);
            ca = ant.ts.decimate( cos(a), tx, fs, order );
            sa = ant.ts.decimate( sin(a), tx, fs, order );

            y = y .* ( ca + 1i*sa );
            
            otherwise
            error( '[bug] Unknown resampling method.' );
        end
        
    end
    
end
