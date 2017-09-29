function faces_f = inner_outer_face_filter(faces, vertexs, f_outer, f_inner, level_plane)


center_points = (vertexs(faces(:,1), :) + vertexs(faces(:,2), :) + vertexs(faces(:,3), :)) ./3;
center_points(:,4) = 1 : length(center_points);
center_points(:,3) = center_points(:,3);

faces_f = zeros(size(center_points));
faces_f_count = 0;

for i = 1 : length(center_points)
    z = center_points(i, 3);
    if z - level_plane < 0.001
        continue
    else
        y_out = polyval(f_outer, center_points(i,1));
        y_in =  polyval(f_inner, center_points(i,1));
        y = center_points(i,2);
        if y <= y_out && y >= y_in
            faces_f_count = faces_f_count + 1;
            faces_f(faces_f_count,:) = center_points(i,:);
        end
    end
end

faces_f = faces_f(1:faces_f_count, :);
faces_f = faces(faces_f(:,4), :);