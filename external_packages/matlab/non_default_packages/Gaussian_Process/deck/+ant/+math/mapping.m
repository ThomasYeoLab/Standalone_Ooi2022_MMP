function ind = mapping( values, index, method )
%
% ind = ant.math.mapping( values, index, method=linear )
%
% Interpolate index in [0,1] as mapping to range of values using method.
% Essentially, this is doing:
%   controlPoints(index).interpolate(values)
%
% by rescaling values in [0,1], and mapping {0->index(1),1->index(end)}.
%
% Index can be 1D or 2D, but values is vectorised internally.
%
% JH

    if nargin < 3, method = 'linear'; end
    
    values = ant.math.rescale( values(:), [0,1] );
    
    ni  = size( index, 1 );
    ind = linspace( 0, 1, ni )';
    ind = interp1( ind, index, values, method );

end
