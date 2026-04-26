# go-toolbox

## 项目

- Go 小工具集合
- 独立工具模式
- `./cmd/<tool>/` 放入口
- `./internal/tools/<tool>/` 放实现
- `./bin/` 放编译产物

## 工具

### `find-and-copy`

- 递归遍历 `-src`
- 匹配 `-ext`
- 复制到 `-folder`
- `-folder` 可不传
- 不传时，目标直接在 `-src` 下
- 目标只保留文件名，不保留父目录
- 重名会打印提示并跳过
- 最后只打印成功数量

### 参数

- `-src`
  - 源目录
  - 必填

- `-ext`
  - 后缀
  - 必填

- `-folder`
  - 目标子文件夹名
  - 可选

### 示例

```powershell
go build -o .\bin\find-and-copy.exe .\cmd\find-and-copy
.\bin\find-and-copy.exe -src E:\data\A -ext .txt
.\bin\find-and-copy.exe -src E:\data\A -ext .txt -folder out
```
