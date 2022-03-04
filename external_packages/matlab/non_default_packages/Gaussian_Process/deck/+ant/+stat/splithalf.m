function out = splithalf( data, dim, nrep, comp )
%
% out = splithalf( data, dim=last, nrep=100, comp=corr )
%
% Recursively split the input data in two groups along dimension 'dim', 
% and compare their means.
%
% If data is a cell array, then each cell is processed independently 
% but using the same grouping as the others at each repeat. Each cell 
% should be a matrix, but possibly with different diemsnions, as long
% as their size along dimension 'dim' is the same across all cells.
%
% The output is a matrix of size Nrepeats x Ncells, with the score of 
% comparison for each cell at each repeat. The default comparison function
% is the correlation.
%
% JH

    if ~iscell(data), data = {data}; end
    if nargin < 2, dim=ndims(data{1}); end
    if nargin < 3, nrep=100; end
    if nargin < 4, comp=@default_comp; end
    
    % convert all cells to matrices where each row is an observation
    data = dk.mapfun( @(x) ant.mat.squash(x,dim), data, false );
    
    % make sure they have the same number of observations
    assert( all(diff(cellfun( @(x)size(x,1), data )) == 0), ...
        'Cells must have the same number of observations.' );
    
    % repeat comparison
    nobs = size(data{1},1);
    ncel = numel(data);
    out  = zeros(nrep,ncel);
    
    for r = 1:nrep
        
        % for each repeat choose a random permutation
        p = randperm(nobs);
        n = fix(nobs/2);
        
        % split it into two groups
        pa = p(1:n);
        pb = p((n+1):end);
        
        % use the same groups to compare each cell
        for c = 1:ncel
            ma = nanmean( data{c}(pa,:), 1 );
            mb = nanmean( data{c}(pb,:), 1 );
            out(r,c) = comp(ma,mb);
        end
        
    end
    
end

% Default comparison is the correlation between means
function s = default_comp( a, b )

    a = a-mean(a);
    b = b-mean(b);
    s = dot(a,b) / sqrt(dot(a,a)*dot(b,b));

end
