function [c,k] = graphcolor(G,r)
%
% [c,k] = ant.math.graphcolor(G,r=1)
%
% Greedy coloring algorithm for input graph G.
%
%   G = binary adjacency matrix (not necessarily symmetric)
%   r = number of runs with randomly permuted order 
%      (best result is returned)
% 
%   c = n-by-1 vector of integers between 1 and k
%      where n is the number of nodes in G
%   k = number of colors
% 
% Increasing the number of runs can lead to better colorings (ie fewer colors).
% For more information, see https://en.wikipedia.org/wiki/Greedy_coloring
%
% JH

    if nargin < 2, r=1; end
    
    assert( islogical(G) && ismatrix(G) && diff(size(G))==0, 'G should be a square logical matrix.' );
    
    % set diagonal to 0
    n = size(G,1);
    G( 1:(n+1):(n*n) ) = false;
    
    % repeat 
    k = Inf;
    q = 1:n;
    while r > 0
        r = r-1;
        p = randperm(n);
        [tc,tk] = run(G(p,p));
        if tk < n
            q(p) = 1:n;
            c = tc(q);
            k = tk;
        end
    end

end

function [c,k] = run(G)

    n = size(G,1);
    c = zeros(n,1);
    c(1) = 1;
    k = 1;
    
    for i = 2:n
        b = false(1,k+1);
        b(1 + c(G(i,:))) = true;
        ci = find( ~b(2:end), 1, 'first' );
        
        if isempty(ci)
            k = k+1;
            c(i) = k;
        else
            c(i) = ci;
        end
    end

end