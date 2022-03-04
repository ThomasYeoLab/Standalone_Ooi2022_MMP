function h = height(varargin)
% 
% Return the height of the screen in pixels.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    h = dk.screen.size(varargin{:});
    h = h(:,1);
    
end
