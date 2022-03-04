function d = path(varargin)
    d = fileparts(mfilename('fullpath'));
    d = fullfile(d,varargin{:});
end
