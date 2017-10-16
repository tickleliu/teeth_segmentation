function [image_out] = outer(in)
%% calc the range file outer border
image_out = in;

image_out(image_out ~= 0) = 1;
image_out = edge(image_out, 'canny', 0.1);
image_out = bwlabel(image_out);
region_count = max(max(image_out));
lengthest_region_length = 0;
for i = 1 : region_count
    cur_region_length = length(find(image_out == i));
    if cur_region_length > lengthest_region_length
        lengthest_region_length = cur_region_length;
        lengthest_region_index = i;
    end
end
image_out(image_out ~= lengthest_region_index) = 0;
image_out(image_out == lengthest_region_index) = 1;