function disp_tree(T,fh)
%
% dk.priv.disp_tree(T, fh=1)
%
% Display a tree in the console, or write to a file.
%
% NOTICE
% If you experience ENCODING ISSUES in the console (weird symbols), type:
%   slCharacterEncoding('UTF-8');
%
% OPTIONS:
%   fh  File-handle for printing
%
% JH

    if nargin < 2, fh=1; end

    [~,remap] = T.indices();
    obj.remap = remap;
    obj.depth = T.all_depths();
    obj.children = T.all_children();
    obj.print = @(fmt,varargin) fprintf( fh, [fmt '\n'], varargin{:} );

    recurse( obj, 1, '', false, true );

end

function recurse(obj,id,padding,isLast,isFirst)

    pad = struct( 'leg', '├── ', 'end', '└── ', 'tab', '   ' );
    tmp = padding(1:end-1);
    if isFirst
        leg = '';
    elseif isLast
        leg = pad.end;
    else
        leg = pad.leg;
    end

    k = obj.remap(id);
    depth = obj.depth(k);
    children = obj.children{k};
    nchildren = numel(children);

    obj.print( '%s%d :%d +%d', [tmp leg], id, depth, nchildren );

    if ~isFirst
        padding = [padding pad.tab];
    end
    for c = 1:nchildren
        isLast = c == nchildren;
        if isLast
            recurse( obj, children(c), [padding ' '], isLast, false );
        else
            recurse( obj, children(c), [padding '|'], isLast, false );
        end
    end

end
