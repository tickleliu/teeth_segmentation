clc;close all;clear all;

%% The directory of your files
str = '/home/wangheda/Desktop/Chenhu-ModelScan';

%% The use of breadth first walk
mFiles = RangTraversal(str, '.dat');
mFiles = mFiles';
modelCount = length(mFiles);
model.vertexs = 0;
model.faces = 0;
d = zeros(1,2);
for i = 1 : modelCount
% for i = 15
    [vertexs, faces] = readmodel(cell2mat(mFiles(i)));
    minZ = min(vertexs(:,3));
    maxZ = max(vertexs(:,3));
    level_plane = (minZ + maxZ) / 3 * 2; 
    arc_sample_point = zeros(1,2);
    arc_sample_count = 1;
    vertexs_count = length(vertexs);
    for j = 1 : vertexs_count
        if(abs(vertexs(j,3) - level_plane) < 0.01)
            arc_sample_count = arc_sample_count + 1;
            arc_sample_point(arc_sample_count,1:2) = vertexs(j,1:2);
        end 
    end
    sample_point_cov = cov(arc_sample_point(:,1), arc_sample_point(:, 2));
    [v, d] = eig(sample_point_cov);
%     v = v * [0 1; 1 0];
%     vertexs(:,1:2) = vertexs(:,1:2) * v;
%     hold on
%     line([0, v(1,1)],[0, v(1,2)]);
%     line([0, v(2,1)],[0, v(2,2)]);
    if d(2) > d(1)
        temp = vertexs(:,1);
        vertexs(:,1) = vertexs(:,2);
        vertexs(:,2) = -1 * temp;
    end
    model(i).vertexs = vertexs;
    model(i).faces = faces;
    [up_image, x0, f] = calc_up_range(vertexs, faces);
    model(i).f = f;
    [int_image_range, int_image_range_index] = calc_image_intercept(faces, vertexs, f, x0);
    model(i).image = int_image_range;
    model(i).image_index = int_image_range_index;
end

save all_model.mat model;