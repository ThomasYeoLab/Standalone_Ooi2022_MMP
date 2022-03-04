function [p,t,f] = spectrogram( ts, freq, fs, sigma, varargin )
%
% [psd,time,freq] = ant.ui.spectrogram( ts, freq, fs=100, sigma=[], varargin )
% 
% Compute the CWT of input signals at frequencies freq, then resample the average (cross-chanel) 
% spectral signals at each frequency to a common sampling rate, and optionally smooth the result
% with a Gaussian filter for improved display.
% 
% Additional inputs are forwarded to ant.img.show
% NOTE: this function does NOT open a new window by default (ie it draws in gcf)
%
% JH

    if nargin < 4 || isempty(sigma), sigma=0; end
    if nargin < 3 || isempty(fs), fs=100; end

    % compute average PSD across channels for each frequency
    tf = ant.dsp.wavelet( ts, freq );
    [p,t,f] = tf.property( 'psd', fs, @(x) mean(x,2) );
    
    % concatenate and smooth PSD
    p = horzcat( p{:} );
    if sigma > 0
        p = imgaussfilt( p, sigma );
    end
    
    % display
    ant.img.show( {t,f,p}, 'xlabel','Time (sec)', 'ylabel','Frequency (Hz)', 'clabel','PSD', varargin{:} );

end
