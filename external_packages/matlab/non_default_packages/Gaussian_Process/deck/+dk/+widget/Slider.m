classdef Slider < handle
%
% Range slider with editable display (horizontal layout).
%
% JH

    properties
        callback;
    end
    
    properties (SetAccess = private)
        handles;
        range, step;
    end
    
    methods
        
        function self = Slider(varargin)
            self.clear();
            if nargin > 0
                self.build(varargin{:});
            end
        end
        
        function clear(self)
            self.handles  = struct();
            self.range    = [0 1];
            self.step     = [0.01 0.1];
            self.callback = @dk.pass;
        end
        
        % Return the current value of the slider object., or NaN if the UI is not open.
        function val = get_value(self)
        
            val = NaN;
            
            if self.check_handle('slider')
                val = self.handles.slider.Value;
            end
        end
        
        % Set the value of the slider and update the display.
        % If the method is called with value, the value is automatically clamped in the slider's min/max range.
        % If the method is called without value, the textbox is updated to display the current slider value.
        function self = set_value(self,val)
            
            assert( self.check_ui(), 'UI not ready.' );
            
            if nargin > 1
                val = dk.num.clamp( val, [self.handles.slider.Min,self.handles.slider.Max] );
                self.handles.slider.Value = val;
            else
                val = self.get_value();
            end
            
            self.handles.text.String = sprintf('%g',val);
            
        end
        
        % Set the range of the slider.
        % Note: this resets the state of slider to the first value in the range.
        function self = set_range(self,range,step)
            
            % set range
            assert( isnumeric(range) && numel(range)==2, 'Range should be a 1x2 vector.' );
            range = sort(dk.torow(range));
            
            self.range = range;
            width = diff(range);
            assert( width > eps, 'Range must be a non-singleton interval.' );
            
            % set step
            if nargin > 2
                
                if isscalar(step)
                    step(2) = min(width/10, 10*step);
                end
                assert( numel(step)==2 && all(step > 0 & step <= width), 'Bad step.' );
                self.step = sort(dk.torow(step));
                
            else
                self.step = [0.05, 0.1]*width;
            end
            
            % update UI
            self.update_ui();
            
        end
        
        % Set the widths of the slider and the text display.
        % By default, the slider is 3 times larger than the text display.
        function self = set_widths(self,slider,text)
            
            if nargin < 3, text = -1; end
            if nargin < 2, slider = -3; end
            
            if self.check_handle('box')
                self.handles.box.Widths = [slider,text];
            end
            
        end
        
        % Set the height of the slider and text display.
        function self = set_height(self,h)
            
            if self.check_ui()
                self.handles.slider.Position(4) = h;
                self.handles.text.Position(4) = h;
            end
            
        end
        
        % Build the slider into parent handle.
        % If a callback function is specified, it is called at each slider/textbox update with the latest value selected.
        function self = build(self,parent,callback)
            
            % create a horizontal box
            self.handles.box = uix.HBox( 'parent', parent, 'spacing', 10, 'padding', 5 );
            
            % set function callback if any
            if nargin < 3 || isempty(callback), callback = @dk.pass; end
            self.callback = callback;
            
            % create the slider
            self.handles.slider = uicontrol( 'parent', self.handles.box, 'style', 'slider', 'callback', @self.callback_slide );
            
            % create textbox
            self.handles.text = uicontrol( 'parent', self.handles.box, 'style', 'edit', 'callback', @self.callback_text );
        
            % set widths
            self.set_widths();
            self.update_ui();
            
        end
        
    end
    
    methods (Hidden)
        
        function ok = check_handle(self,name)
            ok = isfield( self.handles, name ) && ishandle( self.handles.(name) );
        end
        function ok = check_ui(self)
            ok = self.check_handle('slider') && self.check_handle('text');
        end
        
        function callback_slide(self,hobj,edata)
            
            % update text box
            self.set_value();
            
            % trigger callback
            self.callback(hobj.Value);
            
        end
        
        function callback_text(self,hobj,edata)
            
            val = str2num(hobj.String);
            
            % update slider and text box
            self.set_value(val);
            
            % trigger callback
            self.callback(val);
            
        end
        
        % Update the slider range/step/value and textbox string using object properties.
        function update_ui(self)
            
            if self.check_ui()
                self.handles.slider.Min = self.range(1);
                self.handles.slider.Max = self.range(2);
                self.handles.slider.Value = self.range(1);
                self.handles.slider.SliderStep = self.step / diff(self.range);
                
                self.set_value();
            end
            
        end
        
    end
    
end
