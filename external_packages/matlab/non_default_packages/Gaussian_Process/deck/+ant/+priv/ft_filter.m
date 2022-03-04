function vals = ft_filter( vals, hfilt, order, instability_fix )
%
% Adapted from FieldTrip.
%
% Inputs:
%   vals - Ntimes x Nchan data matrix
%   hfilt - function handle returning the pair of coef [b,a] given a filter order
%   order - the desired order for the filter to apply
%   instability_fix - strategy identifier to deal with unstable filters (none, reduce or split)
%
% JH

    if nargin < 4, instability_fix = 'none'; end

    % remember input type
    input_class = class(vals);
    vals        = double(vals);
    
    % use a zero-lag two-pass filtering strategy
    filt_func = @filtfilt;

    % wrap the coefficients function so it returns a structure
    function f = get_filt(ord)
        assert( ord >= 2, '[ant.priv.ft_filter] Order is too low.' ); 
        [b,a] = hfilt(ord);
        
        f.o = ord;
        f.a = double(a);
        f.b = double(b);
    end
    
    % apply filtering and adapt in case of numerical instability
    f = get_filt(order);
    switch lower(instability_fix)
        
        % throw an error
        case {'none','default'}
            assert( ant.priv.filter_check_stability(f.a), '[ant.priv.ft_filter] Filter is unstable.' );
            vals = filt_func( f.b, f.a, vals );
        
        % reduce the order of the filter
        case 'reduce'
            while ~ant.priv.filter_check_stability(f.a)
                order = order-1;
                f = get_filt(order);
            end
            vals = filt_func( f.b, f.a, vals );
            
        % devise an equivalent multi-stage filtering scheme
        case 'split'
            f  = ant.priv.filter_split( get_filt, order );
            nf = numel(f);
            
            for i = 1:nf
                fi   = f(i);
                vals = filt_func( fi.b, fi.a, vals );
            end
            
        otherwise
            error('[ant.priv.ft_filter] Unknown instability fix identifier "%s".', instability_fix);
    end
    
    % restore input type
    vals = cast( vals, input_class );
    
end
