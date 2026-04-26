# 隐藏"3D对象"文件夹
# 需要管理员权限运行

# 检查管理员权限
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "请以管理员身份运行此脚本！"
    Write-Host "正在请求管理员权限..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "正在隐藏'3D对象'文件夹..." -ForegroundColor Green

# 定义注册表路径
$regPath1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
$regPath2 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"

# 删除注册表项（隐藏3D对象文件夹）
try {
    if (Test-Path $regPath1) {
        Remove-Item -Path $regPath1 -Recurse -Force
        Write-Host "✓ 已删除64位注册表项" -ForegroundColor Green
    } else {
        Write-Host "- 64位注册表项不存在" -ForegroundColor Gray
    }
    
    if (Test-Path $regPath2) {
        Remove-Item -Path $regPath2 -Recurse -Force
        Write-Host "✓ 已删除32位注册表项" -ForegroundColor Green
    } else {
        Write-Host "- 32位注册表项不存在" -ForegroundColor Gray
    }
    
    Write-Host "`n操作完成！" -ForegroundColor Cyan
    Write-Host "请重启文件资源管理器或重新打开'此电脑'查看效果。" -ForegroundColor Yellow
    Write-Host "`n提示：可以按 Ctrl+Shift+Esc 打开任务管理器，重启'Windows 资源管理器'进程" -ForegroundColor Gray
    
} catch {
    Write-Host "发生错误：$($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")