function [t,d] = typeid(x)
% Integer part:
%
%   logical       1
%   numeric       2
%   char          3
%   struct        4
%   cell          5
%   json array    10
%   json object   11
%
% Decimal part:
%
%   array   .0
%   column  .1
%   row     .2
%   scalar  .3
%   empty   .4

    if islogical(x)
        t=get_id(1,x);
    elseif isnumeric(x)
        t=get_id(2,x);
    elseif ischar(x)
        t=get_id(3,x);
    elseif isstruct(x)
        t=get_id(4,x);
    elseif iscell(x)
        t=get_id(5,x);
    elseif isa(x,'dk.json.Array')
        t=10;
    elseif isa(x,'dk.json.Object')
        t=11;
    else
        warning('Unrecognised type %s.',class(x));
        t=0;
    end
    
    % separate integer and decimal parts
    if nargout > 1
        d = round(10*mod(t,1));
        t = floor(t);
    end

end

function i=get_id(b,x)

    if isempty(x)
        i=b+0.4;
    elseif isscalar(x)
        i=b+0.3;
    else
        i=b+(isvector(x) + isrow(x))/10;
    end

end
