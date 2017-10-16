function f_in = inner_contour_fit(faces, vertexs, f, level_plane)
%calculate the teeth inner projection image
%f: the 4 degree polynomial coefficient

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
    maxX = max(center_points(:,1)) + 10;
end

x0 = minX:maxX - 1;
y0 = polyval(f,x0);

%calc projection plane coordinate dx = ||dx,f'(x)||
%f(x)f'(x)-y0f'(x)+x-x0=0;
x = length(f)-1:-1:1;
f_derv = f(1:end-1).*x;%f'(x)
y0_ = polyval(f_derv, x0);
eps = 0.0000000001;
t = 17;
k_ = atan(- 1./ (y0_ + eps));
x0_ = x0 - cos(k_) * t .* sign(sin(k_));
y0_ = y0 - sin(k_) * t .* sign(sin(k_));

f_in = polyfit(x0_, y0_, 4);
y0_ = polyval(f_in, x0);
% plot(x0, y0, 'r', x0, y0_, 'b');
