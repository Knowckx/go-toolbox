
### 如何优雅实现在powershell中配置代理

1. 检查你是否已经创建了配置文件
Test-Path $PROFILE

2.如果是false就创建一个
New-Item -Type File -Path $PROFILE -Force

3. 编辑这个配置文件
code $PROFILE
粘贴以下代码1

```powershell
# 代码1
# 开启代理的命令
function useproxy {
    $proxy = "http://127.0.0.1:7890"
    
    # 设置环境变量
    $env:HTTP_PROXY = $proxy
    $env:HTTPS_PROXY = $proxy
    $env:ALL_PROXY = $proxy
    
    Write-Host "已开启代理: $proxy" -ForegroundColor Green
}

# 关闭代理的命令
function unproxy {
    # 清空环境变量
    $env:HTTP_PROXY = ""
    $env:HTTPS_PROXY = ""
    $env:ALL_PROXY = ""

    Write-Host "已关闭代理" -ForegroundColor Yellow
}


# 默认使用UTF-8
[Console]::InputEncoding  = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

```

4. 重开PowerShell 输入 useproxy
