function v = getelem( X, k, v )
%
% v = dk.getelem( X, k, v )
%
% Extract element(s) k from array/struct/cell X.
% If v is provided and k exceeds X's size, then v is returned without causing overflow error.
%

    if numel(X) >= k
    if iscell(X) && isscalar(k)
        v = X{k};
    else
        v = X(k);
    end
    end
    
end