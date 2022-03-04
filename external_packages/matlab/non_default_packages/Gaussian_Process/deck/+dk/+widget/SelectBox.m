classdef SelectBox < handle
%
% A horizontal box with a selector (popup menu) on the left, and a confirm button on the right.
%
% JH

    properties
        callback;
    end
    
    properties (SetAccess=private)
        handles;
        choices;
    end
    
    properties (Dependent)
        n_choices;
    end
    
    methods
        
        function self = SelectBox(varargin)
            self.clear();
            if nargin > 0
                self.build(varargin{:});
            end
        end
        
        function clear(self)
            self.handles  = struct();
            self.choices  = {'--'};
            self.callback = @dk.pass;
        end
        
        % Current number of choices
        function n = get.n_choices(self)
            n = numel(self.choices);
        end
        
        % Return the index and string of the current selection.
        % If the UI is not open, the index is 0 and the string is empty.
        function [idx,str] = current_selection(self)
            
            idx = 0; str = '';
            
            if self.check_ui()
                idx = self.handles.popup.Value;
                str = self.handles.popup.String{idx};
            end
        end
        function self = select(self,n)
            if self.check_ui()
                assert( n >= 1 && n <= self.n_choices, 'Bad choice index.' );
                self.handles.popup.Value = n;
                s = self.handles.popup.String{n};
            end
        end
        
        % Update the selection with the input cell-array of strings.
        function self = set_choices(self,choices)
            
            assert( iscellstr(choices), 'Choices should be a cell.' );
            self.choices = choices;
            
            if self.check_ui()
                self.handles.popup.String = choices;
                self.handles.popup.Value  = 1;
            end
            
        end
        
        % Set the widths of the popup and button.
        % By default, the popup is 3 times larger than the button.
        function self = set_widths(self,selector,button)
            
            if nargin < 3, button = -1; end
            if nargin < 2, selector = -3; end
            
            if self.check_ui()
                self.handles.box.Widths = [selector,button];
            end
            
        end
        
        % Set the height of the popup and button.
        function self = set_height(self,h)
            
            if self.check_ui()
                self.handles.popup.Position(4) = h;
                self.handles.button.Position(4) = h;
            end
            
        end
        
        % Build the select-box in input parent handle.
        % If a callback is specified, then it is called with the index and name of the selected option.
        % The remaining inputs are assigned as properties of the popup handle.
        function self = build(self,parent,callback,varargin)
            
            % create a horizontal box
            self.handles.box = uix.HBox( 'parent', parent, 'spacing', 10, 'padding', 5 );
            
            % create the selector
            self.handles.popup = uicontrol( ...
                'parent', self.handles.box, ...
                'style', 'popup', ...
                'string', self.choices ...
            );
            
            % set popup options
            if nargin > 3
                opt  = dk.c2s(varargin{:});
                fopt = fieldnames(opt);
                for i = 1:numel(fopt)
                    f = fopt{i};
                    self.handles.popup.(f) = opt.(f);
                end
            end
            
            % set callback
            if nargin < 3 || isempty(callback), callback = @dk.pass; end
            self.callback = callback;
            
            % create selection button
            self.handles.button = uicontrol( ...
                'parent', self.handles.box, ...
                'string', 'Select', ...
                'callback', @self.cb_select ...
            );
        
            % set widths
            self.set_widths();
            
        end
        
    end
    
    methods (Hidden)
        
        function ok = check_handle(self,name)
            ok = isfield( self.handles, name ) && ishandle( self.handles.(name) );
        end
        
        function ok = check_ui(self)
            ok = self.check_handle('popup') && self.check_handle('button');
        end
        
        function cb_select(self,varargin)
            [idx,str] = self.current_selection();
            self.callback( idx, str );
        end
        
    end
    
end
