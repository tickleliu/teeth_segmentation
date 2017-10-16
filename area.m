function s = area(a, b, c)
% calculation of triangle area by Euler formula
    s = (a + b + c) / 2;
    s = sqrt(s*(s - a)*(s - b)*(s - c));
end