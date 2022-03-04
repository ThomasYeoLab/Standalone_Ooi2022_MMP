function obj = get(name,varargin)
%
% obj = dk.logger.get(name,varargin)
%
% Return existing, or create new, instance of dk.logger.Logger.
% If called without name, print a list of existing loggers to the console.
%
% See also: dk.logger.Logger
%
% JH

    persistent loggers;
    if isempty(loggers)
        % either create an empty list of Loggers ...
        loggers = {};
    else
        % ... or filter valid existing ones
        loggers = loggers(cellfun( @isvalid, loggers ));
    end
    
    % get names of existing Loggers
    lnames = dk.mapfun( @(x) x.name, loggers, false );
    
    if nargin == 0
        % no input => show list of all Loggers
        if numel(lnames) > 0
            disp( 'Currently registered loggers are:' );
            disp( strjoin(lnames,newline) );
        else
            disp('There are no loggers yet.');
        end
    else
        assert( ischar(name) && ~isempty(name), 'Invalid name.' );
        [~,k] = ismember( name, lnames );

        if k > 0
            % specified name matches existing logger
            obj = loggers{k};
        else
            % otherwise create a new one
            obj = dk.logger.Logger(name,varargin{:});
            loggers{end+1} = obj;
        end
    end

end

function v = isvalid(x)
    try
        x.name;
        v = true;
    catch
        v = false;
    end
end