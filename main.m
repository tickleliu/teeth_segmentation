clc;close all;clear all;

%% The directory of your files
str = '/home/wangheda/Desktop/Chenhu-ModelScan';

%% The use of breadth first walk
mFiles = RangTraversal(str, '.dat');
mFiles = mFiles';
modelCount = length(mFiles);
model = {};
d = zeros(1,2);
height = [];
width = [];
scale = 1;
for i = 1 : modelCount
%     for i = 6
    i
    [vertexs, faces] = readmodel(cell2mat(mFiles(i)));
    fprintf('calc the range image for %s\n', cell2mat(mFiles(i)));
    temp = vertexs(:,1);
    vertexs(:,1) = vertexs(:,2);
    vertexs(:,2) = -1 * temp;
    model(i).vertexs = vertexs;
    [faces_left] = pre3Dmodel(vertexs, faces);
%     model(i).faces = faces_left;
%     faces = faces_left;
%     %     vertexs = model(i).vertexs ;
% %     faces = model(i).faces;
%     minZ = min(vertexs(:,3));
%     maxZ = max(vertexs(:,3));
%     meanZ = mean(vertexs(:, 3))
%     level_plane = meanZ + (maxZ - meanZ) / 3;
%     [f2] = fitContourByConvhull(vertexs, faces, level_plane);
%     model(i).f = f2;
    
    
%     model(i).scale = scale;
%     [int_image_range, int_image_range_index] = calc_image_intercept(faces, vertexs, f2, level_plane, scale);
%     model(i).image = int_image_range;
%     model(i).image_index = int_image_range_index;
%     fprintf('finished the image for %s\n', cell2mat(mFiles(i)));
%     imwrite(int_image_range, [int2str(i), '.jpg']);
end
% save orig_model.mat model;
% load orig_model.mat;
% for i = 1 : modelCount
%     vertexs = model(i).vertexs ;
%     faces = model(i).faces;
%     minZ = min(vertexs(:,3));
%     maxZ = max(vertexs(:,3));
%     
%     level_plane = minZ + (maxZ - minZ) / 3;
%     [f2] = calc_up_range2(vertexs, faces, level_plane);
%     
%     model(i).f = f2;
%     model(i).scale = scale;
%     [int_image_range, int_image_range_index] = calc_image_intercept(faces, vertexs, f2, level_plane, scale);
%     model(i).image = int_image_range;
%     model(i).image_index = int_image_range_index;
%     fprintf('finished the image for %s\n', cell2mat(mFiles(i)));
%     imwrite(int_image_range, [int2str(i), '.jpg']);
% end
% 


