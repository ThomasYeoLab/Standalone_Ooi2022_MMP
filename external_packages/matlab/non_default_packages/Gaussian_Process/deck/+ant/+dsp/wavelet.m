function tf = wavelet( ts, freq, npts, force )
%
% tf = ant.dsp.wavelet( ts, freq, npts, force=false )
%
% Compute the time-frequency wavelet spectrum for each signal using Morlet continuous wavelets.
%
%
% INPUTS
% ------
%
%   freq  Frequencies at which spectral decomposition should be performed
%         
%
%   npts  Number of points per oscillation (default: 0, no resampling)
%
%  force  Force sampling rates by reinterpreting npts (default: false)
%
%
% OUTPUT
% ------
%
% The output type depends on the number of frqeuencies in input:
%   - if freq is scalar, the ouput is of type ant.dsp.TFSeries
%   - if freq is a vector, the output is of type ant.dsp.TFSpectrum
%
%
% NOTES
% -----
%
%   To compute the PSD timecourse estimates from the outputs, do:
%       psd = coef .* conj(coef) / pnorm
%
%
% See also: ant.dsp.TFSeries
%
% JH

    tfs = ts.fs(true);
    
    % process input frequencies
    assert( all(freq > 0), 'Input frequencies should be positive.' );
    assert( all(2*freq <= tfs), 'Input sampling rate is too low for requested frequencies.' );
    nf = numel(freq);
    
    % process sampling inputs
    if nargin < 4, force=false; end
    if nargin < 3, npts=0; end
    
    if force
        fs = npts;
        assert( isnumeric(fs) && all(fs > 0), 'Bad sampling frequency.' );
        if isscalar(fs), fs = fs*ones(1,nf); end
        assert( numel(fs) == nf, 'There should be one sampling rate per frequency.' );
    else
        % adaptive sampling rates
        assert( npts==0 || npts >= 2, 'Number of points per oscillation should be >=2.' );
        fs = min( tfs, npts*freq );
    end
    
    % prepare
    nt = ts.nt;
    df = tfs / nt; % frequency step
    w0 = 6;
    
    scale = w0 ./ (2*pi*freq); % wavelet scales
    omega = 1:fix(nt/2);
    omega = 2*pi*df * [0,omega,-omega( fix((nt-1)/2):-1:1 )]; % wavenumbers
    
    scale = dk.torow(scale);
    omega = dk.tocol(omega);
    
    % Fourier transform of Morlet wavelet 
    dw = 2*pi*df; % wave step
    nw = numel(omega);
    
    mwft = (omega > 0) * sqrt( dw*nw*scale/sqrt(pi) );
    mwft = mwft .* exp(-(omega * scale - w0).^2 /2);
    
    % compute output
    FT = fft(dk.bsx.sub( ts.vals, ts.mean ));
    tf = cell(1,nf);
    
    for i = 1:nf
        coef = ifft(dk.bsx.mul( FT, mwft(:,i) ));
        tf{i} = ant.dsp.TFSeries( ts.time, coef(1:nt,:), freq(i), tfs );
        if fs(i) > 0
            tf{i}.resample(fs(i));
        end
    end
    
    % unwrap singletons
    if nf == 1
        tf = tf{1};
    else
        tf = ant.dsp.TFSpectrum(tf);
    end
    
end
