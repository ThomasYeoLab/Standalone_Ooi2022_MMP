function df = derive( f, x, h )
% df = ant.ts.derive( f, x, h )
%
% f: scalar function handle
% x: point at which the gradient is computed
% h: numeric step for central approx
%
% DEPRECATED, see ant.ts.diff
%
% JH

    if nargin < 3, h = 1e-6; end
    
    warning('DEPRECATION notice (did you want to use ant.ts.diff?)');
    df = ( f(x+h) - f(x-h) ) / (2*h);
    
end
