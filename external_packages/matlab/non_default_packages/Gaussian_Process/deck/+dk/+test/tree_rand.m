function T = tree_rand(depth,sel,deg)
%
% tree_rand(depth,deg,sel)
%
% Create random Tree instance of specified depth and average degree.
%
% JH

    if nargin < 3, deg=@(n) randi([2,5],1,n); end
    if nargin < 2, sel=0.4; end
    if nargin < 1, depth=5; end

    T = dk.ds.Tree();
    k = 1;
    for d = 1:depth

        % select nodes to divide
        n = numel(k);
        r = false(1,n);
        while ~any(r)
            r = rand(1,n) < sel;
        end
        k = k(r);
        n = numel(k);

        % list of degrees
        if isnumeric(deg)
            g = deg*ones(1,n);
        else
            g = deg(n);
        end

        % update tree
        c = cell(1,n);
        for i = 1:n
            ki = k(i);
            gi = g(i);
            ci = zeros(1,gi);
            for j = 1:gi
                ci(j) = T.add_node(ki);
            end
            c{i} = ci;
        end
        k = [c{:}];

    end

end

