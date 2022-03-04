function [gof,mdl] = linfit( x, y, varargin )
%
% [gof,mdl] = linfit( x, y, varargin )
%
% Fit linear model to data x -> y, using Matlab's function fitlm.
%
% Main option is:
%   VarNames   { 'x1', 'x2', .., 'y' }
%
% For more options, see fitlm.
%
%
% Outputs
%
%   gof     Structure with fields
%               sse     sum of squared errors
%               dfe     degrees of freedom in the error
%               rsq     r-squared (coeff of determination)
%               arsq    adjusted r-squared
%               rmse    root-mean-square error (std error)
%               pval    p-value for each variable
%               
%   mdl     Matlab LinearModel object.
%
% Example:
%   n = 100;
%   x = linspace(0,10,n);
%   y = 2 + 5*x + 3*randn(1,n);
%   ant.math.linfit(x,y);
%       
% See also: fitlm, LinearModel
%
% JH

    mdl = fitlm(x,y,varargin{:});
    
    gof.rmse = mdl.RMSE;
    gof.dfe  = mdl.DFE;
    gof.sse  = mdl.SSE;
    gof.rsq  = mdl.Rsquared.Ordinary;
    gof.arsq = mdl.Rsquared.Adjusted;
    gof.pval = mdl.Coefficients.pValue(2:end);
    
    if nargout == 0
        plot(mdl);
    end

end
