%% main file
% parse the config file, load the stl file
% preprocess the stl models, delete the extra structs(such as the metal
% tail...), map the model into a 4-Degree polynomial projection plane.

clc;close all;clear all;

%% The directory of config file
path = '/home/wangheda/Desktop/Chenhu-ModelScan';
scale = 5;
fid = fopen('config.dat');

%% parse the config file
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    [name, value] = strtok(tline, '=');
    if strcmp(name, 'scale') %image zoom out factor
        scale = str2num(value(2:end))
    end
    
    if strcmp(name, 'path') %stl file path
        path = value(2:end)
    end
end
fclose(fid);

%% load the stl file absolute path into a list
mFiles = RangTraversal(path, '.dat');%mFile is the file lists
mFiles = mFiles';
modelCount = length(mFiles);
model = {};

%% main loop, seperate the teeth
for i = 1 : modelCount %
%     for i = 1
    i
    fprintf('calc the range image for %s\n', cell2mat(mFiles(i)));
    
    %% load teeth 3d model
    [vertexs, faces, normals] = readmodel(cell2mat(mFiles(i)));
    
    %% to make the teeth front be x axis, revert the x,y coordinates
    temp = vertexs(:,1);
    vertexs(:,1) = vertexs(:,2);
    vertexs(:,2) = -1 * temp;
    %     model(i).vertexs = vertexs;
    
    %% pre process
    % pre process the model, faces_left is the final result, instead of seperate
    % faces, we use faces_left.
    [faces_left, f] = pre3Dmodel(vertexs, faces);%f is the 4-Degree polynomial projection plane
    theta = atan(f(1));
    rotmat = [cos(theta) -sin(theta); sin(theta) cos(theta)]; %rotate matrix for the upper teeth
    normals = normals(faces_left(:,4), :); %final normals
    faces = faces(faces_left(:,4), :); %final faces
    vertexs(:,2:3) = vertexs(:,2:3) * rotmat; % rot the plane, so the upper face is parallel to th XY plane
%     vertexs(:,3) = vertexs(:,3) - polyval(f, vertexs(:,2));
    
    % fit the teeth outer projection plane
    minZ = min(faces_left(:,3));
    maxZ = max(faces_left(:,3));
    meanZ = mean(faces_left(:, 3));
    level_plane = minZ + (maxZ - minZ) * 0.2;% only the face upper than level_plane will be used
    [f2] = fitContourByConvhull2(vertexs, faces, level_plane);%calc outer 4-Degree polynomial
    f_in = inner_contour_fit(faces, vertexs, f2, level_plane);%calc inner 4-Degree polynomial

    faces = inner_outer_face_filter(faces, vertexs, f2, f_in, level_plane);%filter the faces between the f plane
    normals_f = zeros(size(faces));%we need normals to generate the final stl result
       

    %% map the mesh data into inner & outer projection image
    [int_image_range, int_image_range_index] = calc_image_intercept2(faces, vertexs, f2, minZ, scale);%outer map image
    % int_image_range_index: the map of faces index to image x,y pixel
    [int_image_range_in, int_image_range_index_in] = calc_image_intercept2(faces, vertexs, f_in, minZ, scale);%inner map image
    int_image_range = rot90(int_image_range);
    int_image_range_in = rot90(int_image_range_in);
    % for display result, save the left face to a stl file
    paths = regexp(cell2mat(mFiles(i)), '[\\/]', 'split');
    filename = [cell2mat(paths(end-1)), '@' , cell2mat(paths(end))];
    filename = filename(1:end-3);
%     model(i).range_index = int_image_range_index;
%     model(i).fig = [int2str(i), '@', filename, '.fig'];
%     g = figure(1);
%     image(int_image_range);
%     saveas(g, [int2str(i), '@', filename, '.fig']);
    
    %% select the teeth pixel from projection image
    mask_image = teeth_mask(int_image_range);% outer
    mask_image_in = teeth_mask(int_image_range_in);% inner
    figure(1)
    image(mask_image);
    mask_image = rot90(rot90(rot90(mask_image)));
    mask_image_in = rot90(rot90(rot90(mask_image_in)));
    a = strel('disk',5);
    mask_image = imdilate(mask_image, a);
    mask_image_in = imdilate(mask_image_in, a);
    
    %% select the mesh face for teeth
    % a face is selected by its distance of outer & inner projection plane
    % example: if faces index i in outer distance is mapping into a teeth,
    % in inner distance is mapping into a no-teeth, the nearest distance
    % decide the final result.
    teeth_face = zeros(size(faces));
    teeth_normal = zeros(size(faces));
    teeth_face_count = 0;   
    for j = 1 : length(int_image_range_index)
    
        % both the image index map label a no-tooth, continue
        if int_image_range_index(j,1) == 0 || int_image_range_index(j,2) == 0
            continue
        end
        
        % both the image index map label a no-tooth, selected
        if mask_image(int_image_range_index(j,1),int_image_range_index(j,2)) ...
                ~= 0 && mask_image_in(int_image_range_index_in(j,1),int_image_range_index_in(j,2)) ...
                ~= 0            
            teeth_face_count = teeth_face_count + 1;
            teeth_face(teeth_face_count, : ) = faces(j, :); 
            teeth_normal(teeth_face_count, : ) = normals(j, :);
        
         % nearest distance decide the face label
        elseif mask_image(int_image_range_index(j,1),int_image_range_index(j,2)) ...
                ~= 0 && mask_image_in(int_image_range_index_in(j,1),int_image_range_index_in(j,2)) ...
                == 0  
            if int_image_range_index(j,3) < int_image_range_index_in(j,3)
                teeth_face_count = teeth_face_count + 1;
                teeth_face(teeth_face_count, : ) = faces(j, :);
                teeth_normal(teeth_face_count, : ) = normals(j, :);
            end
            
        elseif mask_image(int_image_range_index(j,1),int_image_range_index(j,2)) ...
                == 0 && mask_image_in(int_image_range_index_in(j,1),int_image_range_index_in(j,2)) ...
                ~= 0 
            if int_image_range_index(j,3) > int_image_range_index_in(j,3)
                teeth_face_count = teeth_face_count + 1;
                teeth_face(teeth_face_count, : ) = faces(j, :);
                teeth_normal(teeth_face_count, : ) = normals(j, :);
            end
        end
    end
    
    teeth_face = teeth_face(1:teeth_face_count,:);  
    teeth_normal = teeth_normal(1:teeth_face_count,:); 
    % save the result to a stl file
    saveStlFile([int2str(i), '@', filename, 'tmp'], '', teeth_face, vertexs, teeth_normal);
    fprintf('finished the image for %s\n', cell2mat(mFiles(i)));
%     close 1;
end
save model.mat model;

