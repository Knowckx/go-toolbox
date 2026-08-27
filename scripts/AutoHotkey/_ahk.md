## ahk脚本加入开机启动

- 找到你刚才写好的 MediaControl.ahk 文件， 右键创建快捷方式
- Win + R  输入 shell:startup   这会打开系统的启动文件夹
- 把脚本的快捷方式放到这里  系统启动后这个快捷方式就被自动运行一次





``` AutoHotkey
; cmd /k  执行完命令后保留窗口
Run 'wt.exe cmd /k find-and-copy.exe -ext .mp3 -src "D:\AsukaFiles\AsuMusic2.0\新音乐\临时1_全部"'
```