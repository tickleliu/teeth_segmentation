function [int_image_range, int_image_range_index] = calc_image_intercept(faces, vertexs, f, level_plane, scale)
%calculate the teeth projection image
%f: the 4 degree polynomial coefficient

%use center point to depict a face, 4 is the face index
center_points = (vertexs(faces(:,1), :) + vertexs(faces(:,2), :) + vertexs(faces(:,3), :)) ./3;
center_points(:,4) = 1 : length(center_points);
%only use the face upper than level_plane
proj_image = center_points(find(center_points(:,3) > level_plane), :);

%% find the image width,use minX, maxX
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

% convert the x axis to poly axis, use dx, dy integral
x0 = [minX:1/scale:maxX - 1];
y0 = polyval(f,x0);
width = floor(sum(sqrt(diff(x0).^2 + diff(y0).^2)));

%% calc the image height
maxZ = max(vertexs(:,3));
heighth = floor(maxZ - level_plane) + 2;

%calc projection plane coordinate dx = ||dx,f'(x)||
%f(x)f'(x)-y0f'(x)+x-x0=0;
x = [length(f)-1:-1:1];
f_derv = f(1:end-1).*x;%f'(x)
f_f_derv = conv(f,f_derv);%f(x)f'(x)
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


%% result
%projection image, and the face to pixel mapping index
int_image_range = zeros(width * scale, heighth * scale);
int_image_range_index = zeros(width * scale, heighth * scale);

%% 
proj_image_center = center_points(proj_image(:,4),:);
proj_image_index = proj_image(:,4);
%create a kd-tree to speed up the nearest point search
Mdl = createns(proj_image_center(:,1:1:3),'NSMethod','kdtree','Distance','euclidean');


% g = f - [0 0 0 0 5];
for i = 1 : heighth * scale
    i
    for j = 1 : width * scale
        %mapping the image pixel x,y to a stl mesh model coordinate x', y'
        x = scale_x(j);y = scale_y(j);z =  i / scale + level_plane;
        normal = scale_normal(j,:);
        
        
        idx_pre = [];idx_ori = [];idx = []; step = 1;radius = 5;%�����뾶
        while(step < 2)

            idx = cell2mat(rangesearch(Mdl,[x, y, z], 5 + step * 20));
            idx_ori = idx;
            idx = setdiff(idx, idx_pre);%ȥ����һ����֤��ĵ�?
 
            if isempty(idx)
                step = step + 1;
                continue
            end
            
            %����knn�������ĵ��ƽ�淨�ߵļн�?
            center_x = [x y z] - center_points(proj_image_index(idx),1:3);
            arc = acos(center_x * normal' ./ sum(abs(center_x).^2,2).^(1/2));
            arc_index = [arc, (1:length(arc))'];
            arc_index = sortrows(arc_index);
            arc = find(arc_index(:,1) < 0.05);
            if length(arc) == 0
                step = step + 1;
                continue
            end
            idx = idx(arc_index(arc,2));
            if mod(j, width) == 0
                length(idx), j
            end
            
            %�жϸõ��Ƿ���������Ԫ��ĳһ���н���
            have_cross = 0;
            cross_point = zeros(1,3);
            for face_index = idx
                linepoint1 = [x,y,z]; %��ʼ��
                linepoint2 = [x,y,z] + 5 .* normal; %ֱ���ط��߷�����һ��
                vertexpoint = vertexs(faces(proj_image_index(face_index),1:3), :); %�����Ԫ��?
                [cross_point, have_cross] = validPoint(linepoint1,linepoint2,... %���㽻��
                    vertexpoint(1,:),vertexpoint(2,:),vertexpoint(3,:));
                if have_cross == 1  %����н��㣬��ô��ݸ���Ԫ��������Ȩ����ʵ�ʵ��?
                    if int_image_range(j, i) == 0
                        int_image_range(j, i) = distance([x,y,z], cross_point)^1.5;
                        int_image_range_index(j, i) = proj_image_index(face_index);
                    else
                        if int_image_range(j, i) > distance([x,y,z], cross_point)^1.5
                            int_image_range(j, i) = distance([x,y,z], cross_point)^1.5;
                            int_image_range_index(j, i) = proj_image_index(face_index);
                        end
                    end
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
% figure(3);
% image(rot90(int_image_range));
%save image_range10.mat int_image_range;



