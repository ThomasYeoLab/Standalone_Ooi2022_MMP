function a = merge( varargin )
%
% a = dk.struct.merge( s1, s2, ..., sN, recursive=false )
%
% Example:
%   a.foo = struct('a',42); b.bar = 'hello'; c.foo = struct('c',5);
%   nonrecursive = dk.struct.merge( a, b, c ); nonrecursive.foo
%   recursive = dk.struct.merge( a, b, c, true ); recursive.foo
%
% JH

    assert( nargin >= 2, 'At least two inputs required.' );
    if islogical(varargin{nargin})
        assert( nargin > 2, 'At least two input structures required.' );
        recursive = varargin{nargin};
        to_merge  = varargin(1:end-1);
    else
        recursive = false;
        to_merge  = varargin;
    end
    nmerge = numel(to_merge);

    assert( all(cellfun(@isstruct,to_merge)), 'Expected structures in input.' );
    assert( all(diff(cellfun(@numel,to_merge)) == 0), 'Struct arrays must be the same size.' );

    if nmerge > 2

        for k = nmerge:-1:2
            to_merge{k-1} = dk.struct.merge( to_merge{k-1}, to_merge{k}, recursive );
        end
        a = to_merge{1};

    else

        a = to_merge{1};
        b = to_merge{2};
        F = fieldnames(b);

        ns = numel(a);
        nf = numel(F);

        for i = 1:nf % fields
        for j = 1:ns % structures

            f = F{i};
            if recursive && isfield(a,f) && isstruct(a(j).(f)) && isstruct(b(j).(f))
                a(j).(f) = dk.struct.merge( a(j).(f), b(j).(f), true );
            else
                a(j).(f) = b(j).(f);
            end

        end
        end

    end

end