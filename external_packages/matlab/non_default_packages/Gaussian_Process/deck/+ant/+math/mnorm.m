function vals = mnorm( mats, name, varargin )
%
% vals = ant.math.mnorm( mats, func )
% vals = ant.math.mnorm( mats, name, varargin )
%
% Matrix norms.
%
%   mats: numeric matrix or volume, or cell of matrices
%   func: function handle to compute the norm of a matrix
%   name: one of the names below
%
%   Euclidean           max(svd(x))
%   Frobenius           Sum of squares
%   Lebesgue            Lp norm
%   amedian             Median absolute value
%   amedian_nodiag      Same, but excluding diagonal
%
% See also: norm
%
% JH
    
    if nargin < 2, name = 'default'; end

    % select norm
    if dk.is.fhandle(name)
        f = name;
    else
    switch lower(name)
        
        case {'default','euclidean','eucl'}
            f = @norm;
        
        case {'fro','frobenius'}
            f = @(x) norm(x,'fro');
            
        case {'lp','lebesgue'}
            f = @(x) norm(x,varargin{1});
            
        case {'amedian'}
            f = @(x) median(abs(x(:)));
            
        case {'amedian_nodiag'}
            f = @(x) median(abs(x( ~eye(size(x),'logical') )));
            
        otherwise
            error('Unknown norm "%s".',name);
        
    end
    end
    
    % apply norm
    if iscell(mats)
        
        % apply to each cell
        vals = dk.mapfun( f, mats, true );
        
    elseif isnumeric(mats)
        
        % iterate over slices
        n = size(mats,3);
        vals = zeros(1,n);

        for i = 1:n
            vals(i) = f(mats(:,:,i));
        end
        
    else
        error( 'Bad input type.' );
    end

end
