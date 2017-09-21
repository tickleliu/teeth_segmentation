% main file to calc segmentation teeth

close all; clear all; clc;

%% load files
[ mFiles] = RangTraversal( './fig', 'fig' );
sample_count = 1;
sample_index = randperm(length(mFiles), sample_count);% random select several files
% sample_index = 292;
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
    imagesc(bw3);
    subplot(sample_count, 2, i * 2);  
    bw3 = link_gap(bw3, 5);
    
    bw3 = ~bw3;
    L = bwlabel(bw3,4);    
    S = regionprops(L, 'area');
    L2 = ismember(L, find([S.Area] >= 200));
    L_s = bwlabel(L2,4);
    L_s = interest_region(L_s, image_out);
    L = render_link_image(L_s);
    L_out =  mask(image_out);
    L = L .* L_out;
    L(:,:,1) = L(:,:,1) + image_out; 
    imagesc(L);
end