## 快速使用示例

同步 Obsidian 主库配置到多个从库，并过滤不应下发的社区插件。
`pwsh -File .\scripts\win10_script\obsidian_setting_sync.ps1`

## 设计架构

- 顶部维护主库路径、目标库列表、同步项、排除插件列表。
- 启动前先校验主库和从库路径，不通过直接退出。
- 同步时对 `plugins` 做目录级过滤，对 `community-plugins.json` 做启用列表过滤，其余项直接覆盖复制。

## 目录内文件职责

- `obsidian_setting_sync.ps1`：同步 Obsidian 配置，并排除不应同步的插件。
- `clean_icon.ps1`：处理图标相关清理。
- `隐藏3D对象.ps1`：处理 Windows 资源管理器 3D 对象显示项。
- `useproxy.md`：代理使用记录。
