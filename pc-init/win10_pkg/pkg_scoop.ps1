# 本脚本的作用 给一台新的电脑装上 scoop和其他常用的软件

# --------------------------> 基础配置

# --------------------------> scoop配置
# 下载安装脚本
irm get.scoop.sh -outfile 'install.ps1'
# 自定义安装 
.\install.ps1 -ScoopDir 'd:\app_data\scoop' -ScoopGlobalDir 'd:\app_data\global_scoop_apps' -RunAsAdmin -NoProxy

scoop config  # 看一下自定义安装中配置的文件夹正常不
# 不要添加国内镜像源 挂代理就够了 

# 必须加代理 因为就算我换了国内的镜像  scoop下载存放于github软件时 比如v2rayn 他还是需要去访问github
scoop config proxy 127.0.0.1:7890 # 回退 scoop config rm proxy

# --------------------------> 基础设施软件
scoop update
scoop install aria2 # 安装并启用多线程下载
scoop config aria2-enabled true

scoop install v2rayn-desktop # Avalonia版本 跨平台UI






# --------------------------> 各种应用软件 
scoop install extras/listary
scoop install extras/tailscale # 内网组网 | 需要管理员psh
# scoop install extras/hwinfo # 可以看硬件信息
# scoop install extras/rustdesk # 远程登陆
# scoop install extras/antigravity # AI
scoop install extras/telegram
scoop install extras/gopeed
scoop install extras/audacity
scoop install extras/obsidian
# --------------------------> 编程相关
# -------------> git
scoop install git
git config --global user.name knowckx
git config --global user.email knowckx@foxmail.com
git config --global core.autocrlf input # 在提交时把CRLF转换成LF，签出时不转换
git config --global core.fileMode false # 忽略文件权限的变化
git config --global core.ignorecase false # 启用文件名大小写敏感 2025-05-19 python被坑了一次
git config --global http.proxy socks5://127.0.0.1:7890
git config --global https.proxy socks5://127.0.0.1:7890


# git config --global --unset http.proxy;
# git config --global --unset https.proxy;



# -------------> 基础命令工具
scoop install ripgrep # rg命令 gpt经常需要



# -------------> python
scoop install python313
scoop install main/uv
[Environment]::SetEnvironmentVariable("UV_CACHE_DIR", "E:\dev\_pkg_cache\uv-cache", "User")

pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple # 使用清华镜像源


# --------------------------> golang
scoop install main/go
go env -w GOPROXY=https://goproxy.cn,direct

# scoop install hugo-extended # Blog
# scoop install mingw # MinGW-w64 C语言编译器 有一些包会需要

# -------------> 前端web相关
scoop install nodejs
scoop install pnpm  
# 设置淘宝镜像源
pnpm config set registry https://registry.npmmirror.com
pnpm setup # 主要是配置下载的包放到哪 并且设置path环境变量
pnpm add -g yalc

scoop install mkcert # 用于生成localhost可用的https证书



