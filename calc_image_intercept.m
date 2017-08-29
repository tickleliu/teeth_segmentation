function [int_image_range, int_image_range_index] = calc_image_intercept(x0, y0)

%��ּ������߳��ȣ�������߳��ȼ���image���ȷ�Χ
width = floor(sum(sqrt(diff(x0).^2 + diff(y0).^2)));
heighth = 15;
scale = 5;%ͼ�����ų߶�
% proj_image = sortrows(proj_image, [1, 2]);


%�������ת��Ϊ�����߶����,�������Ӧ��ķ��򣬷��߷���ƽ����xyƽ�棨nx,ny,0��
delta_f_length = 1 / scale; %���߲����
x1 = x0(1); %��һ�������
scale_normal = zeros(1,3);%ÿһ��ķ���
scale_x = zeros(1,1);%�Ե�λ���߳��ȶ���ĺ����
for i = 1 : scale * width
    z1 = [x1^3,x1^2,x1^1,1];
    k = z1*f_derv';
    scale_x(i) = x1;
    x1 = scale_x(i) + delta_f_length / sqrt(k^2+1);
    nk = atan(k);
    scale_normal(i,:) = [-sin(nk),cos(nk),0];
end

%�������߶�����������������
scale_y = polyval(f, scale_x);

%��ɵ�ͼ���Լ�ͼ�����ض�Ӧ��face index
int_image_range = zeros(width * scale, heighth * scale);
int_image_range_index = zeros(width * scale, heighth * scale);

%Ѱ����Ч��Ԫ�� �ֱ��¼���ĵ�����
proj_image_center = center_points(proj_image(:,4),:);
proj_image_index = proj_image(:,4);
%��������Ч��Ԫ���ĵ㹹��kd tree
% Mdl = createns(proj_image_center(:,1:2:3),'NSMethod','kdtree','Distance','euclidean');
% Mdly = createns(proj_image_center(:,2:3),'NSMethod','kdtree','Distance','euclidean');
Mdl = createns(proj_image_center(:,1:1:3),'NSMethod','kdtree','Distance','euclidean');
%����ÿһ�����ض�Ӧ���ߺ������Ԫ�Ľ���

g = f - [0 0 0 0 5];
for i = 1 : heighth * scale - floor(1.5*scale)
    i
    for j = 1 + 30 * scale : width * scale - 30 * scale
% for i = 71
%     i
%     for j = 620
        %���ص���ͶӰ������ά�ռ����ʵ���
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
        %���ص㷨��
        normal = scale_normal(j,:);
        
        %���ص���x-z, y-zƽ����radius�����ڵ��ھ���Ԫ
        idx_pre = [];idx_ori = [];idx = []; step = 1;radius = 5;%�����뾶
        while(step < 2)
            %             idx = cell2mat(rangesearch(Mdl,[x,z], radius*step));
            %             idy = cell2mat(rangesearch(Mdly,[y,z], radius*step));
            %             idx = knnsearch(Mdl,[x,z], 'k', 1000 * step);
            %             idy = knnsearch(Mdly,[y,z], 'k', 1000 * step);
            idx = cell2mat(rangesearch(Mdl,[x, y, z], 5 + step * 20));
            %             idx = union(idx, idy);%���������Ԫ�Ĳ���
            idx_ori = idx;
            idx = setdiff(idx, idx_pre);%�µ������Ԫ
            %             ������Ԫ���ĵ�ͷ��߼нǣ����˼нǴ�ĵ�
            
            
            if isempty(idx)
                step = step + 1;
                continue
            end
            
            center_x = [x y z] - center_points(proj_image_index(idx),:);
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
            %�жϸõ��Ƿ���������Ԫ��ĳһ���н���
            have_cross = 0;
            cross_point = zeros(1,3);
            for face_index = idx
                linepoint1 = [x,y,z]; %��ʼ��
                linepoint2 = [x,y,z] + 5 .* normal; %ֱ���ط��߷�����һ��
                vertexpoint = vertexs(faces(proj_image_index(face_index),1:3), :); %�����Ԫ��
                [cross_point, have_cross] = validPoint(linepoint1,linepoint2,... %���㽻��
                    vertexpoint(1,:),vertexpoint(2,:),vertexpoint(3,:));
                if have_cross == 1  %����н��㣬��ô��ݸ���Ԫ��������Ȩ����ʵ�ʵ��
                    if int_image_range(j, i) == 0
                        int_image_range(j, i) = distance([x,y,z], cross_point)^1.5;
                    else
                        int_image_range(j, i) = min(int_image_range(j, i), distance([x,y,z], cross_point)^1.5);
                    end
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%��Ҫ������Ԫ����㷨%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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



