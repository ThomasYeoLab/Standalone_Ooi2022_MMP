function txt = write(filename,dat,varargin)
    txt = dk.json.encode(dat,varargin{:});
    f = fopen(filename,'w'); fwrite(f,txt); fclose(f);
end
