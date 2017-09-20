close all; clear all; clc;
[ mFiles] = RangTraversal( './fig', 'fig' );

sample_count = 6;
sample_index = randperm(length(mFiles), sample_count);
% sample_index = 424;
sample_images = {};
for i = 1 : sample_count
    sample_images(i).image = loadfig(cell2mat(mFiles(sample_index(i))));  
end

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
    bw2(bw2 < 1) = 0;
    bw2(bw2 > 1) = 30;
    L = bw2;
%     L(L ~= 0) = 1;
    L = bwlabel(L,4);
    S = regionprops(L, 'area');
    L = ismember(L, find([S.Area] >= 10));
    S = regionprops(L, 'area');
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
%     imagesc(bw3);
    imshow(~bw3);
    subplot(sample_count, 2, i * 2);  
%     image(bw2);
    bw3 = link_gap(bw3, 2);
    imshow(~bw3);
%     image(cout);
%     subplot(sample_count, 3, i * 3);
%     hist_im = imhist(sample_images(i).image);
end