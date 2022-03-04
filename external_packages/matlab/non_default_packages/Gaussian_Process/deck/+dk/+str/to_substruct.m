function sub = to_substruct( str, ignorefirst )
%
% sub = dk.str.to_substruct( str, ignorefirst )
%
% Converts a string corresponding to an access to a variable to the corresponding substruct.
% Example:
%   s = dk.str.to_substruct( 'foo(2).bar.baz{13}.arg(1,2,3)' )
%   t = subsasgn( struct(), s, 3 )
%
% JH

    if nargin < 2, ignorefirst=false; end

    % the "elementary" tokens are separated by dots
    elem = strsplit( str, '.' );
    n    = numel(elem);

    % each token can be of the form <name>.{<bracket>}(<parenthesis>)
    elem = cellfun( @(x) regexp(x,'([\w_]+)(\{[\d,:end]+\})?(\([\d,:end]+\))?','tokens'), elem );

    % concatenate the three matches for each token (results in 1x3*n cell)
    elem = [elem{:}];

    % find which matches are non-empty
    mask = ~cellfun( @isempty, elem );
    if ignorefirst, mask(1) = false; end % first variable name

    % cell-array with matching "operators", ie repeating dot, bracket and parenthesis
    ops  = repmat( {'.','{}','()'}, 1, n );

    % the matches for bracket or parenthesis access are expected to be index lists
    for i = 1:n
        elem{3*i-1} = convert_index_list(elem{3*i-1});
        elem{3*i-0} = convert_index_list(elem{3*i-0});
    end

    % build the substruct
    sub = cell( 1, 2*sum(mask) );
    sub(1:2:end) = ops(mask);
    sub(2:2:end) = elem(mask);

    sub = substruct(sub{:});

end

% An index list is typically what goes in-between bracket or parenthesis access.
% For instance in `a(2,1)` the index-list is '2,1'.
% Here we convert a string index list into a cell array of numeric indices (except for ':').
function il = convert_index_list(il)

    if isempty(il), return; end
    il = strsplit(il(2:end-1),',');
    ni = numel(il);

    for i = 1:ni
    if ~ismember( il{i}, {':','end'} )
        il{i} = str2num(il{i});
        assert( ~isempty(il{i}) );
    end
    end

end
