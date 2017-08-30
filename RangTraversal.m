function [ mFiles] = RangTraversal( strPath, reg )
%定义两数组，分别保存文件和路径
mFiles = {};
fileCount = 1;

mPath{1}=strPath;
Files = dir(fullfile(strPath));
LengthFiles = length(Files);

while LengthFiles>0
    if Files(1).isdir==1
        if strcmp(Files(1).name, '.') || strcmp(Files(1).name, '..') 

        else
            PathTemp = [Files(1).folder '/' Files(1).name];
            FilesTemp = dir(fullfile(PathTemp));
            Files = [Files; FilesTemp];
        end
    else
        filePath = [Files(1).folder '/' Files(1).name];
        if strfind(filePath, reg) ~= 0
            mFiles(fileCount) = {filePath};
            fileCount = fileCount + 1;
        end
    end
    Files = Files(2:end);
    LengthFiles = length(Files);
end
end