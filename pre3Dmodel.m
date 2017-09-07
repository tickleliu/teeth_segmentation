function [faces_left, f] = pre3Dmodel(vertexs, faces)
%pre process the teeth model
%1. delete extra tail struct
%2. delete the faces under fit plane(tooth-up-plane move down by minZ / 2)
%3. rotate the model alone the x axis

center_points = (vertexs(faces(:,1), :) + vertexs(faces(:,2), :) + vertexs(faces(:,3), :)) ./3;
center_points(:,4) = 1 : length(center_points);

%projection the model to yz-plane
points_yz = center_points(:,2:3);
minY = min(points_yz(:,1));
maxY = max(points_yz(:,1));
minZ = min(points_yz(:,2));
maxZ = max(points_yz(:,2));
scale = 10;
y0 = [minY:1/scale:maxY];
z0 = [minZ:1/scale:maxZ];
yz_image = zeros(length(z0), length(y0));%yz projection image
for i = 1 : length(points_yz)
    y = floor((points_yz(i,1) - minY) * scale) + 1;
    z = floor((points_yz(i,2) - minZ) * scale) + 1;
    yz_image(z, y) = 10;
end

%% 1. delete extra tail struct
%alone the z axis to calc sum points, too less points means there is a spin
%plane or line but not teeth, delete them
flag = sum(yz_image(:,:)) ./ 10;
flag(flag < mean(flag) * 0.25) = 0;%delete
startf = 1;
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
    end
end
%clear the yz_image, delete the extra structs
for startf = 1 : length(flag)
    if flag(startf) ~= 0
        break
    end
end
yz_image2 = yz_image;
yz_image(:, 1: startf) = 0;
model_start = startf;
% yz_image(:, endf: end) = 0;

%% 2. delete the faces under fit plane(tooth-up-plane move down by minZ / 2)
% calc the up-boundry of yz-image, then use the gradient of up-boundry to
% fit the plane
% y_line = zeros(length(y0) - startf,2);%up-boundry line
% for i = startf + 1: length(y0)
%     y_line(i - startf, 1) = i;
%     z = find(yz_image(:, i) ~= 0);
%     if length(z) == 0
%         y_line(i - startf, 2) = length(z0);
%         continue
%     end
%     y_line(i - startf, 2) = z(end);
% end

%find the longest smooth line
% y_line_dy = abs(diff(y_line(:,2)));
% y_line_dy(y_line_dy < 3) = 0;
% startf_out = 1;
% endf_out = 1;
% lengthf_out = 1;
% for i = 1 : length(y_line_dy)
%     if y_line_dy(i) == 0
%         startf = i;
%         endf = startf;
%         for endf = startf : length(y_line_dy)
%             if y_line_dy(endf) ~=0
%                 break
%             end
%         end
%         lengthf = endf - startf - 1;
%         if lengthf > lengthf_out
%             lengthf_out = lengthf;
%             startf_out = startf;
%             endf_out = endf - 1;
%             flag(startf:endf) = 0;
%         end
%         i = endf;
%     end
% end
% y_line = y_line(startf_out:endf_out, :);

sample_point_count = 0;
y_line = zeros(5,2);
yz_image_t = yz_image;
while sample_point_count < 5
    for i = length(z0) : -1: 1
        y_sample = find(yz_image_t(i,:) > 0);
        if isempty(y_sample)
            continue
        else
            y_sample = y_sample(1);
            z_sample = i;
            sample_point_count = sample_point_count + 1;
            y_line(sample_point_count, :) = [y_sample, z_sample];
            
            %cut the peak
            start_y = y_sample;
            end_y = y_sample;
            if start_y - 40 > 0
                start_y = start_y - 40;
            else
                start_y = 1;
            end
            if end_y + 40 <= length(y0)
                end_y = end_y + 40;
            else
                end_y = length(y0);
            end
            yz_image_t( :, start_y : end_y) = 0;
            break;
        end
    end
end

%get sample point from tail
while sample_point_count < 6
    for i = length(z0) : -1: 1
        y_sample = find(yz_image_t(i,model_start: model_start + 100) > 0);
        if isempty(y_sample)
            continue
        else
            y_sample = y_sample(1);
            z_sample = i;
            sample_point_count = sample_point_count + 1;
            y_line(sample_point_count, :) = [y_sample, z_sample];
            
            %cut the peak
            start_y = y_sample;
            end_y = y_sample;
            if start_y - 40 > 0
                start_y = start_y - 40;
            else
                start_y = 1;
            end
            if end_y + 40 <= length(y0)
                end_y = end_y + 40;
            else
                end_y = length(y0);
            end
            yz_image_t( :, start_y : end_y) = 0;
            break;
        end
    end
end

f = polyfit(y_line(:,1), y_line(:,2), 1);
if f(1) < 0
    f(1) = 0;
