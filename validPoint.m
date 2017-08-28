function  [CrossPoint, flag] = validPoint(LinePoint1, LinePoint2, TrianglePoint1, TrianglePoint2,TrianglePoint3)
   
    %TriangleV 三角形所在平面的法向量
    %VP12, VP13; 三角形的边方向向量    
    %CrossPoint 直线与平面的交点
    %TriD; 平面方程常数项
    
    CrossPoint = zeros(1,3);   
    LineV = LinePoint2 - LinePoint1;
    %-------计算平面的法向量及常数项-------%
    %point1->point2
    VP12(1) = TrianglePoint2(1) - TrianglePoint1(1);
    VP12(2) = TrianglePoint2(2) - TrianglePoint1(2);
    VP12(3) = TrianglePoint2(3) - TrianglePoint1(3);
    %point1->point3
    VP13(1) = TrianglePoint3(1) - TrianglePoint1(1);
    VP13(2) = TrianglePoint3(2) - TrianglePoint1(2);
    VP13(3) = TrianglePoint3(3) - TrianglePoint1(3);
    %VP12xVP13
    TriangleV(1) = VP12(2)*VP13(3) - VP12(3)*VP13(2);
    TriangleV(2) = -(VP12(1)*VP13(3) - VP12(3)*VP13(1));
    TriangleV(3) = VP12(1)*VP13(2) - VP12(2)*VP13(1);
    %计算常数项
    TriD = -(TriangleV(1)*TrianglePoint1(1) ...
        + TriangleV(2)*TrianglePoint1(2) ...
        + TriangleV(3)*TrianglePoint1(3));
    %/*-------求解直线与平面的交点坐标---------*/
%     /* 思路：
%     * 首先将直线方程转换为参数方程形式，然后代入平面方程，求得参数t，
%     * 将t代入直线的参数方程即可求出交点坐标
%     */
    %临时变量
    
    tempU = TriangleV(1)*LinePoint1(1) + TriangleV(2)*LinePoint1(2) ...
        + TriangleV(3)*LinePoint1(3) + TriD;
    tempD = TriangleV(1)*LineV(1) + TriangleV(2)*LineV(2) + TriangleV(3)*LineV(3);
   
    %直线与平面平行或在平面上
    if (tempD == 0.0)
        %printf("The line is parallel with the plane.\n");
        flag =  0;
        return;
    end
    %计算参数t
    t = -tempU / tempD;
    %计算交点坐标
    CrossPoint(1) = LineV(1)*t + LinePoint1(1);
    CrossPoint(2) = LineV(2)*t + LinePoint1(2);
    CrossPoint(3) = LineV(3)*t + LinePoint1(3);

    %     /*----------判断交点是否在三角形内部---*/
    %计算三角形三条边的长度
     d12 = distance(TrianglePoint1, TrianglePoint2);
     d13 = distance(TrianglePoint1, TrianglePoint3);
     d23 = distance(TrianglePoint2, TrianglePoint3);
    %计算交点到三个顶点的长度
     c1 = distance(CrossPoint, TrianglePoint1);
     c2 = distance(CrossPoint, TrianglePoint2);
     c3 = distance(CrossPoint, TrianglePoint3);
    %求三角形及子三角形的面积
     areaD = area(d12, d13, d23); %三角形面积
     area1 = area(c1, c2, d12); %子三角形1
     area2 = area(c1, c3, d13); %子三角形2
     area3 = area(c2, c3, d23); %子三角形3
    %根据面积判断点是否在三角形内部
    if (abs(area1 + area2 + area3 - areaD) > 0.001)
        flag =  0;
        return;
    end
    flag = 1;
end