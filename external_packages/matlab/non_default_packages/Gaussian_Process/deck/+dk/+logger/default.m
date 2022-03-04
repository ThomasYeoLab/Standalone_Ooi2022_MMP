function L = default()
%
% L = dk.logger.default()
%
% Return default logger, used with dk.log.
% Use this method to set a different configuration for default logs (e.g. backup to file).
%
% The default non-standard config is:
%    nodate: true
%   lvlchar: true
%
% JH

    L = dk.logger.get( 'Deck', 'nodate', true, 'lvlchar', true, 'stdepth', 1 );
    
end