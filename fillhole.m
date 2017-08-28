[width, heighth] = size(int_image_range);

for i = scale + 1 : width - scale
    for j = 3 * scale + 1 : heighth - scale * 3
        
        if int_image_range(i,j) == 0
%             i_start = 0;
%             i_end = 0;
%             for ii = i - 1 : -1 : i - scale
%                 if int_image_range(ii,j) ~= 0
%                     i_start = ii;
%                     break
%                 end
%             end
%             
%             for ii = i + 1 :i + scale
%                 if int_image_range(ii,j) ~= 0
%                     i_end = ii;
%                     break
%                 end
%             end                     
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
            
%             if i_start * i_end ~=0
%                 int_image_range(i,j) = ((i_end - i) * int_image_range(i_start,j)...
%                     + (i - i_start) * int_image_range(i_end,j)) / (i_end - i_start);
%             end
            if j_start * j_end ~=0
                int_image_range(i,j) = ((j_end - j) * int_image_range(i,j_start)...
                    + (j - j_start) * int_image_range(i,j_end)) / (j_end - j_start);
            end
        end
    end
end
image(rot90(int_image_range));