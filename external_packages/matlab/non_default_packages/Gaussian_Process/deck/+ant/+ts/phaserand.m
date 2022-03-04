function vals = phaserand( vals )
%
% vals = ant.ts.phaserand( vals )
%
% Create a random signal with the same Fourier spectrum as the input by phase randomisation.
%
% JH based on code by RA

    % input should be Ntimes x Nsignals
    [nt,ns] = size(vals);
    
    % go to Fourier domain
    fourier = fft(vals);
    
    if isreal(vals)
        
        % there are paired frequencies, so make sure phase randomisation is done properly
        n_unique_freq = floor( (nt-1)/2 );
        if mod(nt,2) == 1  % if there are an odd number of points, no nyquist
            random_idx = [0;ones(n_unique_freq,1);-ones(n_unique_freq,1)];
        else
            random_idx = [0;ones(n_unique_freq,1);0;-ones(n_unique_freq,1)];
        end
        
        % randomise unique coefficients
        orig_coef = fourier(random_idx == 1,:);
        rand_coef = orig_coef .* exp( 1i * 2*pi*rand(n_unique_freq,ns) );
        
        % apply the duplication properly
        fourier(random_idx== 1,:) = rand_coef;
        fourier(random_idx==-1,:) = conj(flipud(rand_coef));
        
    else
        
        % randomise all apart from DC
        random_idx = [false;true(nt-1,1)];
        fourier(random_idx,:) = fourier(random_idx,:) .* exp( 1i * 2*pi*rand(nt-1,ns) );
        
    end
    
    % come back to time-domain
    vals = ifft(fourier);

end
