# ==========================================
# 1. 用户配置区域
# ==========================================

# 你的所有仓库所在的父级文件夹路径
$StorePath = "D:\AsukaFiles\AsuObsidianStore"

# 指定哪个库是“主库”（母库）
$MasterVaultName = "1-指南针"

# 指定需要同步的其他仓库名称列表
$TargetVaultNames = @(
    "2-投资",
    "3-科技",
    "4-绿洲",
    "5-生活",
    "6-打工人"
)

# 指定要同步的具体配置项 (文件夹或文件)
# 建议只同步插件、代码片段和快捷键，跳过 workspace.json
$ItemsToSync = @(
    "plugins",  # 社区插件的物理文件
    "community-plugins.json", # 已启用的社区插件列表
    "core-plugins.json",  # 已启用的核心插件列表

    "snippets",  # CSS 代码片段
    "appearance.json", # 外观设置（主题、字体、颜色、窗口边框等）
    "hotkeys.json", # 自定义快捷键
    "app.json" # 基础应用设置（如：附件存放路径、忽略文件等） | 注意: 不同库的附件存放路径可能会不同

    # "graph.json", # 关系图谱的设置（颜色、力导向参数等） | 不建议同步 每个库的图谱密度不同
    # "workspace.json",  # 工作区布局（当前打开了哪些文件、侧边栏宽度、分屏状态） | 不建议同步 每个库的文件名不同
)

# [新功能] 指定由于环境差异（如 Git 路径）需要排除同步的特定插件名称
$ExcludedPlugins = @(
    "obsidian-git"
)

# ==========================================
# 2. 自动化执行逻辑（无需修改）
# ==========================================

$MasterConfigPath = Join-Path $StorePath "$MasterVaultName\.obsidian"

# 检查主库配置文件夹是否存在
if (-not (Test-Path $MasterConfigPath)) {
    Write-Error "主库配置路径不存在，请检查路径设置: $MasterConfigPath"
    exit
}

foreach ($VaultName in $TargetVaultNames) {
    Write-Host "--------------------------------------------" -ForegroundColor Cyan
    Write-Host "正在处理仓库: $VaultName" -ForegroundColor Cyan
    
    $TargetConfigPath = Join-Path $StorePath "$VaultName\.obsidian"
    
    # 如果目标仓库的 .obsidian 文件夹都不存在，说明路径有错
    if (-not (Test-Path $TargetConfigPath)) {
        Write-Warning "跳过：仓库 $VaultName 下未找到 .obsidian 文件夹。"
        continue
    }

    foreach ($Item in $ItemsToSync) {
        $SourceItemPath = Join-Path $MasterConfigPath $Item
        $TargetItemPath = Join-Path $TargetConfigPath $Item

        # 如果主库里根本没有这个配置项（比如还没写过 CSS），就跳过
        if (-not (Test-Path $SourceItemPath)) { continue }

        # 如果目标路径已存在，先删除它以确保纯净同步（覆盖旧配置）
        if (Test-Path $TargetItemPath) {
            Write-Host "  [清理] 删除旧的 $Item"
            Remove-Item -Recurse -Force $TargetItemPath
        }

        # 执行复制操作
        try {
            if ($Item -eq "plugins") {
                # 如果是插件文件夹，我们要实现“细粒度”同步，排除特定的插件
                # 先确保目标插件文件夹存在
                if (-not (Test-Path $TargetItemPath)) {
                    New-Item -ItemType Directory -Path $TargetItemPath | Out-Null
                }

                # 获取主库中的所有插件子文件夹
                $AllPlugins = Get-ChildItem -Path $SourceItemPath -Directory
                
                foreach ($PluginFolder in $AllPlugins) {
                    if ($ExcludedPlugins -contains $PluginFolder.Name) {
                        Write-Host "  [跳过] 排除插件: $($PluginFolder.Name)" -ForegroundColor Yellow
                        continue
                    }
                    
                    $SubTargetItemPath = Join-Path $TargetItemPath $PluginFolder.Name
                    
                    # 清理旧插件
                    if (Test-Path $SubTargetItemPath) {
                        Remove-Item -Recurse -Force $SubTargetItemPath
                    }
                    
                    Copy-Item -Path $PluginFolder.FullName -Destination $TargetItemPath -Recurse -Force
                }
                Write-Host "  [成功] 已同步插件目录（已过滤排除项）" -ForegroundColor Green
            }
            else {
                # 对于非插件项（如 snippets 或单独的 json 文件），直接整桶复制
                Copy-Item -Path $SourceItemPath -Destination $TargetItemPath -Recurse -Force -ErrorAction Stop
                
                if (Test-Path -Path $SourceItemPath -PathType Container) {
                    Write-Host "  [成功] 已同步文件夹: $Item" -ForegroundColor Green
                }
                else {
                    Write-Host "  [成功] 已同步文件: $Item" -ForegroundColor Green
                }
            }
        }
        catch {
            Write-Error "  [失败] 无法同步 $Item : $_"
        }
    }
}

Write-Host "`n所有操作已完成！" -ForegroundColor Cyan

$userInput = Read-Host -Prompt "Bye,Bye...按下Enter以退出"
