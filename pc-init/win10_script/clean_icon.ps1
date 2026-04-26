# 这个脚本的作用 清理windows托盘的图标缓存  
# 原因是 任务栏设置 - 选择哪些图标显示在任务栏上  有些软件已经被卸载了 但是图标还留在这里

# 打印提示信息
Write-Host "正在关闭资源管理器 (Explorer)..." -ForegroundColor Cyan

# 1. 强制结束 explorer 进程
Get-Process explorer | Stop-Process -Force

# 2. 定义注册表路径
$regPath = "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\TrayNotify"

# 3. 删除图标缓存键值
# 使用 ErrorAction SilentlyContinue 是为了防止如果键值已经被删除了，脚本不报错
Write-Host "正在清理注册表缓存..." -ForegroundColor Cyan
Remove-ItemProperty -Path $regPath -Name "IconStreams" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path $regPath -Name "PastIconsStream" -ErrorAction SilentlyContinue

# 4. 稍微等待一下，确保注册表操作完成且进程完全释放
Start-Sleep -Seconds 2

# 5. 重启 explorer
Write-Host "正在重启资源管理器..." -ForegroundColor Cyan
Start-Process explorer

Write-Host "清理完成！你的任务栏图标列表已重置。" -ForegroundColor Green