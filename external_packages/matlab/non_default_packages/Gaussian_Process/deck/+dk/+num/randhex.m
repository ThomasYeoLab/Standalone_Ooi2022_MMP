function s = randhex( len )

    sym = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
    s   = [sym{randi(16,1,len)}];

end
