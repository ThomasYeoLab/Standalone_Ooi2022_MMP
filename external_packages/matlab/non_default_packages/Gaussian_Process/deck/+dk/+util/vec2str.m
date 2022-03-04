function str = vec2str(vec,sep)
%
% str = vec2str(vec,sep=', ')
%
% Convert numeric vector to a comma-separated list of strings.
% 
% JH

    if nargin < 2, sep=', '; end
    str = strjoin( dk.mapfun( @num2str, vec, false ), sep );
end