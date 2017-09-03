function [faces_left] = pre3Dmodel(vertexs, faces)

center_points = (vertexs(faces(:,1), :) + vertexs(faces(:,2), :) + vertexs(faces(:,3), :)) ./3;
center_points(:,4) = 1 : length(center_points);

points_yz = center_points(:,2:3);


minY = min(points_yz(:,1));
maxY = max(points_yz(:,1));
minZ = min(points_yz(:,2));
maxZ = max(points_yz(:,2));


scale = 10;
y0 = [minY:1/scale:maxY];
z0 = [minZ:1/scale:maxZ];

yz_image = zeros(length(z0), length(y0));

for i = 1 : length(points_yz)   
    y = floor((points_yz(i,1) - minY) * scale) + 1;
    z = floor((points_yz(i,2) - minZ) * scale) + 1;      
    yz_image(z, y) = 10;
end

flag = sum(yz_image(:,:)) ./ 10;
mean(flag) * 0.25
flag(flag < mean(flag) * 0.25) = 0;
startf = 1;
endf = 1;
for i = 1 : length(flag)
    if flag(i) ~= 0
        startf = i;
        endf = startf;
        for endf = startf : length(flag)
            if flag(endf) ==0
                break
            end
        end
        lengthf = endf - startf - 1;
        if lengthf < 20
            flag(startf:endf) = 0;
        end
        i = endf;
    end
end

for startf = 1 : length(flag)
    if flag(startf) ~= 0
        break
    end
end

for endf = length(flag) : -1 : 1
    if flag(endf) ~= 0
        break
    end
end

yz_image2 = yz_image;
yz_image(:, 1: startf) = 0;
% yz_image(:, endf: end) = 0;

y_line = zeros(length(y0) - startf,2);
for i = startf + 1: length(y0)
    y_line(i - startf, 1) = i;
    z = find(yz_image(:, i) ~= 0);
    if length(z) == 0
        y_line(i - startf, 2) = length(z0);
        continue
    end
    y_line(i - startf, 2) = z(end);
end
y_line_dy = abs(diff(y_line(:,2)));
y_line_dy(y_line_dy < 3) = 0;
startf_out = 1;
endf_out = 1;
lengthf_out = 1;
startf = 1;
endf = 1;
for i = 1 : length(y_line_dy)
    if y_line_dy(i) == 0
        startf = i;
        endf = startf;
        for endf = startf : length(y_line_dy)
            if y_line_dy(endf) ~=0
                break
            end
        end
        lengthf = endf - startf - 1;
        if lengthf > lengthf_out
            lengthf_out = lengthf;
            startf_out = startf;
            endf_out = endf - 1;
            flag(startf:endf) = 0;
        end
        i = endf;
    end
end


y_line = y_line(startf_out:endf_out, :);
f = polyfit(y_line(:,1), y_line(:,2), 1);

for i = 1 : length(y_line)
    yz_image(floor(polyval(f, y_line(i,1))), y_line(i,1)) = 30;
end

faces_left = zeros(length(center_points), 4);
faces_left_count = 1;
y = (startf - 1) / scale + minY - 0.1;
floor((points_yz(i,1) - minY) * scale) + 1;
for i = 1 : length(center_points)
    if center_points(i, 2) > y
        faces_left(faces_left_count, :) = center_points(i, :); 
        faces_left_count = faces_left_count + 1;
    end  
end
faces_left = faces_left(1 : faces_left_count - 1, :);



subplot(3,1,1)
image(rot90(rot90(yz_image2)));
subplot(3,1,2)
image(rot90(rot90(yz_image)));
subplot(3,1,3)
scatter3(faces_left(:,1),faces_left(:,2),faces_left(:,3));

