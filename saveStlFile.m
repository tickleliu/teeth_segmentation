function saveStlFile(path, intor, faces, vertexs, face_normals)
fid = fopen(path, 'w');
% for i = 1 : 80
%     count = fwrite(fid, ' ', 'char');
% end
fwrite(fid, length(faces), 'int32', 'b');
fwrite(fid, face_normals(:,1), 'float32', 'b');
fwrite(fid, face_normals(:,2), 'float32', 'b');
fwrite(fid, face_normals(:,3), 'float32', 'b');
fwrite(fid, vertexs(faces(:,1),1), 'float32', 'b');
fwrite(fid, vertexs(faces(:,1),2), 'float32', 'b');
fwrite(fid, vertexs(faces(:,1),3), 'float32', 'b');
fwrite(fid, vertexs(faces(:,2),1), 'float32', 'b');
fwrite(fid, vertexs(faces(:,2),2), 'float32', 'b');
fwrite(fid, vertexs(faces(:,2),3), 'float32', 'b');
fwrite(fid, vertexs(faces(:,3),1), 'float32', 'b');
fwrite(fid, vertexs(faces(:,3),2), 'float32', 'b');
fwrite(fid, vertexs(faces(:,3),3), 'float32', 'b');
% for i = 1 : length(faces)
%     fwrite(fid, face_normals(i,1), 'float32', 'l');
%     fwrite(fid, face_normals(i,2), 'float32', 'l');
%     fwrite(fid, face_normals(i,3), 'float32', 'l');
%     fwrite(fid, vertexs(faces(i,1),1), 'float32', 'l');
%     fwrite(fid, vertexs(faces(i,1),2), 'float32', 'l');
%     fwrite(fid, vertexs(faces(i,1),3), 'float32', 'l');
%     fwrite(fid, vertexs(faces(i,2),1), 'float32', 'l');
%     fwrite(fid, vertexs(faces(i,2),2), 'float32', 'l');
%     fwrite(fid, vertexs(faces(i,2),3), 'float32', 'l');
%     fwrite(fid, vertexs(faces(i,3),1), 'float32', 'l');
%     fwrite(fid, vertexs(faces(i,3),2), 'float32', 'l');
%     fwrite(fid, vertexs(faces(i,3),3), 'float32', 'l');
%     fwrite(fid, 0, 'short', 'l');
% end
fclose(fid);