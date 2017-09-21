% main file to calc segmentation teeth

close all; clear all; clc;

%% load files
[ mFiles] = RangTraversal( './fig', 'fig' );
sample_count = 1;
sample_index = randperm(length(mFiles), sample_count);% random select several files
sample_index = 292;
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
    bw = bw(3 : m-2, 3 : n-2);
    image_out = outer(sample_images(i).image);
    % delete holes away from outer
%     [bw2, bw_delete] = delete_holes(bw, image_out) + image_out * 30;
    bw2 = bw;
    edge_threshold = 0.5;
    bw2(bw2 < edge_threshold) = 0;
    bw2(bw2 > edge_threshold) = 30;
    L = bw2;
%     L(L ~= 0) = 1;
    L = bwlabel(L,4);
    bw3 = bw2 .* L;
%     bw3 = bwlabel(bw3, 4);
%     bw3 = imerode(bw3, B);
    subplot(sample_count, 2, i * 2 - 1);
%     image(sample_images(i).image);
%     bw3 = bw3 * 2 + 10;
    bw3 = sample(bw3, image_out);
%     bw3 = imdilate(bw3, B);
%     bw3 = imdilate(bw3, B);
%     bw3 = imdilate(bw3, B);
%     bw3 = bwmorph(bw3, 'skel', inf);
    L = bwlabel(bw3,4);
    L = render_link_image(L);
    imagesc(L);
%     imshow(~bw3);
    subplot(sample_count, 2, i * 2);  
%     image(bw2);
    bw3 = link_gap(bw3, 5);
    bw3 = ~bw3;
    L = bwlabel(bw3,4);
    S = regionprops(L, 'area');
    L_s = ismember(L, find([S.Area] >= 30));
    
    L = bwlabel(bw3,4);
    L = L .* L_s;
    L = render_link_image(L);
    L_out =  mask(image_out);
    L = L .* L_out;
    imagesc(L);
%     image(cout);
%     subplot(sample_count, 3, i * 3);
%     hist_im = imhist(sample_images(i).image);
end