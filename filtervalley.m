int_image_range2 = int_image_range;
filter_coff = [2 1 -5 1 2];
filter_coff = filter_coff ./ norm(filter_coff);
[width, heighth] = size(int_image_range);
for i = 3 : width - 3
    for j = 3 : heighth - 3
        vec = int_image_range(i,j -2 : j + 2);
        vec = vec ./ norm(vec);
        ifv = filter_coff * vec';
        vecx = int_image_range(i - 2 : i + 2, j);
        vecx = vecx ./ norm(vecx);
        ifvx = filter_coff * vecx;
        if  norm(ifv, ifvx) <  0.07
            
            int_image_range2(i, j) = 100;
        end
        
    end
end
image(rot90(int_image_range2));