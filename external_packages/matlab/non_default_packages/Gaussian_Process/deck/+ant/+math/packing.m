function P = packing(w,n)
%
% P = ant.math.packing(w,n)
%
% Solve the packing problem of grouping input weights w into n roughly equal batches.
% The algorithm implemented is greedy, and works well with uniformly random weigths.
% The solution is obviously not optimal, but good enough e.g. to distribute jobs in batches.
%
% Output is a 1xn cell with arrays of indices.
%
% EXAMPLE
% -------
%
%   w = rand(1,100);
%   P = ant.math.packing(w,10);
%   cellfun( @(k) sum(w(k)), P )
% 
% JH

    assert( all(w >= 0) && n > 0, 'Bad inputs.' );

    % normalise weights and initialise dequeue
    [w,r] = sort(w / sum(w));
    P = cell(1,n);
    b = 1;
    e = numel(w);
    
    % create initial batches
    for i = 1:n
        [P{i},b,e] = pack(w,b,e,n);
    end
    
    % sort batches in ascending weight
    [~,ord] = sort(cellfun( @(k) sum(w(k)), P ));
    P = P(ord);
    
    % distribute remaining items sequentially, heavy first
    c = 0;
    while b <= e
        P{c+1}(end+1) = e;
        e = e-1;
        c = mod(c+1,n);
    end
    
    % convert sorted indices back to input order
    P = dk.mapfun( @(k) r(k), P );
    no_overlap(P); % debug: sanity check

end

function [k,b,e] = pack(w,b,e,n)

    t = 0;
    k = [];
    
    while e > b && t+w(e) < 1/n
        k(end+1) = e;
        t = t+w(e);
        e = e-1;
    end
    
    while b <= e && t+w(b) < 1/n
        k(end+1) = b;
        t = t+w(b);
        b = b+1;
    end

end

function no_overlap(P)

    n = numel(P);
    for i = 1:n
    for j = i+1:n
        assert( isempty(intersect(P{i},P{j})), 'Overlapping batches found (%d and %d).', i, j );
    end
    end

end