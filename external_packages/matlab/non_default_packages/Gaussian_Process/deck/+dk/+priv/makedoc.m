function makedoc( indir, outdir, varargin )

    opt = dk.obj.kwArgs(varargin{:});

    % explore
    T = dk.ds.Tree('path',indir);
    next = {folder(indir)};
    
    while ~isempty(next)
        
        cur  = next;
        next = {};
        ncur = numel(cur);
        
        for i = 1:ncur
            
            curi = cur{i};
            
            % list contents
            [sub,cls,fun,scr] = list_folder(curi);
            
            % add submodules for next exploration
            
            
            
        end
        
    end
    
end

function f=folder(base,pfx)
    f.base = base;
    f.pfx = pfx;
    f.full = fullfile(base,pfx);
    f.path = @(varargin) fullfile(f.full,varargin{:});
end

function print(ind,fmt,varargin)
    dk.print( [repmat('\t',1,ind) fmt], varargin{:} );
end

function cname = callname(fpath)
    segments = strtok(fpath,fsep);
    withplus = cellfun(@(s) s(1)=='+',segments);
    
    % first first segment
    first = numel(withplus);
    while (first > 1) && withplus(first-1)
        first = first-1;
    end
    
    cname = segments(first:end);
    cname = [ cellfun(@(s) s(2:end),cname(1:end-1)), cname(end) ];
    cname = strjoin(cname,'.');
end

function [sub,cls,fun,scr] = list_folder(fol,ind)

    sub = dk.fs.lsdir( fol.full, '^\+.*' );
    cls = dk.fs.lsdir( fol.full, '^@.*' );
    fil = dk.fs.lsext( fol.full, '*.m' );

    % find which files are scripts, functions and classes
    type = classifile( fol, fil );
    cls = horzcat( cls, fil(type==2) );
    fun = fil(type==1);
    scr = fil(type==0);
    
end

function type = classifile(fol,fil)

    n = numel(fil);
    type = zeros(1,n);
    
    for i = 1:n
        
        f = fil{i}; %filename
        p = fullfile(fol.full,f); %filepath
        c = callname(p); %callname
        
        if nargin(c) >= 0
            type(i) = 1;
        elseif exist(c,'class')
            type(i) = 2;
        else
            % script, leave 0
        end 
        
    end

end


