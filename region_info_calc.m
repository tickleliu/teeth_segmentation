function region_info = region_info_calc(L)
% calc the linked region infos
% have area, size
region_count = max(max(L));
region_info = {};

for i = 1 : region_count
    [m,n] = find(L(:,:) == i);
    region_info(i).length = length(m);
    region_info(i).minY = min(m);
    region_info(i).maxY = max(m);
    region_info(i).minX = min(n);
    region_info(i).maxX = max(n);
    region_info(i).points = [m, n];
end
