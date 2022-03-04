function h = hostname()
    [~,h] = unix('hostname'); h = deblank(h);
end
