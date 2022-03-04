function duration = seconds2duration( sec )
%
% Convert an input amount of seconds to an integer vector with days, hours, .. down to miliseconds.
% 
% Contact: jhadida [at] fmrib.ox.ac.uk

    [d,sec] = dk.num.divmod(sec,86400);
    [h,sec] = dk.num.divmod(sec,3600);
    [m,sec] = dk.num.divmod(sec,60);
    [s,sec] = dk.num.divmod(sec,1);
    ms = floor(sec*1000);
    
    duration = [ d, h, m, s, ms ];
    
end
