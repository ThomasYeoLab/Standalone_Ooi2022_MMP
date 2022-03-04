function restrict( s, allowed, required )
%
% dk.struct.restrict( s, allowed )
%
% Check fieldnames of s, and throw an error if any is unknown.
%
% JH

    if nargin < 3, required = {}; end
    if isnumeric(required)
        required = allowed(required);
    end

    assert( isstruct(s) && iscellstr(allowed) && iscellstr(required), 'Bad inputs.' );

    fields = fieldnames(s);
    unknown = setdiff( fields, allowed );
    assert( isempty(unknown), 'Unknown fieldnames:\n%s', strjoin(unknown,newline) );
    
    missing = setdiff( required, fields );
    assert( isempty(missing), 'Missing required fields:\n%s:', strjoin(missing,newline) );

end