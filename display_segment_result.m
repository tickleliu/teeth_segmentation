[vertexs, faces, normals] = readmodel('C:\Users\think\Desktop\fig\fig\Dent1-base.dat');
[vertexs1, faces1, normals1] = readmodel('C:\Users\think\Desktop\fig\fig\Dent1-Intact.dat');
seginfo1 = zeros(length(faces1),1) + 0.5;
[c, ia, ib] = intersect(vertexs1, vertexs, 'rows');
for i = 1 :length(ia)
    t1 = find(faces1(:,1) == ia(i));
    t2 = find(faces1(:,2) == ia(i));
    t3 = find(faces1(:,3) == ia(i));
    seginfo1(t1) = 0.2;
    seginfo1(t2) = 0.2;
    seginfo1(t3) = 0.2;
end
plot_mesh_segmentation(vertexs1',faces1', seginfo1);