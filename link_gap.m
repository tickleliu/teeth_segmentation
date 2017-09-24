function bw_l = link_gap(bw, gap_size)
% if linked region gap < gap_size, then the region will be linked together
% from four direction to find if the region could have a linked neighbour:
% left, right, up, down
L = bwlabel(bw, 8);
S = regionprops(L, 'area');
L = ismember(L, find([S.Area] >= 20));
L(L~=0) = 1;
bw = bw .* L;
[m, n] = find(bw ~= 0);
[height, width] = size(bw);

for i = 1 : length(m)
    %left
    if n(i) - gap_size < 1 || m(i) - gap_size < 1 || m(i) + gap_size > height
        continue
    end
    
    if sum(bw(m(i) - 1 : m(i) + 1, n(i) - 1)) == 0
        [pm, pn] = find(bw(m(i) - floor(gap_size / 2) : m(i) + floor(gap_size / 2),...
            n(i) - gap_size : n(i) - 1) ~= 0);
        pm = pm + m(i) - floor(gap_size / 2) - 1;
        pn = pn + n(i) - gap_size - 1;
        if ~isempty(pm)
            index  = min_dist_p(m(i), n(i), pm, pn);
            [psm, psn] = fill2points(pm(index), pn(index), m(i), n(i));
            bw(psm, psn) = 1;
        end
    end
    
    %right
    if n(i) + gap_size > width || m(i) - gap_size < 1 || m(i) + gap_size > height
        continue
    end
    if sum(bw(m(i) - 1 : m(i) + 1, n(i) + 1)) == 0
        [pm, pn] = find(bw(m(i) - floor(gap_size / 2) : m(i) + floor(gap_size / 2),...
            n(i) + 1 : n(i) + gap_size) ~= 0);
        pm = pm + m(i) - floor(gap_size / 2) - 1;
        pn = pn + n(i) + 1 - 1;
        if ~isempty(pm)
            index  = min_dist_p(m(i), n(i), pm, pn);
            [psm, psn] = fill2points(pm(index), pn(index), m(i), n(i));
            bw(psm, psn) = 1;
        end
    end
    
%     %up
%     if m(i) - gap_size < 1 || n(i) - gap_size < 1 ||n(i) + gap_size > width
%         continue
%     end
%     if sum(bw(m(i) - 1, n(i) - 1: n(i) + 1)) == 0
%         [pm, pn] = find(bw(m(i) - gap_size : m(i) - 1,...
%             n(i) - floor(gap_size / 2) : n(i) + floor(gap_size / 2)) ~= 0);
%         pm = pm + m(i) - gap_size - 1;
%         pn = pn + n(i) - floor(gap_size / 2) - 1;
%         if ~isempty(pm)
%             index  = min_dist_p(m(i), n(i), pm, pn);
%             [psm, psn] = fill2points(pm(index), pn(index), m(i), n(i));
%             bw(psm, psn) = 1;
%         end
%     end   
%     
%     
%     %down
%     if m(i) + gap_size > height || n(i) - gap_size < 1 ||n(i) + gap_size > width
%         continue
%     end
%     if sum(bw(m(i) + 1, n(i) - 1: n(i) + 1)) == 0
%         [pm, pn] = find(bw(m(i) + 1  : m(i) + gap_size,...
%             n(i) - floor(gap_size / 2) : n(i) + floor(gap_size / 2)) ~= 0);
%         pm = pm + m(i) + 1 - 1;
%         pn = pn + n(i) - floor(gap_size / 2) - 1;
%         if ~isempty(pm)
%             index  = min_dist_p(m(i), n(i), pm, pn);
%             [psm, psn] = fill2points(pm(index), pn(index), m(i), n(i));
%             bw(psm, psn) = 1;
%         end
%     end   
end
bw_l = bw;
end

% use the return point to fill the gap
function [pm, pn] = fill2points(p1m, p1n, p2m, p2n)
if p1m < p2m
    t = p1m;
    p1m = p2m;
    p2m = t;
end

if p1n < p2n
    t = p1n;
    p1n = p2n;
    p2n = t;
    
end
pm = p2m : p1m;
pn = p2n : p1n;
end

% find the min distance neighbour point
function index  = min_dist_p(des_pm, des_pn, pms, pns)
dist = (pms - des_pm).^2 + (pns - des_pn).^2;
[min_dis, index] = min(dist);
end