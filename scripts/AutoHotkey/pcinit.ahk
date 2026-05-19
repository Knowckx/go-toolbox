#Requires AutoHotkey v2.0

vscode := "C:\Users\AA\AppData\Local\Programs\Microsoft VS Code\Code.exe"
chrome := "C:\Program Files\Google\Chrome\Application\chrome.exe"



; Exit

; ----- 桌面2 -----
Sleep 500
Send "^#{Right}"
Run 'obsidian://open?vault=1-指南针'
Run 'C:\Users\AA\Desktop\foobar2000 plus (x64).lnk'

Run Format(
    '"{}" --new-window "{}" "{}"',
    chrome,
    "https://chatgpt.com/",
    "https://wx.mail.qq.com/"
)


; ----- 桌面1 -----
Sleep 2000
Send "^#{Left}"

Run 'obsidian://open?vault=2-投资'

Run Format('"{}" -n "{}"', vscode, "E:\dev\py\alchemy-dev")
Run Format('"{}" -n "{}"', vscode, "E:\dev\py\alchemy-dev\python")


Run Format(
    '"{}" --new-window "{}" "{}"',
    chrome,
    "https://chatgpt.com/",
    "https://chatgpt.com/codex/cloud/settings/analytics#usage"
)

Run "codex app"


; ; 在当前桌面打开一个新的 VSCode 窗口
; Run "code -n"
