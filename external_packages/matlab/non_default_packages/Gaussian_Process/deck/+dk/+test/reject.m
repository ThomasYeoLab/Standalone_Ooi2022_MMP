function reject( condition, success, varargin )

    if ~any(logical(condition))
        dk.print(success);
    else
        error( varargin{:} );
    end

end
