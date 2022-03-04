function n = nsdim(x) 
%
% n = ant.nsdim(x) 
%
% First non-singleton dimension of multidimensional input x.
%   n = 0 if x is empty
%   n = 1 if x is scalar
%
% JH

    s = size(x);
    switch prod(s)
        case 0
            n = 0;
        case 1
            n = 1;
        otherwise
            n = find(s > 1,1,'first');
    end

end