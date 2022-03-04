function [bounds,rtype] = range( x, rtype, bounds )
%
% [bounds,rtype] = dk.cmap.range( x, rtype='auto', bounds=[] )
%
% Determine value range of input data, in a way suitable for display.
% Inf and NaN values in x are filtered, and percentiles are used to determine bounds [a,b].
% If the value-range crosses zero, then bounds is of the form: M * [-1,1] (i.e. centred around 0).
%
% If bounds is specified, it overrides the bounds calculated previously, and forces the output range
% to these bounds provided.
% 
% Range types, if rtype is specified:
%
%   auto  Determined automatically from value range.
%   pos   Map interval [a,b] from left to right.
%   neg   Map interval [a,b] from right to left.
%   ctr   Split interval [a,b] into neg:[a,m] pos:[m,b], where m=(a+b)/2
%
% Output:
%
%   rtype   If input is not 'auto', then output=input.
%           Otherwise output is one of: bool, ctr, pos, neg
%
%   bounds  1x2 array with lower/upper bounds
%           Default is 1-99th percentile
%
% JH

    if islogical(x)
        bounds = [0,1];
        rtype  = 'bool';
        return;
    end

    assert( isnumeric(x), '[dk.cmap.range] Input data should be numeric.' );
    if nargin < 2, rtype='auto'; end
    if nargin < 3, bounds=[]; end
    
    % color range
    if isempty(bounds)
        assert( ~isempty(x), 'Color range cannot be determined without data.' );
        bounds = double(prctile( single(dk.num.filter(x)), [1 99] ));
    else
        rtype = 'manual';
    end
    
    % truncate to 2 significant digits
    bounds = dk.num.trunc(sort(bounds), 2);
    if diff(bounds) <= 0
        warning( 'Empty color range (might be too narrow).' );
        bounds = [0 1];
    end
    
    % characterise range
    lo = bounds(1);
    hi = bounds(2);
    if (lo < -eps) && (hi > eps)
        btype = 0; % range crosses 0
    elseif hi < eps
        btype = -1; % both negative
    else
        btype = 1;
    end
    
    % automatic rtype deduction
    if strcmpi( rtype, 'auto' )
        switch btype
            case 0
                rtype = 'ctr';
            case 1
                rtype = 'pos';
            case -1
                rtype = 'neg';
        end
    else
        if abs(lo+hi) < eps
            rtype = 'ctr';
        elseif abs(hi) < eps
            rtype = 'neg';
        elseif abs(lo) < eps
            rtype = 'pos';
        end
    end
    
    % set color-scale
    mg = max(abs(bounds));
    switch lower(rtype)
        case {'none','manual'}
            % nothing to do
            rtype = 'manual';
        case {'pos','positive'}
            rtype = 'pos';
            if lo < hi/4
                bounds = bounds .* [0 1]; % force lo to 0
            end
        case {'neg','negative','revneg'}
            rtype = 'neg';
            if hi > lo/4
                bounds = bounds .* [1 0]; % force hi to 0
            end
        case {'ctr','sym','symmetric','centred'}
            rtype  = 'ctr';
            bounds = mg * [-1 1]; % centred
    end
    
end
    