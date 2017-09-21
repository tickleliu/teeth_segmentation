function [image] = loadfig(path)
%load fig file to a matrix
h=open(path);
a=get(h);
b=get(a.Children);
c=get(b.Children);
d = c.CData;
image = rot90(d);
close all;