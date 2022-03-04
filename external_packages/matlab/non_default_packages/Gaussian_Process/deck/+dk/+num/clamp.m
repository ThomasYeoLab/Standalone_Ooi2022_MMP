function vals = clamp( vals, varargin )
%
% vals = dk.num.clamp( vals, [lo,hi] )
% vals = dk.num.clamp( vals, lo, hi )
%
% Clamp input values in the range bvals to values cvals.
%
% JH

    if nargin == 3
        lo = varargin{1};
        hi = varargin{2};
    else
        lo = varargin{1}(1);
        hi = varargin{1}(2);
    end

    vals = max( vals, lo );
    vals = min( vals, hi );
    
end
