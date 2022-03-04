function c = centre(varargin)
%
% Return pixel coordinates of center of all screens.
%
% JH

    c = dk.screen.info(varargin{:});
    c = vertcat( c.centre );

end