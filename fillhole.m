function int_image_range = fillhole(image, scale)

[width, heighth] = size(image);
int_image_range = image;
for i = scale + 1 : width - scale
    for j = 3 * scale + 1 : heighth - scale * 3
        
        if int_image_range(i,j) == 0                   
           j_start = 0;
            j_end = 0;
            for jj = j - 1 : -1 : j - 3 * scale
                if int_image_range(i,jj) ~= 0
                    j_start = jj;
                    break
                end
            end
            
            for jj = j + 1 :j + 3 * scale
                if int_image_range(i,jj) ~= 0
                    j_end = jj;
                    break
                end
            end      

            if j_start * j_end ~=0
                int_image_range(i,j) = ((j_end - j) * int_image_range(i,j_start)...
                    + (j - j_start) * int_image_range(i,j_end)) / (j_end - j_start);
            end
        end
    end
end