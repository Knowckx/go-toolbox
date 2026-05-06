# ------ 国内镜像源
# 移除官方源
# winget source remove winget
# 添加中科大镜像源
# winget source add winget https://mirrors.ustc.edu.cn/winget-source

# 先升级自己
scoop install winget

# ------ 常用软件

# 安装PowerShell7
winget install --id Microsoft.PowerShell -e --source winget --proxy http://127.0.0.1:7890

# 升级 
# winget upgrade --id Microsoft.PowerShell

# powershell的配置
Set-ExecutionPolicy UnRestricted # 允许运行本地脚本

$proxy = "http://127.0.0.1:7890"
$env:HTTP_PROXY = $proxy
$env:HTTPS_PROXY = $proxy
$env:ALL_PROXY = $proxy




# ------------ 图形应用 winget会比scoop更好
# 重启后会加入右键菜单 | 快速启动 win+r 输入wt 
winget install Microsoft.WindowsTerminal

# vscode 有上下文的版本
winget install --id Microsoft.VisualStudioCode -e

# Codex
winget install Codex


winget install --id PixPin.PixPin


# --------------------------> App应用软件
winget install Tencent.TIM


# # 应用软件 - 后缀名打开
# choco install mpc-be # 视频播放

# # 应用软件 - 功能
# choco install obs  # 录屏软件


# choco install fsviewer # 看图
# # choco install icaros # win资源管理器显示缩略图 比如webp

