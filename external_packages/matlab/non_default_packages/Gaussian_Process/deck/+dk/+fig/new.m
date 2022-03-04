function f = new( name, figsize, screen, varargin )
%
% f = new( name, figsize, screen, varargin )
%
%     name : name of the new figure
%  figsize : size of the figure in pixels or normalised units
%   screen : screen in which the figure should be moved to
% varargin : additional arguments forwarded to Figure
%
%        f : figure handle
%
% JH

    if nargin < 3, screen=[]; end
    if nargin < 2, figsize=[]; end
    if nargin < 1, name=''; end
    
    assert( ischar(name) && isnumeric(figsize) && isnumeric(screen), 'Bad inputs.' );
    
    if isempty(name)
        f = figure( varargin{:} );
    else
        f = figure( 'Name', name, varargin{:} );
    end
    
    if ~isempty(screen)
        dk.fig.movetoscreen(f,screen);
    end
    if ~isempty(figsize)
        dk.fig.resize(f,figsize);
    end

end