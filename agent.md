# go-toolbox AI 说明文档

## 项目说明

`go-toolbox` 是一个面向日常开发和文件处理场景的 Go 小工具集合项目。

当前项目采用“独立工具模式”：

- 每个工具一个独立入口，放在 `./cmd/<tool-name>/`
- 每个工具的具体实现放在 `./internal/tools/<tool-name>/`
- 编译产物统一输出到 `./bin/`


## 当前工具列表

### `find-and-copy`
用于递归遍历指定源目录，查找符合后缀条件的文件，并复制到指定目标目录。

- 使用示例
- 
```powershell
go build -o .\bin\find-and-copy.exe .\cmd\find-and-copy
.\bin\find-and-copy.exe -src E:\data\A -dst E:\data\out -ext .txt
```
