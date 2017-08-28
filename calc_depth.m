%计算mesh中点到投影面距离
% calc the vertex deepth
% calc the tangent point
%切点方程 f(x)f'(x)-y0f'(x)+x-x0=0;
hold on;
x = [length(f)-1:-1:1];
f_derv = f(1:end-1).*x;%f'(x)
f_f_derv = conv(f,f_derv);%f(x)f'(x)
for i = 1:length(arc_sample_point)
    xy = arc_sample_point(i,:);
    f_tangent=f_f_derv+[0 0 0 0 -1*xy(2)*f_derv] +[0 0 0 0 0 0 1 -1*xy(1)];
    res = roots(f_tangent);
    for j = 1:length(res)
        if abs(res(j)-xy(1)) < 5 && isreal(res(j))
            line([xy(1), res(j)],[xy(2), polyval(f, res(j))]);
            x1 = res(j);
            z1 = [x1^3,x1^2,x1^1,1];
            k = z1*f_derv';
            t = 10;
            nk = atan(k);
            ex_normal = [-sin(nk),cos(nk)];
            t = 5;
            line([res(j) + t * ex_normal(1), res(j)],[polyval(f, res(j)) + t * ex_normal(2), polyval(f, res(j))]);
        end
    end
end

%genelize the range map
%计算每个顶点（vertex）映射到最终图中的坐标
disp 'calculate the vertexs projection'
proj_image = zeros(1,4);%1 映射到曲线的x坐标，2z坐标，3到拟合曲线距离，4面元index
proj_image_length = 1;
vertexs_map_image = zeros(length(vertexs),4);
res_threshold = 10;
for i = 1 : length(vertexs)
    vertexs_map_image(i, 4) = i;
    if vertexs(i, 3) < 4
        continue;
    end
    xy = vertexs(i,1:2);
    f_tangent=f_f_derv+[0 0 0 0 -1*xy(2)*f_derv] +[0 0 0 0 0 0 1 -1*xy(1)];
    res = roots(f_tangent);
    for j = 1:length(res)
        if abs(res(j)-xy(1)) < res_threshold && isreal(res(j))
            vertexs_map_image(i,1:3) = [res(j), vertexs(i,3), norm([res(j), polyval(f,res(j))] - xy)];           
            break
        end
    end
    if mod(i, 10000) == 0
        i
    end
end

%计算每个三角面元映射到最终图像中的坐标
disp 'calculate the faces projection'
center_points = (vertexs(faces(:,1), :) + vertexs(faces(:,2), :) + vertexs(faces(:,3), :)) ./3;
% for i = 1 : length(faces)
%     center_points(i,:) = (vertexs(faces(i,1), :) + vertexs(faces(i,2), :) + vertexs(faces(i,3), :)) ./3;
%     if mod(i, 10000) == 0
%         i
%     end
% end

for i = 1 : length(faces)
    if center_points(i, 3) < 5 %只考虑水平线以上的面元
        continue;
    end
    xy = center_points(i, 1:2);
    f_tangent=f_f_derv + [0 0 0 0 -1*xy(2)*f_derv] + [0 0 0 0 0 0 1 -1*xy(1)];
    res = roots(f_tangent);
    for j = 1:length(res)
        if abs(res(j)-xy(1)) < res_threshold && isreal(res(j))
            proj_image(proj_image_length,1:3) = [res(j), center_points(i,3), norm([res(j), polyval(f,res(j))] - xy)];
            proj_image(proj_image_length,4) = i;
            proj_image_length = proj_image_length + 1;
            break
        end
    end
    if mod(i, 10000) == 0
        i
    end
end

