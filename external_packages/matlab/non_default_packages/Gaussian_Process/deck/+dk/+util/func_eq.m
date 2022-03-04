function e = func_eq( f1, f2 )
%
% Compare two function handles

    e = strcmp( func2str(f1), func2str(f2) );
end
