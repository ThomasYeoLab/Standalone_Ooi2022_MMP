function splitapply()

    x = round(rand(1,1000),2);
    [u,~,L] = unique(x); % labeling
    u = u(:)';
    L = L(:)';
    
    r = 100;
    t = tic;
    for i = 1:r, do1(L); end
    disp( toc(t)/r ); 
    
    t = tic;
    for i = 1:r, do3(L); end
    disp( toc(t)/r ); 
    
end

function G = do1(L)
    n = numel(L);
    G = splitapply( @(varargin)varargin, 1:n, L );
end

function G = do2(L)
    [~,s] = sort(L,'ascend');
    
    c = accumarray(L(:),1);
    t = 1 + cumsum([0,c']);
    
    n = numel(c);
    G = cell(1,n);
    
    for i = 1:n
        G{i} = s(t(i):(t(i+1)-1));
    end
end

function G = do3(L)
    G = dk.grouplabel(L);
end
