function assert( condition, success, varargin )

    if all(logical(condition))
        dk.print(success);
    else
        error( varargin{:} );
    end

end
