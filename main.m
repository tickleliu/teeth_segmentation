%main file for pre process the stl model
clc;close all;clear all;

%% The directory of your files
path = '/home/wangheda/Desktop/Chenhu-ModelScan';
scale = 5;

fid = fopen('config.dat');
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    [name, value] = strtok(tline, '=');
    if strcmp(name, 'scale')
        scale = str2num(value(2:end))
    end
    
    if strcmp(name, 'path')
        path = value(2:end)
    end
end
fclose(fid);

%%
mFiles = RangTraversal(path, '.dat');
mFiles = mFiles';
modelCount = length(mFiles);
model = {};
d = zeros(1,2);
height = [];
width = [];

% for i = 1 : modelCount
    for i = 3
    i
    fprintf('calc the range image for %s\n', cell2mat(mFiles(i)));
    
    %% load teeth 3d model
    [vertexs, faces, normals] = readmodel(cell2mat(mFiles(i)));
    
    %% to make the teeth front be x axis, revert the x,y coordinates
    temp = vertexs(:,1);
    vertexs(:,1) = vertexs(:,2);
    vertexs(:,2) = -1 * temp;
    %     model(i).vertexs = vertexs;
    
    %% pre process the model, faces_left is the final result
    [faces_left, f] = pre3Dmodel(vertexs, faces);%f is the teeth upper plane
    theta = atan(f(1));
    rotmat = [cos(theta) -sin(theta); sin(theta) cos(theta)]; %rotate matrix for the upper teeth
    normals = normals(faces_left(:,4), :); %final normals
    faces = faces(faces_left(:,4), :); %final faces
    vertexs(:,2:3) = vertexs(:,2:3) * rotmat; % rot the plane
%     vertexs(:,3) = vertexs(:,3) - polyval(f, vertexs(:,2));
    
    % fit the teeth outer projection plane
    minZ = min(faces_left(:,3));
    maxZ = max(faces_left(:,3));
    meanZ = mean(faces_left(:, 3));
    level_plane = minZ + (maxZ - minZ) * 0.2;
    [f2] = fitContourByConvhull2(vertexs, faces, level_plane);
    
    % for display result, save the left face to a stl file
    paths = regexp(cell2mat(mFiles(i)), '[\\/]', 'split');
    filename = [cell2mat(paths(end-1)), '@' , cell2mat(paths(end))];
    filename = filename(1:end-3);
%     saveStlFile([int2str(i), '@', filename, 'tmp'], '', faces, vertexs, normals);
    [int_image_range, int_image_range_index] = calc_image_intercept2(faces, vertexs, f2, minZ, scale);
    model(i).range_index = int_image_range_index;
    model(i).fig = [int2str(i), '@', filename, '.fig'];
%     g = figure(1);
%     image(int_image_range);
%     saveas(g, [int2str(i), '@', filename, '.fig']);
    fprintf('finished the image for %s\n', cell2mat(mFiles(i)));
    int_image_range = rot90(int_image_range);
    mask_image = teeth_mask(int_image_range);
    figure(1)
    image(mask_image);
    mask_image = rot90(rot90(rot90(mask_image)));
    
    teeth_face = zeros(size(faces));
    teeth_normal = zeros(size(faces));
    teeth_face_count = 0;
    
    for j = 1 : length(int_image_range_index)
        
        if int_image_range_index(j,1) == 0 || int_image_range_index(j,2) == 0
            continue
        end
        
        if mask_image(int_image_range_index(j,1),int_image_range_index(j,2)) ...
                ~= 0
            teeth_face_count = teeth_face_count + 1;
            teeth_face(teeth_face_count, : ) = faces(j, :); 
            teeth_normal(teeth_face_count, : ) = normals(j, :);
        end
    end
    teeth_face = teeth_face(1:teeth_face_count,:);  
    teeth_normal = teeth_normal(1:teeth_face_count,:); 
    saveStlFile([int2str(i), '@', filename, 'tmp'], '', teeth_face, vertexs, teeth_normal);
%     close 1;
end
save model.mat model;

