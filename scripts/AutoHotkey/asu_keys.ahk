#Requires AutoHotkey v2.0
#SingleInstance Force

; ==================== 快捷键配置 ====================
; 符号说明：# = Win键, + = Shift键, ^ = Ctrl键, ! = Alt键


; 1. 加载同一目录下的 DLL 动态链接库
dllPath := A_ScriptDir . "\dll\VirtualDesktopAccessor.dll"
if !FileExist(dllPath) {
    MsgBox("未找到 VirtualDesktopAccessor.dll，请确保 DLL 与本脚本在同一文件夹！", "错误", 16)
    ExitApp
}
hDll := DllCall("LoadLibrary", "Str", dllPath, "Ptr")

; 【Win + Alt + 左方向键】：将当前窗口移至上一个桌面（并跟随切换）
#!Left::MoveWindowToAdjacentDesktop(-1, true)

; 【Win + Alt + 右方向键】：将当前窗口移至下一个桌面（并跟随切换）
#!Right::MoveWindowToAdjacentDesktop(1, true)

; 提示：如果希望「只把窗口扔过去，自己留在当前桌面」，将上面的 true 改为 false 即可。
; ====================================================

MoveWindowToAdjacentDesktop(offset, follow := true) {
    global dllPath
    ; 获取当前活动窗口句柄
    hwnd := WinExist("A")
    if !hwnd
        return

    ; 获取当前桌面编号与总桌面数 (索引从 0 开始)
    current := DllCall(dllPath . "\GetCurrentDesktopNumber", "Int")
    count := DllCall(dllPath . "\GetDesktopCount", "Int")
    
    target := current + offset
    if (target < 0 || target >= count)
        return  ; 已经在最前或最后桌面，不作处理

    ; 移动窗口到目标桌面
    DllCall(dllPath . "\MoveWindowToDesktopNumber", "Ptr", hwnd, "Int", target)
    
    ; 视角跟随切换到目标桌面
    if follow {
        DllCall(dllPath . "\GoToDesktopNumber", "Int", target)
    }
}

; ::vai.::{
;     promptMenu := Menu()
;     promptMenu.Add("&1 提示词-项目开始", (*) => SendText("请先读取并学习本项目的文档 然后我们会开始下一步的工作"))
;     promptMenu.Add("&2 提示词-切新窗口", (*) => SendText("判断当前对话是否应该切新窗口。只回答：是否建议切 + 原因 + 如果切，给我一份使用markdown块引用的 500 字以内的交接摘要"))
;     promptMenu.Show()
; }

; 提示词 prompt
; ::vaip::{
;     ToolTip "1 项目开始`n2 切新窗口"

;     ih := InputHook("L1 T5")
;     ih.Start()
;     ih.Wait()

;     ToolTip

;     switch ih.Input {
;         case "1":
;             SendText("请先读取并学习本项目的文档 然后我们会开始下一步的工作")
;         case "2":
;             SendText("判断当前对话是否应该切新窗口。只回答：是否建议切 + 原因 + 如果切，给我一份使用markdown块引用的 500 字以内的交接摘要")
;     }
; }



; ==================== 快捷键--针对obsidian移除空行 ====================
#HotIf WinActive("ahk_exe Obsidian.exe")

^!v::{
    ToolTip "移除空行"

    saved := ClipboardAll()

    text := A_Clipboard

    ; 统一换行
    text := StrReplace(text, "`r`n", "`n")
    text := StrReplace(text, "`r", "`n")

    ; 删除所有空白行
    text := RegExReplace(text, "m)^[ \t]*\n", "")

    ; 临时写回剪贴板并粘贴
    A_Clipboard := text
    ClipWait 0.5
    Send "^v"

    ; 等待 Obsidian 读取剪贴板后恢复
    Sleep 100
    A_Clipboard := saved
}

#HotIf

; ==================== 禁用Insert ====================
Insert::{
    ToolTip "Insert 已禁用"
    SetTimer () => ToolTip(), -800
}


; ==================== 媒体播放/暂停  ====================
<#<!Space::Send "{Media_Play_Pause}"