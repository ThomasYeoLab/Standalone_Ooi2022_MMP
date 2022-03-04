function cdata = face2vertex(cdata,faces,nvert)
%
% cdata = dk.ui.face2vertex( cdata, faces, nvert=max(faces) )
%
% Convert vector of color for each face to a vector of color for each vertex.
% This is useful if you want to display scalar data on a surface using triangulation 
% (delaunay) and patches, but that the scalar data is assigned to each FACE and not 
% to each VERTEX (cf FaceVertexCData option).
%
% This script computes a colour for each vertex as a weighted average amongst the 
% colour of the faces which contain that vertex.
%
% Source: http://stackoverflow.com/a/41076913/472610
%
% JH

    fmax = max(faces(:));
    if nargin < 3, nvert=fmax; end
    if size(faces,1)~=3, faces=faces'; end

    assert( size(faces,1)==3, 'Bad faces size.' );
    assert( size(faces,2)==numel(cdata), 'Input size mismatch.' );
    assert( nvert >= fmax, 'Number of vertices too small.' );

    faces = faces(:);
    cdata = repelem( cdata(:), 3 ); % triplicate face colors

    nfpv  = accumarray( faces, 1, [nvert,1] ); % #of faces per vertex
    cdata = accumarray( faces, cdata, [nvert,1] ) ./ max(1,nfpv);

end