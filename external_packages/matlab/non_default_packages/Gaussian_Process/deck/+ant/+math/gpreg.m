function [gpr,reg,ph,fh] = gpreg( x, y, q, gopt, popt, fopt )
%
% [gpr,reg] = gpreg( x, y, q, gopt, popt, fopt )
%
% Simple wrapper for fitrgp, computing GP regression for inputs (x,y), predicting
% values at query points q, and optionally drawing the results (if nargin > 4).
%
% INPUTS
%
%   x, y  Inputs to be regressed, both should have the same dimensions.
%      q  Query points to be predicted.
%         Default: 100 points between bounds of x
%   gopt  Structure with options for fitrgp, or cell of key-value pairs.
%         Default: BasisFunction, constant, KernelFunction, squaredexponential
%   popt  Struct or cell of options for dk.ui.sdplot
%   fopt  Struct or cell of options for dk.ui.sdplot
%
% OUTPUTS
%
%    gpr  RegressionGP object returned by fitrgp
%    reg  Structure with fields:
%           x  Same as q
%           y  Predicted values
%           s  Estimate of prediction std
%          ci  95% confidence interval (gopt.Alpha = 0.05)
%
%  ph,fh  Plot and fill handle if the results are drawn.
%
% Example:
%
%   -
%
% See also: fitrgp, dk.ui.sdplot
%
% JH

    if nargin < 6, fopt=[]; end
    if nargin < 5, popt=[]; end
    if nargin < 4 || isempty(gopt), gopt=struct(); end
    
    % input data
    x = x(:); 
    y = y(:); 
    n = numel(x);
    
    assert( isnumeric(x) && isnumeric(y), 'Expected numeric data.' );
    assert( numel(y)==n, 'Input size mismatch.' );
    
    % query points
    if nargin < 3
        q = linspace( min(x), max(x), 100 );
    end
    assert( isnumeric(q), 'Expected numeric query points.' );
    q = q(:);
    
    % set default options
    gdef.BasisFunction  = 'constant';
    gdef.KernelFunction = 'squaredexponential';
    gdef.Alpha          = 0.05;
    
    if iscell(gopt), gopt=dk.c2s(gopt{:}); end
    gopt = dk.struct.merge( gdef, gopt );
    
    % run gpr
    gpr = rmfield(gopt,'Alpha'); % fitrgp doesn't accept invalid arguments..
    gpr = dk.struct.to_cell(gpr);
    gpr = fitrgp( x, y, gpr{:} );
    
    % prediction
    reg.x = q;
    [reg.y, reg.s, reg.ci] = gpr.predict( q, 'Alpha', gopt.Alpha );
    
    % plot
    if nargin > 4 || nargout > 2
        [ph,fh] = dk.ui.sdplot( reg.x, reg.y, reg.ci, popt, fopt );
    end
    
end
