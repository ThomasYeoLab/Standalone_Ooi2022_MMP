classdef kwArgs < handle
% 
% dk.obj.kwArgs()
%
% A simple key/value parser object for function's arguments.
% For more control over inputs, check Matlab's inputParser.
%
% By default, names are NOT case sensitive. Set the option 
%
% Construction:
%   parse( struct )
%   parse( key, value, ... )
%   parse( varargin )
%
%   parse( true, ... ) to set case-sensitive names
%
%   merge()
%   clear()
%   reset_accessed()
%
% Manipulate options:
%   set( name, value )
%   rem( name )
%   get( name, default )
%   pop( name, default )
%   has( name )
%   has_nonempty( name )
%
% Process options:
%   sanitise( name, callback )
%   validate( name, callback )
%   sanitise_opt( name, callback )
%   validate_opt( name, callback )
%
% Check accessed options:
%   access_report()
%
%
% See also: inputParser
%
% JH

    properties
        CaseSensitive;
    end

    properties (SetAccess = private)
        parsed;
        accessed;
    end
    
    methods (Hidden)
        
        function name = field(self,name)
            if ~self.CaseSensitive
                name = lower(name);
            end
        end
    end
    
    methods
        
        % Constructor
        function self = kwArgs(varargin)
            self.clear();
            if nargin > 0
                self.parse(varargin{:});
            end
        end
        
        function self = clear(self)
            self.parsed        = struct();
            self.accessed      = {};
            self.CaseSensitive = false;
        end
        
        function self = copy(self,other)
            self.CaseSensitive = other.CaseSensitive;
            self.parsed        = other.parsed;
        end
        
        % report of which fields were set vs which were accessed 
        function self = reset_accessed(self)
            self.accessed = {};
        end
        function [ok,not_accessed] = access_report(self)
            
            all_fields   = fieldnames(self.parsed);
            not_accessed = setdiff( all_fields, self.accessed );
            ok = isempty(not_accessed);
            
            if nargout == 0
                dk.print( '[dk.obj.kwArgs] Access report:' );
                if isempty(all_fields)
                    dk.print( '\t Nothing has been parsed yet.' );
                elseif isempty(not_accessed)
                    dk.print( '\t All parsed field(s) were accessed.' );
                else
                    dk.print( '\t %d out of %d field(s) in total were accessed so far, here is the list of unaccessed field(s):' );
                    cellfun( @(x) fprintf(['\t\t - ' x '\n']), not_accessed );
                end
            end
            
        end
        
        % convert parsed inputs as a cell of inputs that can typically be passed to a function
        function args = to_cell(self)
            args = dk.struct.to_cell(self.parsed);
        end
        
        function self = parse(self,varargin)
            
            self.parsed = struct();
            self.reset_accessed();
            
            % unwrap inputs
            args = dk.unwrap(varargin{:});
            
            % either a cell of key-values or a structure
            if isempty(args)
                return;
                
            elseif iscell(args)
                n = numel(args); % we know n >= 2
                
                % allow parse( true, varargin ) to set case-sensitive
                if islogical(args{1})
                    self.CaseSensitive = args{1};
                    self.parse( args{2:end} );
                    return;
                end
                
                % edit name case
                if ~self.CaseSensitive
                    args(1:2:end) = dk.mapfun( @lower, args(1:2:end), false );
                end
                
                % not struct(args{:}), to avoid issues with cells and duplicate fields
                for i = 1:2:n
                    self.parsed.(args{i}) = args{i+1};
                end
                
            elseif isstruct(args)
                assert( numel(args) == 1, 'Struct arrays are not accepted.' );
                self.parse( dk.struct.to_cell(args) );
                
            elseif isa(args,'dk.obj.kwArgs')
                self.copy(args);
                
            else
                error('Inputs should be either a cell of key-values or a structure.');
            end
        end
        
        function self = merge(self,varargin)
            if nargin < 2, return; end
            p = self.parsed;
            self.parse(varargin{:});
            self.parsed = dk.struct.merge( p, self.parsed );
        end
        
        % check field existence
        function yes = has(self,name)
            yes = isfield(self.parsed,self.field(name));
        end
        function yes = has_nonempty(self,name)
            name = self.field(name);
            yes  = isfield(self.parsed,name) && ~isempty(self.parsed.(name));
        end
        
        % restrict possible fields
        function restrict(self,names)
            if nargin < 2
                names = self.accessed;
            end
            assert( iscellstr(names), 'Expected cell of option names.' );
            if ~self.CaseSensitive
                names = dk.mapfun( @lower, names, false );
            end
            dk.struct.restrict( self.parsed, names );
        end
        
        % sanitisation methods
        function self = sanitise(self,name,sanitise_fun)
            name = self.field(name);
            self.parsed.(name) = sanitise_fun(self.parsed.(name));
        end
        function self = sanitise_opt(self,name,sanitise_fun)
            if self.has(name)
                self.sanitise(name,sanitise_fun);
            end
        end
        
        % validation methods
        function self = validate(self,name,validate_fun)
            validate_fun( self.parsed.(self.field(name)) );
        end
        function self = validate_opt(self,name,validate_fun)
            if self.has(name)
                self.validate(name,validate_fun);
            end
        end
        
        % get field value or specified default
        function default = get(self,name,default)
            
            name = self.field(name);
            dk.assert( nargin > 2 || isfield(self.parsed,name), ...
                'Required key "%s" not found.', name );
            
            if isfield(self.parsed,name)
                default = self.parsed.(name);
            else
                self.parsed.(name) = default;
            end
            self.accessed{end+1} = name;
        end
        
        % set default explicitly
        function self = default(self,name,value)
            name = self.field(name);
            if ~isfield(self.parsed,name)
                self.parsed.(name) = value;
            end
        end
        
        % like get, but deletes the field if it exists after returning its value
        function default = pop(self,name,default)
            
            name = self.field(name);
            dk.assert( nargin > 2 || isfield(self.parsed,name), ...
                'Required key "%s" not found.', name );
            
            if isfield(self.parsed,name)
                default = self.parsed.(name);
                self.parsed = rmfield(self.parsed,name);
            end
            self.accessed{end+1} = name;
        end
        
        % set field value
        function self = set(self,name,value)
            self.parsed.(self.field(name)) = value;
        end
        
        % remove field
        function self = rem(self,name)
            name = self.field(name);
            if isfield(self.parsed,name)
                self.parsed = rmfield(self.parsed,name);
            end
        end
        
    end
    
end
