function L = light( varargin )
%
% L = dk.ui.light( L1, L2, ... )
%
% Remove all lights in current axes, and set specified lights one by one instead.
%
%
% INPUTS
% ------
%
% String input:
%   headlight
%        left
%       right
%
% Vector input:
%   1x2 vector [az,el]
%
% Cell input:
%   { angle, type }
%
%
% EXAMPLE
% -------
%
%   dk.ui.light( 'left', {[0,90],'infinite'} );
%
%
% See also: camlight
%
% JH

    % delete current lights
    delete(findobj( gca, 'type', 'light' ));

    % create new lights
    L = gobjects(1,nargin);
    for i = 1:nargin
        
        arg = dk.wrap(varargin{i});
        if isnumeric(arg{1})
            arg  = horzcat( num2cell(arg{1}), arg(2:end) );
        end
        L(i) = camlight(arg{:});
        
    end

end
