function [C,lr,ur,cmap] = combmat( L, U, varargin )
%
% [C,lr,ur,cmap] = combmat( L, U, varargin )
%
% Combine two sets of matrices L and U as a single set C, in which 
%   tril(Ci) = tril(Li)
%   triu(Ci) = triu(Ui)
%
% L and U should be cells of matrices of same size.
% C is a cell of RGB matrices, same size as matrices in L and U.
%
%
% OPTIONS
% -------
%
%   cmap    colormap used to generate matrices in M
%           default: dk.cmap.bgr(64)
%
%   lr      range of values for matrices in L
%           default: auto
%
%   ur      range of values for matrices in U
%           default: auto
%
%   diag    colour on the diagonal of C
%           default: [0,0,0]
%
%
% See also: ant.img.range, dk.cmap.interp
%
% JH

    % parse options
    opt = dk.obj.kwArgs(varargin{:});
    
    lr = opt.get( 'lr', 'auto' );
    ur = opt.get( 'ur', 'auto' );
    
    cmap = opt.get( 'cmap', dk.cmap.bgr(64) ); 
    diag = opt.get( 'diag', [0,0,0] );

    % process options
    if ischar(lr)
        lr = ant.img.range(L,lr);
    end
    if ischar(ur)
        ur = ant.img.range(U,ur);
    end
    
    % validate options
    assert( isnumeric(lr) && numel(lr)==2, 'Bad range lr.' );
    assert( isnumeric(ur) && numel(ur)==2, 'Bad range ur.' );
    
    L = dk.wrap(L);
    U = dk.wrap(U);
    n = numel(L);
    assert( numel(U)==n, 'U and L should have the same size.' );
    
    % combine matrices
    C = cell(1,n);
    for i = 1:n
        
        Li = L{i}; 
        Ui = U{i};
        
        assert( ismatrix(Li) && ismatrix(Ui) && all(size(Li)==size(Ui)), 'Bad matrices at index %d.', i );
        
        s = size(Li);
        Tlo = tril( true(s), -1 );
        Tup = triu( true(s),  1 );
        
        Li = dk.cmap.interp( cmap, Li(Tlo), lr );
        Ui = dk.cmap.interp( cmap, Ui(Tup), ur );
        
        Cr = diag(1)*eye(s); Cr(Tlo) = Li(:,1); Cr(Tup) = Ui(:,1);
        Cg = diag(2)*eye(s); Cg(Tlo) = Li(:,2); Cg(Tup) = Ui(:,2);
        Cb = diag(3)*eye(s); Cb(Tlo) = Li(:,3); Cb(Tup) = Ui(:,3);
        
        C{i} = cat(3,Cr,Cg,Cb);
        
    end
    
end