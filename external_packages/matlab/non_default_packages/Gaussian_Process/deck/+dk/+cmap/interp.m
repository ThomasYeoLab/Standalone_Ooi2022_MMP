function col = interp( cmap, val, range, method )
%
% col = dk.cmap.interp( cmap, val, range=[min(val),max(val)], method=linear );
%
% Interpolate color for each value in val according to specified range using colormap cmap.
% By default, the range is set to the extremal values in val, and the interpolation is linear.
% The colormap input should be a nx3 array or RGB colors.
%
% JH

    if nargin < 4, method='linear'; end
    
    assert( ismatrix(cmap) && isnumeric(cmap) && size(cmap,2)==3, 'First input (cmap) should be a nx3 matrix.' );
    assert( isnumeric(val), 'Second input (value) should be numeric.' );
    val = val(:);
    
    if nargin < 3 || isempty(range), range=[min(val),max(val)]; end
    assert( isnumeric(range) && numel(range)==2, 'Range should be a 1x2 vector.' );
    if ~all( val>=range(1) & val<=range(2) )
        warning( 'Values outside specified range will be clamped.' );
        val = dk.num.clamp( val, range );
    end
    
    col = linspace( 0, 1, size(cmap,1) );
    val = (val - range(1)) / diff(range);
    col = interp1( col(:), cmap, val, method );

end
