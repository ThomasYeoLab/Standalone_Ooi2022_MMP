function R = from_quaternion( a, b, c, d )

    if nargin == 1
        [a,b,c,d] = dk.deal(a);
    end

    R = [ 1 - 2*c^2 - 2*d^2 , 2*b*c - 2*d*a     , 2*b*d + 2*c*a ; ...
          2*b*c + 2*d*a     , 1 - 2*b^2 - 2*d^2 , 2*c*d - 2*b*a ; ...
          2*b*d - 2*c*a     , 2*c*d + 2*b*a     , 1 - 2*c^2 - 2*b^2 ];

end
