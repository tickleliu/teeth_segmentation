function L_s = interest_region(L, image_out)
% select the region near the image outer
S = regionprops(L, 'area');
region_prob = zeros(1, length([S.Area]));
borderheight = zeros(1, size(image_out,2));
region_inter =  zeros(length([S.Area]), length([S.Area]));
for i  = 1 : length(borderheight)
    border_i = find(image_out(:,i)~=0);
    if isempty(border_i)
        continue;
    end
    borderheight(i) = min(border_i);
    
    cur_region = 0;
    for j = borderheight(i) : size(L,1)
        if L(j, i) ~= 0 && cur_region == 0 % interest region must near the border
            region_prob(L(j, i)) = region_prob(L(j, i)) ...
                + 1;
            cur_region = L(j, i);
        end
        
        if cur_region ~= L(j, i) && L(j, i)~= 0 % find two layer deep region
            region_inter(L(j, i), cur_region) = region_inter(L(j, i), cur_region) + 1;
            break;
        end
    end
end
region_prob(region_prob < 5) = 0;
region_need_r = [];

for i = 1 : length(region_prob)
   if  region_prob(i) == 0
       continue
   end
   if sum(region_inter(i, :)) > 10
       region_need_r = [region_need_r, i];
   end   
end

L_t = zeros(size(L));

for i = 1 : length(region_need_r)
    L_t(L == region_need_r(i)) = region_need_r(i);
end
figure(1)
img = render_link_image(L_t);
imagesc(img);
figure(2)
img2 = render_link_image(L);
imagesc(img2);
L_s = L;

