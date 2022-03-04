function out = img2cell(in)
%
% out = dk.priv.img2cell(in)
%
%   Convert input array to cell of images.
%
%
% GOTCHAS
% -------
%
%   1. Cell inputs are taken as valid output without checking contents.
%
%   2. By default, 3D arrays are interpreted as grayscale slices.
%      If you want to pass a single RGB image, then pass it as a scalar cell.
%
% JH

    if isnumeric(in)
        switch ndims
            case 2
                % single graycolor image
                out = {in};
            case 3
                % by default, split 3D stacks as graycolor images
                n = size(in,3);
                out = cell(1,n);
                for i = 1:n
                    out{i} = in(:,:,i);
                end
            case 4
                % single RGB image
                n = size(in,4);
                out = cell(1,n);
                for i = 1:n
                    out{i} = in(:,:,:,i);
                end
            otherwise
                error( 'Unexpected shape.' );
        end
    else
        out = in;
    end
    assert( iscell(out), 'Input should be a cell or numeric array.' );

end