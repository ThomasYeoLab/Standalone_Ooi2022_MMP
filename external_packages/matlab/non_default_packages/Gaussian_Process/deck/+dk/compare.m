function c = compare( v1, v2, cmp_shape, fp_thresh )
%
% c = dk.compare( v1, v2, cmp_shape=true, fp_thresh=1e-10 )
%
% Generic comparison function between two values v1 and v2.
% Performs a recursive comparison on cells and structs.
% Floating point comparison is done with absolute threshold fp_thresh.
% Function handle comparison is done based on their string representation.
%
% Any other type/class should implements the operator ==.
%
% JH

    if nargin < 3 || isempty(cmp_shape), cmp_shape=true; end
    if nargin < 4, fp_thresh=1e-10; end
    
    if cmp_shape
        cmp_shape = @(a,b) ndims(a)==ndims(b) && all(size(a) == size(b));
    else
        cmp_shape = @(a,b) true;
    end

    if isstruct(v1)
        
        n = numel(v1);
        f = fieldnames(v1);
        c = isstruct(v2) && (numel(v2) == n);
        c = c && cmp_shape(v1,v2);
        i = 1;
        
        while c && (i <= n)
            for j = 1:numel(f)
                c = c && dk.compare( v1(i).(f{j}), v2(i).(f{j}) );
            end
            i = i+1;
        end
        
    elseif iscell(v1)
        
        n = numel(v1);
        c = iscell(v2) && (numel(v2) == n);
        c = c && cmp_shape(v1,v2);
        i = 1;
        
        while c && (i <= n)
            c = c && dk.compare( v1{i}, v2{i} );
            i = i+1;
        end
        
    elseif ischar(v1)
        c = ischar(v2) && strcmp(v1,v2);
        
    elseif isnumeric(v1)
        %c = isnumeric(v2) && (numel(v1) == numel(v2)) && all( v1(:) == v2(:) );
        c = isnumeric(v2) && cmp_shape(v1,v2) && ...
            ( isempty(v1) || max(abs(v1(:)-v2(:))) < fp_thresh );
    
    elseif islogical(v1)
        c = islogical(v2) && cmp_shape(v1,v2) && ~any(xor(v1,v2));
        
    elseif isa(v1,'function_handle')
        c = isa(v2,'function_handle') && strcmp(func2str(v1), func2str(v2));
        
    elseif isa(v1,'table')
        c = isa(v2,'table') && dk.compare(table2struct(v1), table2struct(v2), [], fp_thresh);
        
    elseif isa(v1,'containers.Map')
        if isa(v2,'containers.Map')
            k1 = v1.keys(); v1 = v1.values();
            k2 = v2.keys(); v2 = v2.values();
            c = dk.compare(k1,k2,[],fp_thresh) && dk.compare(v1,v2,[],fp_thresh);
        else
            c = false;
        end
        
    else
        try
            c = all(v1 == v2);
        catch
            warning( 'Dont know how to compare values of type "%s".', class(v1) );
            c = false;
        end
    end

end
