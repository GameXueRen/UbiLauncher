#Requires AutoHotkey v2.0
;调试
; ListLines()
;@Ahk2Exe-SetVersion 1.0
;@Ahk2Exe-SetName 育碧平台启动器
;@Ahk2Exe-SetCompanyName GameXueRen
;@Ahk2Exe-SetCopyright © 2024 GameXueRen
runAsAdmin()
toolVersion := "v1.0"
toolName := "育碧平台启动器"
;配置文件
profilesName := toolName "配置.ini"
mainConfigName := "main"
ubiDirPathName := "育碧平台安装目录"
oldUbiVersionName := "旧版文件所在目录"
;备份文件后缀
backupExt := "gmxrbak"
isRunning := false

;主界面
creatMyGui()

;创建主界面控件及事件
creatMyGui()
{
    ;读取配置文件
    global ubiDirPath := readMainCfg(ubiDirPathName, "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher")
    global oldUbiVersion := readMainCfg(oldUbiVersionName, "148.0.0.10969")
    ;创建主界面
    global myGui := Gui("-Resize -MaximizeBox", toolName toolVersion)
    myGui.SetFont("s10")
    myGuiW := 420
    marginX := 8
    marginY := 8
    myGui.MarginX := marginX
    myGui.MarginY := marginY
    ;教程贴
    myGui.AddLink("Section xm ym", '退回原理参考此贴：<a href="https://tieba.baidu.com/p/9088077589">关于“强制退回旧版育碧平台”最新有效办法</a>')
    ;选择、打开育碧平台安装目录
    pathEditW := myGuiW - marginX * 2
    selectButtonW := 60
    selectButtonH := 30
    ubiTextCtrl := myGui.AddText("+0x200 xs r1 w" myGuiW - marginX * 2, ubiDirPathName "：")
    ubiTextCtrl.SetFont("s10 cRed w700")
    global ubiDirPathCtrl := myGui.AddEdit("ReadOnly r1 w" pathEditW, ubiDirPath)
    global selectUbiDirCtrl := myGui.AddButton("Section xp w" selectButtonW " h" selectButtonH, "选择")
    selectUbiDirCtrl.SetFont("w700")
    openUbiDirCtrl := myGui.AddButton("yp hp wp", "打开")
    ;关于
    startW := 94
    startH := 60
    offlineW := 30
    buttonMarginX := 16
    aboutW := 100
    aboutCtrl := myGui.AddLink("xs y+4 h48 w" myGuiW-marginX*2-startW*2-offlineW*2-buttonMarginX, 'GameXueRen制作`n工具开源：<a href="https://github.com/GameXueRen/UbiLauncher">UbiLauncher</a>`n友情推广：<a href="https://github.com/GameXueRen/GRW-CNChat">GRW-CNChat</a>`nQQ群：299177445')
    aboutCtrl.SetFont("s9")
    ;新版启动按钮
    global startNewUbiOfflineCtrl := myGui.AddButton("Section ys x" myGuiW - marginX - offlineW " w" offlineW " h" startH, "脱`n机`n模`n式")
    global startNewUbiCtrl := myGui.AddButton("Section ys x" myGuiW - marginX - offlineW - startW " w" startW " h" startH, "启动新UI`n(测试版)`n育碧平台")
    startNewUbiCtrl.SetFont("s12 w560")
    global newUbiVersionCtrl := myGui.AddDropDownList("xp y+2 Choose1 Disabled1 wp+" offlineW)
    ;旧版启动按钮
    global startOldUbiOfflineCtrl := myGui.AddButton("ys xp-" buttonMarginX + offlineW " h" startH " w" offlineW, "脱`n机`n模`n式")
    global startOldUbiCtrl := myGui.AddButton("ys xp-" startW " h" startH " w" startW, "启动旧UI`n(标准版)`n育碧平台")
    startOldUbiCtrl.SetFont("s12 w560")
    global oldUbiVersionCtrl := myGui.AddDropDownList("xp y+2 Choose1 wp+" offlineW, ["148.0.0.10969", "147.0.0.10965", "146.0.0.10945", "自定义旧版"])
    oldUbiVersionCtrl.Text := oldUbiVersion
    ;显示主界面
    myGui.Show("Center AutoSize w" myGuiW)
    ;添加控件事件
    selectUbiDirCtrl.OnEvent("Click", selectDirCtrl_Click)
    openUbiDirCtrl.OnEvent("Click", openDirCtrl_Click)
    startNewUbiCtrl.OnEvent("Click", (*) => startCtrl_Click(true))
    startOldUbiCtrl.OnEvent("Click", (*) => startCtrl_Click(false))
    startNewUbiOfflineCtrl.OnEvent("Click", (*) => startCtrl_Click(true, true))
    startOldUbiOfflineCtrl.OnEvent("Click", (*) => startCtrl_Click(false, true))
    oldUbiVersionCtrl.OnEvent("Change", oldUbiVersionCtrl_Change)
    myGui.OnEvent("Close", myGui_Close)
    ;托盘右键菜单定制
    A_TrayMenu.Delete()
    A_TrayMenu.Add("打开", (*) => myGui.Show())
    A_TrayMenu.Add("重新加载", (*) => Reload())
    A_TrayMenu.Add("退出", (*) => ExitApp())
    A_TrayMenu.ClickCount := 1
    A_TrayMenu.Default := "打开"
    A_IconTip := toolName toolVersion
    ;控件刷新
    startOldUbiCtrl.Focus()
    refreshNewUbiVersionCtrl()
}
;窗口关闭事件
myGui_Close(*)
{
    if isRunning
    {
        warningMsgBox("正在启动育碧平台中！`n请等待启动完成后再关闭！", "关闭失败！")
    }
    return isRunning
}
;以管理员身份运行
runAsAdmin()
{
    full_command_line := DllCall("GetCommandLine", "str")
    if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
    {
        try
        {
            if A_IsCompiled
                Run '*RunAs "' A_ScriptFullPath '" /restart'
            else
                Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
        }
        ExitApp
    }
}
;旧版本号选择事件
oldUbiVersionCtrl_Change(GuiCtrlObj, info)
{
    newText := GuiCtrlObj.Text
    if newText != oldUbiVersion
    {
        global oldUbiVersion := newText
        writeMainCfg(newText, oldUbiVersionName)
    }
}
;刷新新版本号控件
refreshNewUbiVersionCtrl()
{
    newUbiVersion := ""
    try {
        newUbiVersion := FileGetVersion(ubiDirPath "\upc.exe")
    }
    if !newUbiVersion
        newUbiVersion := "未检索到版本号"
    newUbiVersionCtrl.Delete()
    newUbiVersionCtrl.Add([newUbiVersion])
    newUbiVersionCtrl.Text := newUbiVersion
}
;启动按钮事件
startCtrl_Click(isNewUbi, isOffline := false)
{
    global isRunning := true
    startNewUbiCtrl.Enabled := false
    startNewUbiOfflineCtrl.Enabled := false
    startOldUbiCtrl.Enabled := false
    startOldUbiOfflineCtrl.Enabled := false
    selectUbiDirCtrl.Enabled := false
    oldUbiVersionCtrl.Enabled := false

    result := startUbi(isNewUbi, isOffline)

    delayTime := result ? -10000 : -100
    SetTimer(reEnabledCtrl, delayTime)
    reEnabledCtrl()
    {
        startNewUbiCtrl.Enabled := true
        startNewUbiOfflineCtrl.Enabled := true
        startOldUbiCtrl.Enabled := true
        startOldUbiOfflineCtrl.Enabled := true
        selectUbiDirCtrl.Enabled := true
        oldUbiVersionCtrl.Enabled := true
        global isRunning := false
    }
}
;启动育碧平台
startUbi(isNewUbi, isOffline := false)
{
    if !DirExist(ubiDirPath)
    {
        warningMsgBox(ubiDirPath "`n不存在！`n请确保已选择有效目录！", "启动失败！")
        return false
    }
    ubiStartPath := ubiDirPath "\upc.exe"
    if !FileExist(ubiStartPath)
    {
        warningMsgBox("upc.exe 不存在！`n" ubiDirPath "`n育碧平台安装目录无效！", "启动失败！")
        return false
    }
    if !isNewUbi
    {
        if !DirExist(oldUbiVersion)
        {
            warningMsgBox(oldUbiVersion "`n该旧版本文件夹不存在！", "启动失败！")
            return false
        }
        if !FileExist(oldUbiVersion "\uplay.exe")
        {
            warningMsgBox(oldUbiVersion "`n旧版本文件夹内的 uplay.exe 不存在！", "启动失败！")
            return false
        }
        ubiStartPath := ubiDirPath "\uplay.exe"
    }
    if ProcessExist("upc.exe")
    {
        result := warningMsgBox("新UI(测试版)育碧平台正在运行中！`n是否强制重启？", "强制重启？", "OKCancel Default2 Iconi")
        if result != "OK"
            return false
        ProcessClose("upc.exe")
        ProcessWaitClose("upc.exe", 10)
    } else if ProcessExist("uplay.exe")
    {
        result := warningMsgBox("旧UI(标准版)育碧平台正在在运行中！`n是否强制重启？", "强制重启？", "OKCancel Default2 Iconi")
        if result != "OK"
            return false
        ProcessClose("uplay.exe")
        ProcessWaitClose("uplay.exe", 10)
    }
    ;相关文件操作
    if isNewUbi
    {
        loop files ubiDirPath "\*"
        {
            if A_LoopFileExt != backupExt
                continue
            defaultFile := RTrim(A_LoopFileFullPath, "." A_LoopFileExt)
            if FileExist(defaultFile) && (DateDiff(FileGetTime(defaultFile), A_LoopFileTimeModified, "S") > 0)
            {
                ;备份文件修改时间比原文件小，则删除无效备份文件
                try {
                    FileDelete(A_LoopFileFullPath)
                }
            } else
            {
                ;强制恢复备份文件
                try {
                    FileMove(A_LoopFileFullPath, defaultFile, 1)
                }
            }
        }
    } else
    {
        loop Files oldUbiVersion "\*"
        {
            ubiDirLoopFile := ubiDirPath "\" A_LoopFileName
            backupFile := ubiDirLoopFile "." backupExt
            isNeedBackup := false
            if FileExist(ubiDirLoopFile)
            {
                ;根据文件大小与文件修改时间判断是否一致、是否需要备份
                ubiDirLoopFileTime := FileGetTime(ubiDirLoopFile)
                fileDiffTime := DateDiff(ubiDirLoopFileTime, A_LoopFileTimeModified, "S")
                if (FileGetSize(ubiDirLoopFile) = A_LoopFileSize) && (fileDiffTime = 0)
                    continue
                if FileExist(backupFile)
                {
                    backupDiffTime := DateDiff(ubiDirLoopFileTime, FileGetTime(backupFile), "S")
                    if backupDiffTime > 0
                    {
                        isNeedBackup := true
                    }
                }else
                {
                    if fileDiffTime > 0
                    {
                        isNeedBackup := true
                    }
                }
            }
            if isNeedBackup
            {
                try {
                    FileMove(ubiDirLoopFile, backupFile, 1)
                    Sleep(100)
                    FileCopy(A_LoopFileFullPath, ubiDirLoopFile, 1)
                } catch {
                    warningMsgBox("文件操作失败，请重试！", "启动失败！")
                    return false
                }
            } else
            {
                try {
                    FileCopy(A_LoopFileFullPath, ubiDirLoopFile, 1)
                } catch {
                    warningMsgBox("文件操作失败，请重试！", "启动失败！")
                    return false
                }
            }
        }
    }
    ;修改育碧平台配置文件
    ubiCfgDir := EnvGet("LocalAppData") "\Ubisoft Game Launcher"
    ubiCfgFile := ubiCfgDir "\settings.yaml"
    if DirExist(ubiCfgDir)
    {
        if FileExist(ubiCfgFile)
        {
            ubiCfg := FileRead(ubiCfgFile, "UTF-8")
        } else
        {
            ;配置文件不存在时，默认配置为中文
            ubiCfg := "language:`r`n  code: zh-CN"
        }
    } else
    {
        try {
            DirCreate(ubiCfgDir)
        }
        ubiCfg := "language:`r`n  code: zh-CN"
    }
    isChangeConnectView := changeYAMLData(&ubiCfg, "connect_view", "enabled", isNewUbi ? "true" : "false")
    isChangeUser := changeYAMLData(&ubiCfg, "user", "offline", isOffline ? "true" : "false")
    if isChangeConnectView or isChangeUser
    {
        try {
            FileDelete(ubiCfgFile)
        }
        Sleep(100)
        try
        {
            FileAppend(ubiCfg, ubiCfgFile, "UTF-8")
        } catch
        {
            continueResult := warningMsgBox("育碧平台配置文件修改失败！`n是否继续启动？", "是否继续？", "YesNo Default2 Iconi")
            if continueResult != "Yes"
                return false
        }
    }
    try {
        Run(ubiStartPath)
        return true
    }
    warningMsgBox(ubiStartPath "`n启动失败,请重试！", "启动失败！")
    return false
}
;修改YAML数据,返回值为数据是否有变化
changeYAMLData(&yamlData, section, key, value)
{
    ;数据为空，则追加section及key: value
    if !yamlData
    {
        yamlData := section ":`r`n  " key ": " value
        return true
    }
    ;查询section位置
    sectionStartPos := InStr(yamlData, section ":`r`n", 1)
    ;如果section不存在，则追加section及key: value
    if !sectionStartPos
    {
        yamlData := yamlData "`r`n" section ":`r`n  " key ": " value
        return true
    }
    sectionTitleLen := StrLen(section ":`r`n")
    sectionEndPos := InStr(yamlData, ":`r`n", 1, sectionStartPos + sectionTitleLen)
    ;查询key位置
    keyStartPos := InStr(yamlData, key ": ", 1, sectionStartPos + sectionTitleLen)
    ;判断是否在section层级下
    if sectionEndPos && (keyStartPos > sectionEndPos)
        keyStartPos := 0
    if keyStartPos
    {
        ;key存在且在section层级下，判断是否需要修改value
        valueStartPos := keyStartPos + StrLen(key ": ")
        valueEndPos := InStr(yamlData, "`r`n", 1, valueStartPos)
        if valueEndPos
        {
            oldValue := SubStr(yamlData, valueStartPos, valueEndPos - valueStartPos)
        }else
        {
            oldValue := SubStr(yamlData, valueStartPos)
        }
        if value != oldValue
        {
            ;修改value
            yamlData := SubStr(yamlData, 1, valueStartPos-1) value SubStr(yamlData, valueEndPos)
            return true
        } else
        {
            ;无变化
            return false
        }
    }else
    {
        ;key不存在或不在section层级下，追加key: value
        yamlData := SubStr(yamlData, 1, sectionStartPos + StrLen(section)-1) ":`r`n  " key ": " value SubStr(yamlData, sectionStartPos + StrLen(section ":"))
        return true
    }
}
;选择目录
selectDirCtrl_Click(GuiCtrlObj, info)
{
    myGui.Opt("+OwnDialogs")
    ; 允许用户选择 此电脑 目录下的文件夹
    folder := RegExReplace(DirSelect("::{20D04FE0-3AEA-1069-A2D8-08002B30309D}", 2, "选择 " ubiDirPathName), "\\$")
    if !folder
        return
    if (folder != ubiDirPath)
    {
        global ubiDirPath := folder
        ubiDirPathCtrl.Text := folder
        writeMainCfg(folder, ubiDirPathName)
        refreshNewUbiVersionCtrl()
    }
}
;打开目录
openDirCtrl_Click(GuiCtrlObj, info)
{
    if !ubiDirPath
        return
    try
    {
        Run("explore " ubiDirPath)
    } catch
    {
        warningMsgBox(ubiDirPath "`n打开目录失败！`n请确保已选择有效目录！", "打开目录失败！")
    }
}
;读取配置文件main
readMainCfg(Key?, Default := "")
{
    return IniRead(profilesName, mainConfigName, Key ?? unset, Default)
}
;写入配置文件main
writeMainCfg(Value, Key)
{
    if !FileExist(profilesName)
    {
        FileAppend "[" mainConfigName "]", profilesName, "CP0"
    }
    IniWrite(Value, profilesName, mainConfigName, Key)
}
;普通的警告样式弹窗
warningMsgBox(text?, title?, options?)
{
    if IsSet(myGui)
    {
        myGui.Opt("+OwnDialogs")
        myGui.GetPos(&myGuiX, &myGuiY)
        msgBoxX := myGuiX + 50
        msgBoxY := myGuiY + 50
        res := MsgBoxAt(msgBoxX, msgBoxY, text ?? unset, title ?? "警告！", options ?? "Icon!")
    } else
        res := MsgBox(text ?? unset, title ?? "警告！", options ?? "Icon!")
    return res ?? ""
}
;支持自定义弹出坐标的MsgBox
MsgBoxAt(x, y, text?, title?, options?)
{
    if hHook := DllCall("SetWindowsHookExW", "int", 5, "ptr", cb := CallbackCreate(CBTProc), "ptr", 0, "uint", DllCall("GetCurrentThreadId", "uint"), "ptr") {
        res := MsgBox(text ?? unset, title ?? unset, options ?? unset)
        if hHook
            DllCall("UnhookWindowsHookEx", "ptr", hHook)
    }
    CallbackFree(cb)
    return res ?? ""
    CBTProc(nCode, wParam, lParam) {
        if nCode == 3 && WinGetClass(wParam) == "#32770" {
            DllCall("UnhookWindowsHookEx", "ptr", hHook)
            hHook := 0
            pCreateStruct := NumGet(lParam, "ptr")
            NumPut("int", x, pCreateStruct, 44)
            NumPut("int", y, pCreateStruct, 40)
        }
        return DllCall("CallNextHookEx", "ptr", 0, "int", nCode, "ptr", wParam, "ptr", lParam)
    }
}
