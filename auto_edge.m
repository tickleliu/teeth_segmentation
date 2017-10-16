function bw = auto_edge(image, minIO, maxIO)
% search the edge between minIO, maxIO
% not used 
% make the i / o = [3.9, 4.1]
threshold = 0.01;
threshold_step = 0.001;
count = 0;
j = 1;
while count < 100
    bw = edge(image, 'canny', threshold);
    image_out = outer(image);
    edge_length = length(find(bw ~= 0));      
    outer_length = length(find(image_out ~= 0));
    inner_length = edge_length - outer_length;
    idivo = inner_length / outer_length;
    idivo, threshold
    if idivo > minIO && idivo < maxIO
        break
    end
    if idivo < minIO
        threshold = threshold - threshold_step;
    end
    if idivo > maxIO
        threshold = threshold + threshold_step;
    end
    if threshold < 0
        break
    end
    count = count + 1;
end
