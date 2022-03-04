function dat = read(filename,varargin)
    dat = dk.json.decode(fileread(filename),varargin{:});
end
