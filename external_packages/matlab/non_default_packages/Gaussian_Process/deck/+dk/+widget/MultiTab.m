classdef MultiTab < handle
    
    properties
        tab;
    end
    
    properties (SetAccess=protected, Hidden)
        handles;
    end
    
    properties (Dependent)
        ntabs, curtab;
    end
    
    methods
        
        function self = MultiTab(varargin)
            self.clear();
            if nargin > 0
                self.build(varargin{:});
            end
        end
        
        function self = clear(self)
            self.close();
            self.clear_tabs();
            self.handles = struct();
        end
        
        % build multiple tabs
        function build(self,varargin)
            
            self.open();
            for i = 1:nargin-1
                
                v = varargin{i};
                if isempty(v)
                    % []: create new tab with no name (default to 'Tab %d')
                    self.add();
                elseif ischar(v)
                    % name: create new tab with given name
                    self.add(v);
                elseif isstruct(v)
                    if isscalar(v)
                        % scalar struct: create new tab with given name and data
                        self.add( v.name, v.data );
                    else
                        % struct-array: repackage as cell, and call build again
                        assert( nargin == 2, 'Struct-array inputs should be the only argument.' );
                        v = dk.mapfun( @(x) x, v, false );
                        self.build(v{:});
                    end
                elseif iscell(v)
                    % {name,data}: create new tab with given name and data
                    assert( numel(v)==2 && ischar(v{1}), 'Cell inputs should be 1x2 {name,value}.' );
                    self.add( v{1}, v{2} );
                else
                    error('Could not process tab %d',i);
                end
                
            end
            
        end
        
        % open the figure
        function open(self)
            
            if self.is_open
                figure(self.handles.fig);
            else
                
                % reset handles
                self.handles.fig  = figure();
                self.handles.tabs = uix.TabPanel( 'parent', self.handles.fig );
                
                % save a reference to this instance in the figure data
                self.handles.fig.UserData.obj = self;

                % resize and set the colormap
                self.tab_width( 130 );
                
                % iterate over tabs if any
                old_tabs = self.tab;
                self.clear_tabs();
                for i = 1:numel(old_tabs)
                    t = old_tabs(i);
                    self.add( t.name, t.data );
                end
                
            end
            
        end
        
        % close the figure
        function close(self)
            if self.is_open
                close( self.handles.fig );
            end
            self.handles.fig = NaN;
        end
        
        % add/remove tabs
        function [n,h] = add(self,name,data)
            
            n = self.ntabs + 1;
            if nargin < 3, data=struct(); end
            if nargin < 2, name=sprintf('Tab %d',n); end
            
            % add tab panel if open
            if self.is_open
                h = uix.VBox( 'parent', self.handles.tabs, 'spacing', 10, 'padding', 5 );
            else
                h = NaN;
            end
            
            % add tab element
            t = struct(...
                'name',   name, ...
                'data',   data, ...
                'handle', h ...
            );
            self.tab(n) = t;
            
            % set tab name
            self.tab_name(n,name);
            
        end
        
        function rem(self,n)
            
            if ischar(n), n = self.find_tab(n); end
            self.check_index(n);
            
            if self.is_open
                delete( self.handles.tabs.Contents(n) );
            end
            self.tab(n) = [];
            
        end
        
        % select specified tab (focus)
        function select(self,n)
            
            assert( self.is_open, 'Figure is not open.' );
            if ischar(n), n = self.find_tab(n); end
            self.check_index(n);
            
            self.handles.tabs.Selection = n;
        end
        
        % export tab as an image
        function F = export(self,fname,varargin)
            
            assert( ischar(fname), 'Input should be a filename.' );
            assert( self.is_open, 'Tabs need to be drawn for export.' );
            F = dk.ui.axes2image( self.tab_handle(self.curtab), fname, varargin{:} );
            
        end
        
    end
    
    % Properties
    methods
        
        function n = get.ntabs(self)
            n = numel(self.tab);
        end
        
        function n = get.curtab(self)
            if self.is_open
                n = self.handles.tabs.Selection;
            else
                n = 0;
            end
        end
        
        % get handle of a tab
        function h = tab_handle(self,n)
            h = self.tab(n).handle;
        end
        
        % get figure handle
        function h = figure(self)
            h = self.handles.fig;
        end
        
        % get/set name of specified tab
        function name = tab_name(self,n,name)
            self.check_index(n);
            if nargin > 2
                if self.is_open
                    self.handles.tabs.TabTitles{n} = name;
                end
                self.tab(n).name = name;
            else
                name = self.tab(n).name;
            end
        end
        
        % get/set data of specified tab
        function data = tab_data(self,n,data)
            self.check_index(n);
            if nargin > 2
                self.tab(n).data = data;
            else
                data = self.tab(n).data;
            end
        end
        
        % get data of all tabs
        function data = all_data(self)
            data = dk.mapfun( @(x) x.data, self.tab, false );
        end
        
        % tab width (all equal)
        function w = tab_width(self,w)
            assert( self.is_open, 'Figure is not open.' );
            if nargin > 1
                self.handles.tabs.TabWidth = w;
            else
                w = self.handles.tabs.TabWidth;
            end
        end
        
        % figure title
        function t = title(self,t)
            assert( self.is_open, 'Figure is not open.' );
            if nargin > 1
                self.handles.fig.Title = t;
            else
                t = self.handles.fig.Title;
            end
        end
        
    end
    
    % Utilities
    methods
        
        % check that handle 'name' exists and is active
        function ok = check_handle(self,name)
            ok = isfield( self.handles, name ) && ishandle( self.handles.(name) );
        end
        
        % check that main figure is open
        function y = is_open(self)
            y = self.check_handle('fig');
        end
        
        % check taht tab index is valid
        function ok = check_index(self,n)
            ok = dk.is.number(n) && (n > 0) && (n <= self.ntabs);
            dk.assert( nargout>0 || ok, 'Invalid tab index.' );
        end
        
        % find tab index from tab title
        function n = find_tab(self,name)
            assert( ischar(name), 'Expected name in input.' );
            [~,n] = ismember( name, self.handles.tabs.TabTitles );
            dk.reject( n == 0, 'Could not find tab named "%s".', name );
        end
        
        % reset tabs
        function clear_tabs(self)
            self.tab = repmat( struct('name',[],'data',[],'handle',[]), 0 );
        end
        
    end
    
end