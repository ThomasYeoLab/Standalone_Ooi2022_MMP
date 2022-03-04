function [clvl,flvl] = verb( clvl, flvl )
%
% dk.verb()
% dk.verb( consoleLevel )
% dk.verb( consoleLevel, fileLevel )
%
% Control verbose level of default logger. 
% Valid levels are:
%
%   all
%   trace
%   debug
%   info
%   warning
%   error
%   critical
%   off
%
% See also: dk.log, dk.logger.Logger
%
% JH

    L = dk.logger.default();

    if nargin >= 1
        L.consoleLevel = clvl;
    else
        clvl = L.consoleLevel;
    end
    
    if nargin >= 2
        L.fileLevel = flvl;
    else
        flvl = L.fileLevel;
    end
    
    dk.print( '[Deck] Verbose levels: {console: %s; file: %s}', clvl, flvl );

end
