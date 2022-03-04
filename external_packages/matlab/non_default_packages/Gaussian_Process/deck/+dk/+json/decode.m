function dat = decode( txt, varargin )

    car = dk.json.Caret(txt,varargin{:}).skipspaces();
    switch car.cur
        case '['
            dat = convert_array(parse_array(car),car);
        case '{'
            dat = convert_object(parse_object(car),car);
        otherwise
            error('JSON must be enclosed in an array or object.');
    end
    
end

function assertfmt( cdt, varargin )
    if ~all(logical(cdt)), error(varargin{:}); end
end

function parse_char(car,c)
    if car.skipspaces().cur ~= c
        error( 'Expected character %c at position %d, but got %c instead:\n\t%s', ...
            c, car.pos, car.cur, car.fbsub(7) );
    else
        car.inc();
    end
end

function unexpected(car)
    error( 'Unexpected character %c at position %d:\n\t%s', ...
        car.cur, car.pos, car.fbsub(7) );
end

function c = escaped_char(c)
    switch c
        case {'a','b','f','n','r','t','v'}
            c = sprintf(['\' c]);
        case 'u'
            error('Unicode characters not supported.');
    end
end
    
function val = parse_value(car)
    switch lower(car.skipspaces().cur)
        case '"'
            val = parse_string(car);
        case '['
            val = parse_array(car);
        case '{'
            val = parse_object(car);
        case {'-','0','1','2','3','4','5','6','7','8','9'}
            val = parse_number(car);
        case 't'
            if car.rem >= 3 && strcmpi(car.sub(4),'true')
                val = true;
                car.inc(4);
            end
        case 'f'
            if car.rem >= 4 && strcmpi(car.sub(5),'false')
                val = false;
                car.inc(5);
            end
        case 'n'
            if car.rem >= 3 && strcmpi(car.sub(4), 'null')
                val = [];
                car.inc(4);
            end
    end
end

function str = parse_string(car)
    parse_char(car,'"');
    str = repmat(' ',1,255);
    esc = false;
    
    b = car.pos;
    e = b;
    n = 0;
    
    while e <= car.len
        c = car.str(e);
        switch c
            case '\'
                esc=true;
            case '"'
                if ~esc
                    str = str(1:n); car.inc(e-b+1);
                    return;
                else
                    esc=false; n=n+1;
                    str(n) = '"';
                end
            otherwise
                n = n+1;
                if esc
                    esc = false;
                    str(n) = escaped_char(c);
                else
                    str(n) = c;
                end
        end
        e = e+1;
    end
    error('Reached end of text parsing string.');
end

function num = parse_number(car)
    num = '^\s*-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+\-]?\d+)?';
    len = regexp( car.skipspaces().sub(63), num, 'end' );
    num = str2double(car.sub(len));
    car.inc(len);
end

function obj = parse_object(car)
    parse_char(car,'{');
    obj = dk.json.Object();
    com = false;
    
    while ~car.eos
        switch car.skipspaces().cur
            case '}'
                car.inc(); break;
            case '"'
                assertfmt(~com,'Missing comma before new field at position %d:\n\t%s', ...
                    car.pos, car.fbsub(7) );
                
                field = parse_string(car);
                parse_char(car,':');
                value = parse_value(car);
                obj.add_field( field, value );
                com = true;
            case ','
                assertfmt(com,'Unexpected comma at position %d:\n\t%s',car.pos,car.fbsub(7));
                com=false; car.inc();
            otherwise
                unexpected();
        end
    end
end

function arr = parse_array(car)
    parse_char(car,'[');
    arr = dk.json.Array();
    com = false;
    
    while ~car.eos
        switch car.skipspaces().cur
            case ']'
                car.inc(); break;
            case ','
                assertfmt(com,'Unexpected comma at position %d:\n\t%s',car.pos,car.fbsub(7));
                com=false; car.inc();
            otherwise
                assertfmt(~com,'Missing comma before new item at position %d:\n\t%s', ...
                    car.pos, car.fbsub(7) );
                arr.append(parse_value(car)); com=true;
        end
    end
end

function out = convert_object(obj,car)

    out = struct();
    val = convert_cell(obj.values,car);
    len = numel(val);
    
    % empty object become empty struct
    if len==0, return; end
    
    % fields corresponding to shape arrays
    shapefields = cellfun( @(x)[car.shapepfx x], {'size','stride','value'}, 'UniformOutput', false );
    
    % check if all fields have suitable names for Matlab
    valid_name = @(s) ~isempty(regexp(s,'^[a-zA-Z][a-zA-Z0-9_]*$','once'));
    if all(cellfun( valid_name, obj.fields ))
        
        out = struct();
        for i = 1:len
            out.(obj.fields{i}) = val{i};
        end
        
    % check if this is a shape array
    elseif isempty(setdiff( obj.fields, shapefields ))
        
        [~,idx] = ismember( shapefields, obj.fields );
        out = reshape( val{idx(3)}, val{idx(1)} );
        
    % otherwise, convert it to a struct(fields,values)
    else
        
        warning([ 'One or several fieldname(s) are not suitable for Matlab structures, ' ...
            'returning separate cells of fields and values in output structure.' ]);
        out.fields = obj.fields;
        out.values = val;
        
    end
end

function out = convert_array(arr,car)

    % systematically convert to a cell
    [out,type,contains_array] = convert_cell(arr.items,car);
    
    % if any inner-cell, we can't reduce further
    if contains_array || any(floor(type)==5)
        return;
    
    % if all numeric/logical scalars, then it's a vector
    elseif all(type==1.3) || all(type==2.3)
        out = [out{:}];
    
    % if all structures, try to concatenate them
    elseif all(type==4.3) && ~car.structcell
        
        try 
            arr = [out{:}]; % this will fail if structs cant be concatenated
            out = arr; % only assign output once previous statement is through
        catch
            % leave it 
        end
        
    end
    
end

function [out,type,contains_array] = convert_cell(out,car)
    
    % detect type for each elem
    type = cellfun( @dk.json.typeid, out );
    contains_array = any(type == 10);
    if isempty(out), return; end
    
    % convert nested JSON objects if any
    function convert_nested(mask,fun)
        k = find(mask);
        n = numel(k);
        for i = 1:n
            out{k(i)}  = fun(out{k(i)},car);
            type(k(i)) = dk.json.typeid(out{k(i)});
        end
    end
    convert_nested( type==10, @convert_array );
    convert_nested( type==11, @convert_object );
    assert( all(type < 10), 'This is a bug.' );
    
    % if mixture of numbers and small strings, the strings might be Inf/NaN
    small_str  = cellfun( @(x) ischar(x) & numel(x)<7, out );
    infnan_str = { '_inf_', '-_inf_', '_nan_' };
    infnan_num = { inf, -inf, nan };
    
    if any(small_str) && all( type==2.3 | small_str ) 
        
        lower_string = cellfun( @lower, out(small_str), 'UniformOutput', false );
        [found,idx]  = ismember( lower_string, infnan_str );
        if all(found)
            out(small_str)  = infnan_num(idx); 
            type(small_str) = 2.3;
        end
        
    end

end
