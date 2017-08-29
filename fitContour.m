function f = fitContour(vertexs, faces)
% 拟合牙齿模型外轮廓线
% vertexs, faces顶点，面元列表
vertexs_count = length(vertexs);
arc_sample_point = zeros(1,2);
arc_sample_count = 0;
vertexs_left = zeros(vertexs_count,3);
vertexs_left_count = 1;
level_plane = 6; %初始切割水平线位置
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

derv_threshold = 10;
%delete the repeat x value
last_value = max_value;
for i = max_index - 1: -1 : 2
    if (last_value - arc_sample_point(i, 2)) ...
            < derv_threshold && (last_value - arc_sample_point(i, 2)) > 0
        last_value = arc_sample_point(i, 2);
        left_count = 1 + left_count;
        arc_sample_point1(left_count,:) = arc_sample_point(i,:);
    end    
end

last_value = max_value;
for i = max_index + 1 : arc_sample_count
    if (last_value - arc_sample_point(i, 2)) ...
            < derv_threshold && (last_value - arc_sample_point(i, 2)) > 0
        last_value = arc_sample_point(i, 2);
        left_count = 1 + left_count;
        arc_sample_point1(left_count,:) = arc_sample_point(i,:);
    end
end
arc_sample_point1 = sortrows(arc_sample_point1,1);
arc_sample_point = arc_sample_point1;
plot(arc_sample_point(:,1),arc_sample_point(:,2),'g*',arc_sample_point1(:,1),arc_sample_point1(:,2),'b');
f = polyfit(arc_sample_point(3:end -3,1),arc_sample_point(3:end -3,2),4);

f(5) = f(5) + 4;%将顶点上移五个距离，是外轮廓线与三维模型有一定距离,有修改的空间，可以搜索使得全部的值都比这个值小
is_include_all = length(find((polyval(f, vertexs_left(:,1)) - vertexs_left(:,2)) < 0));
while is_include_all > 200
    f(5) = f(5) + 0.1;
    is_include_all = length(find((polyval(f, vertexs_left(:,1)) - vertexs_left(:,2)) < 0));
end
x0 = [60:0.01:140];
y0 = polyval(f,x0);
hold on
scatter3(vertexs_left(:,1),vertexs_left(:,2),vertexs_left(:,3))
scatter(x0,y0)

