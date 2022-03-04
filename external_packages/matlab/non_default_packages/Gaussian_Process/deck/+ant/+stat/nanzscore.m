function z = nanzscore( x, flag, dim )
%
% z = ant.stat.nanzscore( x, flag, dim )
%
% Matlab doesn't have a nanzscore function.
%
% JH

    if nargin < 2, flag = []; end
    if nargin < 3, dim = 1; end

    z = bsxfun( @rdivide, bsxfun(@minus,x,nanmean(x,dim)), max(eps,nanstd(x,flag,dim)) );

end