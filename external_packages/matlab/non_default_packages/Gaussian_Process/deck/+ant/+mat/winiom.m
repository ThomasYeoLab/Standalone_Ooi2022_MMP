function idx = winiom(msz,wsz,ref)
%
% idx = ant.mat.winiom(msz,wsz,ref)
%
% Window index-offset mask for arbitrary sized matrices.
%
% JH

    if nargin < 3, ref='centre'; end
    
    assert( isrow(msz) && all(msz > 0), 'Matrix size should be a positive vector.' );
    d = numel(msz);
    
    if isscalar(wsz), wsz = wsz * ones(1,d); end
    assert( isrow(wsz) && numel(wsz)==d && all(wsz > 0), 'Window size mismatch.' );
    
    if ischar(ref)
    switch lower(ref)
        case {'topleft','tl','first'}
            ref = [1,1];
        case 'centre'
            assert( all(dk.is.odd(wsz)), 'Centre of mask is undefined for even-sized windows.' );
            ref = ceil(wsz/2);
        otherwise
            error( 'Unknown reference: %s', ref );
    end
    end
    assert( isrow(ref) && numel(ref)==d && all(ref > 0 & ref <= wsz), 'Bad reference element.' );
    
    n = prod(wsz);
    idx = cell(1,d);
    [idx{:}] = ind2sub( wsz, (1:n)' );
    idx = dk.bsx.sub( horzcat(idx{:}), ref );
    idx = dk.bsx.mul( idx, [1,cumprod(msz(1:end-1))] );
    idx = reshape( sum(idx,2), wsz );

end