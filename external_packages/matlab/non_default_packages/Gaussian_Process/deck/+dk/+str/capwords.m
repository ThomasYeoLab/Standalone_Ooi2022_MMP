function str = capwords( str, lower_other )
%
% str = dk.str.capwords( str, lower_other=false )
%
% Run singlespaces and capitalise every word.
% If option lower_other is true, every other character is set to lower font (default not).
%
% JH

    if nargin < 2, lower_other = false; end

    str = dk.str.singlespaces(str);
    loc = regexp(str,'([ -]["'']?\w)','end');
    loc = [1 loc];
    str(loc) = upper(str(loc));

    if lower_other
        len = numel(str);
        loc = setdiff( 1:len, loc );
        str(loc) = lower(str(loc));
    end

end
