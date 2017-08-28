

%积分计算曲线长度，根据曲线长度计算image长度范围
width = floor(sum(sqrt(diff(x0).^2 + diff(y0).^2)));
heighth = 15;
scale = 10;%图像缩放尺度
% proj_image = sortrows(proj_image, [1, 2]);


%将横坐标转换为曲线线段坐标,并计算对应点的法向，法线方向平行移xy平面（nx,ny,0）
delta_f_length = 1 / scale; %曲线步进长度
x1 = x0(1); %第一个点坐标
scale_normal = zeros(1,3);%每一点的法向
scale_x = zeros(1,1);%以单位曲线长度定义的横坐标
for i = 1 : scale * width
    z1 = [x1^3,x1^2,x1^1,1];
    k = z1*f_derv';
    scale_x(i) = x1;
    x1 = scale_x(i) + delta_f_length / sqrt(k^2+1);
    nk = atan(k);
    scale_normal(i,:) = [-sin(nk),cos(nk),0];
end

%以曲线线段坐标做横坐标的纵坐标
scale_y = polyval(f, scale_x);

%生成的图像，以及图像像素对应的face index
int_image_range = zeros(width * scale, heighth * scale);
int_image_range_index = zeros(width * scale, heighth * scale);

%寻找有效面元， 分别记录中心点和序号
proj_image_center = center_points(proj_image(:,4),:);
proj_image_index = proj_image(:,4);
%将利用有效面元中心点构造kd tree
% Mdl = createns(proj_image_center(:,1:2:3),'NSMethod','kdtree','Distance','euclidean');
% Mdly = createns(proj_image_center(:,2:3),'NSMethod','kdtree','Distance','euclidean');
Mdl = createns(proj_image_center(:,1:1:3),'NSMethod','kdtree','Distance','euclidean');
%计算每一个像素对应法线和最近面元的交点

g = f - [0 0 0 0 5];
for i = 1 : heighth * scale - floor(1.5*scale)
    i
    for j = 1 + 30 * scale : width * scale - 30 * scale
% for i = 71
%     i
%     for j = 620
        %像素点在投影面在三维空间的真实坐标
        x = scale_x(j);y = scale_y(j);z =  i / scale + 5;
        
        %         f_derv_x = polyval(f_derv, x);
        %         f_tangent= [0 0 0 -1 (x-f_derv_x*y)]+ f_derv_x * g;
        %         res = roots(f_tangent);
        %         for k = 1:length(res)
        %             if abs(res(k)-x) < 20 && isreal(res(k))
        %                 x_n = res(k);
        %                 break;
        %             end
        %         end
        %         y_n = polyval(g, x_n);
        %像素点法向
        normal = scale_normal(j,:);
        
        %像素点在x-z, y-z平面上radius距离内的邻居面元
        idx_pre = [];idx_ori = [];idx = []; step = 0;radius = 5;%搜索半径
        while(step < 3)
            %             idx = cell2mat(rangesearch(Mdl,[x,z], radius*step));
            %             idy = cell2mat(rangesearch(Mdly,[y,z], radius*step));
            %             idx = knnsearch(Mdl,[x,z], 'k', 1000 * step);
            %             idy = knnsearch(Mdly,[y,z], 'k', 1000 * step);
            idx = cell2mat(rangesearch(Mdl,[x, y, z], 5 + step * 10));
            %             idx = union(idx, idy);%搜索三角面元的并集
            idx_ori = idx;
            idx = setdiff(idx, idx_pre);%新的三角面元
            %             计算面元中心点和法线夹角，过滤夹角大的点
            
            
            if isempty(idx)
                step = step + 1;
                continue
            end
            
            center_x = [x y z] - center_points(proj_image_index(idx),:);
            arc = acos(center_x * normal' ./ sum(abs(center_x).^2,2).^(1/2));
            arc_index = [arc, (1:length(arc))'];
            arc_index = sortrows(arc_index);
            arc = find(arc_index(:,1) < 0.2);
            if length(arc) == 0
                step = step + 1;
                continue
            end
            idx = idx(arc_index(arc,2));
            if mod(j, width) == 0
                length(idx), j
            end
            %判断该点是否与上述面元的某一个有交点
            have_cross = 0;
            cross_point = zeros(1,3);
            for face_index = idx
                linepoint1 = [x,y,z]; %起始点
                linepoint2 = [x,y,z] + 5 .* normal; %直线沿法线方向另一点
                vertexpoint = vertexs(faces(proj_image_index(face_index),1:3), :); %三角面元点
                [cross_point, have_cross] = validPoint(linepoint1,linepoint2,... %计算交点
                    vertexpoint(1,:),vertexpoint(2,:),vertexpoint(3,:));
                if have_cross == 1  %如果有交点，那么根据该面元三个顶点加权计算实际点距
                    if int_image_range(j, i) == 0
                        int_image_range(j, i) = distance([x,y,z], cross_point)^1.5;
                    else
                        int_image_range(j, i) = min(int_image_range(j, i), distance([x,y,z], cross_point)^1.5);
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%需要更新面元序号算法%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
% save image_range10.mat int_image_range;



