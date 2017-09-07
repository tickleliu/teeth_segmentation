function [image_range, image_range_index] = calc_range_image(faces, vertexs, f, level_plane, scale)

%积分计算曲线长度，根据曲线长度计算image长度范围
% 考虑几个问题1是x转为曲线微元
% 2是调整灰度分布图，
% 3是把没有值得部分填充了

center_points = (vertexs(faces(:,1), :) + vertexs(faces(:,2), :) + vertexs(faces(:,3), :)) ./3;
center_points(:,4) = 1 : length(center_points);
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

if minX < -100
    minX = min(center_points(:,1)) - 10;
end

if maxX > 100
    maxX = max(center_points(:,1))  + 10;
end

x0 = [minX:1/scale:maxX - 1];
y0 = polyval(f,x0);
width = floor(sum(sqrt(diff(x0).^2 + diff(y0).^2)));
maxZ = max(center_points(:,3));
minZ = level_plane;
heighth = floor(maxZ - level_plane) + 2;
image_range = zeros(width * scale, heighth * scale);
image_range_index = zeros(width * scale, heighth * scale);

[proj_image, vertexs_map_image] = calcDepth(faces, vertexs, f, level_plane);
proj_image = sortrows(proj_image, 1);
scale_x = x0(1);
delta_f_length = 1 / scale;
x1 = x0(1);
x = [length(f)-1:-1:1];
f_derv = f(1:end-1).*x;%f'(x)
for i = 2 : scale * width
    z1 = [x1^3,x1^2,x1^1,1];
    k = z1*f_derv';
    scale_x(i) = x1 + delta_f_length / sqrt(k^2+1);
    x1 = scale_x(i);
end


% 调整顶点的映射，将x坐标转化为曲线坐标
scale_x_index = 1;
vertexs_map_image = sortrows(vertexs_map_image, 1);

for i = 1 : length(vertexs_map_image)
    if vertexs_map_image(i, 3) > 20
        continue
    end
    if sum(vertexs_map_image(i,1:3)) == 0
        continue
    end
    x = floor((vertexs_map_image(i,1) - minX) * scale);
    y = floor((vertexs_map_image(i,2) - minZ) * scale);
    
    while scale_x_index <= length(scale_x)
        if scale_x(scale_x_index) > vertexs_map_image(i,1)
            break;
        end
        scale_x_index = scale_x_index + 1;
    end
    vertexs_map_image(i,1) = scale_x_index;
    vertexs_map_image(i,2) = y;
    
    if scale_x_index >=1 && scale_x_index <= width * scale ...
            && y >=1 && y <= heighth * scale
        if image_range(scale_x_index, y) ==0
            image_range(scale_x_index, y) = vertexs_map_image(i,3);
        else
            image_range(scale_x_index, y) = min(vertexs_map_image(i,3), image_range(scale_x_index, y));
        end
    end
end

scale_x_index = 1;
for i = 1 : length(proj_image)
    if proj_image(i, 3) > 20
        continue
    end
    x = floor((proj_image(i,1) - minX) * scale);
    y = floor((proj_image(i,2) - minZ) * scale);
    
    if (x < 1 || x > width * scale || y < 1 || y > heighth * scale)
        continue
    end
    
    while scale_x_index <= length(scale_x)
        if scale_x(scale_x_index) > proj_image(i,1)
            break;
        end
        scale_x_index = scale_x_index + 1;
    end
    if image_range(scale_x_index, y) ==0
        image_range(scale_x_index, y) = proj_image(i,3);
    else
        image_range(scale_x_index, y) = min(proj_image(i,3), image_range(scale_x_index, y));
    end
    image_range_index(scale_x_index, y) = proj_image(i,4);
end
% image_range = fillhole(image_range, scale);
% figure(4)
% image(rot90(image_range));
% w = fspecial('laplacian',1);
% image(rot90(imfilter(image_range,w,'replicate')));