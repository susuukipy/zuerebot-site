local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui", 15)
if not playerGui then return end
local global = (type(getgenv) == "function" and getgenv()) or _G
if type(global.DOLL4040_V6_CLOSE) == "function" then pcall(global.DOLL4040_V6_CLOSE) end
local old = playerGui:FindFirstChild("DOLL4040_FLICK_ECLIPSE_V6")
if old then old:Destroy() end
local alive = true
local connections = {}
local activeTweens = {}
local settingsFile = "DOLL4040_FLICK_ECLIPSE_V6.json"
local colors = {
    bg = Color3.fromRGB(4,5,7),
    surface = Color3.fromRGB(12,14,18),
    surface2 = Color3.fromRGB(20,23,29),
    elevated = Color3.fromRGB(29,33,41),
    text = Color3.fromRGB(246,247,250),
    secondary = Color3.fromRGB(163,172,186),
    muted = Color3.fromRGB(102,111,124),
    border = Color3.fromRGB(57,63,73)
}
local themes = {
    FROST = Color3.fromRGB(174,221,238),
    VIOLET = Color3.fromRGB(182,150,254),
    BLOOD = Color3.fromRGB(255,119,139),
    GHOST = Color3.fromRGB(232,234,240)
}
local prefs = {
    theme = "FROST",
    hud = true,
    crosshair = false,
    artwork = true,
    motion = true,
    scan = true,
    compact = false,
    glow = true
}
local function save()
    if type(writefile) == "function" then
        pcall(function() writefile(settingsFile, HttpService:JSONEncode(prefs)) end)
    end
end
if type(readfile) == "function" and type(isfile) == "function" then
    local ok, stored = pcall(function()
        if not isfile(settingsFile) then return nil end
        return HttpService:JSONDecode(readfile(settingsFile))
    end)
    if ok and type(stored) == "table" then
        for key,value in pairs(stored) do
            if prefs[key] ~= nil and type(value) == type(prefs[key]) then
                prefs[key] = value
            end
        end
    end
