function dF = gradient( F, x, h )
% dF = gradient( F, x, h )
%
% F: function handle such that for any nxk matrix
%       X  = [ X1, X2, .. Xk ]
%     of column vectors
%       Xi = [xi1,xi2, ..., xin]'
%    F(X) returns a mxk matrix 
%       F(X) = [ F(X1), F(X2), .. F(Xk) ]
%    with column vectors
%       F(Xi) = [f1(Xi),f2(Xi), ... fm(Xi)]'
%
% x: n-dimensional point at which the gradient is computed
% h: scalar or n-dimensional step for central approx
%
%
% dF: if F is scalar (ie for m = 1), dF is the numeric gradient of F
%     otherwise (ie for m > 1), dF is the numeric Jacobian of F
%
% JH

    if nargin < 3, h = 1e-6; end

    x = x(:);
    h = h(:);
    
    nx = numel(x);
    nh = numel(h);
    
    if nh == 1, h = h*eye(nx);
    else        h = diag(h); end
    
    xa = dk.bsx.add( x, h );
    xb = dk.bsx.sub( x, h );
    dF = dk.bsx.rdiv( F(xa)-F(xb), 2*diag(h)' );
    
end
