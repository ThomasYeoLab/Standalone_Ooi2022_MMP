function r = radinv(x,b)
%
% r = radinv(x,b)
%
% Radical inverse function of numbers x in base b.
%
% JH

    r = fliplr(dk.num.digits(x,b));
    L = size(r,2);
    for i = 1:L
        r(:,i:L) = r(:,i:L) / b;
    end
    r = sum(r,2);
    
end
