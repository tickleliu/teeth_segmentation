function [int_image_range, int_image_range_index] = calc_image_intercept(faces, vertexs, f)
%计算牙齿模型外表面全局投影
%f：需要投影的四次曲线
%计算沿4次曲线方向投影面长度
x0 = [60:0.01:140];
y0 = polyval(f,x0);
width = floor(sum(sqrt(diff(x0).^2 + diff(y0).^2)));
heighth = 15;
scale = 5;%投影缩放尺度
level_plane = 6; %初始切割水平线位置

%计算四次曲面上等距离点的x，y坐标
%切点方程 f(x)f'(x)-y0f'(x)+x-x0=0;
x = [length(f)-1:-1:1];
f_derv = f(1:end-1).*x;%f'(x)
f_f_derv = conv(f,f_derv);%f(x)f'(x)
delta_f_length = 1 / scale; %缩放尺度
x1 = x0(1); %投影面第一个点
scale_normal = zeros(scale * width,3);%投影面法向量?
scale_x = zeros(scale * width,1);%4次平面上的x坐标
for i = 1 : scale * width
    z1 = [x1^3,x1^2,x1^1,1];
    k = z1*f_derv';
    scale_x(i) = x1;
    x1 = scale_x(i) + delta_f_length / sqrt(k^2+1);
    nk = atan(k);
    scale_normal(i,:) = [-sin(nk),cos(nk),0];
end
%4次曲面上等距点对应的y坐标
scale_y = polyval(f, scale_x);


center_points = (vertexs(faces(:,1), :) + vertexs(faces(:,2), :) + vertexs(faces(:,3), :)) ./3;
center_points(:,4) = 1 : length(center_points);
%需要考察的面元
proj_image = center_points(find(center_points(:,3) > level_plane), :);

%计算每个三角面元映射到最终图像中的坐标
int_image_range = zeros(width * scale, heighth * scale);
int_image_range_index = zeros(width * scale, heighth * scale);

%有效点坐标和序号?
proj_image_center = center_points(proj_image(:,4),:);
proj_image_index = proj_image(:,4);
%使用kd tree搜索临近点
Mdl = createns(proj_image_center(:,1:1:3),'NSMethod','kdtree','Distance','euclidean');


% g = f - [0 0 0 0 5];
for i = 1 : heighth * scale - floor(1.5*scale)
    i
    for j = 1 + 30 * scale : width * scale - 30 * scale
        %锟斤拷锟截碉拷锟斤拷投影锟斤拷锟斤拷锟斤拷维锟秸硷拷锟斤拷锟绞碉拷锟斤拷
        x = scale_x(j);y = scale_y(j);z =  i / scale + level_plane;
        normal = scale_normal(j,:);
        
        %锟斤拷锟截碉拷锟斤拷x-z, y-z平锟斤拷锟斤拷radius锟斤拷锟斤拷锟节碉拷锟节撅拷锟斤拷元
        idx_pre = [];idx_ori = [];idx = []; step = 1;radius = 5;%锟斤拷锟斤拷锟诫径
        while(step < 2)

            idx = cell2mat(rangesearch(Mdl,[x, y, z], 5 + step * 20));
            idx_ori = idx;
            idx = setdiff(idx, idx_pre);%去掉上一轮验证过的点
 
            if isempty(idx)
                step = step + 1;
                continue
            end
            
            %计算knn搜索到的点和平面法线的夹角
            center_x = [x y z] - center_points(proj_image_index(idx),1:3);
            arc = acos(center_x * normal' ./ sum(abs(center_x).^2,2).^(1/2));
            arc_index = [arc, (1:length(arc))'];
            arc_index = sortrows(arc_index);
            arc = find(arc_index(:,1) < 0.1);
            if length(arc) == 0
                step = step + 1;
                continue
            end
            idx = idx(arc_index(arc,2));
            if mod(j, width) == 0
                length(idx), j
            end
            
            %锟叫断该碉拷锟角凤拷锟斤拷锟斤拷锟斤拷锟斤拷元锟斤拷某一锟斤拷锟叫斤拷锟斤拷
            have_cross = 0;
            cross_point = zeros(1,3);
            for face_index = idx
                linepoint1 = [x,y,z]; %锟斤拷始锟斤拷
                linepoint2 = [x,y,z] + 5 .* normal; %直锟斤拷锟截凤拷锟竭凤拷锟斤拷锟斤拷一锟斤拷
                vertexpoint = vertexs(faces(proj_image_index(face_index),1:3), :); %锟斤拷锟斤拷锟皆拷锟?
                [cross_point, have_cross] = validPoint(linepoint1,linepoint2,... %锟斤拷锟姐交锟斤拷
                    vertexpoint(1,:),vertexpoint(2,:),vertexpoint(3,:));
                if have_cross == 1  %锟斤拷锟斤拷薪锟斤拷悖拷锟矫达拷锟捷革拷锟斤拷元锟斤拷锟斤拷锟斤拷锟斤拷权锟斤拷锟斤拷实锟绞碉拷锟?
                    if int_image_range(j, i) == 0
                        int_image_range(j, i) = distance([x,y,z], cross_point)^1.5;
                    else
                        int_image_range(j, i) = min(int_image_range(j, i), distance([x,y,z], cross_point)^1.5);
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%修改映射点的坐标，未完成%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    int_image_range_index(j, i) = proj_image_index(face_index);
                end
            end
            if have_cross == 1               
                break
            else
                step = step + 1;
                idx_pre = idx_ori;
            end
        end
    end
end
figure(3);
image(rot90(int_image_range));
%save image_range10.mat int_image_range;



