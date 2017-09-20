function bw_l = link_gap(bw, gap_size)

[m, n] = find(bw ~= 0);
bw_l = bw;
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
            bw_l(psm, psn) = 1;
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
            bw_l(psm, psn) = 1;
        end
    end
    
end
end

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


function index  = min_dist_p(des_pm, des_pn, pms, pns)
dist = (pms - des_pm).^2 + (pns - des_pn).^2;
[min_dis, index] = min(dist);
end