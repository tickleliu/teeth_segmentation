function [vertexs, faces] = readmodel(path)
% 读取模型文件
% path模型文件路径
fid = fopen(path);
%read vertex coordinate
[vertex_count, count] = fread(fid, 1, 'int32', 'b');
[vertexs, count] = fread(fid, [3, vertex_count], 'float', 'b');
vertexs = vertexs';
[face_count, count] = fread(fid, 1, 'int32', 'b');
[faces, count] = fread(fid, [3,face_count], 'int32','b');
faces = faces';
fclose(fid);

% for i=1:face_count
%     seginfo(i) = mod(i, 3);
%     if mod(i, 10000) == 0
%         i
%     end
% end

% 
% save model.mat faces vertexs seginfo;
% % load model.mat
% plot_mesh_segmentation(vertexs',faces', seginfo');
