classdef (ConstructOnLoad) EventData < event.EventData
%
% An opaque data wrapper to work with Matlab's event system.
%
% JH
    properties
       data
    end
    methods
        function self = EventData(varargin)
            self.data = dk.c2s(varargin);
        end
    end
end