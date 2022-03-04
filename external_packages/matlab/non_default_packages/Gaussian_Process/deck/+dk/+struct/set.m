function s = set( s, field, value, overwrite )
%
% s = dk.struct.set( s, field, value, overwrite=false )
%
% Set a field value in a structure or struct-array.
% If it is already set, this functionn will _not_ overwrite by default.
%
% JH

    if nargin < 4, overwrite=false; end

    if ~isfield(s,field) || overwrite
        [s.(field)] = dk.deal(value);
    end

end

% OLD VERSION
%
%     n = numel(s);
%     if isscalar(value)
%         for i = 1:n, s(i).(field) = value; end
%     elseif numel(value) == n
%         if iscell(value)
%             for i = 1:n, s(i).(field) = value{i}; end
%         else
%             for i = 1:n, s(i).(field) = value(i); end
%         end
%     else
%         error('Number of value(s) does not match structure size.');
%     end
%