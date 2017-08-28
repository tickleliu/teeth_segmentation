function h = plot_mesh_segmentation(vertex,face, seginfo)
% h = plot_mesh_segmentation(vertex,face, seginfo)
% Plot the mesh segmentation given vertex, face and segmentation
% information. seginfo is a vector with number of rows equal to the number
% of faces and had labels for each face.
%
% Zhile Ren<jrenzhile@gmail.com>
% Apr, 2013

vertex = vertex';
face = face';

face_vertex_color = seginfo +1;

h = patch('vertices',vertex,'faces',face,'FaceVertexCData',face_vertex_color, 'FaceColor','flat');


set(h,'EdgeColor','none');

colormap(lines);

axis off;
axis image;