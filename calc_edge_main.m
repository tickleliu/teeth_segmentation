% main file to calc segmentation teeth

close all; clear all; clc;

%% load files
[ mFiles] = RangTraversal( './fig', 'fig' );
sample_count = 5;
sample_index = randperm(length(mFiles), sample_count);% random select several files
% sample_index = 234;
% sample_index = 433;
% sample_index = 447;
% sample_index = 45;
sample_images = {};
for i = 1 : sample_count
    sample_images(i).image = loadfig(cell2mat(mFiles(sample_index(i))));  
end

%% segmentation teeth
figure(1)
B = [0 1 0; 1 1 1; 0 1 0];
for i = 1 : sample_count
    bw = filtervalley(sample_images(i).image);
    [m, n] = size(bw);
    bw2 = bw(3 : m-2, 3 : n-2);
    image_out = outer(sample_images(i).image);
    % delete holes away from outer
%     [bw2, bw_delete] = delete_holes(bw, image_out) + image_out * 30;
    edge_threshold = 0.5;
    bw2(bw2 < edge_threshold) = 0;
    bw2(bw2 > edge_threshold) = 30;
    L = bwlabel(bw2,4);
    bw3 = bw2 .* L;
%     bw3 = imerode(bw3, B);imdilate
    subplot(sample_count, 2, i * 2 - 1);
    bw3 = sample(bw3, image_out);
    bw3 = link_gap(bw3, 5);
    bw3 = ~bw3;
    L = bwlabel(bw3,4);  
    
    S = regionprops(L, 'area');
    L2 = ismember(L, find([S.Area] >= 20));
    L_s = bwlabel(L2,4);
    L_out =  mask(image_out);
    L_s = L_s .* L_out;
%     img_L = render_link_image(L_s); 
%     img_L(:,:,1) = img_L(:,:,1) + image_out; 
    imagesc(L_s + image_out);
    subplot(sample_count, 2, i * 2);  
   
    L_s = interest_region(L_s, image_out);
    downborder = zeros(1, size(L_s, 2));
    
    x = [];
    y = [];
    %find down border for each region
    start_x = 10000;
    end_x = 0;
    for j = 1 : length(downborder)
        teeth_pixel = find(L_s(:, j) ~= 0);
        if ~isempty(teeth_pixel)
            if start_x > j
                start_x = j;
            end
            
            if j > end_x
                end_x = j;
            end
            downborder(j) = max(teeth_pixel);
%             L_s(downborder(j), j) = 100;
            x = [x, j];
            y = [y, downborder(j)];
        end
    end
    
    yi = spline(x, y, [1 : length(downborder)]);
    yi(floor(yi) <= 0) = 1;
    yi(yi > size(L,1)) = size(L,1);
    
    L = render_link_image(L_s); 
%     L(:,:,1) = L(:,:,1) + image_out; 
    L(:,:,1) = L(:,:,1);
    for j = start_x : end_x
        L(floor(yi(j)), j, 1) = L(floor(yi(j)), j ,1) + 10;
    end
    temp_image = sample_images(i).image;
    for j = start_x : end_x
        s = min(find(image_out(:, j)~=0));    
        temp_image( s : floor(yi(j)), j) = 50;
    end
%     image(temp_image);
    imagesc(L);
end