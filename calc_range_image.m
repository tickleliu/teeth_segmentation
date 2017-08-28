%积分计算曲线长度，根据曲线长度计算image长度范围
% 考虑几个问题1是x转为曲线微元
% 2是调整灰度分布图，
% 3是把没有值得部分填充了
width = floor(sum(sqrt(diff(x0).^2 + diff(y0).^2)));
heighth = 15;
scale = 1;

proj_image = sortrows(proj_image, 1);
scale_x = x0(1);
delta_f_length = 1 / scale;
x1 = x0(1);
for i = 2 : scale * width    
     z1 = [x1^3,x1^2,x1^1,1];
     k = z1*f_derv';
     scale_x(i) = x1 + delta_f_length / sqrt(k^2+1);
     x1 = scale_x(i);
end
image_range = zeros(width * scale, heighth * scale);
image_range_index = zeros(width * scale, heighth * scale);

% 调整顶点的映射，将x坐标转化为曲线坐标
scale_x_index = 1;
vertexs_map_image2 = vertexs_map_image;
vertexs_map_image = sortrows(vertexs_map_image, 1);

for i = 1 : length(vertexs_map_image)  
    if sum(vertexs_map_image(i,1:3)) == 0
        continue
    end   
    x = floor((vertexs_map_image(i,1) - 65) * scale);
    y = floor((vertexs_map_image(i,2) - 5) * scale);
  
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
        image_range(scale_x_index, y) = vertexs_map_image(i,3);
    end
end
vertexs_map_image = sortrows(vertexs_map_image, 4);

scale_x_index = 1;
for i = 1 : length(proj_image)
    
    x = floor((proj_image(i,1) - 65) * scale);
    y = floor((proj_image(i,2) - 5) * scale);
    
    if (x < 1 || x > width * scale || y < 1 || y > heighth * scale)
        continue
    end
    
    while scale_x_index <= length(scale_x)
        if scale_x(scale_x_index) > proj_image(i,1)
            break;
        end
        scale_x_index = scale_x_index + 1;
    end
    image_range(scale_x_index, y) = proj_image(i,3);
    image_range_index(scale_x_index, y) = proj_image(i,4);
    
    %render the face
    face_vertexs = vertexs_map_image(faces(proj_image(i,4),:),:);
    minX = floor(min(face_vertexs(:, 1)));
    maxX = floor(max(face_vertexs(:, 1)));
    minY = floor(min(face_vertexs(:, 2)));
    maxY = floor(max(face_vertexs(:, 2)));
    if minX <= 0
        continue
    end
    if maxX >= scale * width
        continue
    end
    if minY <=0
        continue
    end
    if maxY >= scale * heighth
        continue
    end
%     image_range(minX:maxX, minY:maxY) = proj_image(i,3)^2;
%     image_range_index(minX:maxX, minY:maxY) = proj_image(i,4);    
end
figure(4)
image(rot90(image_range));
vertex_map_image = vertexs_map_image2;
% w = fspecial('laplacian',1);
% image(rot90(imfilter(image_range,w,'replicate')));