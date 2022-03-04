function tf = hilbert( ts, band, npts, force )
%
% tf = ant.dsp.hilbert( ts, band, npts, force=false )
%
% Time-frequency spectrum using Hilbert transform (analytic signal) in each input frequency band.
%
%
% INPUTS
% ------
%
%   band  Cell of 1x2 band-filters (see ant.dsp.do.filter).
%         These are used to filter the input time-series, in order to obtain narrow-band 
%         analytic signals. 
%   
%   npts  Number of sample point per oscillation, used to determine the output sampling rate.
%         DEFAULT: 0 (no resampling)
%
%  force  Force sampling rate manually. 
%         npts is re-interpreted as a sampling rate in Hz.
%         Can be scalar (applied to all bands), or vector (one per band).
%         DEFAULT: false (adaptive sampling)
%
%
% OUTPUT
% ------
%
% The output type depends on the number of bands in input:
%   - for a single-band input, the ouput is of type ant.dsp.TFSeries
%   - for a multi-band input, the output is of type ant.dsp.TFSpectrum
%
%
% See also: ant.dsp.TFSeries, ant.ts.ansig, ant.priv.ansig_downsample
%
% JH

    tfs = ts.fs(true);

    % process input frequency bands
    is_band_filter = @(x) isnumeric(x) && numel(x)==2 && diff(x)>eps && all(x > 0);
    
    band = dk.wrap(band);
    assert( all(cellfun( is_band_filter, band )), 'Invalid band filter in input.' );
    nb = numel(band);
    
    % process sampling inputs
    if nargin < 4, force=false; end
    if nargin < 3, npts=0; end
    
    if force
        fs = npts;
        assert( isnumeric(fs) && all(fs > 0), 'Bad sampling frequency.' );
        if isscalar(fs), fs = fs*ones(1,nb); end
        assert( numel(fs) == nb, 'There should be one sampling rate per band.' );
    else
        assert( npts==0 || npts >= 2, 'Number of points per oscillation should be >=2.' );
        
        % adaptive sampling rates
        fs = cellfun(@max, band);
        assert( all(2*fs <= tfs), 'Input sampling rate is too low for requested bands.' );
        fs = min( tfs, npts*fs );
    end
    
    % compute analytic signal in each band
    tf = cell(1,nb);
    for i = 1:nb
        [time,vals] = do_transform( ts, band{i}, fs(i) );
        % power should be normalised by the width of the band in which it is computed
        tf{i} = ant.dsp.TFSeries( time, vals, band{i}, diff(band{i}) ); 
    end
    
    % unwrap singletons
    if nb == 1
        tf = tf{1}; 
    else
        tf = ant.dsp.TFSpectrum(tf);
    end 
    
end

function [time,vals] = do_transform( ts, prefilt, fs )

    % filter pre-processed time-courses
    ts = ant.dsp.do.filter( ts, prefilt );
    
    % analytic signal
    time = ts.time;
    [vals,phi] = ant.ts.ansig( ts.vals );
    
    % downsample (complex values)
    if fs > 0
        [time,vals,phi] = ant.priv.ansig_downsample( time, vals, phi, fs );
    end
    vals = vals .* exp(1i*phi);
    
end
