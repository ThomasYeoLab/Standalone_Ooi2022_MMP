function [frq,dfc] = fourier( vals, fs, npts )
%
% Computes the Fast Fourier Transform of a given time-series.
% For real inputs, the positive spectrum is returned with correctly scaled amplitude/power.
% For complex inputs, the full spectrum centered around frequency 0 is returned.
% 
% [freq,amp,phi] = ant.ts.fourier( vals, fs [,npts] )
%
% Inputs:
%
%   vals  - NxM matrix of real- or complex-valued observations (1 observation = 1 row) at regular timepoints.
%   fs    - Sampling frequency (positive scalar).
%   npts  - (optional) number of points used for the transform, default is the number of timepoints.
%
% Outputs:
%
%   frq   - column vector of frequencies in Hz
%   dfc   - corresponding discrete Fourier coefficients (complex)
%
% Note:
%   The energy corresponds to the squared magnitude of the coefficients.
%   The power spectral density corresponds to the energy divided by df (= frq(2)-frq(1)).
%   The phase corresponds to the argument of the coefficients.
%
% References:
%   https://en.wikipedia.org/wiki/Discrete_Fourier_transform
%
% JH

    assert( ismatrix(vals), 'Input values should be a matrix.' );
    
    % assume a unitary frequency if it is omitted
    if nargin < 2, fs = 1; end
    
    % if fixed-size transform is not required, take the number of time-points by default
    if nargin < 3, npts = size(vals,1); end
    
    assert( isscalar(fs) && fs > eps, 'Sampling frequency should be a positive scalar.' );
    assert( isscalar(npts), 'Transform size should be scalar.' );
    assert( npts >= size(vals,1), 'Transform size should be greater than the number of timepoints.' );
    
    % sampling information
    df = fs/npts;
    nf = floor( npts/2 + 1 ); % number of frequencies >= 0

    % Discrete Fourier Coefficients (complex)
    dfc = fft(vals,npts) / npts;

    % real input: return one-sided spectra
    if isreal(vals)
        
        % correct magnitudes to account for discarding negative frequencies
        dfc = sqrt(2)*dfc( 1:nf, : );
        frq = (0:nf-1)*df;

        % .. except for the DC component
        dfc(1,:) = dfc(1,:)/sqrt(2);
        
        % .. and for the Nyquist frequency (only if nt is even)
        if mod(npts,2) == 0
            dfc(end,:) = dfc(end,:)/sqrt(2); 
        end

    % complex input: return full spectra with neg and pos frequencies centered around 0
    else

        % shift the spectrum to center frequencies around 0
        dfc = ant.ts.fftshift( dfc );
        frq = ( floor(1-npts/2):(npts/2) )*df;

    end

    % make sure frq is a column vector
    frq = frq(:);

end
