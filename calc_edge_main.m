close all; clear all; clc;
[ mFiles] = RangTraversal( './fig', 'fig' );

sample_count = 2;
sample_index = randperm(length(mFiles), sample_count);
sample_images = {};
for i = 1 : sample_count
    sample_images(i).image = loadfig(cell2mat(mFiles(sample_index(i))));
    outer(sample_images(i).image);
end

figure(1)
B = [0 1 0; 1 1 1; 0 1 0];
for i = 1 : sample_count
    threshold_count = 5;
    threshold_start = 0.05;
    for j = 1 : threshold_count
    subplot(threshold_count, sample_count, i * threshold_count -j + 1);
    bw = edge(sample_images(i).image, 'canny', threshold_start / j);
    L = bwlabel(bw);
%     bw = imdilate(bw, B);
%     bw = imdilate(bw, B);
%     bw = imerode(bw, B);
    imshow(bw);
    end
end