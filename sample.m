function bw_s = sample(bw)
%select the region near the border
[height, width] = size(bw);
bw_s = zeros(height, width);
L = bwlabel(bw, 4);
[m, n] = find(bw ~= 0);
for i = min(n) : max(n)
    y_link_count = 0;
    border_start = min(find(bw(:, i) ~= 0));%from border,first calc border width
    border_end = y_link(bw, i, border_start);
    bw_s(border_start:border_end, i) = 1;
    
    if border_end - border_start > 20 %two teeth intersection border
        continue
    end
    j = border_end + 1;
    while j <= height
        if bw(j, i) == 0
            j = j + 1;
            continue
        else
            y_start = j;
            y_end = y_link(bw, i, y_start);
            bw_s(y_start:y_end, i) = 1;
            link_index = L(y_start, i);
            bw_s(find(L == link_index)) = 1;
            y_link_count = y_link_count + 1;
            j = y_end + 1;
        end
        if y_link_count == 1
            break
        end
    end    
end

% subplot(2,1,1)
% image(bw_s * 10)
% 
% subplot(2,1,2)
% image(bw)
end

function y_end = y_link(bw, x, y_start)
y_end = y_start;
[height, width] = size(bw);
for i = y_start : height
    if bw(i, x) ~= 0
        y_end = i;
    else
        break
    end
end
end