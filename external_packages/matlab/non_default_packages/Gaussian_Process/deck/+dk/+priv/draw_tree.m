function gobj = draw_tree(T,varargin)
%
% gobj = dk.priv.draw_tree(T,varargin)
%
% Draw the tree.
%
% Options:
%
%      Newfig  Open new figure to draw.
%             >Default: true
%        Name  Set name of figure being drawn.
%             >Default: '[dk] Tree plot'
%        Link  Link options (cf Line properties)
%             >Default: {} (none)
%      Height  Function of width and depth giving the height of links.
%              Should generally be a decreasing function of depth.
%              Can also be scalar or array.
%             >Default: @(w,d) w(1) ./ sqrt(1:d)
%      Sepfun  Function of the depth adding width to separate branches
%             >Default: @(x)x/10 or @(x)zeros(size(x))
%     Balance  Balancing flag (children reordering)
%             >Default: true
%    NodeSize  RELATIVE size of the node (between 0 and 1)
%             >Default: 0.5
%   NodeColor  Face-color of the node
%             >Default: hsv colormap
%    NodeEdge  Colour of the edges
%             >Default: 'k'
%     ToolTip  Function handle to be called by datacursormode
%             >Default: shows "id: NodeID"
%      Radial  Flag to draw the tree with radial geometry
%             >Default: false
%
% JH

    %H = mean(W) * (D:-1:1);
    %H = W(1) ./ log2(1+(1:D));
    %H = W(1) ./ log1p(1:D);
    %H = W(1) ./ sqrt(1:D);
    %R = 0:D-1;
    %R = R.*log1p(R);
    %R = R.*sqrt(R);

    opt = dk.obj.kwArgs(varargin{:});
    radial = opt.get('Radial',false);
    balance = opt.get('Balance',true);

    % compute widths
    if radial
        sepfun = opt.get( 'Sepfun', @(x)x/10 );
    else
        sepfun = opt.get( 'Sepfun', @(x)zeros(size(x)) );
    end
    nodes = compute_widths(T,sepfun);

    % compute heights
    height = opt.get('Height', @(w,d) w(1)/2 ./ (1:d) );
    if dk.is.fhandle(height)
        height = height( nodes.width, nodes.d );
    elseif isscalar(height)
        height = height * ones(1,nodes.d);
    else
        assert( numel(height) >= nodes.d, 'Heights vector is not long enough.' );
    end

    height = cumsum(height(:));
    height = height - height(1); % root at 0
    if radial
        height = 2*height;
    else
        height = -height;
    end
    nodes.height = height;

    % drawing properties
    defcol = hsv(max( nodes.d, 6 ));
    linkopt = opt.get('Link', {} );
    nodes = add_prop( nodes, ...
        opt.get('NodeSize',0.5), ...
        opt.get('NodeColor', defcol( nodes.depth, : )), ...
        opt.get('NodeEdge','k') ...
    );

    % draw the tree
    if opt.get('Newfig',true)
        figure('Color','w');
    end
    set( gcf, 'name', opt.get('Name','[dk] Tree plot') );
    if radial
        gobj = radial_draw(T,nodes,balance,linkopt);
    else
        gobj = vertical_draw(T,nodes,balance,linkopt);
    end

    % set data tip
    tooltip = opt.get( 'ToolTip', @datatip );
    set( datacursormode(gcf), 'updatefcn', tooltip );
    
    % set user data
    f = gcf;
    f.UserData.tree = nodes;
    f.UserData.gobj = gobj;
    
end

