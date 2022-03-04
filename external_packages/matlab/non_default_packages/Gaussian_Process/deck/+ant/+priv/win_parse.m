function [len,step,burn] = win_parse( varargin )
%
% [len,step,burn] = win_parse( len, step=len/3, burn=0 )
% [len,step,burn] = win_parse( [len,step,burn] )
% [len,step,burn] = win_parse( {len,step,burn} )
% [len,step,burn] = win_parse( struct )
%
%
% Parse sliding-window parameters.
%
% JH

    if nargin == 1 % either a struct, or a cell, or an array, or a scalar or a kwArgs object
        
        arg = varargin{1};
        
        % Cell: expected input is {len [,step=len/3 [,burn=0]] }
        if iscell(arg)
            [len,step,burn] = ant.priv.win_parse(arg{:});
        
        % Struct: expected fields {'len' [,'step'] [,'burn'] }
        elseif isstruct(arg)
            
            len  = arg.len;
            step = dk.struct.get( arg, 'step', len/3 );
            burn = dk.struct.get( arg, 'burn', 0 );
            
        % kwArgs object: expected fields are either
        %   - 'swin' with any valid input to this function
        %   - 'len' [,'step'] [,'burn']
        elseif isa( arg, 'dk.obj.kwArgs' )
            
            if arg.has('swin')
                [len,step,burn] = ant.priv.win_parse(arg.get('swin'));
            else
                len  = arg.get('len');
                step = arg.get('step', len/3);
                burn = arg.get('burn', 0);
            end
        
        % Array: [len, step, burn]
        elseif isrow(arg) && ~isscalar(arg)
            
            len  = arg(1);
            step = arg(2);
            burn = arg(3);
        
        % Scalar: expects the value of len
        else
            
            len  = arg;
            step = len/3;
            burn = 0;
            
        end
        
    % Key-value pairs with fields 'len', 'step' and 'burn'
    elseif nargin >= 2 && ischar(varargin{1})
        
        [len,step,burn] = ant.priv.win_parse(struct(varargin{:}));
        
    % Unnamed scalar inputs
    elseif nargin > 1
        
        len  = varargin{1};
        step = varargin{2};
        if nargin > 2, burn=varargin{3}; else, burn = 0; end
        
    end

end
