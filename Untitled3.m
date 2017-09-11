%load fig file template
a = open('1@ChenJiaKang_UpperJaw_2016-11-19@UpperJaw..fig');
a = get(a);
b = get(a.Chindren);
b = get(a.Children);
c = get(b.Children);
d = c.CData;
d = rot90(d);