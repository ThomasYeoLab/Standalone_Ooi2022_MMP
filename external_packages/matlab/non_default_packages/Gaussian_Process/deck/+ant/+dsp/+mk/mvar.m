function out = mvar(in,order,tlen)
%
% Create surrogate data from input time-series by fitting and generating from an MVAR process.
%

    [mvar,ts] = ant.dsp.MVAR( in, order );
    fs = 1/(ts.time(2)-ts.time(1));
    out = mvar.gen( tlen, fs );
    
end
