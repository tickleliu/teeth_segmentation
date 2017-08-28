function s = area(a, b, c)
    s = (a + b + c) / 2;
    s = sqrt(s*(s - a)*(s - b)*(s - c));
end