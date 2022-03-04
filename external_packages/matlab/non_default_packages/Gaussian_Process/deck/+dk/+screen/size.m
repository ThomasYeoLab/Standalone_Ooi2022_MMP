function s = size( varargin )
% 
% Return the size of all screens in pixels.
%
% JH

    s = dk.screen.info(varargin{:});
    s = vertcat( s.size );
    
end
