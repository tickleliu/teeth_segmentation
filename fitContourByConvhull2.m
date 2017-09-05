function [f] = fitContourByConvhull2(vertexs, faces, level_plane)
%calc the teeth contour by poly 4 degree use the convhull method
%use the whole point higher than level_plane

center_points = (vertexs(faces(:,1), :) + vertexs(faces(:,2), :) + vertexs(faces(:,3), :)) ./3;
center_points(:,4) = 1 : length(center_points);
center_points(:,3) = center_points(:,3);

%select sample point to fit the plane
count = 1;
points = zeros(1,2);
for i = 1 : length(center_points)
    z = center_points(i, 3);
    if z - level_plane > 0
        points(count,:) = center_points(i,1:2);
        count = count + 1;
    end
end
points = sortrows(points);

% meanY = mean(points(:, 2));
% varY = var(points(:, 2));

%get the poly sample point use convhull method
h  = convhull(points(:,1), points(:,2));
points_r = points(h,:);
midY1 = median(points_r(1:2, 2));
midY2 = median(points_r(end:-1:end-1, 2));
midY = min(midY1, midY2) * 1.2;

%delete the lowwer points
points_sample = zeros(1,2);
points_sample_count = 1;
for i = 1 : length(points_r)
    if points_r(i,2) > midY
        points_sample(points_sample_count,:) = points_r(i,:);
        points_sample_count = points_sample_count + 1;
    end
end
points_r = points_sample;%the points to fit the poly

f = polyfit_coff(points_r(:,1),points_r(:,2),4);
f(5) = f(5) + 5;% move up to include the whole teeth model

% while length(find(points(:,2) > points_f)) > 3
%     f(5) = f(5) + 1;
%     distance = distance + 1;
%     points_f = polyval(f, points(:,1));
% end

% display the result
% figure(1)
% clf;
% subplot(2,1,1)
% hold on;
% scatter(points(:,1), points(:,2), 'g.');
% scatter(points(:,1), polyval(f, points(:,1)), 'r*');
% subplot(2,1,2)
% minX = min(vertexs(:,1));
% maxX = max(vertexs(:,1));
% minY = min(vertexs(:,2));
% maxY = max(vertexs(:,2));
% 
% if maxX - minX < 150
%     midX = (minX + maxX) / 2;
%     minX = midX - 75;
%     maxX = midX + 75;
% end
% if maxY - minY < 150
%     midY = (minY + maxY) / 2;
%     minY = midY - 75;
%     maxY = midY + 75;
% end
% 
% scale = 10;
% x0 = [minX:1/scale:maxX];
% y0 = [minY:1/scale:maxY];
% up_image = zeros(length(x0), length(y0));
% for i = 1 : length(center_points)
%     
%     x = floor((center_points(i,1) - minX) * scale) + 1;
%     y = floor((center_points(i,2) - minY) * scale) + 1;
%     z = center_points(i,3);
%     
%     if up_image(x, y) == 0
%         up_image(x, y) = z;
%     else
%         up_image(x, y) = max(up_image(x, y), z);
%     end  
% end
% image_deco = up_image;
% points = zeros(1,2);
% for i = 1 : length(center_points)
%     x = floor((center_points(i,1) - minX) * scale) + 1;
%     y = floor((polyval(f, center_points(i,1)) - minY) * scale) + 1;
%     if x >= 1 && x <= length(x0) && y >= 1 && y <= length(y0)
%         image_deco(x, y) = 40;
%     end
%     count = count + 1;
% end
% image(rot90(image_deco));
% hold off;
