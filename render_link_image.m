function img_color = render_link_image(L)
% render segment result
% L must be a link region map

num = max(max(L));
[m,n] = size(L);
img_color = zeros(m,n,3);   % ��ʾͼ����ͨ����
for i = 1:1:num
    img_color(find(L == i),1)= rand(1);
    img_color(find(L == i),2)= rand(1);
    img_color(find(L == i),3)= rand(1);
end