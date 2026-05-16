#Requires AutoHotkey v2.0

; --------------------------------------------------------------
; 媒体播放/暂停 
<#<!Space::Send "{Media_Play_Pause}"

; 禁用Insert
Insert::{
    ToolTip "Insert 已禁用"
    SetTimer () => ToolTip(), -800
}


; 傻瓜密码 试用中 
::qa.::qA.142356

; ::vai.::{
;     promptMenu := Menu()
;     promptMenu.Add("&1 提示词-项目开始", (*) => SendText("请先读取并学习本项目的文档 然后我们会开始下一步的工作"))
;     promptMenu.Add("&2 提示词-切新窗口", (*) => SendText("判断当前对话是否应该切新窗口。只回答：是否建议切 + 原因 + 如果切，给我一份使用markdown块引用的 500 字以内的交接摘要"))
;     promptMenu.Show()
; }

; 提示词 prompt
::vaip::{
    ToolTip "1 项目开始`n2 切新窗口"

    ih := InputHook("L1 T5")
    ih.Start()
    ih.Wait()

    ToolTip

    switch ih.Input {
        case "1":
            SendText("请先读取并学习本项目的文档 然后我们会开始下一步的工作")
        case "2":
            SendText("判断当前对话是否应该切新窗口。只回答：是否建议切 + 原因 + 如果切，给我一份使用markdown块引用的 500 字以内的交接摘要")
    }
}





; obsidian md格式 alt+b → 列表项加粗
#HotIf WinActive("ahk_exe Obsidian.exe")

!b::{
    oldClip := A_Clipboard
    A_Clipboard := ""

    Send "^c"
    if ClipWait(0.2) {
        selected := A_Clipboard
        SendText("- **" selected "**")
    } else {
        SendText("- ****")
        Send "{Left 2}"
    }

    A_Clipboard := oldClip
}

#HotIf


