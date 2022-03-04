function matlab_compare_datastruct(m,n)
%
% matlab_compare_datastruct( nrows=1e5, ncols=6 )
%
% Compare the byte-size of arrays, tables, struct-arrays and cells.
% NOTE: with this implementation, ncols must be <= 52.
%

    if nargin < 1, m=1e5; end
    if nargin < 2, n=6; end
    
    x = 1:n;
    f = num2cell(char( 96 + x ));

    A = repmat(x,m,1);
    disp('Array size:');
    dk.util.var_size(A);
    
    T = array2table(A,'VariableNames',f);
    disp('Table size:');
    dk.util.var_size(T);
    
    S = cell(1,2*n);
    S(1:2:end) = f;
    S(2:2:end) = num2cell(x);
    S = struct(S{:});
    S = repmat(S,m,1);
    disp('Struct-array size:');
    dk.util.var_size(S);
    
    C = cell(m,n);
    for i = 1:n
        [C{:,i}] = deal(x(i));
    end
    disp('Cell size:');
    dk.util.var_size(C);
    
end