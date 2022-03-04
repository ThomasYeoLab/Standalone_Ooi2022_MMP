function out = hex2rgb( in )
%
% out = dk.color.hex2rgb( in )
%
% Converts HEX colors to RGB vectors.
% Accepts cells in input.
%
% JH

    if iscell(in)
        out = dk.mapfun( @convert_hex, in, false );
    else
        out = convert_hex(in);
    end

end

function out=convert_hex(in)
    % remove leading #
    assert( ischar(in), 'Expected string in input.' );
    if in(1)=='#', in=in(2:end); end
    assert( numel(in)==6, 'Bad hex color length.' );
    out = [ hex2dec(in([1,2])), hex2dec(in([3,4])), hex2dec(in([5,6])) ]/255;
end
