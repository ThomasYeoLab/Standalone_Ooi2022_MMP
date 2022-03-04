function mesh = CBIG_ConvertCaretSurfaces2MyFormat(coord_file, topo_file)

% mesh = CBIG_ConvertCaretSurfaces2MyFormat(coord_file, topo_file)
%
% This function is used to convert the caret coordinates and topological 
% structure to a mesh structure format. This mesh structure is the same as 
% the one can be obtained by using CBIG_ReadNCAvgMesh.m
%
% Input:
%      -coord_file: 
%       caret coordinate file. e.g 'path_to_coord_file/xxx.coord'
%
%      -topo_file:
%       caret topological file. e.g. 'path_to_topo_file/xxx.topo'
%
% Output:
%      -mesh: 
%       a mesh structure where coord_file corresponds to the field 'vertices'.
%       topo_file corresponds to the field 'faces'.
%
% Example:
% mesh = CBIG_ConvertCaretSurfaces2MyFormat('path_to_coord_file/xxx.coord', 'path_to_topo_file/xxx.topo')
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


coord = caret_load(coord_file);
topo  = caret_load(topo_file);

vertices = single(coord.data);
faces = int32(topo.data);

%Find vertexFaces
vertexFaces =  MARS_convertFaces2FacesOfVert(faces, int32(size(vertices, 1)));
num_per_vertex = length(vertexFaces)/size(vertices,1);
vertexFaces = reshape(vertexFaces, size(vertices,1), num_per_vertex);

% Compute Face Areas.
faceAreas = MARS_computeMeshFaceAreas(int32(size(faces, 1)), int32(faces'), single(vertices'));  

%Find vertexNbors
vertexNbors = MARS_convertFaces2VertNbors(faces, int32(size(vertices,1)));
num_per_vertex = length(vertexNbors)/size(vertices,1);
vertexNbors = reshape(vertexNbors, size(vertices,1), num_per_vertex);

%Find vertexDistSq2Nbors
vertexDistSq2Nbors = MARS_computeVertexDistSq2Nbors(int32(size(vertexNbors', 1)), int32(size(vertices', 2)), int32(vertexNbors'), single(vertices'));

% create mesh structure
mesh = struct('vertices', vertices', 'faces', faces', 'vertexNbors', vertexNbors', 'vertexFaces', vertexFaces', 'vertexDistSq2Nbors', vertexDistSq2Nbors, ...
    'faceAreas', faceAreas');