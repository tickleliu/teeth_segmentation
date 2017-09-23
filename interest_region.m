function L_s = interest_region(L, image_out)
% select the region near the image outer
% select the region most like teeth
% and rode the region near upper border to seperate
% L must be a labeled linked region index from 1 to N
% image_outer is the range teeth border labeled 1

S = regionprops(L, 'area');
Box = regionprops(L, 'boundingbox');
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
            
            if j - borderheight(i) > 20 % the current region too far away from the border, give up this i
                break
            end
            
            region_prob(L(j, i)) = region_prob(L(j, i)) ...
                + 1;
            cur_region = L(j, i);
        end
        
        if cur_region ~= L(j, i) && L(j, i)~= 0 % find two layer deep region
            region_inter(L(j, i), cur_region) = region_inter(L(j, i), cur_region) + 1;
            cur_region = L(j, i);
            if j - borderheight(i) < 20 % the current region too far away from the border, give up this i
                region_prob(L(j, i)) = region_prob(L(j, i)) ...
                + 1;
            end
        end
    end
end
bound = reshape([Box.BoundingBox], 4, length([S.Area]));
bound = bound(3,:);

for i = 1 : length(region_prob)
    if region_prob(i) > 30
        continue;
    end
    
    if region_prob(i) / bound(i) < 0.5
        region_prob(i) = 0;
    end
%     region_prob(region_prob < 5) = 0;%delete the region far away from border
end


region_need_r = [];
region_need_s = [];

for i = 1 : length(region_prob)
   if  region_prob(i) == 0
       continue
   end
   if sum(region_inter(i, :)) > 50
       region_need_r = [region_need_r, i];
   else
       region_need_s = [region_need_s, i];
   end   
end

L_temp = zeros(size(L));
for i = 1 : length(region_need_r)
    L_temp(L == region_need_r(i)) = region_need_r(i);
end
L_s = zeros(size(L));
for i = 1 : length(region_need_s)
    L_s(L == region_need_s(i)) = region_need_s(i);
end

for i = 1 : 50
    [L_s, L_temp, region_need_r] = i_interest_region(L_s, L_temp, image_out, i);
    if isempty(region_need_r)
        break
    end
end

% figure(1)
% img = render_link_image(L);
% imagesc(img);
% figure(2)
% img2 = render_link_image(L_s);
% imagesc(img2);


end

function [L_s, L_temp, region_need_r] = i_interest_region(L_s, L_temp, image_out, rode_count)

B = [0 1 0; 1 1 1; 0 1 0];
L_temp = imerode(L_temp, B);
L_temp = bwlabel(L_temp, 4);
r_region_start = max(max(L_s));
L_temp = L_temp + r_region_start;
L_temp(L_temp == r_region_start) = 0;
L = L_temp + L_s;

%     bw3 = imerode(bw3, B);imdilate
S = regionprops(L, 'area');
Box = regionprops(L, 'boundingbox');
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
            if j - borderheight(i) > 20 % the current region too far away from the border, give up this i
                break
            end    
            region_prob(L(j, i)) = region_prob(L(j, i)) ...
                + 1;
            cur_region = L(j, i);
        end
        
        if cur_region ~= L(j, i) && L(j, i)~= 0 % find two layer deep region
            region_inter(L(j, i), cur_region) = region_inter(L(j, i), cur_region) + 1;
            cur_region = L(j, i);
            if j - borderheight(i) < 20 % the current region too far away from the border, give up this i
                region_prob(L(j, i)) = region_prob(L(j, i)) ...
                + 1;
            end
        end
        
    end
end

bound = reshape([Box.BoundingBox], 4, length([S.Area]));
bound = bound(3,:);
for i = 1 : length(region_prob)
    if region_prob(i) > 30
        continue;
    end
    if region_prob(i) / bound(i) < 0.5
        region_prob(i) = 0;
    end
%     region_prob(region_prob < 5) = 0;%delete the region far away from border
end
region_need_r = [];
region_need_s = [];

for i = 1 : length(region_prob)
   if  region_prob(i) == 0
       continue
   end
   if sum(region_inter(i, :)) > 50
       region_need_r = [region_need_r, i];
   else
       region_need_s = [region_need_s, i];
   end   
end

L_temp = zeros(size(L));
for i = 1 : length(region_need_r)
    L_temp(L == region_need_r(i)) = region_need_r(i);
end
for i = 1 : length(region_need_s)
    L_s(L == region_need_s(i)) = region_need_s(i);  
    if region_need_s(i) > r_region_start
        for kk = 1 : rode_count
            L_s = dilate_region_by_index(L_s, region_need_s(i));
        end
    end
end
end

function L_out = dilate_region_by_index(L, index)
% dilate the index region
L_temp = zeros(size(L));
L_temp(L == index) = index;
L(L == index) = 0;
B = [0 1 0; 1 1 1; 0 1 0];
L_temp = imdilate(L_temp, B);
L_out = L + L_temp;
end