end
if not themes[prefs.theme] then prefs.theme = "FROST" end
local accent = themes[prefs.theme]
local function track(signal, callback)
    local connection = signal:Connect(callback)
    connections[#connections + 1] = connection
    return connection
end
local function element(class, properties, parent)
    local instance = Instance.new(class)
    for key, value in pairs(properties or {}) do instance[key] = value end
    instance.Parent = parent
    return instance
end
local function corner(parent, radius)
    return element("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, parent)
end
local function outline(parent, color, transparency)
    return element("UIStroke", {Color = color or colors.border, Thickness = 1, Transparency = transparency or .45}, parent)
end
local function frame(parent, name, color, transparency)
    return element("Frame", {
        Name=name or "Frame", BackgroundColor3=color or colors.surface,
        BackgroundTransparency=transparency or 0, BorderSizePixel=0
    }, parent)
end
local function label(parent, textValue, size, color, bold)
    return element("TextLabel", {
        Text=textValue, TextColor3=color or colors.text,
        Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextSize=size or 14, BackgroundTransparency=1,
        BorderSizePixel=0, TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,
        TextTruncate=Enum.TextTruncate.AtEnd
    }, parent)
end
local function button(parent, title, filled)
    local b = element("TextButton", {
        Text=title, TextSize=13, Font=Enum.Font.GothamBold,
        TextColor3=filled and colors.bg or colors.text,
        BackgroundColor3=filled and accent or colors.elevated,
        AutoButtonColor=false, BorderSizePixel=0
    }, parent)
    corner(b, 10)
    outline(b, filled and accent or colors.border, filled and .12 or .55)
    return b
end
local function tween(target, duration, properties, easing)
    if not target or not target.Parent or not alive then return end
    if not prefs.motion then
        for k,v in pairs(properties) do pcall(function() target[k] = v end) end
        return
    end
    local last = activeTweens[target]
    if last then pcall(function() last:Cancel() end) end
    local tw = TweenService:Create(target, TweenInfo.new(duration, easing or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties)
    activeTweens[target] = tw
    tw:Play()
    return tw
end
local function decode(data)
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local output = {}
    local value, count = 0, 0
    for i = 1, #data do
        local char = data:sub(i,i)
        if char == "=" then break end
        local pos = alphabet:find(char,1,true)
        if pos then
            value = value * 64 + pos - 1
            count = count + 6
            if count >= 8 then
                count = count - 8
                output[#output+1] = string.char(math.floor(value / 2 ^ count) % 256)
                value = value % (2 ^ count)
            end
        end
    end
    return table.concat(output)
end
local ART = [==[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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAcAAAAAAAEgUAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAMQAUAAEoAUAAAAAAAAAAAAAAAAAAAAAAAQAgAAEAgAgEAAAQIUAAAAAAAAAAAAAAAAAAAAAAAoEoAAUAIAoUAAEQAUAAAAAAAAAAAAAAAAAAAAAAgEAoAAQAgAgUEAMAAUAAAAAAAAAAAAAAAAAAAAAAoQwAQwUAIAIQEAQwgQwAAAAAAAAAAAAAAAAAAAAAgAAAAwQI0IgAQAAAgEAAAAAAAAAAAAAAAAAAAAAAAAAoAAA0IAEgAAAAAUAAAAAAAAAAAAAAAAAAAAAAAAAQwAAAAwgAAAAAwgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEsoQAokAAEEEAAAAAAAAAAAAAAAAAAAAAAAAAAAAUoIcIgQMkA08AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQoo0oggkgEEwsYU8YwMws0EAkQQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/8QAFBEBAAAAAAAAAAAAAAAAAAAAoP/aAAgBAwEBPxARH//EABQRAQAAAAAAAAAAAAAAAAAAAKD/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]==]
local function artwork()
    local assetFunction = getcustomasset or getsynasset
    if type(assetFunction) ~= "function" or type(writefile) ~= "function" then return nil end
    local path = "DOLL4040_FLICK_404.jpg"
    local ok, result = pcall(function()
        if type(isfile) ~= "function" or not isfile(path) then
            writefile(path, decode(ART))
        end
        return assetFunction(path)
    end)
    if ok and type(result) == "string" then return result end
    return nil
end
local gui = element("ScreenGui", {
    Name="DOLL4040_FLICK_ECLIPSE_V6", ResetOnSpawn=false,
    IgnoreGuiInset=true, DisplayOrder=880,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling
}, playerGui)
local dim = frame(gui,"Dim", colors.bg, .28)
dim.Size = UDim2.fromScale(1,1)
dim.Visible = false
local panel = element("CanvasGroup", {
    Name="Eclipse", Size=UDim2.fromOffset(900,590),
    AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
    BackgroundColor3=colors.surface, BackgroundTransparency=0,
    GroupTransparency=1, BorderSizePixel=0, ClipsDescendants=true
},gui)
corner(panel,17)
outline(panel,colors.border,.18)
local innerGlow = frame(panel,"TopLine",accent)
innerGlow.Size = UDim2.new(1,0,0,2)
local top = frame(panel,"Header",colors.surface)
top.Position=UDim2.fromOffset(0,2)
top.Size=UDim2.new(1,0,0,70)
local icon = frame(top,"LogoMark",colors.bg)
icon.Position=UDim2.fromOffset(16,12)
icon.Size=UDim2.fromOffset(46,46)
corner(icon,12)
outline(icon,accent,.15)
local iconText=label(icon,"404",20,accent,true)
iconText.TextXAlignment=Enum.TextXAlignment.Center
iconText.Size=UDim2.fromScale(1,1)
local heading=label(top,"DOLL4040 FLICK",22,colors.text,true)
heading.Position=UDim2.fromOffset(76,13)
heading.Size=UDim2.new(1,-190,0,27)
local headingSub=label(top,"E C L I P S E   •   V I S U A L  S Y S T E M",10,colors.muted,false)
headingSub.Position=UDim2.fromOffset(78,39)
headingSub.Size=UDim2.new(1,-195,0,22)
local close = button(top,"—",false)
close.Name="Minimize"
close.AnchorPoint=Vector2.new(1,0)
close.Position=UDim2.new(1,-16,0,16)
close.Size=UDim2.fromOffset(46,40)
local topRule=frame(panel,"Rule",colors.border,.55)
topRule.Position=UDim2.fromOffset(0,72)
topRule.Size=UDim2.new(1,0,0,1)
local navBar=frame(panel,"Navigation",colors.bg,.12)
local navTitle=label(navBar,"NULLSPACE",12,colors.muted,true)
local navItems={}
local tabs={"HOME","HUD","STYLE","SYSTEM"}
local navButtons={}
for i,tab in ipairs(tabs) do
    local navButton=button(navBar,tab,false)
    navButton.Name=tab
    navButtons[tab]=navButton
    navItems[i]=navButton
end
local content=frame(panel,"Pages",colors.surface)
content.BackgroundTransparency=1
local pageFrames={}
local function createPage(name)
    local page=element("ScrollingFrame",{
        Name=name, BorderSizePixel=0, BackgroundTransparency=1,
        ScrollBarThickness=3, ScrollBarImageColor3=accent,
        CanvasSize=UDim2.fromOffset(0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        ElasticBehavior=Enum.ElasticBehavior.WhenScrollable,
        Visible=false
    },content)
    element("UIPadding",{
        PaddingTop=UDim.new(0,8), PaddingBottom=UDim.new(0,10),
        PaddingLeft=UDim.new(0,4), PaddingRight=UDim.new(0,9)
    },page)
    element("UIListLayout",{
        FillDirection=Enum.FillDirection.Vertical,
        HorizontalAlignment=Enum.HorizontalAlignment.Left,
        Padding=UDim.new(0,12), SortOrder=Enum.SortOrder.LayoutOrder
    },page)
    pageFrames[name]=page
    return page
end
local home=createPage("HOME")
local hudPage=createPage("HUD")
local stylePage=createPage("STYLE")
local sysPage=createPage("SYSTEM")
local function card(parent, height, titleValue, desc, order)
    local c=frame(parent,"Card",colors.surface2)
    c.Size=UDim2.new(1,-1,0,height)
    c.LayoutOrder=order or 1
    corner(c,13)
    outline(c,colors.border,.53)
    if titleValue then
        local t=label(c,titleValue,15,colors.text,true)
        t.Position=UDim2.fromOffset(16,10)
        t.Size=UDim2.new(1,-32,0,26)
    end
    if desc then
        local d=label(c,desc,11,colors.muted,false)
        d.Position=UDim2.fromOffset(16,39)
        d.Size=UDim2.new(1,-32,0,24)
    end
    return c
end
local hero = card(home,210,nil,nil,1)
hero.ClipsDescendants=true
local heroGlow=frame(hero,"AccentGlow",accent,.32)
heroGlow.Size=UDim2.new(1,0,0,2)
heroGlow.ZIndex=6
local heroScan=frame(hero,"Scanline",accent,.76)
heroScan.Position=UDim2.fromOffset(0,0)
heroScan.Size=UDim2.new(1,0,0,2)
heroScan.ZIndex=7
local scanTween=TweenService:Create(heroScan,TweenInfo.new(3.2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,true),{Position=UDim2.new(0,0,1,-2)})
local function setDecorations()
    heroGlow.Visible=prefs.glow
    heroScan.Visible=prefs.scan
    if prefs.scan and prefs.motion then
        scanTween:Play()
    else
        scanTween:Pause()
    end
end
local heroBackground=frame(hero,"HeroBackground",colors.bg)
heroBackground.Size=UDim2.fromScale(1,1)
corner(heroBackground,13)
local bgImage = element("ImageLabel",{
    Name="404Artwork",Image="",BackgroundTransparency=1,
    ImageTransparency=.24, Size=UDim2.fromScale(1,1),
    ScaleType=Enum.ScaleType.Crop
},heroBackground)
local bgFallback=label(heroBackground,"404",132,Color3.fromRGB(55,57,63),true)
bgFallback.AnchorPoint=Vector2.new(.5,.5)
bgFallback.Position=UDim2.fromScale(.68,.45)
bgFallback.Size=UDim2.new(.64,0,0,140)
bgFallback.TextXAlignment=Enum.TextXAlignment.Center
local bgFallbackSub=label(heroBackground,"Not Found",23,Color3.fromRGB(61,64,70),true)
bgFallbackSub.Position=UDim2.new(.51,0,.68,0)
bgFallbackSub.Size=UDim2.new(.45,0,0,33)
bgFallbackSub.TextXAlignment=Enum.TextXAlignment.Center
local heroTitle=label(hero,"THE VOID IS ONLINE",21,colors.text,true)
heroTitle.Position=UDim2.fromOffset(20,19)
heroTitle.Size=UDim2.new(1,-38,0,36)
local heroSub=label(hero,"DOLL4040  /  ECLIPSE  /  404",11,accent,false)
heroSub.Position=UDim2.fromOffset(22,53)
heroSub.Size=UDim2.new(1,-40,0,24)
local heroBadge=frame(hero,"HeroBadge",colors.surface,.15)
heroBadge.Position=UDim2.fromOffset(22,153)
heroBadge.Size=UDim2.fromOffset(177,30)
corner(heroBadge,8)
outline(heroBadge,accent,.48)
local heroStatus=label(heroBadge,"●   SYSTEM READY",11,accent,true)
heroStatus.Position=UDim2.fromOffset(10,0)
heroStatus.Size=UDim2.new(1,-20,1,0)
local profile = card(home,111,"PLAYER IDENTITY","LOCAL PROFILE  /  PRIVATE INTERFACE",2)
local avatar=element("ImageLabel",{
    Size=UDim2.fromOffset(52,52), Position=UDim2.new(1,-69,0,30),
    BackgroundColor3=colors.bg, BorderSizePixel=0, Image=""
},profile)
corner(avatar,13)
outline(avatar,accent,.44)
local nick=label(profile,player.DisplayName,17,colors.text,true)
nick.Position=UDim2.fromOffset(17,65)
nick.Size=UDim2.new(1,-104,0,21)
local account=label(profile,"@"..player.Name,11,colors.muted,false)
account.Position=UDim2.fromOffset(17,89)
account.Size=UDim2.new(1,-105,0,17)
local metrics=card(home,103,"LIVE METRICS","LIGHTWEIGHT PERFORMANCE MONITOR",3)
local fpsHome=label(metrics,"-- FPS",19,accent,true)
fpsHome.Position=UDim2.fromOffset(17,70)
fpsHome.Size=UDim2.new(.45,0,0,27)
local pingHome=label(metrics,"-- MS",19,colors.text,true)
pingHome.Position=UDim2.new(.51,0,0,70)
pingHome.Size=UDim2.new(.44,0,0,27)
local homeActions=card(home,92,"QUICK ACCESS","RightShift on PC  •  Floating 404 on mobile",4)
local quick=button(homeActions,"OPEN HUD SETTINGS",false)
quick.Position=UDim2.new(1,-169,0,52)
quick.Size=UDim2.fromOffset(152,30)
quick.TextSize=10
local headerHUD=card(hudPage,84,"HUD / PERSONAL OVERLAY","Own-client indicators only. No enemy tracking.",1)
local overlay=frame(gui,"PerformanceWidget",colors.surface2,.08)
overlay.AnchorPoint=Vector2.new(1,0)
overlay.Position=UDim2.new(1,-18,0,18)
overlay.Size=UDim2.fromOffset(164,48)
corner(overlay,12)
outline(overlay,accent,.45)
local overlayText=label(overlay,"-- FPS  •  -- MS",12,colors.text,true)
overlayText.Size=UDim2.new(1,-14,1,0)
overlayText.Position=UDim2.fromOffset(10,0)
local crosshair=frame(gui,"Crosshair",accent)
crosshair.AnchorPoint=Vector2.new(.5,.5)
crosshair.Position=UDim2.fromScale(.5,.5)
crosshair.Size=UDim2.fromOffset(4,4)
corner(crosshair,3)
local crossLines={}
for i = 1,4 do
    local line=frame(gui,"CrossLine",accent)
    line.AnchorPoint=Vector2.new(.5,.5)
    line.Position=UDim2.fromScale(.5,.5)
    if i<=2 then
        line.Size=UDim2.fromOffset(2,12)
        line.Position=UDim2.new(.5,0,.5,i==1 and -14 or 14)
    else
        line.Size=UDim2.fromOffset(12,2)
        line.Position=UDim2.new(.5,i==3 and -14 or 14,.5,0)
    end
    crossLines[#crossLines+1]=line
end
local toggles={}
local function addToggle(parent,titleValue,subtitle,key,order)
    local row=card(parent,80,titleValue,subtitle,order)
    local toggle=button(row,"",false)
    toggle.AnchorPoint=Vector2.new(1,.5)
    toggle.Position=UDim2.new(1,-16,.5,1)
    toggle.Size=UDim2.fromOffset(62,32)
    local function update()
        toggle.Text=prefs[key] and "ON" or "OFF"
        tween(toggle,.18,{BackgroundColor3=prefs[key] and accent or colors.elevated,TextColor3=prefs[key] and colors.bg or colors.secondary})
    end
    toggles[key]=update
    track(toggle.Activated,function()
        prefs[key]=not prefs[key]
        update()
        save()
        if key=="hud" then overlay.Visible=prefs.hud end
        if key=="crosshair" then
            crosshair.Visible=prefs.crosshair
            for _,line in ipairs(crossLines) do line.Visible=prefs.crosshair end
        end
        if key=="artwork" then bgImage.Visible=prefs.artwork and bgImage.Image~="" end
        if key=="scan" or key=="glow" or key=="motion" then setDecorations() end
    end)
    update()
end
addToggle(hudPage,"Performance widget","FPS and ping in a floating overlay","hud",2)
addToggle(hudPage,"Crosshair overlay","Decorative local screen marker","crosshair",3)
local hudInfo=card(hudPage,104,"OPTIMIZED FOR EVERY SCREEN","Touch-ready buttons, no per-frame ESP or player scans.",4)
local hudInfoLine=label(hudInfo,"NO TRACKERS  /  NO EXTERNAL REQUESTS",10,colors.secondary,false)
hudInfoLine.Position=UDim2.fromOffset(16,74)
hudInfoLine.Size=UDim2.new(1,-32,0,19)
local styleTitle=card(stylePage,84,"ECLIPSE / APPEARANCE","One Lua for touch screens and desktop.",1)
local themeCard=card(stylePage,162,"COLOR LAB","Select your accent signature.",2)
local swatches={}
for i,name in ipairs({"FROST","VIOLET","BLOOD","GHOST"}) do
    local b=button(themeCard,name,true)
    b.Name=name
    b.BackgroundColor3=themes[name]
    b.TextColor3=colors.bg
    b.TextSize=11
    swatches[name]=b
    track(b.Activated,function()
        prefs.theme=name
        accent=themes[name]
        innerGlow.BackgroundColor3=accent
        iconText.TextColor3=accent
        heroSub.TextColor3=accent
        heroStatus.TextColor3=accent
        fpsHome.TextColor3=accent
        overlayText.TextColor3=colors.text
        overlay.UIStroke.Color=accent
        icon.UIStroke.Color=accent
        avatar.UIStroke.Color=accent
        heroBadge.UIStroke.Color=accent
        for _,v in ipairs(crossLines) do v.BackgroundColor3=accent end
        crosshair.BackgroundColor3=accent
        for _,btn in pairs(swatches) do btn.UIStroke.Transparency=.55 end
        b.UIStroke.Transparency=0
        for _,update in pairs(toggles) do update() end
        save()
    end)
end
addToggle(stylePage,"Animated transitions","Disable for slower devices","motion",3)
addToggle(stylePage,"404 artwork","Show the built-in monochrome image","artwork",4)
addToggle(stylePage,"Scanline decoration","Animated title shimmer","scan",5)
addToggle(stylePage,"Accent glow","Subtle colored details","glow",6)
local sysTitle=card(sysPage,86,"SYSTEM / DIAGNOSTICS","A standalone interface, without game-specific modules.",1)
local sysOverview=card(sysPage,163,"RUNTIME STATUS","Information from your current Roblox client.",2)
local systemRuntime=label(sysOverview,"CLIENT: LOADING",12,colors.secondary,false)
systemRuntime.Position=UDim2.fromOffset(16,70)
systemRuntime.Size=UDim2.new(1,-32,0,24)
local systemScreen=label(sysOverview,"DISPLAY: --",12,colors.secondary,false)
systemScreen.Position=UDim2.fromOffset(16,96)
systemScreen.Size=UDim2.new(1,-32,0,24)
local systemArt=label(sysOverview,"ARTWORK: PENDING",12,colors.secondary,false)
systemArt.Position=UDim2.fromOffset(16,122)
systemArt.Size=UDim2.new(1,-32,0,24)
local sysActions=card(sysPage,132,"PREFERENCES","Local save if your runtime supports file writes.",3)
local saveButton=button(sysActions,"SAVE CONFIG",true)
saveButton.Position=UDim2.fromOffset(16,72)
saveButton.Size=UDim2.new(.5,-25,0,44)
local resetButton=button(sysActions,"RESET STYLE",false)
resetButton.Position=UDim2.new(.5,6,0,72)
resetButton.Size=UDim2.new(.5,-22,0,44)
local sysFoot=card(sysPage,85,"DOLL4040 FLICK / ECLIPSE V6","VISUAL INTERFACE  •  PC + MOBILE  •  NO GAME MODIFICATION",4)
local navHint=label(panel,"DOLL4040  /  USER INTERFACE",10,colors.muted,false)
navHint.Position=UDim2.new(0,174,1,-27)
navHint.Size=UDim2.new(1,-188,0,21)
local float=button(gui,"404",false)
float.Name="FloatingReopen"
float.TextSize=21
float.BackgroundColor3=colors.bg
float.TextColor3=accent
float.AnchorPoint=Vector2.new(1,1)
float.Position=UDim2.new(1,-15,1,-15)
float.Size=UDim2.fromOffset(62,62)
float.Visible=false
outline(float,accent,.15)
local activePage="HOME"
local panelOpen=false
local function selectPage(name)
    activePage=name
    for tab,page in pairs(pageFrames) do
        page.Visible=(name==tab)
    end
    for tab,b in pairs(navButtons) do
        local selected=tab==name
        tween(b,.2,{
            BackgroundColor3=selected and accent or colors.elevated,
            TextColor3=selected and colors.bg or colors.secondary
        })
        b.UIStroke.Color=selected and accent or colors.border
    end
end
for name,b in pairs(navButtons) do track(b.Activated,function() selectPage(name) end) end
track(quick.Activated,function() selectPage("HUD") end)
local function setOpen(isOpen)
    panelOpen=isOpen
    if isOpen then
        panel.Visible=true
        dim.Visible=true
        float.Visible=false
        panel.GroupTransparency=1
        tween(panel,.32,{GroupTransparency=0})
        tween(dim,.22,{BackgroundTransparency=.28})
    else
        tween(panel,.22,{GroupTransparency=1})
        tween(dim,.22,{BackgroundTransparency=1})
        task.delay(.25,function()
            if not alive or panelOpen then return end
            panel.Visible=false
            dim.Visible=false
            float.Visible=true
        end)
    end
end
track(close.Activated,function() setOpen(false) end)
track(float.Activated,function() setOpen(true) end)
track(UserInputService.InputBegan,function(input,processed)
    if not processed and input.KeyCode==Enum.KeyCode.RightShift then setOpen(not panelOpen) end
end)
local mobile=false
local function layout()
    if not alive then return end
    local cam=workspace.CurrentCamera
    local view=cam and cam.ViewportSize or Vector2.new(1152,720)
    local w,h=view.X,view.Y
    mobile=w<740
    local pw=math.max(290,math.min(w-16,mobile and 450 or 930))
    local ph=math.max(320,math.min(h-16,mobile and 730 or 615))
    panel.Size=UDim2.fromOffset(pw,ph)
    local navH=mobile and 62 or 0
    local navW=mobile and 0 or 164
    navBar.Position=mobile and UDim2.new(0,0,1,-navH) or UDim2.fromOffset(0,73)
    navBar.Size=mobile and UDim2.new(1,0,0,navH) or UDim2.new(0,navW,1,-73)
    navTitle.Visible=not mobile
    navTitle.Position=UDim2.fromOffset(22,25)
    navTitle.Size=UDim2.fromOffset(120,22)
    local navButtonW=mobile and math.floor((pw-20)/4)-2 or 138
    for i,tab in ipairs(tabs) do
        local b=navItems[i]
        b.Position=mobile and UDim2.fromOffset(10+(i-1)*(navButtonW+2),11) or UDim2.fromOffset(13,77+(i-1)*60)
        b.Size=UDim2.fromOffset(navButtonW,mobile and 42 or 48)
        b.TextSize=mobile and 10 or 13
    end
    content.Position=UDim2.fromOffset(navW+10,81)
    content.Size=UDim2.fromOffset(pw-navW-20,ph-100-navH)
    for _,page in pairs(pageFrames) do page.Size=UDim2.fromScale(1,1) end
    navHint.Visible=not mobile
    heading.TextSize=mobile and 17 or 22
    heading.Position=UDim2.fromOffset(75,12)
    heading.Size=UDim2.new(1,-146,0,28)
    headingSub.TextSize=mobile and 8 or 10
    headingSub.Position=UDim2.fromOffset(77,41)
    headingSub.Size=UDim2.new(1,-151,0,19)
    icon.Size=mobile and UDim2.fromOffset(42,42) or UDim2.fromOffset(46,46)
    close.Size=UDim2.fromOffset(38,37)
    close.Position=UDim2.new(1,-12,0,17)
    hero.Size=UDim2.new(1,-1,0,mobile and 176 or 210)
    heroBadge.Position=UDim2.fromOffset(16,mobile and 124 or 153)
    heroTitle.TextSize=mobile and 17 or 21
    heroTitle.Position=UDim2.fromOffset(mobile and 15 or 20,16)
    heroSub.Position=UDim2.fromOffset(mobile and 17 or 22,48)
    bgFallback.TextSize=mobile and 92 or 132
    bgFallbackSub.TextSize=mobile and 17 or 23
    local space=math.max(0,themeCard.AbsoluteSize.X-32)
    local each=(space-18)/2
    for i,name in ipairs({"FROST","VIOLET","BLOOD","GHOST"}) do
        local b=swatches[name]
        local col=(i-1)%2
        local row=math.floor((i-1)/2)
        b.Position=UDim2.fromOffset(16+col*(each+18),72+row*39)
        b.Size=UDim2.fromOffset(each,34)
    end
    systemRuntime.Text="CLIENT: "..(UserInputService.TouchEnabled and "TOUCH ENABLED" or "DESKTOP INPUT")
    systemScreen.Text=string.format("DISPLAY: %d x %d",w,h)
end
local dragging=false
local dragInput
local origin
local startPosition
track(top.InputBegan,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true
        dragInput=input
        origin=input.Position
        startPosition=panel.Position
    end
end)
track(UserInputService.InputChanged,function(input)
    if not dragging or not origin then return end
    if input.UserInputType==Enum.UserInputType.MouseMovement or input==dragInput then
        local d=input.Position-origin
        panel.Position=UDim2.new(startPosition.X.Scale,startPosition.X.Offset+d.X,startPosition.Y.Scale,startPosition.Y.Offset+d.Y)
    end
end)
track(UserInputService.InputEnded,function(input)
    if input==dragInput or input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)
local function updateTheme()
    for _,item in pairs(toggles) do item() end
    for _,name in ipairs({"FROST","VIOLET","BLOOD","GHOST"}) do
        swatches[name].UIStroke.Transparency=name==prefs.theme and 0 or .55
    end
    accent=themes[prefs.theme]
    innerGlow.BackgroundColor3=accent
    iconText.TextColor3=accent
    heroSub.TextColor3=accent
    heroStatus.TextColor3=accent
    fpsHome.TextColor3=accent
    avatar.UIStroke.Color=accent
    overlay.UIStroke.Color=accent
    float.UIStroke.Color=accent
    float.TextColor3=accent
    for _,line in ipairs(crossLines) do line.BackgroundColor3=accent end
    crosshair.BackgroundColor3=accent
    heroGlow.BackgroundColor3=accent
    heroScan.BackgroundColor3=accent
    setDecorations()
    for tab,b in pairs(navButtons) do
        if tab==activePage then b.BackgroundColor3=accent b.TextColor3=colors.bg end
    end
end
track(saveButton.Activated,function() save() saveButton.Text="SAVED ✓" task.delay(1.3,function() if alive then saveButton.Text="SAVE CONFIG" end end) end)
track(resetButton.Activated,function()
    prefs.theme="FROST"
    prefs.hud=true
    prefs.crosshair=false
    prefs.motion=true
    prefs.artwork=true
    prefs.scan=true
    prefs.glow=true
    updateTheme()
    overlay.Visible=true
    crosshair.Visible=false
    for _,line in ipairs(crossLines) do line.Visible=false end
    bgImage.Visible=bgImage.Image~=""
    save()
end)
local frameCount=0
local last=os.clock()
local lastView=Vector2.new(0,0)
local elapsed=0
track(RunService.Heartbeat,function(dt)
    frameCount=frameCount+1
    elapsed=elapsed+dt
    if elapsed<1 then return end
    local fps=math.floor(frameCount/elapsed + .5)
    frameCount=0
    elapsed=0
    local ping=0
    pcall(function()
        ping=math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()+.5)
    end)
    fpsHome.Text=tostring(fps).." FPS"
    pingHome.Text=tostring(ping).." MS"
    overlayText.Text=tostring(fps).." FPS  /  "..tostring(ping).." MS"
    local cam=workspace.CurrentCamera
    if cam and cam.ViewportSize~=lastView then
        lastView=cam.ViewportSize
        layout()
    end
end)
local splash=frame(gui,"BootScreen",colors.bg)
splash.Size=UDim2.fromScale(1,1)
splash.ZIndex=150
local splashCard=element("CanvasGroup",{
    Name="BootCard", AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(510,330), BackgroundColor3=colors.surface,
    GroupTransparency=0, BorderSizePixel=0, ClipsDescendants=true, ZIndex=151
},splash)
corner(splashCard,18)
outline(splashCard,colors.border,.15)
local splashAccent=frame(splashCard,"Line",accent)
splashAccent.Size=UDim2.new(1,0,0,3)
local splashImage=element("ImageLabel",{
    Name="Background404", Image="", ImageTransparency=.5,
    Size=UDim2.fromScale(1,1), ScaleType=Enum.ScaleType.Crop,
    BackgroundTransparency=1, ZIndex=151
},splashCard)
local splashOverlay=frame(splashCard,"Tint",colors.bg,.35)
splashOverlay.Size=UDim2.fromScale(1,1)
splashOverlay.ZIndex=152
local splashNumber=label(splashCard,"404",111,Color3.fromRGB(88,91,99),true)
splashNumber.Position=UDim2.fromOffset(24,24)
splashNumber.Size=UDim2.new(1,-50,0,123)
splashNumber.ZIndex=153
local splashName=label(splashCard,"DOLL4040 FLICK",22,colors.text,true)
splashName.Position=UDim2.fromOffset(27,148)
splashName.Size=UDim2.new(1,-54,0,33)
splashName.ZIndex=154
local splashDesc=label(splashCard,"E C L I P S E   /   N U L L S P A C E",10,colors.secondary,false)
splashDesc.Position=UDim2.fromOffset(28,183)
splashDesc.Size=UDim2.new(1,-56,0,20)
splashDesc.ZIndex=154
local splashStatus=label(splashCard,"INITIALIZING INTERFACE",10,colors.muted,false)
splashStatus.Position=UDim2.fromOffset(29,231)
splashStatus.Size=UDim2.new(1,-58,0,21)
splashStatus.ZIndex=154
local splashRail=frame(splashCard,"ProgressRail",colors.elevated)
splashRail.Position=UDim2.new(0,28,1,-53)
splashRail.Size=UDim2.new(1,-94,0,5)
splashRail.ZIndex=154
corner(splashRail,3)
local splashFill=frame(splashRail,"Progress",accent)
splashFill.Size=UDim2.fromScale(0,1)
splashFill.ZIndex=155
corner(splashFill,3)
local splashPercent=label(splashCard,"0%",13,colors.text,true)
splashPercent.TextXAlignment=Enum.TextXAlignment.Right
splashPercent.AnchorPoint=Vector2.new(1,1)
splashPercent.Position=UDim2.new(1,-14,1,-37)
splashPercent.Size=UDim2.fromOffset(49,28)
splashPercent.ZIndex=155
local function splashLayout()
    local cam=workspace.CurrentCamera
    local v=cam and cam.ViewportSize or Vector2.new(1100,700)
    splashCard.Size=UDim2.fromOffset(math.min(510,v.X-20),math.min(330,v.Y-20))
end
local function progress(value, status)
    splashStatus.Text=status
    splashPercent.Text=tostring(value).."%"
    tween(splashFill,.23,{Size=UDim2.fromScale(value/100,1)})
end
local function closeEverything()
    if not alive then return end
    alive=false
    pcall(function() scanTween:Cancel() end)
    for _,tw in pairs(activeTweens) do pcall(function() tw:Cancel() end) end
    for _,connection in ipairs(connections) do pcall(function() connection:Disconnect() end) end
    pcall(function() gui:Destroy() end)
end
global.DOLL4040_V6_CLOSE=closeEverything
local function bootstrap()
    panel.Visible=false
    dim.Visible=false
    overlay.Visible=prefs.hud
    crosshair.Visible=prefs.crosshair
    for _,line in ipairs(crossLines) do line.Visible=prefs.crosshair end
    splashLayout()
    layout()
    selectPage("HOME")
    progress(12,"SYNCING DEVICE PROFILE")
    task.wait(.19)
    progress(31,"ADAPTING MOBILE / DESKTOP")
    task.wait(.19)
    progress(52,"LOADING 404 ARTWORK")
    local picture=artwork()
    if picture then
        bgImage.Image=picture
        splashImage.Image=picture
        bgFallback.Visible=false
        bgFallbackSub.Visible=false
        systemArt.Text="ARTWORK: EMBEDDED IMAGE LOADED"
    else
        systemArt.Text="ARTWORK: VECTOR FALLBACK ACTIVE"
    end
    bgImage.Visible=prefs.artwork and picture~=nil
    task.wait(.18)
    progress(76,"RESTORING VISUAL SETTINGS")
    updateTheme()
    task.spawn(function()
        local ok, img=pcall(function()
            return Players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150)
        end)
        if ok and alive then avatar.Image=img end
    end)
    task.wait(.18)
    progress(100,"ECLIPSE ONLINE")
    task.wait(.26)
    tween(splashCard,.37,{GroupTransparency=1})
    task.wait(.39)
    if not alive then return end
    splash:Destroy()
    setOpen(true)
end
task.spawn(bootstrap)