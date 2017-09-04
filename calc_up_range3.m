function [up_image, x0, f] = calc_up_range3(vertexs, faces, level_plane)
% 

minX = min(vertexs(:,1));
maxX = max(vertexs(:,1));
minY = min(vertexs(:,2));
maxY = max(vertexs(:,2));
minZ = min(vertexs(:,3));

if maxX - minX < 150
    midX = (minX + maxX) / 2;
    minX = midX - 75;
    maxX = midX + 75;
end
if maxY - minY < 150
    midY = (minY + maxY) / 2;
    minY = midY - 75;
    maxY = midY + 75;
end
scale = 10;
x0 = [minX:1/scale:maxX];
y0 = [minY:1/scale:maxY];
up_image = zeros(length(x0), length(y0));

center_points = (vertexs(faces(:,1), :) + vertexs(faces(:,2), :) + vertexs(faces(:,3), :)) ./3;
center_points(:,4) = 1 : length(center_points);
center_points(:,3) = center_points(:,3) - minZ;
for i = 1 : length(center_points)
    
    x = floor((center_points(i,1) - minX) * scale) + 1;
    y = floor((center_points(i,2) - minY) * scale) + 1;
    z = center_points(i,3);
    
    if z < level_plane
        continue
    end
    
    if up_image(x, y) == 0
        up_image(x, y) = z;
    else
        up_image(x, y) = max(up_image(x, y), z);
    end  
end

count = 1;
temp = up_image;
image_deco = up_image;
points = zeros(1,2);
while count < 30
    [x y] = find(temp == max(max(temp)));
    temp(x-50:x+50, y-50:y + 50) = 0;
    points(count, :) =[x y];
    image_deco(x-5:x+5, y-5:y+5) = 50;
    count = count + 1;
end

points = sortrows(points);
points(:,1) = (points(:,1) - 1) / scale + minX;
points(:,2) = (points(:,2) - 1) / scale + minY;
h  = convhull(points(:,1), points(:,2));
points_result = points;
points = points(h,:);

f = polyfit(points(:,1),points(:,2),4);
points_f = polyval(f, points(:,1));
while length(find(points(:,2) > points_f)) > 3
    f(5) = f(5) + 1;
    points_f = polyval(f, points(:,1));
end

% figure(1)
% clf;
% subplot(2,1,1)
% hold on;
% scatter(points_result(:,1), points_result(:,2), 'g');
% scatter(points_result(:,1), polyval(f, points_result(:,1)), 'r*');
% scatter(points(:,1), points(:,2), 'b');
% subplot(2,1,2)
% image(rot90(image_deco));
% hold off;


