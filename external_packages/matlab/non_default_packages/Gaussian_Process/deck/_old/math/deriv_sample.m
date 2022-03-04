function dy = deriv_sample( x, y, h )
% dy = deriv_sample( x, y, h )
%
% Numeric derivative of a sampled scalar function using central approximation.
%
% x: sampling locations
% y: sampled values at x
% h: numeric step for central approx
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    if nargin < 3, h = 1e-6; end
    
    try 
        % cubic interpolation
        after  = interp1( x, y, x+h, 'pchip' );
        before = interp1( x, y, x-h, 'pchip' );
    catch
        % fallback to linear (equivalent to Matlab's "gradient" function)
        after  = interp1( x, y, x+h, 'linear' );
        before = interp1( x, y, x-h, 'linear' );
    end
    dy = (after-before) / (2*h);

end
