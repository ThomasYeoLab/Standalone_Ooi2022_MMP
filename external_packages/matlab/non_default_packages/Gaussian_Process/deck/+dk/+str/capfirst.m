function str = capfirst( str, lower_other )
%
% str = dk.str.capfirst( str, lower_other=false )
%
% Run singlespaces and capitalise the first letter.
% If option lower_other is true, other letters are forced to lower font (default not).
%
% JH

    if nargin < 2, lower_other = false; end

    str = dk.str.singlespaces(str);
    str(1) = upper(str(1));

    if lower_other
        str(2:end) = lower(str(2:end));
    end

end
