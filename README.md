### 工具1 find-and-copy
遍历某个文件夹，根据后缀名找目标文件，然后复制到特定目录：

go build -o .\bin\find-and-copy.exe .\cmd\find-and-copy

运行方式是：
.\bin\find-and-copy.exe -src E:\data\A -dst E:\data\out -ext .txt