function varargout = deal(varargin)
%
% Deal function that behaves well with arrays and cells.
%
% Example:
%   
%   x = dk.struct.repeat( {'a','b'}, 1, 3 );
%   [x([1,3]).a] = dk.deal( 0 );            [x(1).a, x(3).a]
%   [x([1,3]).a] = dk.deal([1,2]);          [x(1).a, x(3).a]
%   [x([1,3]).a] = dk.deal({NaN, 'Hey'});   {x(1).a, x(3).a}
%
% JH

    if nargout == nargin
        varargout = varargin;
    else
        assert( nargin == 1, 'Input/output size mismatch.' );
        arg = varargin{1};
        
        if iscell(arg)
            assert( numel(arg) == nargout, 'Cell-size does not match output-size.' );
            varargout = arg;
        elseif isscalar(arg) || ischar(arg)
            varargout = cell(1,nargout);
            [varargout{:}] = deal(arg);
        else
            assert( numel(arg) == nargout, 'Input-size does not match output-size.' );
            varargout = num2cell(arg);
        end
    end

end