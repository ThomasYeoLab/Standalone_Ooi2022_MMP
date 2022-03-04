function array_resize( n, m, p )

    if nargin < 1, n=4e4; end
    if nargin < 2, m=10; end
    if nargin < 3, p=1000; end
    
    r=100;
    x=rand(n,m);
    
    t=tic;
    for i = 1:r, resize1(x,p); end
    disp( toc(t)/r );
    
    t=tic;
    for i = 1:r, resize2(x,p); end
    disp( toc(t)/r );

end

function x=resize1(x,n)
    r = size(x,1);
    x(r+(1:n),:) = nan;
end

function y=resize2(x,n)
    y = vertcat( x, nan(n,size(x,2)) );
end