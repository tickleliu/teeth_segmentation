fid = fopen('config.dat');
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    [name, value] = strtok(tline, '=')
    if strcmp(name, 'scale')
        scale = str2num(value(2:end))
    end
    
    if strcmp(name, 'path')
        path = value(2:end)
    end
end
fclose(fid);