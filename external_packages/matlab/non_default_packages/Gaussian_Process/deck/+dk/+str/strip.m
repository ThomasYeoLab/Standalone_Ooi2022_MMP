function s = strip( s, chars )
%
% s = dk.str.strip( s, chars='' )
%
% Remove specified leading and trailing characters.
%
%  INPUTS
%   s        the string to process
%   chars    the list of characters to remove, defaults to ''
%
% JH

    if nargin < 2, chars = '\s'; end

    s = regexp( s, ['^[' chars ']*(.*?)[' chars ']*$'], 'tokens', 'once' );
    s = s{1};

end
