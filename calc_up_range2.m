function [f] = calc_up_range2(vertexs, faces, level_plane)
%
center_points = (vertexs(faces(:,1), :) + vertexs(faces(:,2), :) + vertexs(faces(:,3), :)) ./3;
center_points(:,4) = 1 : length(center_points);
center_points(:,3) = center_points(:,3);
count = 1;
points = zeros(1,2);
for i = 1 : length(center_points)
    z = center_points(i, 3);
    if abs(z - level_plane) < 0.01
        points(count,:) = center_points(i,1:2);
        count = count + 1;
    end
end

points = sortrows(points);

% meanY = mean(points(:, 2));
% varY = var(points(:, 2));

h  = convhull(points(:,1), points(:,2));
points_r = points(h,:);
midY1 = median(points_r(1:2, 2));
midY2 = median(points_r(end:-1:end-1, 2));
midY = min(midY1, midY2) * 1.2;

points_sample = zeros(1,2);
points_sample_count = 1;
for i = 1 : length(points_r)
    if points_r(i,2) > midY
        points_sample(points_sample_count,:) = points_r(i,:);
        points_sample_count = points_sample_count + 1;
    end
end
points_r = points_sample;
f = polyfit(points_r(:,1),points_r(:,2),4);
points_f = polyval(f, points(:,1));
while length(find(points(:,2) > points_f)) > 3
    f(5) = f(5) + 1;
    points_f = polyval(f, points(:,1));
end
% hold on
% scatter(points(:,1), points(:,2), 'bo');
% scatter(points(:,1), points_f, 'g*');
% hold off
%f(x)f'(x)-y0f'(x)+x-x0=0;
x = [length(f)-1:-1:1];
f_derv = f(1:end-1).*x;%f'(x)
f_f_derv = conv(f,f_derv);%f(x)f'(x)
depth = zeros(1,2);
for i = 1:length(points)
    xy = points(i,:);
    depth(i,1) = 1000;
    f_tangent=f_f_derv+[0 0 0 0 -1*xy(2)*f_derv] +[0 0 0 0 0 0 1 -1*xy(1)];
    res = roots(f_tangent);
    for j = 1:length(res)
        if isreal(res(j))
            depth_cur = norm([(res(j)-xy(1)), (xy(2) - polyval(f, res(j)))]);
            if depth_cur < depth(i,1) 
                depth(i,1) = depth_cur;
            end
        end
    end
end
depth(:,2) = [1 : length(depth)];
depth = sortrows(depth,1);
points_result = points(depth(1:floor(length(points) / 4 * 3),2),:);

f_r = polyfit(points_result(:,1),points_result(:,2),4);

points_f = polyval(f_r, points_result(:,1));
while length(find(points_result(:,2) > points_f)) > 3
    f_r(5) = f_r(5) + 1;
    points_f = polyval(f_r, points_result(:,1));
end
figure(1)
clf;
hold on;
scatter(points(:,1), points(:,2), 'g.');
scatter(points(:,1), polyval(f, points(:,1)), 'r*');
% scatter(points_result(:,1), points_result(:,2), 'bo');
% scatter(points_result(:,1), polyval(f_r, points_result(:,1)), 'r*');
hold off;
