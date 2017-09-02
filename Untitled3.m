h=convhull(points(:,1), points(:,2));%¼ÆËãÂÖÀªÍ¹°ü
conv_mask=zeros(m,n);
hold on
for i=1:length(h)-1
    x1=points(:,1);
    y1=y(h(i));
end
hold off
figure,imshow(conv_mask);