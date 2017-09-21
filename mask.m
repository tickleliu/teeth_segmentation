function m = mask(image_out)
% calc the outer bounder mask, use this mask can restrict the segmentation 
% result inside the range model 
m = image_out;
[height, width] = size(image_out);
for i = 1 : width
    h = find(image_out(:, i) == 1);
    if isempty(h)
        m(:, i) = -1;
    else
        h_min = min(h);
        m(1: h_min, i) = -1;     
    end
end
m(m ~= -1) = 1;
m(m == -1) = 0;