function p = jmx_path(varargin)
    p = fileparts(mfilename('fullpath'));
    p = fullfile(p, varargin{:});
end