function s = join( cstr, sep )
%
% s = dk.str.join( strings, sep )
%
% Variant of strjoin which excludes empty strings before joining.
% You can use deblank on the cellstr beforehand if you want to exclude whitespace strings:
%   dk.str.join( deblank(strings), sep )
%
% See also: strjoin, deblank
% 
% JH

    assert( iscellstr(cstr), 'Expected a cellstr in input.' );
    cstr = cstr(cellfun( @(x) ~isempty(x), cstr ));
    s = strjoin( cstr, sep );

end