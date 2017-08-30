function [f, x0, y0] = fitContour(vertexs, faces)
% �������ģ����������
% vertexs, faces���㣬��Ԫ�б�
vertexs_count = length(vertexs);
arc_sample_point = zeros(1,2);
arc_sample_count = 0;
vertexs_left = zeros(vertexs_count,3);
vertexs_left_count = 1;

minX = min(vertexs(:,1));
maxX = max(vertexs(:,1));
if maxX - minX < 200
    midX = (minX + maxX) / 2;
    minX = midX - 50;
    maxX = midX + 50;
end
minZ = min(vertexs(:,3));
maxZ = max(vertexs(:,3));
level_plane = (minZ + maxZ) / 3 * 2; %��ʼ�и�ˮƽ��λ��
for i = 1 : vertexs_count
    if(abs(vertexs(i,3) - level_plane) < 0.01)
        arc_sample_count = arc_sample_count + 1;
        arc_sample_point(arc_sample_count,1:2) = vertexs(i,1:2);
    end
    if vertexs(i, 3) < level_plane
        continue;
    else
        vertexs_left(vertexs_left_count,:) = vertexs(i,:);
        vertexs_left_count = vertexs_left_count + 1;
    end
end
vertexs_left = vertexs_left(1:vertexs_left_count - 1,:);
arc_sample_point = sortrows(arc_sample_point,1);
arc_sample_point(:,3) = 1:length(arc_sample_point);

[max_value, max_index] = max(arc_sample_point(:,2));
arc_sample_point1 = arc_sample_point(max_index,:);
left_count = 1;

derv_threshold = 5;
%delete the repeat x value
last_value = max_value;
mean_x = (max(arc_sample_point(:,1)) + min(arc_sample_point(:,1))) / 2;
mean_y = (max(arc_sample_point(:,2)) + min(arc_sample_point(:,2))) / 2;

for i = max_index - 1: -1 : 2
    %     if (last_value - arc_sample_point(i, 2)) ...
    %             < derv_threshold && (last_value - arc_sample_point(i, 2)) > 0
    %         last_value = arc_sample_point(i, 2);
    if norm([(mean_x - arc_sample_point(i, 1)), ...
            (mean_y - arc_sample_point(i, 2))])...
            > 15
        left_count = 1 + left_count;
        arc_sample_point1(left_count,:) = arc_sample_point(i,:);
    end
end
last_value = max_value;
for i = max_index + 1 : arc_sample_count
    if norm([(mean_x - arc_sample_point(i, 1)), ...
            (mean_y - arc_sample_point(i, 2))])...
            > 25
        left_count = 1 + left_count;
        arc_sample_point1(left_count,:) = arc_sample_point(i,:);
    end

%     if (last_value - arc_sample_point(i, 2)) ...
%             < derv_threshold && (last_value - arc_sample_point(i, 2)) > 0
%         last_value = arc_sample_point(i, 2);
%         left_count = 1 + left_count;
%         arc_sample_point1(left_count,:) = arc_sample_point(i,:);
%     end
end
plot(arc_sample_point(:,1),arc_sample_point(:,2),'g*',arc_sample_point1(:,1),arc_sample_point1(:,2),'b', mean_x, mean_y, 'ro');

arc_sample_point1 = sortrows(arc_sample_point1,1);
arc_sample_point = arc_sample_point1;
f = polyfit(arc_sample_point(3:end -3,1),arc_sample_point(3:end -3,2),4);

f(5) = f(5) + 4;%����������������룬��������������άģ����һ������,���޸ĵĿռ䣬��������ʹ��ȫ����ֵ�������ֵС
is_include_all = length(find((polyval(f, vertexs_left(:,1)) - vertexs_left(:,2)) < 0));
while is_include_all > 200
    f(5) = f(5) + 0.1;
    is_include_all = length(find((polyval(f, vertexs_left(:,1)) - vertexs_left(:,2)) < 0));
end
x0 = [minX:0.01:maxX];
y0 = polyval(f,x0);
% hold on
% scatter3(vertexs_left(:,1),vertexs_left(:,2),vertexs_left(:,3))
% scatter(x0,y0)
% hold off

