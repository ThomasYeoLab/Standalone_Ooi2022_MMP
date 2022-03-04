function txt = encode( dat, varargin )

    fmt = dk.json.Format(varargin{:});
    txt = write_value(dat,fmt);

end

function s=write_value(x,w,flag)

    % cell parent flag
    if nargin < 3, flag=false; end

    [t,d] = dk.json.typeid(x);
    switch d
        case 0 % n-d array
            s=write_array(x,w,t);
            
        case 1 % column
            if w.col2row
                s=write_row(x',w,t);
            else
                s=write_array(x,w,t);
            end
            
        case 2 % row
            s=write_row(x,w,t);
            
        case 3 % scalar
            s=write_scalar(x,w,t);
            if flag && (t==1 || t==2)
                s=['[' s ']']; 
            end
            
        case 4 % empty
            s=write_empty(x,w,t); 
            
        otherwise
            error('Unknown shape specifier #%d.',d);
    end
end

function s=write_struct(x,w,p)

    % field prefix
    if nargin < 3, p=''; end
    assert( isstruct(x) && isscalar(x) );

    F = fieldnames(x);
    n = numel(F);
    s = cell(1,n);
    
    if n==0, s='{}'; return; end
    
    w.tab();
    for i = 1:n
        f    = F{i};
        s{i} = [w.ind w.enc.char([p f]) ':' w.sp write_value(x.(f),w)];
    end
    w.untab();
    
    s = ['{' w.nl strjoin(s,[',' w.nl]) w.nl w.ind '}'];

end

function s=write_cell(x,w,flag)

    % struct-array flag
    if nargin < 3, flag=false; end
    assert( iscell(x) || isstruct(x) );
    
    n = numel(x);
    s = cell(1,n);
    
    w.tab();
    for i = 1:n
        if flag
            s{i} = [w.ind write_struct(x(i),w)];
        else
            s{i} = [w.ind write_value(x{i},w,true)];
        end
    end
    w.untab();
    
    s = ['[' w.nl strjoin(s,[',' w.nl]) w.nl w.ind ']'];

end

function s=write_array(x,w,t)
    
    % dimensions and row-major strides
    dim = size(x);
    str = [1,cumprod(dim)];
    str = str(1:end-1);
    
    % type name (not used for now)
    name = {'logical','numeric','char','struct','cell'};
    name = name{t};
    
    switch t
        case 5 % special handling for cells (see issue #5)
            x = struct( 'size', dim, 'stride', str, 'value', {reshape(x,1,numel(x))} );
        otherwise
            x = struct( 'size', dim, 'stride', str, 'value', reshape(x,1,numel(x)) );
    end
    s = write_struct(x,w,w.shapepfx);
    
end

function s=write_row(x,w,t)
    switch t
        case 1 % logical
            s=['[' strjoin(w.boolalpha(1+x),',') ']'];
        case 2 % numeric
            s=['[' strjoin(arrayfun( w.enc.numeric, x, 'UniformOutput', false ),',') ']'];
        case 3 % char
            s=w.enc.char(x);
        case 4 % struct
            s=write_cell(x,w,true);
        case 5 % cell
            s=write_cell(x,w);
    end 
end

function s=write_scalar(x,w,t)
    switch t
        case 1 % logical
            s=w.boolalpha{1+x};
        case 2 % numeric
            s=w.enc.numeric(x);
        case 3 % char
            s=w.enc.char(x);
        case 4 % struct
            s=write_struct(x,w);
        case 5 % cell
            s=['[' write_value(x{1},w) ']'];
    end
end

function s=write_empty(x,w,t)
    switch t
        case {1,2} % numeric/logical
            s='[]';
        case 3 % char
            s='""';
        case 4 % struct
            s='{}';
        case 5 % cell
            s=w.emptycell;
    end
end
