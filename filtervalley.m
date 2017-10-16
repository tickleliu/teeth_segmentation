function int_image_range2 = filtervalley(int_image_range)
% use 5 * 5 Laplace of Gaussion(LoG) to calc edge
[m, n] = size(int_image_range);
L_o_G = [-2 -4 -4 -4 -2;
       -4 0 8 0 -4;
        -4 8 24 8 -4;
        -4 0 8 0 -4;
        -2 -4 -4 -4 -2];
int_image_range2 = conv2(int_image_range, L_o_G);