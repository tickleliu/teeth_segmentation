function img_color = render_link_image(L)
% render segment result
% L must be a link region map

num = unique(L);
[m,n] = size(L);
img_color = zeros(m,n,3);   % ��ʾͼ����ͨ����
for i = 2:length(num)
    img_color(find(L == num(i)),1)= rand(1);
    img_color(find(L == num(i)),2)= rand(1);
    img_color(find(L == num(i)),3)= rand(1);
end