function nodes = compute_widths(T,sepfun)
%
% Compute the width required for displaying each node and its children.
% The leaf nodes have a width of 1, which is equivalent to right and left margins of 1/2.
%
% The width of leaf nodes is propagated to their parents (summing for all children), then
% to their grandparents, etc. Until we reach the root.
% Note that this _needs_ to be done level by level.
%
% Sepfun is used to insert a space between different families at each level.
% This is done indirectly by adding width to nodes that are closer to the root. Then when
% we draw the nodes, the discrepancy between the width of the children, and that of the
% parent, is the separation increment.
%
% The output is a structure with fields:
%   n       Total number of nodes
%   d       Maximum depth
%   width   Vector of width for each node
%   depth   Vector of depth for each node
%   index   Tree index of each node
%   lw      Level width (total width at each depth)
%   map     Reverse mapping between the ordering of these vectors,
%           and indices of nodes in the tree.
%
% JH

    D = T.all_depths();     % depth
    G = T.all_nchildren();  % degree
    P = T.all_parents();    % parent
    [I,R] = T.indices();
    n = numel(D);

    maxd = max(D);
    inc = sepfun(fliplr(0:maxd-1));  % level spacings

    % initialise width
    w = zeros(n,1);
    w(G == 0) = 1; % set all leaves to 1

    % propagate width level by level, starting from the bottom
    for h = maxd:-1:2
        c = find(D == h);
        p = R(P(c));
        m = numel(p);

        assert( all(p <= n), 'Bad index' );

        % needs to be done with a for loop
        for i = 1:m
            w(c(i)) = w(c(i)) + inc(h);
            w(p(i)) = w(p(i)) + w(c(i));
        end
    end

    % compute total width for each level
    Lwidth = accumarray( D(:), w(:), [maxd,1] ); % width of each level
    Lsize  = accumarray( D(:), 1, [maxd,1] ); % number of nodes at each level

    % pack all this information
    nodes = struct( 'n', n, 'd', maxd, 'lw', Lwidth, 'ls', Lsize, ...
        'width', w, 'depth', D, 'idx', I, 'deg', G, 'rev', R );

end

% draw tree with a vertical layout
function gobj = vertical_draw(T,nodes,balance,linkopt)

    N = nodes.n;
    D = nodes.d;
    W = nodes.width;
    H = nodes.height;
    C = T.all_children();

    % axis coordinate and offset for each node
    coord = zeros(1,N);
    offset = zeros(1,N);

    % open new figure for display
    gobj.node = gobjects(1,N);
    gobj.link = gobjects(1,N); % first link is null

    % draw the root
    coord(1) = W(1)/2;
    gobj.node(1) = draw_node( W(1)/2, H(1), nodes.prop(1) );
    hold on;

    % draw tree level by level, starting from the root
    for d = 1:D-1

        % find nodes at that level, and their children
        p = nodes.idx( nodes.depth == d );

        % draw the children of each parent
        np = numel(p);
        for j = 1:np

            % skip if there are no children
            pj = p(j);
            kj = nodes.rev(pj);
            if T.is_leaf(pj), continue; end

            % reorder children to balance the tree
            cj = C{kj};
            wj = W(nodes.rev(cj));
            nc = numel(cj);
            if balance
                cj = reorder_children( cj, wj );
            end

            % draw the children in order
            x0 = offset(kj); % offset of the parent
            x0 = x0 + (W(kj) - sum(wj))/2; % add separation increment
            for i = 1:nc
                cji = cj(i);
                kji = nodes.rev(cji);

                % save position of current node
                offset(kji) = x0;
                coord(kji) = x0 + W(kji)/2;

                % update offset for siblings
                x0 = x0 + W(kji);

                % draw node and link to parent
                glink = draw_link( coord(kji), H(d+1), coord(kj), H(d), linkopt );
                gnode = draw_node( coord(kji), H(d+1), nodes.prop(kji) );

                % set datatip
                gnode.UserData.id = cji;
                glink.UserData.id = pj;

                % save handles
                gobj.node(kji) = gnode;
                gobj.link(kji) = glink;
            end
        end

        %fprintf('Level %d\n',d);
    end
    hold off; axis equal tight off;

end

