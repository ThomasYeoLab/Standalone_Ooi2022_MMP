function h = mesh(m,varargin)
%
% h = dk.ui.mesh( mesh, args... )
%
% The input mesh should be a struct { faces, vertices }.
% This mesh is drawn as a patch with specified options:
%
%   - Additional options FaceColors and VertexColors
%   - FaceVertexCData automatically converts face-colors to vertex-colors
%   - FaceColor defaults to 'flat'
%
% See also: dk.ui.face2vertex, patch
%
% JH

    % find faces and vertices fields
    fields = fieldnames(m);
    lf = dk.mapfun( @lower, fields );
    f = m.(fields{strcmp( 'faces', lf )});
    v = m.(fields{strcmp( 'vertices', lf )});
    
    % check size of facevertexcdata
    nf = size( f, 1 );
    nv = size( v, 1 );
    
    auto_facecolor = true;
    for i = 1:2:nargin-1
        switch lower(varargin{i})
            case 'facecolor'
                auto_facecolor = false;
            case 'vertexcolors'
                varargin{i} = 'FaceVertexCData';
            case 'facecolors'
                varargin{i} = 'FaceVertexCData';
                varargin{i+1} = dk.ui.face2vertex( varargin{i+1}, f, nv );
            case 'facevertexcdata'
                if size(varargin{i+1},1) ~= nv
                    varargin{i+1} = dk.ui.face2vertex( varargin{i+1}, f, nv );
                end
        end
    end
    if auto_facecolor
        varargin = [varargin, {'FaceColor','flat'}];
    end
    
    % draw patch
    h = patch( 'Faces', f, 'Vertices', v, varargin{:} );

end