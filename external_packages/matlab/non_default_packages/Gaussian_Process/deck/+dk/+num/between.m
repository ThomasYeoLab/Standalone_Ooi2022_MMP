function y = between( val, lo, hi, bc )
%
% y = dk.num.between( val, lo, hi, bc='[]' )
%
% Check whether input value is within specified range, with optional boundary condition.
% Valid conditions are:
%   open, ()
%   closed, []
%   [), (]
%
% Can be used with arrays as well, e.g. combined with all() to test all elements at once.
%
% JH
    
    if nargin < 4, bc = '[]'; end
    
    switch bc
        
        case {'open','()'}
            y = (val > lo) & (val < hi);
            
        case {'closed','[]'}
            y = (val >= lo) & (val <= hi);
            
        case '[)'
            y = (val >= lo) & (val < hi);
            
        case '(]'
            y = (val > lo) & (val <= hi);
            
        otherwise
            error('Boundary condition should be one of "[]", "[)", "()", "(]".' );
        
    end
    
end
