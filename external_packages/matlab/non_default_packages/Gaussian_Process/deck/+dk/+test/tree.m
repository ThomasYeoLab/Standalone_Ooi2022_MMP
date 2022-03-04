
rng(12346);
sep = @() disp('==========================');

T = dk.test.tree_rand(4);

% plot tree and shape
T.plot('Name','First plot');
disp(T);
sep()

% traversal
disp('Depth-first search:');
T.dfs( @(k,n,p) fprintf('%d ',k) ); fprintf('\n');

disp('Breadth-first search:');
T.bfs( @(k,n,p) fprintf('%d ',k) ); fprintf('\n');

% remove node and redraw
n = T.n_nodes;
r = randi(fix(n/2));
T.rem_node(r);
T.plot('Name','After removing');
dk.print('After removing node %d / %d',r,n);
disp(T);
sep()

% cleanup and redraw
T.compress();
T.plot('Name','After cleanup','Radial',true);
disp('After cleanup:');
disp(T);
sep()

% traversal
disp('Depth-first search:');
T.dfs( @(k,n,p) fprintf('%d ',k) ); fprintf('\n');

disp('Breadth-first search:');
T.bfs( @(k,n,p) fprintf('%d ',k) ); fprintf('\n');
