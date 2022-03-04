function [M,v] = formatmv( M, v, type )
%
% [M,v] = dk.formatmv( M, v, type='vert' )
% 
% Format matrix and associated vector either horizontally, or vertically.
% The vector should match one of the dimensions of the input matrix.
%
% Type can be one of:
%   v,vert,vertical
%   h,horz,horizontal
%
% JH

    if nargin < 3, type='vert'; end

    n = numel(v);
    assert( ismatrix(M) && any(size(M)==n), 'Matrix/vector size mismatch.' );
    
    switch lower(type)
        case {'vertical','vert','v'}
            v = v(:);
            if size(M,2)==n && size(M,1)~=n
                M = transpose(M);
            end
        case {'horizontal','horz','h'}
            v = transpose(v(:));
            if size(M,1)==n && size(M,2)~=n
                M = transpose(M);
            end
        otherwise
            error( 'Unknown type: %s', type );
    end
    
end
