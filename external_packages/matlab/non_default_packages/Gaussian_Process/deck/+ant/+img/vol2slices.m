function x = vol2slices( x )
%
% slices = ant.img.vol2slices( vol )
%
% Put each slice of a stacked volume into a cell array.
% If input is already a cell, it is simply forwarded in output.
%
% JH

    if isnumeric(x)
        d = ndims(x);
        n = size(x,d);
        y = cell(1,n);
        for i = 1:n
            switch d
                case 3
                    y{i} = x(:,:,i);
                case 4
                    y{i} = x(:,:,:,i);
                otherwise
                    error('Unexpected number of dimensions.');
            end
        end
        x = y;
    end
    dk.assert( iscell(x), 'Unrecognised volume format.' );

end