end


%move down the line to the middle of yz_image(startf)
mean_upper_z = 0;
step = 10;
for i = model_start + 1: model_start + step
    z = find(yz_image(:, i) ~= 0);
    if isempty(z)
        mean_upper_z = mean_upper_z + 0;
        continue
    end
    mean_upper_z = z(end) + mean_upper_z;
end
mean_upper_z = mean_upper_z / step / 2;

f(2) =  mean_upper_z - model_start * f(1);
yz_line = zeros(length(y0),2);
for i = 1 : length(y0)
    if floor(polyval(f, i)) >= 1 && floor(polyval(f, i)) <= length(z0)
        start = floor(polyval(f, i)) - 2;
        end_ = floor(polyval(f, i)) + 2;
        if start < 1
            start = 1;
        end
        if end_ > length(z0)
            end_ = length(z0);
        end
        yz_image(start:end_, i) = 30;
    end
    y = (i - 1) / scale + minY;
    z = (polyval(f, i) - 1) / scale + minZ;
    yz_line(i,:) = [y,z];
end
f = polyfit(yz_line(:,1), yz_line(:,2), 1);

faces_left = zeros(length(center_points), 4);
faces_left_count = 1;
y = (model_start - 1) / scale + minY - 0.1;
floor((points_yz(i,1) - minY) * scale) + 1;
for i = 1 : length(center_points)
    if center_points(i, 2) > y && center_points(i, 3) >...
            polyval(f, center_points(i, 2))
        faces_left(faces_left_count, :) = center_points(i, :);
        faces_left_count = faces_left_count + 1;
    end
end
faces_left = faces_left(1 : faces_left_count - 1, :);
%3. rotate the model alone the x axis
theta = atan(f(1));
rotmat = [cos(theta) -sin(theta); sin(theta) cos(theta)];
faces_left(:,2:3) = faces_left(:,2:3) * rotmat;
minZ = min(faces_left(:,3));
maxZ = max(faces_left(:,3));
while maxZ - minZ < 20 
    faec_left_count_pre = length(faces_left);
    f(2) = f(2) - 10;
    faces_left = zeros(length(center_points), 4);
    faces_left_count = 1;
    for i = 1 : length(center_points)
        if center_points(i, 2) > y && center_points(i, 3) >...
                polyval(f, center_points(i, 2))
            faces_left(faces_left_count, :) = center_points(i, :);
            faces_left_count = faces_left_count + 1;
        end
    end
    faces_left = faces_left(1 : faces_left_count - 1, :);
    faces_left(:,2:3) = faces_left(:,2:3) * rotmat;
    minZ = min(faces_left(:,3));
    maxZ = max(faces_left(:,3));
    
    if faec_left_count_pre == length(faces_left)
        break;
    end
end

%3. rotate the model alone the x axis
theta = atan(f(1));
rotmat = [cos(theta) -sin(theta); sin(theta) cos(theta)];



minY = min(faces_left(:,2));
maxY = max(faces_left(:,2));
minZ = min(faces_left(:,3));
maxZ = max(faces_left(:,3));
scale = 10;
y0 = [minY:1/scale:maxY];
z0 = [minZ:1/scale:maxZ];
n_yz_image = zeros(length(z0), length(y0));%yz projection image
for i = 1 : length(faces_left)
    y = floor((faces_left(i,2) - minY) * scale) + 1;
    z = floor((faces_left(i,3) - minZ) * scale) + 1;
    n_yz_image(z, y) = 10;
end
max_y_end = 0;
for i = length(z0) : -1 : floor(length(z0) / 2)
    y_end = find(n_yz_image(i, :) > 0);
    if isempty(y_end)
        continue
    end
    y_end = y_end(end);
    if y_end > max_y_end
        max_y_end = y_end;
    end
end
max_z_end = 0;
if max_y_end < length(y0) - 2
    for i = max_y_end - 1 : length(y0)
        z_end = find(n_yz_image(:, i) > 0);
        if isempty(z_end)
            continue
        end
        z_end = z_end(end);
        if z_end > length(z0) / 2 % for plane y0 front
            continue
        end
        if z_end > max_z_end
            max_z_end = z_end;
        end
    end
    if max_z_end > 2
    n_yz_image( max_z_end-1 :max_z_end , :) = 50;
    end
end

max_z_end = (max_z_end + 1) / scale + minZ;
faces_left = faces_left(faces_left(:,3) > max_z_end,:);

%display result
% subplot(4,1,1)
% image(rot90(rot90(yz_image2)));
% subplot(4,1,2)
% image(rot90(rot90(yz_image)));
% subplot(4,1,3)
% image(rot90(rot90(n_yz_image)));
% subplot(4,1,4)
% scatter3(faces_left(:,1),faces_left(:,2),faces_left(:,3));


