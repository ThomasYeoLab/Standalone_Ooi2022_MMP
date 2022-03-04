function [out,scale] = morlet( vals, fs, freq )
%
% [out,scale] = ant.ts.morlet( vals, fs, freq )
%
% Fast continuous wavelet transform capable of computing several signals at once.
% Unless there is only one query frequency, the output is a cell array where each cell corresponds to a frequency.
%
% INPUT:
%
%   vals  Ntimes x Nsignals matrix of signals in column
%     fs  Input sampling frequency
%   freq  Query frequencies at which the Wavelet transform should be computed
%
% JH
    
    assert( ismatrix(vals) && isreal(vals), 'Expected real Ntimes x Nsignals matrix in input.' );

    % dimensions
    [nt,ns] = size(vals);

    % Fourier transform
    FT = fft(dk.bsx.sub( vals, mean(vals,1) ));
    
    % frequencies and scales
    df = fs / nt; % frequency step
    nf = numel(freq);
    w0 = 6;
    
    scale = w0 ./ (2*pi*freq(:))'; % wavelet scales (row)
    omega = 1:fix(nt/2);
    omega = 2*pi*df * [0,omega,-omega( fix((nt-1)/2):-1:1 )]'; % wavenumbers (column)
    
    % Fourier transform of Morlet wavelet
    dw = 2*pi*df; % wave step
    nw = numel(omega);
    
    mwft = (omega > 0) * sqrt( dw*nw*scale/sqrt(pi) );
    mwft = mwft .* exp(-(omega * scale - w0).^2 /2);

    % output
    out = cell( 1, nf );
    
    for i = 1:nf
        out{i} = ifft(dk.bsx.mul( FT, mwft(:,i) ));
        out{i} = out{i}(1:nt,:);
    end
    
    if nf == 1
        out = out{1};
    end
    
end
