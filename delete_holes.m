function [bw2, delete_bw] = delete_holes(bw, outer)

[m, n] = find(bw > 80);
[height, width] = size(bw);
bw2 = bw;
bw_delete = zeros(height, width);
for i = 1 : length(n)
    startY = m(i) - 2;
    if startY < 1
        startY = 1;
    end
    endY = m(i) + 2;
    if endY > height
        endY = height;
    end
    startX = n(i) - 2;
    if startX < 1
        startX = 1;
    end
    endX = n(i) + 2;
    if endX > width
        endX = width;
    end
    
    threshold = sum(outer(startY:endY, startX:endX));
    if threshold == 0
        bw2(m(i), n(i)) = 0;
        bw_delete(m(i), n(i)) = 1;
    end
end
% figure(2)
% subplot(2,1,1)
% image(bw);
% subplot(2,1,2)
% image(bw2);
% end