function notify( obj, name, varargin )
%
% dk.notify( obj, name, varargin )
%
% Notification wrapper to work with Matlab's event system.
%
% JH

    notify( obj, name, dk.priv.EventData(varargin{:}) );
end