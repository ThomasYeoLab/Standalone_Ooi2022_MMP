classdef PropertyEditor < handle
%
% Property editor with pre-formated fields in a uitable.
%
% Example usage:
%
% editor = dk.widget.PropertyEditor() ...
%     .set_field_numeric_vector ('a') ...
%     .set_field_logical        ('b') ...
%     .set_field_string         ('c') ...
%     .set_field_numeric        ('d') ...
% ;
% 
% param = struct( 'a', [1 2 3], 'b', 0, 'c', 'Hey', 'd', pi );
% ufunc = @(p) disp(p);
% 
% editor.build( ...
%     uipanel( 'parent', figure(), 'title', 'Settings' ), ...
%     param, ufunc ...
% );
%
%
% JH

    properties
        format;
    end
    properties (SetAccess = private)
        handles;
    end
    
    
    methods
        
        function self = PropertyEditor( format, varargin )
            self.clear();
            if nargin > 0
                self.format = format;
            end
            if nargin > 2
                self.open(varargin{:});
            end
        end
        
        function clear(self)
            self.format  = struct();
            self.handles = struct();
        end
        
        % check whether the table is displayed
        function yes = is_open(self)
            yes = self.check_handle('table');
        end
        
        % manually trigger user-specified callback function
        function self = apply(self)
            self.handles.callback( self.get_data() );
        end
        
        % get the names of formatted fields
        function [f,n] = fieldnames(self)
            f = fieldnames(self.format);
            n = numel(f);
        end
        
        % set/get uitable property
        function self = set_prop(self,varargin)
            set( self.handles.table, varargin{:} );
        end
        function x = get_prop(self,varargin)
            x = get( self.handles.table, varargin{:} );
        end
        
        % set/get data
        function self = set_data(self,data)
            self.handles.table.Data = self.data_export(data);
        end
        function data = get_data(self)
            data = self.data_import( self.handles.table.Data );
        end
        
    end
    
    
    %------------------------
    % define formatted fields
    %------------------------
    methods
        
        function self = rem_field(self,field)
            self.format = rmfield( self.format, field );
        end
        
        function self = set_field(self,field,label,extract,format)
            self.format.(field) = struct( 'label', label, 'extract', extract, 'format', format );
        end
        
        function self = set_field_numeric(self,field,label)
            if nargin<3, label=field; end
            self.set_field( field, label, @str2num, @(x) sprintf('%g',x) );
        end
        
        function self = set_field_logical(self,field,label)
            if nargin<3, label=field; end
            names = {'false','true'};
            self.set_field( field, label, @(x) strcmpi(x,'true'), @(x) sprintf('%s',names{1+x}) );
        end
        
        function self = set_field_numeric_vector(self,field,label)
            if nargin<3, label=field; end
            function s = format_numeric_vector(x)
                if isempty(x)
                    s = '[]';
                else
                    s = ['[ ' sprintf('%g',x(1)) sprintf(', %g',x(2:end)) ' ]'];
                end
            end
            self.set_field( field, label, @str2num, @format_numeric_vector );
        end
        
        function self = set_field_string(self,field,label)
            if nargin<3, label=field; end
            self.set_field( field, label, @(x) x, @(x) x );
        end
        
    end
    
    
    %-----------
    % ui methods
    %-----------
    methods
        
        % create a new figure and build the property editor in it
        function fig = open(self,data,callback,title)
            
            % create figure
            if nargin < 4, title='Property Editor'; end
            fig = figure( 'name', title );
            
            % build editor within the new figure
            self.build( fig, data, callback );
            
        end
        
        % build the property editor in the parent's handle
        function self = build(self,parent,data,callback)
            
            self.handles.callback = callback;
            self.handles.parent   = parent;
            
            % create VBox
            h_vbox = uix.VBox( 'parent', self.handles.parent, 'spacing', 10 );
            
            % table
            self.handles.table = uitable( 'parent', h_vbox, ...
                'Data',              self.data_export(data), ...
                'ColumnFormat',      ({'char','char'}), ...
                'ColumnEditable',    [false true], ...
                'CellEditCallback',  @self.callback_edit ...
            );
        
            % buttons
            self.handles.buttons = uix.HBox( 'parent', h_vbox, 'spacing', 10 );
            
            uicontrol( 'parent', self.handles.buttons, ...
                'string', 'Apply', 'callback', @self.callback_apply );
            
            % set dimensions
            h_vbox.Heights = [-1 40];
            
        end
        
    end
    
    
    %-------------
    % hidden stuff
    %-------------
    methods (Hidden)
        
        % formatted structure to data cell
        function Data = data_export(self,data)
            
            % get all field names
            [fields,nf] = self.fieldnames();
            
            % create data cell for uitable
            Data = cell( nf, 2 );
            for i = 1:nf
                
                name = fields{i};
                F    = self.format.(name);
                
                Data{i,1} = F.label;
                Data{i,2} = F.format( data.(name) );
            end
            
        end
        
        % data cell to formatted structure
        function data = data_import(self,Data)
            
            % get all field names
            [fields,nf] = self.fieldnames();
            
            % create data struct from uitable
            for i = 1:nf
                
                name = fields{i};
                F    = self.format.(name);
                
                data.(name) = F.extract( Data{i,2} );
            end
            
        end
        
        % check that handle 'name' exists and is active
        function ok = check_handle(self,name)
            ok = isfield( self.handles, name ) && ishandle( self.handles.(name) );
        end
        
        % internal callback every time a cell is edited
        function callback_edit(self,hobj,cdata)
            
            fields = self.fieldnames();
            
            % edit cell
            val = cdata.EditData;
            r   = cdata.Indices(1);
            c   = cdata.Indices(2);
            F   = self.format.(fields{r});
            
            % process value
            hobj.Data{r,c} = F.format(F.extract(val));
            
        end
        
        % invoke the user-specified callback when the button 'Apply' is pushed
        function callback_apply(self,varargin)
            self.apply();
        end
        
    end
    
end
