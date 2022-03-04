function hw = size(varargin)
%
% hw = size( f, inner=false )
%
% Using dk.fig.position internally to return the figure size.
%
    [~,hw] = dk.fig.position(varargin{:});
end