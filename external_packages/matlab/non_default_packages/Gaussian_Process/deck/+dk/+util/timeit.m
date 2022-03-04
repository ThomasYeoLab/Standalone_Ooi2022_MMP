function [tstat,t] = timeit( nrep, fun, varargin )
% 
% [tstat,t] = timeit( nrep, fun, data )
% 
% Apply function a number of times, measure the execution time, and return time stats.
% Optionally provide arguments for the function.
%
% JH
    
    t = zeros(1,nrep); tic;
    for i = 1:nrep
        fun(varargin{:}); 
        t(i) = toc;
    end
    t = diff([0,t]);
    tstat = [mean(t),std(t),median(t)];
    
    if nargout == 0
        astr = dk.time.sec2str(tstat(1));
        sstr = dk.time.sec2str(tstat(2));
        mstr = dk.time.sec2str(tstat(3));
        dk.print( 'Runtime:\n\t avg %s\n\t std %s\n\t med %s', astr, sstr, mstr );
    end
    
end
