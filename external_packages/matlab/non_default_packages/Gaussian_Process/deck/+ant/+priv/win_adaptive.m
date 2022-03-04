function swin = win_adaptive( cenfrq, nosc, burn, ovr )
%
% swin = ant.priv.win_adaptive( cenfrq, nosc, burn=0, ovr=0.5 )
%
% Sliding window specified in terms of number of oscillations for a given 
% centre frequency. Output is Nx3, where N is the length of cenfrq.
%
% JH

    if nargin < 4, ovr=0.5; end
    if nargin < 3, burn=0; end
    
    assert( all(cenfrq > eps), 'Frequencies should be > 0' );
    assert( all(nosc > eps), 'Number of oscillations should be > 0' );
    assert( all(burn >= 0), 'Burn-ins should be >= 0' );
    assert( all(ovr >= 0 & ovr < 1), 'Overlaps should be in [0,1)' );

    n = numel(cenfrq);
    wlen = nosc(:) ./ cenfrq(:); % window time-lengths
    swin = [ wlen, (1-ovr(:)) .* wlen, burn(:) .* ones(n,1) ];
    
    % min sampling rate to honour required ntpts
    %fs = ceil( npc ./ wlen ); 

end