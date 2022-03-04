function [imfs,status] = emd( data, varargin )
%
% [imfs,status] = ant.ts.emd( data, varargin )
%
% Empirical mode decomposition (Hilbert-Huang transform).
% data should be a scalar-valued time-course (vectorised internally).
%
% OPTIONS
%
%    sd_thresh  Stop decomposition if std goes below this threshold.
%      max_imf  Maximum number of IMFs
%   min_energy  Stop decomposition if energy goes below this threshold.
%
% JH

    % parse options
    opt = dk.obj.kwArgs(varargin{:});
    
        opt_sd_thresh  = opt.get( 'sd_thresh', 0.25 );
        opt_max_imf    = opt.get( 'max_imf', 50 );
        opt_min_energy = opt.get( 'min_energy', 1e-6 );
    
    % allocate memory
    data = data(:);
    imfs = cell(1,opt_max_imf);
    iter = 0;
    
    % iterative mode extraction
    while true
        
        % initialisation
        iter = iter+1;
        sd   = inf;
        h1   = data;
        
        % iterative sifting
        while (sd > opt_sd_thresh) || ~is_imf(h1)
            
            h2 = do_sift(h1);
            sd = sum( (h1-h2).^2 ) / sum(h1.^2);
            h1 = h2;
            
        end
        imfs{iter} = h1;
        
        % iteration check
        if iter == opt_max_imf
            status.msg = 'Reached the maximum number of iterations.';
            break;
        end
        
        % energy check
        data = data - h1;
        if sum(data.^2) <= opt_min_energy
            status.msg = 'Residual energy is below threshold.';
            break;
        end
        
    end
    
    % sort imfs
    imfs = fliplr(horzcat( imfs{1:iter} ));
    
    % status
    status.n_iter = iter;
    
end

function [lmin,lmax] = local_extrema_old( x )

    dx = diff(x,1,1); % x(t+1)-x(t)
    zc = [dx(1:end-1) .* dx(2:end) <= 0; 1]; % zero-crossings (add 1 to include last point)
    le = [ -dx(1); zc .* dx ]; % derivative at crossing (add -dx(1) to include first point)
    
    lmin = find( le < 0 );
    lmax = find( le > 0 );

end

function [lmin,lmax] = local_extrema_sym(x)

    dx = diff([ x(2); x; x(end-1) ],1,1); % symmetric replication
    zc = dx(1:end-1) .* dx(2:end) <= 0; % zero-crossing
    le = zc .* dx(1:end-1); % backward-derivative at zero-crossing
    
    lmin = find( le < 0 );
    lmax = find( le > 0 );

end

function [lmin,lmax] = local_extrema(x)

    % exclude first and last point
    dx = diff(x,1,1);
    zc = dx(1:end-1) .* dx(2:end) <= 0; % zero-crossing
    le = zc .* dx(1:end-1); % backward-derivative at zero-crossing
    
    lmin = 1+find( le < 0 );
    lmax = 1+find( le > 0 );

end

function yes = is_imf( h )
    
    % find local extrema
    [lmin,lmax] = local_extrema(h);
    
    nle = length(lmin) + length(lmax); % # of local extrema
    nzc = sum( h(1:end-1) .* h(2:end) < 0 ); % # of zero-crossings
    yes = nle <= 3 || abs( nzc - nle ) <= 2;
    
end

function h = do_sift( x )

    n = numel(x);
    t = transpose(1:n);

    % local extrema
    [lmin,lmax] = local_extrema(x);
    
    % we need at least 4 points (2 min, 2 max) to interpolate
    if length(lmin) + length(lmax) <= 3
        h = x;
        return;
    end
    
    % add first and last point manually for "stable" interpolation
    lmin = [1; lmin; n];
    lmax = [1; lmax; n];
    
    % min and max envelopes (cubic interpolation)
    emin = interp1( lmin, x(lmin), t, 'pchip' );
    emax = interp1( lmax, x(lmax), t, 'pchip' );
    
    % do the sift
    h = x - (emin + emax)/2;
    
end
