function [I,d] = inv2(M)
% The inverse of a 2x2 matrix:
% 
% | a11 a12 |-1             |  a22 -a12 |
% | a21 a22 |    =  1/DET * | -a21  a11 |
% 
% with DET  =  a11a22-a12a21

    assert( ismatrix(M) && all(size(M) == 2), 'M must be a 2x2 matrix.' );
    d = M(1,1)*M(2,2) - M(1,2)*M(2,1);
    assert( abs(d) > eps, 'M is not inversible.' );
    
    I = [ M(2,2) -M(1,2); -M(2,1) M(1,1) ] / d;
    
end
