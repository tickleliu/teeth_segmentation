function [image_out] = outer(in)
[m,n] = size(in);
image_out = zeros(m, n);

for i = 1 : m
    for j = 1 : n
        if in(i, j) == 0
            continue
        else
            p1 = i - 1;
            if i - 1 < 1
                p1 = 1;
            end
            p2 = i + 1;
            if i + 1 > m
                p2 = m;
            end
            q1 = j - 1;
            if j - 1 < 1
                q1 = 1;
            end
            q2 = j + 1;
            if j + 1 > n
                q2 = n;
            end
            
            flag = false;
            
            for k = p1 : p2
                for kk = q1 : q2
                    if in(k, kk) == 0
                        flag = true;
                        break;
                    end
                end
            end
            
            if flag == true
                image_out(i, j) = 30;
            end
        end
    end
end
L = bwlabel(image_out);
region_count = max(max(L));
lengthest_region = 1;
lengthest_region_size = 0;
for i = 1 : region_count
    cur_region_size = length(find(L(:,:) == i));
    if cur_region_size > lengthest_region_size
        lengthest_region_size = cur_region_size;
        lengthest_region = i;
    end
end
image_out(L ~= lengthest_region) = 0;
image(image_out);