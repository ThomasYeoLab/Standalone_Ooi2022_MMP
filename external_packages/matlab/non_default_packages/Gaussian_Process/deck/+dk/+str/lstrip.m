function s = lstrip( s, chars )
%
% s = dk.str.lstrip( s, chars='' )
%
% Remove specified leading characters.
%
%  INPUTS
%   s        the string to process
%   chars    the list of characters to remove, defaults to ''
%
% JH

    if nargin < 2, chars = '\s'; end

    s = regexp( s, ['^[' chars ']*(.*?)$'], 'tokens', 'once' );
    s = s{1};

end
