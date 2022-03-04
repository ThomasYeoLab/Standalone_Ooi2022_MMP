function h = home(varargin)
%
% On UNIX systems, returns the value of the environment variable $HOME.
%
% JH

    h = fullfile( getenv('HOME'), varargin{:} );
end
