function str = singlespaces( str )
%
% str = dk.str.singlespaces( str )
%
% Replace all forms of spaces (multiple spaces, tabs, etc) by a single space, then trim the result.
%
% JH

    str = strtrim(regexprep( str, '(\s+)', ' ' ));

end
