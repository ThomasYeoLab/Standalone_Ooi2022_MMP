function t = title( varargin )
%
% t = dk.ui.title( varargin )
%
% Short for: title(sprintf( ... ))
%
% JH

    t = title(sprintf(varargin{:}));
    
end