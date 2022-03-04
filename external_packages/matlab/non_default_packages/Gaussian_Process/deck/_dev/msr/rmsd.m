function r = rmsd( A, B, dims, dimm )
% r = rmsd( A, B, dims, dimm )
%
% RMS of difference between A and B.
% See rms for more details.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

	if nargin < 4, dimm=1; end
    if nargin < 3, dims=2; end
    
	r = ant.msr.rms( bsxfun(@minus,A,B), dims, dimm );
	
end
