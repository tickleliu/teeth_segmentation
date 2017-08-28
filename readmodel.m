clear all;close all;clc;
fid = fopen('Dent2.dat');
%read vertex coordinate
str_vertex_count = fgetl(fid);
vertex_count = str2double(str_vertex_count);
vertexs=zeros(vertex_count,3);
for i = 1:vertex_count
    str_temp = fgetl(fid);
    vertexs(i,:) = str2num(str_temp);
    if mod(i, 10000) == 0
        i
    end
end

%read face vertex indx
face_count = str2double(fgetl(fid));
faces=zeros(face_count,3);
seginfo = zeros(face_count,1);

for i=1:face_count
    str_temp = fgetl(fid);
    faces(i,:) = str2num(str_temp);
    seginfo(i) = mod(i, 3);
    if mod(i, 10000) == 0
        i
    end
end
fclose(fid);

save model.mat faces vertexs seginfo;
% load model.mat
plot_mesh_segmentation(vertexs',faces', seginfo);
