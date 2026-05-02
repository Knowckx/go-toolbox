
# 本文件用于在新电脑 快速创建各类符合习惯的文件夹

# 1. 强制控制台输出 UTF8 编码，确保 ✅ 能够正常显示
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "--- 准备初始化目录结构 ---" -ForegroundColor Cyan

# 定义需要创建的路径列表
$out = @(
    "D:\app_data", # 放各种软件的数据
    "D:\downloads", # 默认的下载目录

    "D:\asu_files", # 个人数据 方便迁移
    "D:\asu_files\music", # 音乐
    "D:\asu_files\obsidian_store", # 笔记
    "D:\asu_files\green_soft", # 绿色软件

    "E:\dev", # 开发根目录
    "E:\dev\_pkg_cache", # 各语言包管理软件的缓存
    "E:\dev\py\vendor", # python第三方包 | vendor 小贩 | 会自动创建父文件夹
    "E:\dev\nodejs", # node项目
    "E:\dev\github_projs", # 从github下载的社区项目
    
    "E:\stock", # 股票
    "E:\game" # 游戏
    
)




# 循环创建
foreach ($p in $out) {
    if (-not (Test-Path $p)) {
        try {
            # -Force 相当于 mkdir -p，会自动创建父目录
            New-Item -Path $p -ItemType Directory -Force | Out-Null
            Write-Host "✅ 已就绪: $p" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ 无法创建 ${p}: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "ℹ️ 已存在: $p" -ForegroundColor Yellow
    }
}



Write-Host "`n✨ 目录初始化完成！" -ForegroundColor Cyan