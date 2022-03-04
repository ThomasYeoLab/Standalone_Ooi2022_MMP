function r = rms( X, dims, dimm )
% r = rms( X, dims, dimm )
%
% Compute RMS metric on X.
%
% INPUT
%	X numeric array.
%   dims (default: 2) the dimension corresponding to coordinates.
%   dimm (default: 1) the dimension corresponding to observations.
%
% Constraints:
%	X is numeric, dim* are scalars.
%
% OUTPUT
%	Output size is based on X's, but reduces the dimensions dims (sum of squared) and dimm (mean).
%
% Contact: jhadida [at] fmrib.ox.ac.uk
	
    if nargin < 3, dimm = 1; end
    if nargin < 2, dims = 2; end
    
    r = sqrt(mean( dot(X,conj(X),dims), dimm ));

end
