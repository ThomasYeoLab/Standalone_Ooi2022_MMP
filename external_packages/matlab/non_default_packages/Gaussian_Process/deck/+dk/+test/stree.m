
rng(12346);
sep = @() disp('==========================');

T = dk.test.stree_rand(4);

% plot tree and shape
T.plot('Name','First plot');
disp(T);
sep()

% traversal
disp('Depth-first search:');
T.dfs( @(k,n,p) fprintf('%d ',k) ); fprintf('\n');

disp('Breadth-first search:');
T.bfs( @(k,n,p) fprintf('%d ',k) ); fprintf('\n');
