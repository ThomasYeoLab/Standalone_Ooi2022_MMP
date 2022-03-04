function R = with_convention( alpha, beta, gamma, convention )

    assert( ischar(convention) && numel(convention)==3 && all(ismember(convention,'xyz')), ...
        'Convention must be a 3-letter string.' );
    
    r  = @(c)(sprintf('around_%c',c));
    r1 = r(convention(1));
    r2 = r(convention(2));
    r3 = r(convention(3));
    
    R = rotation.(r1)(alpha) ...
        * rotation.(r2)(beta) ...
        * rotation.(r3)(gamma);
    
end
