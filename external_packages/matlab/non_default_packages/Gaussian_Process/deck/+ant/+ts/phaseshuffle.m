function vals = phaseshuffle( vals )
%
% vals = ant.ts.phaseshuffle( vals )
%
% Shuffle the Fourier phase of input signals.
%
% JH

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
        shuf_coef = angle(orig_coef);
        
        for i = 1:ns
            shuf_coef(:,i) = abs(orig_coef(:,i)) .* exp( 1i * shuf_coef(randperm(n_unique_freq),i) );
        end
        
        % apply the duplication properly
        fourier(random_idx== 1,:) = shuf_coef;
        fourier(random_idx==-1,:) = conj(flipud(shuf_coef));
        
    else
        
        % randomise all apart from DC
        random_idx = [false;true(nt-1,1)];
        coef_phase = angle(fourier(random_idx,:));
        for i = 1:ns
            fourier(random_idx,i) = abs(fourier(random_idx,i)) .* exp( 1i * coef_phase(randperm(nt-1),i) );
        end
        
    end
    
    % come back to time-domain
    vals = ifft(fourier);

end
