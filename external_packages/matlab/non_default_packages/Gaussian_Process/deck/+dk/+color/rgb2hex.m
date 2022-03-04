function out = rgb2hex( in )
%
% out = dk.color.rgb2hex( in )
%
% Converts RGB colors to HEX strings.
% Accepts Nx3 inputs.
%
% JH

    if numel(in)==3
        out = convert_rgb(in);
    else
        assert( ismatrix(in) && size(in,2)==3, 'Expected Nx3 matrix in input.' );
        n = size(in,1);
        out = cell(1,n);
        for i = 1:n
            out{i} = convert_rgb( in(i,:) );
        end
    end

end

function out = convert_rgb(in)

    assert( numel(in)==3, 'Expected 1x3 vector in input.' );
    out = dk.mapfun( @dec2hex, in, false );
    out = dk.mapfun( @do_pad, out, false );
    out = [ '#' out{:} ];

end

function x=do_pad(x)
    if length(x)==1, x=['0' x]; end
    assert( length(x)==2, 'Unexpected length.' );
end
