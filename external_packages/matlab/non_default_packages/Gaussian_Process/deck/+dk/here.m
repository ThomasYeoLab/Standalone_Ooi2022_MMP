function f = here(varargin)
%
% f = here(varargin)
%
% Uses dbstack to determine the absolute path to the file calling this function.
% Additional inputs are concatenated to that path using fullfile.
%
% JH

    f = dbstack('-completenames');
    f = fullfile( fileparts(f(2).file), varargin{:} );
end