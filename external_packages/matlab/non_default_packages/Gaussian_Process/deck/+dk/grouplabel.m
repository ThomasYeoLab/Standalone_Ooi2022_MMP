function G = grouplabel(L,n,t)
%
% G = dk.grouplabel(L)
% G = dk.grouplabel(L,n)
% G = dk.grouplabel(L,n,t)
%
% For each unique label in L, find indices of elements equal to this label.
% Output G is a 1xn cell:
%   - if n is not specified, then n=max(L) by default;
%   - otherwise, if n < max(L), then G only contains the first n groups.
%
% If t is specified, then:
%   - L should be sorted, and 
%   - t is a 1xn vector, such that t(i) is the index of the first element
%     in L equal to the i^th label.
%
%
% Complexity is m log(m), where m=length(L).
% In theory, could be improved to linear complexity using integer sort.
% This version is already ~10-20x faster than using Matlab's splitapply.
%
% NOTE:
%   - LABELS ARE ASSUMED TO BE CONSECUTIVE INTEGERS STARTING AT 1.
%   - Consequently, group G{i} has label i.
%   - If that is not the case, consider using dk.groupunique instead.
%
% See also: dk.groupunique
%
% JH

    % empty input
    if isempty(L)
        G = {};
        return
    end

    % format labels
    L = L(:);
    if nargin < 2 || isempty(n)
        n = max(L); 
    end
    
    % compute t
    if nargin < 3
        
        % count each label
        c = accumarray( L, 1, [n,1] ); % this will fail if L is not proper

        % sort labels
        [~,s] = sort(L,'ascend');

        % define strides in sorted version
        t = 1 + cumsum([0; c]);
        
    else
        
        nL = numel(L);
        assert( isvector(t) && numel(t)==n, 'Bad input t.' );
        assert( all(dk.num.between( t, 1, nL )), 'Bad indices t.' );
        s = 1:nL;
        t(end+1) = nL+1;
        
    end
    
    % define groups
    s = s(:)';
    t = t(:)';
    G = cell(1,n);
    for i = 1:n
        G{i} = s( t(i):(t(i+1)-1) );
    end 
    
    % get corresponding labels (empty groups are assigned NaN)
    %u = L(s(t(1:n)))';
    %u(diff(t) == 0) = nan;

end
