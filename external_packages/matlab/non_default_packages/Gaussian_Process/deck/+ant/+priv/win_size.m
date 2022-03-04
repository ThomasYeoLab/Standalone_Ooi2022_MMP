function wsize = win_size( ts, len )
    
    % wlen should be in seconds and ts should be uniformly sampled
    wsize = 1 + ts.numsteps(len);
    
end
