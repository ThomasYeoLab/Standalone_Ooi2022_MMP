classdef Template < handle
%
% Python-style string template.
%
% JH

    properties
        text
        strict
    end

    methods

        function self = Template(varargin)
            self.clear();
            if nargin > 0
                self.assign(varargin{:});
            end
        end

        function clear(self)
            self.text = '';
            self.strict = false;
        end

        % Assign text containing placeholders, or load filename containing text.
        function self = assign(self,text,isfilename)

            if nargin < 3, isfilename=false; end
            if isfilename
                self.text = dk.fs.gets(text);
            else
                self.text = text;
            end

        end

        % List all placeholders found in the text.
        % If called without output, the names are displayed instead.
        function v = placeholders(self)

            v = regexp( self.text, '[^$]\$\{[\w\d_-]+\}', 'match' );
            v = unique(dk.mapfun( @(x) x(4:end-1), v, false ));
            if nargout == 0, cellfun(@disp,v); end

        end

        % Substitute placeholders found in the text with input values.
        % Call either with Name/Value pairs, or with a structure.
        %
        % Variable names are case sensitive, and all values must be strings.
        function s = substitute(self,varargin)

            sub = dk.obj.kwArgs();
            sub.CaseSensitive = true;
            sub.parse(varargin{:});
            sub = sub.parsed;

            f = fieldnames(sub);
            n = numel(f);
            s = self.text;

            assert( ~self.strict || isempty(setxor(f,self.placeholders())), ...
                'Missing or unknown field(s) in input, please check variable names.' );

            for i = 1:n
                s = strrep( s, ['${' f{i} '}'], sub.(f{i}) );
            end

        end

    end

end
