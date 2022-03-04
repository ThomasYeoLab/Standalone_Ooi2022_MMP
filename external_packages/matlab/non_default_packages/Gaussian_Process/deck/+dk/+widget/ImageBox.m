classdef ImageBox < handle
%
% A vertical box with a selector (popup menu) on top of an image axes.
%
% JH

    properties (SetAccess = private)
        handles;
        images;
    end
    
    properties (Dependent)
        n_images;
    end
    
    methods
        
        function self = ImageBox(varargin)
            self.clear();
            if nargin > 0
                self.build(varargin{:});
            end
        end
        
        function clear(self)
            self.handles = struct();
            self.images  = [];
        end
       
        % Get number of images.
        function n = get.n_images(self)
            n = numel(self.images);
        end
        
        % Return the index and name of the currently selected image.
        % If the UI is not open, the index is NaN and the name is empty.
        function [idx,name] = current_selection(self)
            
            idx = NaN; name = '';
            
            if self.check_handle('popup')
                idx  = self.handles.popup.Value;
                name = self.handles.popup.String{idx};
            end
        end
        
        % Set the images.
        %
        % Input data should be a struct-array with fields:
        %   img
        %       Image (matrix or cell array).
        %   name
        %       Name of the image as will appear in the popup menu.
        %   opt
        %       Structure of options for ant.img.show.
        % 
        function self = set_images(self,data)
        
            if isnumeric(data)
                data = dk.priv.img2cell(data);
            end
            if iscell(data)
                n = numel(data);
                name = dk.mapfun( @(k) sprintf('Image %d',k), 1:n );
                data = dk.struct.array( 'img', data, 'name', name );
            end
            
            assert( dk.is.struct(data,{'img','name'},false), 'Bad input data.' );
            self.images = dk.struct.set( data, 'opt', struct() ); % will not overwrite
            
            if self.check_handle('popup')
                
                self.handles.popup.String = dk.mapfun( @(x) x.name, self.images );
                self.select_image(1);
                
            end
            
        end
        
        % Set the height of the selector (default 30px).
        function self = set_heights(self,selector)
            
            if nargin < 2, selector = 30; end
            
            if self.check_handle('image')
                self.handles.box.Heights = [selector,-1];
            end
            
        end
        
        % Select image by index and update the popup selector and image axes.
        function self = select_image(self,num)
            
            if self.check_handle('image')
                
                % get corresponding image
                hdl = self.handles.image;
                dat = self.images(num);
                
                % display this image
                set( ancestor(hdl,'figure'), 'currentaxes', hdl );
                ant.img.show( dat.img, dat.opt );
                
                % update the selector
                self.handles.popup.Value = num;
                
            end
            
        end
        
        % Build the image box in the input parent handle.
        % Additional inputs as set as properties of the popup selector.
        function self = build(self,parent,varargin)
            
            % create a vertical box
            self.handles.box = uix.VBox( 'parent', parent, 'spacing', 10, 'padding', 5 );
            
            % build the selector
            if self.n_images == 0
                tstr = {'---'};
            else
                tstr = arrayfun( @(x) x.name, self.images, 'UniformOutput', false );
            end
            
            self.handles.popup = uicontrol( ...
                'parent', self.handles.box, ...
                'style', 'popup', ...
                'string', tstr, ...
                'callback', @self.cb_select ...
            );
        
            % set popup options
            if nargin > 2
                opt  = dk.c2s(varargin{:});
                fopt = fieldnames(opt);
                for i = 1:numel(fopt)
                    f = fopt{i};
                    self.handles.popup.(f) = opt.(f);
                end
            end
        
            % create axes for image
            self.handles.image = axes( 'parent', uicontainer('parent',self.handles.box) );
            self.set_heights();
            
        end
        
    end
    
    methods (Hidden)
        
        function ok = check_handle(self,name)
            ok = isfield( self.handles, name ) && ishandle( self.handles.(name) );
        end
        
        function cb_select(self,hobj,edata)
            
            % retrieve selection from the box
            val = hobj.Value;
            
            % select that image
            self.select_image(val);
            
        end
        
    end
    
end
