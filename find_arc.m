
vertexs_count = length(vertexs);
arc_sample_point = zeros(1,2);
arc_sample_count = 0;
for i = 1 : vertexs_count
    if(abs(vertexs(i,3) - 5) < 0.01)
        arc_sample_count = arc_sample_count + 1;
        arc_sample_point(arc_sample_count,1:2) = vertexs(i,1:2);
    end
end

arc_sample_point = sortrows(arc_sample_point,1);

arc_sample_point1 = arc_sample_point(1,:);
left_count = 1;
step = 5;
last_value = mean(arc_sample_point(1:10,2));
derv_threshold = 10;
%delete the repeat x value
for i = 2 : arc_sample_count
    if arc_sample_point(i - 1, 1) ~= arc_sample_point(i, 1)
        %         abs((arc_sample_point(i, 2) - last_value) / ...
        %                 (arc_sample_point(i - 1, 1) - arc_sample_point(i, 1)))
        if abs((arc_sample_point(i, 2) - last_value)) ...
                < derv_threshold
            last_value = arc_sample_point(i, 2);
            left_count = 1 + left_count;
            arc_sample_point1(left_count,:) = arc_sample_point(i,:);
        end
    end
end
arc_sample_point = arc_sample_point1;
% plot(arc_sample_point(:,1),arc_sample_point(:,2),'g*',arc_sample_point1(:,1),arc_sample_point1(:,2),'b');
% f = interp1(arc_sample_point(:,1),arc_sample_point(:,2), [60:0.1:130], 'nearest');
f = polyfit(arc_sample_point(3:end -3,1),arc_sample_point(3:end -3,2),4);
f(5) = f(5) + 5;%ffffffffffffffffffffffffffffffffffff
x0 = [60:0.01:140];
y0 = polyval(f,x0);
plot(arc_sample_point(:,1),arc_sample_point(:,2),'-r', x0,y0,'-b');


