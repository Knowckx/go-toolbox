#Requires AutoHotkey v2.0

vscode := "C:\Users\AA\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Scoop Apps\Visual Studio Code.lnk"
chrome := "C:\Program Files\Google\Chrome\Application\chrome.exe"

; 打开开发环境

Run 'obsidian://open?vault=2-投资'
Sleep 500

Run Format('"{}" -n "{}"', vscode, "E:\dev\py\alchemy-dev")
Sleep 1000
; Run Format('"{}" -n "{}"', vscode, "E:\dev\py\alchemy-dev\py_gateway")
; Sleep 500
Run Format('"{}" -n "{}"', vscode, "E:\dev\py\alchemy-dev\go_trade")
Sleep 500

Run Format(
    '"{}" --new-window "{}"',
    chrome,
    "https://chatgpt.com/",
)
Sleep 500

