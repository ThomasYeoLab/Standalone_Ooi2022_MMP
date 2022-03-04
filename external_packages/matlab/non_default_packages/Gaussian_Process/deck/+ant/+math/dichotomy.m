function [best,step] = dichotomy( is_greater_than, range, maxerr, maxshift )
%
% [best,step] = ant.math.dichotomy( is_greater_than, range, maxerr=1e-6, maxshift=[0,0] )
%
% Search range of parameter by dichotomy, with a precision of at least maxerr.
%
% INPUTS
%
%   is_greater_than
%       Function handle taking a single parameter in input, and returning true if the 
%       value sought is higher (ie, the input is too low).
%
%   range
%       Either scalar, or 1x2 vector.
%       If scalar, then the search range is set to [0,range] (or [range,0] if range < 0).
%       If vector, then the parameter is sought in the specified range.
%
%   maxerr (default: 1e-6)
%       The maximum error tolerance.
%       That is: best-maxerr < truth < best+maxerr
%
%   maxshift (default: [0,0])
%       If you don't know enough about the search range, you can allow a certain number 
%       of range-shifts before the dichotomic search. The range can be shifted left or right, 
%       such that the final search range will be:
%           range +/- k*diff(range)   with   k <= maxshift
%
%       The format of the input is: [maxdownshit, maxupshit]
%       If the input range is shifted more than maxshift times, an error is thrown.
%       
%
% OUTPUTS
%
%   best
%       Best parameter guess, within a precision maxerr.
%
%   step
%       Actual precision achieved, which is < maxerr.
%       That is: best-step <= truth <= best+step  (note <= and not <)
% 
% JH

    if nargin < 3, maxerr = 1e-6; end
    if nargin < 4, maxshift = [0,0]; end

    % process range
    assert( isnumeric(range), 'Search range should be numeric.' );
    if isscalar(range), range = [0,range]; end
    
    range = range(:)';
    assert( numel(range) == 2, 'Search range should be 1x2.' );
    if range(1) > range(2), range = fliplr(range); end
    
    delta = range(2)-range(1);
    step = delta / 2;
    if delta < eps
        assert( is_greater_than(range(1)) && ~is_greater_than(range(2)), ...
            'Range is too narrow, and value is not within bounds.' );
        
        best = mean(range);
        warning( 'Range is too narrow, aborting.' );
        return;
    end
    assert( maxerr > eps, 'Maxerr is too small.' );
    
    
    % adjust range by shifting it left or right
    assert( numel(maxshift)==2 && all(maxshift >= 0), 'Maxshift vector should be 1x2 with non-negative entries.' );
    
    maxdownshift = maxshift(1);
    if maxdownshift > 0 
        while ~is_greater_than(range(1))
            range = range - delta;
            maxdownshift = maxdownshift - 1;
            assert( maxdownshift >= 0, 'Search range should be lower (maxdownshift exceeded).' );
        end
    end
    
    maxupshift = maxshift(2);
    if maxupshift > 0 
        while is_greater_than(range(2))
            range = range + delta;
            maxupshift = maxupshift + 1;
            assert( maxupshift >= 0, 'Search range should be higher (maxupshift exceeded).' );
        end
    end
    
    
    % dichotomy search
    best = mean(range);
    while step >= maxerr
        step = step / 2;
        if is_greater_than(best)
            best = best + step;
        else
            best = best - step;
        end
    end

end
