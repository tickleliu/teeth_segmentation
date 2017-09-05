clc;close all;clear all;

%% The directory of your files
path = '/home/wangheda/Desktop/Chenhu-ModelScan';
scale = 5;

fid = fopen('config.dat');
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    [name, value] = strtok(tline, '=')
    if strcmp(name, 'scale')
        scale = str2num(value(2:end))
    end
    
    if strcmp(name, 'path')
        path = value(2:end)
    end
end
fclose(fid);

%% 
mFiles = RangTraversal(str, '.dat');
mFiles = mFiles';
modelCount = length(mFiles);
model = {};
d = zeros(1,2);
height = [];
width = [];

for i = 1 : modelCount
% for i = 103
    i
    [vertexs, faces, normals] = readmodel(cell2mat(mFiles(i)));
    fprintf('calc the range image for %s\n', cell2mat(mFiles(i)));
    temp = vertexs(:,1);
    vertexs(:,1) = vertexs(:,2);
    vertexs(:,2) = -1 * temp;
    %     model(i).vertexs = vertexs;
    [faces_left, rotmat] = pre3Dmodel(vertexs, faces);
    %     model(i).faces = faces_left;
    minZ = min(faces_left(:,3));
    maxZ = max(faces_left(:,3));
    meanZ = mean(faces_left(:, 3));
    level_plane = minZ + (maxZ - minZ) * 0.1;
    normals_left = normals(faces_left(:,4), :);
    faces_left = faces(faces_left(:,4), :);
    vertexs(:,2:3) = vertexs(:,2:3) * rotmat;
    [f2] = fitContourByConvhull2(vertexs, faces_left, level_plane);
    %     model(i).f = f2;
    %     model(i).scale = scale;
    %     saveStlFile([int2str(i), '.tmp'], '', faces_left, vertexs, normals_left);
    [int_image_range, int_image_range_index] = calc_image_intercept(faces_left, vertexs, f2, minZ, scale);
    model(i).image = int_image_range;
    %     model(i).image_index = int_image_range_index;
%     g = figure('visible', 'off');
    g = figure;
    image(int_image_range);
    saveas(g, [int2str(i), '.fig']);
    fprintf('finished the image for %s\n', cell2mat(mFiles(i)));
end
save model as all_model.mat;

