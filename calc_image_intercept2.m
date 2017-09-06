function [int_image_range, int_image_range_index] = calc_image_intercept2(faces, vertexs, f, level_plane, scale)
%calculate the teeth panoramic projection image
%f: the 4 degree polynomial coefficient

center_points = (vertexs(faces(:,1), :) + vertexs(faces(:,2), :) + vertexs(faces(:,3), :)) ./3;
center_points(:,4) = 1 : length(center_points);
%��Ҫ��������?
proj_image = center_points(center_points(:,3) > level_plane, :);

minX = min(center_points(:,1));
maxX = max(center_points(:,1));
midX = (minX + maxX) / 2;

minY = min(center_points(:,2));
minY_X = -10000;
maxY_X = 10000;
f_y = f;
f_y(5) = f(5) - minY;
res = roots(f_y);
for j = 1:length(res)
    if isreal(res(j))
        if res(j) < midX && ((midX - res(j)) < (midX - minY_X))
            minY_X = res(j);
        end
        if res(j) > midX && ((res(j) - midX) < (maxY_X - midX))
            maxY_X = res(j);
        end
    end
end
minX = min(minX, minY_X) - 5;
maxX = max(maxX, maxY_X) + 5;

x0 = minX:1/scale:maxX - 1;
y0 = polyval(f,x0);
width = floor(sum(sqrt(diff(x0).^2 + diff(y0).^2)));

maxZ = max(vertexs(:,3));
heighth = floor(maxZ - level_plane) + 2;

%calc projection plane coordinate dx = ||dx,f'(x)||
%f(x)f'(x)-y0f'(x)+x-x0=0;
x = length(f)-1:-1:1;
f_derv = f(1:end-1).*x;%f'(x)
% f_f_derv = conv(f,f_derv);%f(x)f'(x)
delta_f_length = 1 / scale; %step
x1 = x0(1); %start from x0(1)
scale_normal = zeros(scale * width,3);%projection plane normal
scale_x = zeros(scale * width,1);%x coordinate in projection plane
for i = 1 : scale * width
    z1 = [x1^3,x1^2,x1^1,1];
    k = z1*f_derv';
    scale_x(i) = x1;
    x1 = scale_x(i) + delta_f_length / sqrt(k^2+1);
    nk = atan(k);
    scale_normal(i,:) = [-sin(nk),cos(nk),0];
end
scale_y = polyval(f, scale_x);


%����ÿ�������Ԫӳ�䵽����ͼ���е����
[int_image_range, int_image_range_index] = calc_range_image(faces, vertexs, f, level_plane, scale);
% int_image_range = zeros(width * scale, heighth * scale);
% int_image_range_index = zeros(width * scale, heighth * scale);
width_start_index = zeros(scale *width,1);
for i = 1 : scale * width
    heighth_start_index = find(int_image_range(i, :) > 0);
    if isempty(heighth_start_index)
        width_start_index(i) = 0;
    else
        width_start_index(i) = heighth_start_index(end);
    end
end
empty_pixels = zeros(scale * width * heighth * scale,2);
empty_pixels_count = 0;

for i = 1 : scale * width
    for j = 1 : width_start_index(i)
        if int_image_range(i,j) == 0
            empty_pixels_count = empty_pixels_count + 1;
            empty_pixels(empty_pixels_count, :) = [i, j];
        end
    end
end
empty_pixels = empty_pixels(1:empty_pixels_count,:);
%��Ч���������?
proj_image_center = center_points(proj_image(:,4),:);
proj_image_index = proj_image(:,4);
%ʹ��kd tree�����ٽ��?
Mdl = createns(proj_image_center(:,1:1:3),'NSMethod','kdtree','Distance','euclidean');
% g = f - [0 0 0 0 5];
disp(empty_pixels_count);
radius = max(max(int_image_range));
for ii = 1 : empty_pixels_count
    if mod(ii ,floor(empty_pixels_count / 100)) == 0
        percent = ii / empty_pixels_count
    end
    j = empty_pixels(ii,1);
    i = empty_pixels(ii,2);
    %���ص���ͶӰ������ά�ռ����ʵ���
    x = scale_x(j);y = scale_y(j);z =  i / scale + level_plane;
    normal = scale_normal(j,:);
    
    %���ص���x-z, y-zƽ����radius�����ڵ��ھ���Ԫ
    idx_pre = [];
    
    idx = cell2mat(rangesearch(Mdl,[x, y, z], radius));
    idx = setdiff(idx, idx_pre);%ȥ����һ����֤��ĵ�?
    
    %����knn�������ĵ��ƽ�淨�ߵļн�?
    center_x = [x y z] - center_points(proj_image_index(idx),1:3);
    arc = acos(center_x * normal' ./ sum(abs(center_x).^2,2).^(1/2));
    arc_index = [arc, (1:length(arc))'];
    arc_index = sortrows(arc_index);
    arc = arc_index(:,1) < 0.05;
    idx = idx(arc_index(arc,2));
    
    %�жϸõ��Ƿ���������Ԫ��ĳһ���н���
    have_cross = 0;
    for face_index = idx
        linepoint1 = [x,y,z]; %��ʼ��
        linepoint2 = [x,y,z] + 5 .* normal; %ֱ���ط��߷�����һ��
        vertexpoint = vertexs(faces(proj_image_index(face_index),1:3), :); %�����Ԫ��?
        [cross_point, have_cross] = validPoint(linepoint1,linepoint2,... %���㽻��
            vertexpoint(1,:),vertexpoint(2,:),vertexpoint(3,:));
        if have_cross == 1  %����н��㣬��ô��ݸ���Ԫ��������Ȩ����ʵ�ʵ��?
            if int_image_range(j, i) == 0
                int_image_range(j, i) = distance([x,y,z], cross_point);
                int_image_range_index(j, i) = proj_image_index(face_index);
            else
                if int_image_range(j, i) > distance([x,y,z], cross_point)
                    int_image_range(j, i) = distance([x,y,z], cross_point);
                    int_image_range_index(j, i) = proj_image_index(face_index);
                end
            end
        end
    end
    if have_cross == 1
        break
    end
end
figure(3);
image(rot90(int_image_range));
%save image_range10.mat int_image_range;



