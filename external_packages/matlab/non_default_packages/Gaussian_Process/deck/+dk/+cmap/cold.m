function c = cold( varargin )
%
% c = Cold( n=64, sign=1 )
%
% Film-negative of dk.cmap.hot colormap.
% 
% If sign > 0, the values go from white to cyan through blue.
% If sign < 0, the values go from red to white through yellow.
% If sign == 0:
%   - the positive part is the same as s > 0;
%   - the negative part is the same as s < 0.
%
% JH

    c = 1 - dk.cmap.hot(varargin{:});
    if nargout == 0, dk.cmap.show(c); end

end
