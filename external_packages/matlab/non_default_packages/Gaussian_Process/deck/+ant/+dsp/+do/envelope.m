function ts_out = envelope( ts_in )
%
% Compute broadband Hilbert envelope.
%
% JH

    ts_out = abs(hilbert(dk.bsx.sub( ts_in.vals, ts_in.mean )));
    ts_out = ant.TimeSeries( ts_in.time, ts_out );

end