% draw tree with radial layout
function gobj = radial_draw(T,nodes,balance,linkopt)

    C = T.all_children();
    N = nodes.n;
    D = nodes.d;
    R = nodes.height / (2*pi);
    W = nodes.width;
    L = max(nodes.lw);
    F = 0.9;

    % axis coordinate and offset for each node
    angle = zeros(1,N);
    offset = zeros(1,N);

    % open new figure for display
    gobj.node = gobjects(1,N);
    gobj.link = gobjects(1,N); % first link is null

    % draw the root
    angle(1) = 0;
    gobj.node(1) = draw_node2( 0, 0, nodes.prop(1) );
    hold on;

    % draw tree level by level, starting from the root
    for d = 1:D-1

        % find nodes at that level, and their children
        p = nodes.idx( nodes.depth == d );

        % draw the children of each parent
        rc = R(d+1);
        rp = R(d);
        f = F;
        np = numel(p);
        for j = 1:np

            % skip if there are no children
            pj = p(j);
            kj = nodes.rev(pj);
            aj = angle(kj);
            if T.is_leaf(pj), continue; end

            % reorder children to balance the tree
            cj = C{kj};
            wj = W(nodes.rev(cj));
            nc = numel(cj);
            if balance
                cj = reorder_children( cj, wj );
            end

            % draw the children in order
            x0 = offset(kj); % offset of the parent
            x0 = x0 + (W(kj) - sum(wj))/2;
            for i = 1:nc
                cji = cj(i);
                kji = nodes.rev(cji);

                % save position of current node
                offset(kji) = x0;
                angle(kji) = 2*pi*f*(x0 + W(kji)/2)/L - pi*(0.5 + f);

                % update offset for siblings
                x0 = x0 + W(kji);
                aji = angle(kji);

                % draw node and link to parent
                glink = draw_link( rc*cos(aji), rc*sin(aji), rp*cos(aj), rp*sin(aj), linkopt );
                gnode = draw_node2( rc*cos(aji), rc*sin(aji), nodes.prop(kji) );

                %fprintf( 'Node %d: %.2f\n', kji, 180*aji/pi );

                % set datatip
                gnode.UserData.id = cji;
                glink.UserData.id = pj;

                % save handles
                gobj.node(kji) = gnode;
                gobj.link(kji) = glink;
            end
        end

        %fprintf('Level %d\n',d);
    end
    hold off; axis equal tight off;

end

% Isolate functions which actually draw stuff.
function h = draw_node2(x,y,p)
    %opt = { 'MarkerSize', p.size, 'MarkerFaceColor', p.face, 'MarkerEdgeColor', p.edge };
    opt = { 'MarkerFaceColor', p.face, 'MarkerEdgeColor', p.edge };
    h = plot(x,y,'o',opt{:});
end
function h = draw_node3(x,y,p)
    opt = { 'FaceColor', p.face, 'EdgeColor', p.edge, 'LineWidth', 0.2 };
    h = dk.ui.circle( [x,y], p.size, opt{:} );
end
function h = draw_node(x,y,p)
    opt = { 'EdgeColor', p.edge, 'LineWidth', 0.2 };
    h = dk.ui.disk( [x,y], p.size, 31, p.face, opt{:} );
end

function h = draw_link(x,y,xx,yy,opt)
    h = plot([x,xx],[y,yy],'k-',opt{:});
end


function txt = datatip(~,evt)
    try
        dat = evt.Target.UserData;
        txt = { ['id: ' num2str(dat.id)] };
    catch
        txt = 'Undefined';
    end
end


% make sure that input has n rows
function x = check_numrows(x,n)
    if iscell(x), x = vertcat(x{:}); end
    if ischar(x) || size(x,1) < n
        x = repmat(x,n,1);
    end
    assert( numel(x)==n || size(x,1)==n, 'Bad input size.' );
end

% create struct-array of node properties
function nodes = add_prop(nodes,sz,fc,ec)

    n = nodes.n;
    assert( isnumeric(sz), 'Size should be numeric.' );
    if numel(sz) < n, sz = sz*ones(n,1); end
    assert( numel(sz)==n, 'Bad input size.' );
    assert( all(sz >= 0 & sz <= 1), 'Sizes should be between 0 and 1.' );

    % face and edge color
    fc = check_numrows(fc,n);
    ec = check_numrows(ec,n);

    % normalisation factor for the size
    w = min(nonzeros( nodes.width ./ (1+nodes.deg) ));

    prop = dk.struct.repeat( {'size','face','edge'}, 1, n );
    for i = 1:n
        prop(i).size = sz(i)*w;
        prop(i).face = fc(i,:);
        prop(i).edge = ec(i,:);
    end
    nodes.prop = prop;

end


function c = reorder_children( c, w )
%
% Simple balancing technique which distributes weights in decreasing order,
% starting at the centre and alternating right and left.
%

    n = numel(c);
    if n == 1, return; end

    [~,o] = sort(w,'descend');
    r = zeros(1,n);
    p = ceil(n/2);

    for i = 1:n
        if mod(i,2) == 1 % odd
            r( p - (i-1)/2 ) = c(o(i));
        else
            r( p + i/2 ) = c(o(i));
        end
    end
    c = r;

end
