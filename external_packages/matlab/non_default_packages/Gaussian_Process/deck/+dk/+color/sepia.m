function s = sepia(c)
%
% s = dk.color.sepia(c)
%
% Transform input RGB colors to sepia.
%
% JH

    assert( dk.is.rgb(c), 'Input should be an RGB matrix.' );

    M = [ ...
        0.393, 0.349, 0.272;
        0.769, 0.686, 0.534;
        0.189, 0.168, 0.131
    ];
    s = min( 1, c*M );
    
end