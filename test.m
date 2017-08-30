clear all;clc;close all;
theta = [-pi:0.01:0]
x = 3 * cos(theta);
y = 1 * sin(theta);
rot = [sin(1) cos(1); cos(1) -sin(1)];
p = [x' y'];
p1 = p * rot;
point_cov = cov(p1(:,1), p1(:,2));
[v, d] = eig(point_cov);
v = v * [0 1; 1 0];
p2 = p1 * v;
plot(x, y,'r',p1(:,1), p1(:,2), 'b',p2(:,1), p2(:,2), '*');
