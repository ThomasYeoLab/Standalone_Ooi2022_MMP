classdef FrameStack < handle
%
% Vertical box with a slider + play button on top of image axes.
%
% Example usage:
%
%   frames = rand(100,100,35); 
%   fstack = dk.widget.FrameStack( figure ).set_frames(frames).select_frame(13);
%   fstack.framerate = 10; % in Hz
%
% JH

    properties
        framerate;
        options;
    end

    properties (SetAccess = private)
        handles;
        frames;
        playing;
    end
    
    properties (Dependent)
        n_frames;
    end
    
    methods
        
        function self = FrameStack(varargin)
            self.clear();
            if nargin > 0
                self.build(varargin{:});
            end
        end
        
        function clear(self)
            self.handles   = struct();
            self.frames    = {};
            self.framerate = 1;
            self.options   = struct();
            self.playing   = false;
        end
                
        % Get current number of frames
        function n = get.n_frames(self)
            if isempty(self.frames)
                n = 0; 
            else
                n = numel(self.frames);
            end
        end
        
        % Return index of currently selected frame.
        % If the UI is not open, the index is NaN.
        function num = current_frame(self)
            
            num = NaN;
            if self.check_ui()
                num = self.handles.slider.Value;
            end
            
        end
        
        % Set the frames (3d array).
        % The framerate should be specified in Hz and corresponds to the speed at which frames will be played.
        % The options should be a structure of display options used by ant.img.show.
        function self = set_frames(self,frames,framerate,options)
        
            if nargin < 4, options = struct(); end
            if nargin < 3, framerate = 1; end
            
            assert( isnumeric(framerate) && isscalar(framerate) && framerate > eps, 'Framerate should be a positive scalar.' );
            assert( isstruct(options), 'Options should be a structure.' );
            
            self.frames    = dk.priv.img2cell(frames);
            self.framerate = framerate;
            self.options   = options;
            
            self.update_ui();
            self.select_frame(1);
            
        end
        
        % Set the height of the controls (default 30px).
        function self = set_heights(self,controls)
            
            if nargin < 2, controls = 30; end
            
            if self.check_ui
                self.handles.box.Heights = [controls,-1];
            end
            
        end
        
        % Select frame by number and update slider and display.
        % If input 'fast' is true, the new frame is displayed by updating the existing image axes CData.
        % If it is false, then playing is interrupted and ant.img.show is called with the display options.
        function self = select_frame(self,num,fast)
            
            if nargin < 3, fast = false; end
            if self.n_frames > 0 && self.check_ui
                
                num = round(num);
                
                if self.check_handle('image') && fast 
                    
                    % replace image data in existing image handle
                    self.handles.image.CData = self.frames{num}; 
                    
                else
                    
                    % interrupt playing
                    self.cb_stop();

                    % display this image
                    dk.fig.select( self.handles.axes );
                    self.handles.image = ant.img.show( self.frames{num}, self.options );
                    
                end
                
                % update the slider
                self.handles.slider.Value = num;
                self.handles.text.String  = num2str(num);
                
            end
            
        end
        
        % Build frame-stack in input parent handle.
        function self = build(self,parent)
        
            % create a vertical box
            self.handles.box = uix.VBox( 'parent', parent, 'spacing', 10, 'padding', 5 );
            
            % build controls
            self.handles.controls = uix.HBox( 'parent', self.handles.box, 'spacing', 10 );
            
            self.handles.button = uicontrol( ...
                'parent', self.handles.controls, ...
                'string', 'Play', 'callback', @self.cb_button );
            
            self.handles.slider = uicontrol( ...
                'parent', self.handles.controls, ...
                'style', 'slider', 'callback', @self.cb_slider ...
            );
        
            self.handles.text = uicontrol( ...
                'parent', self.handles.controls, ...
                'style', 'edit', 'callback', @self.cb_text ...
            );
        
            self.handles.controls.Widths = [ 40 -1 30 ];
            
            % create axes for image
            self.handles.axes = axes( 'parent', uicontainer('parent',self.handles.box) );
            
            self.set_heights();
            self.update_ui();
            
        end
        
    end
    
    methods (Hidden)
        
        function ok = check_handle(self,name)
            ok = isfield( self.handles, name ) && ishandle( self.handles.(name) );
        end
        
        function ok = check_ui(self)
            ok = self.check_handle('axes') && self.check_handle('slider') && self.check_handle('button');
        end
        
        % Update slider min/max/step/value and text display based on current properties
        function update_ui(self)
            
            if self.check_ui
            
                nf = max(1,self.n_frames);
                
                self.handles.slider.Min = 1;
                self.handles.slider.Max = nf;
                self.handles.slider.Value = 1;
                self.handles.slider.SliderStep = (nf > 1) * [ 1, min(10,ceil(nf/3)) ]/nf;
                
                self.handles.text.String = '1';
                
            end
            
        end
        
        % Select image based on slider value
        function cb_slider(self,hobj,varargin)
            self.select_frame( hobj.Value );
        end
        
        % Select image based on textbox value
        function cb_text(self,hobj,varargin)
            num = dk.num.clamp( round(str2num( hobj.String )), [1,self.n_frames] );
            self.select_frame(num);
        end
        
        % Trigger start/stop frame playing.
        function cb_button(self,varargin)
            if self.playing
                self.cb_stop(); 
            else
                self.cb_start();
            end
        end
        
        function cb_stop(self,varargin)
            
            if self.check_ui
                self.playing = false;
                self.handles.button.String = 'Play';
            end
            
        end
        
        function cb_start(self,varargin)
            
            fr = self.framerate;
            assert( isnumeric(fr) && isscalar(fr) && fr > eps, 'Framerate should be a positive scalar.' );
            if self.check_ui
                
                self.handles.button.String = 'Stop';
                self.playing = true;
                
                n = self.current_frame()-1;
                while self.n_frames > 0 && self.playing

                    n = mod(n+1,self.n_frames);
                    self.select_frame( n+1, true );
                    drawnow; pause( 1/fr );

                end
                
            end
            
        end
        
    end
    
end
