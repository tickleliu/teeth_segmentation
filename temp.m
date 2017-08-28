
x =  [ 112.8706  -59.8398    9.2000];
normal = [0.4917    0.8708         0];
t = -20: 0.1 :0;
xline = zeros(length(t),3);
xline(:,1) = (normal(1) .* t + x(1))';
xline(:,2) = normal(2) .* t + x(2);
xline(:,3) = normal(3) .* t + x(3);
vertexpoint = [
    105.6288  -72.6496    9.3533
    105.3778  -72.8053    9.1727
    105.7295  -72.8090    9.2008];
cross_point = [105.5553  -72.7942    9.2000];
center_point = [105.5787  -72.7546    9.2423];

vertexpoint1 =[
    110.2712  -64.3639    9.1293
    110.1909  -64.5264    9.3207
    110.2773  -64.5505    9.2363];

center_point1 = [  110.2465  -64.4803    9.2288];
cross_point = [ 110.2612  -64.4608    9.2000];
distance(x, center_point)
distance(x, center_point1)
figure;
hold on
fill3(vertexpoint(:,1),vertexpoint(:,2),vertexpoint(:,3),[1 1 1])
fill3(vertexpoint1(:,1),vertexpoint1(:,2),vertexpoint1(:,3),[0.5 0.5 0.5])
plot3(x(1),x(2),x(3), '-ob')
plot3(xline(:,1),xline(:,2),xline(:,3), '-r')