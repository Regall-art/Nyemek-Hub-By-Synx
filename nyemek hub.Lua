--[[
FISH IT SCRIPT - RAYFIELD EDITION
Fitur lengkap Auto Fishing, Auto Sell, Teleport, ESP, dll.
Dibuat berdasarkan referensi dari berbagai sumber
]]

-- Validasi Place ID game Fish It
local validPlaceIds = {
    [121864768012064] = true, -- Fish It place ID utama
    -- Tambahkan place ID lain jika diperlukan
}

if not validPlaceIds[game.PlaceId] then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Fish It Script",
        Text = "Game tidak terdeteksi sebagai Fish It! Script mungkin tidak berfungsi.",
        Duration = 5
    })
end

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Buat Window utama
local Window = Rayfield:CreateWindow({
    Name = "⚡ FISH IT - ATOMIC HUB ⚡",
    Icon = 0,
    LoadingTitle = "FISH IT SCRIPT 2026",
    LoadingSubtitle = "by Atomic Hub",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AtomicHub_FishIt",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = false
    },
    KeySystem = false
})

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Variables Global
local isFarming = false
local isAutoSelling = false
local isTeleporting = false
local isInfJump = false
local isESPEnabled = false
local isAntiAfk = false
local isAutoUpgrade = false
local isAutoEquip = false
local isFastCast = false
local isAutoCollect = false
local isNoOxygen = false
local isWalkSpeed = false
local isJumpPower = false
local isFpsBoost = false

local fishDelay = 1.5
local walkSpeedValue = 16
local jumpPowerValue = 50
local selectedRod = ""
local selectedBait = ""
local teleportWaypoints = {}

-- Deteksi Remote Events
local function findRemoteEvents()
    local remotes = {}
    
    -- Cari di Packages/_Index
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if packages then
        local index = packages:FindFirstChild("_Index")
        if index then
            for _, folder in pairs(index:GetChildren()) do
                if folder:IsA("Folder") then
                    local net = folder:FindFirstChild("net")
                    if net then
                        -- Remote Functions dan Events
                        for _, remote in pairs(net:GetDescendants()) do
                            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") or remote:IsA("Un/reliableRemoteEvent") then
                                local name = remote.Name
                                if not remotes[name] then
                                    remotes[name] = remote
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    -- Cari juga di lokasi lain
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and not remotes[obj.Name] then
            remotes[obj.Name] = obj
        end
    end
    
    return remotes
end

local remote = findRemoteEvents()
print("✅ Remote Events ditemukan:", #remote)

-- Fungsi untuk mendapatkan remote spesifik
local function getRemote(namePattern)
    for remoteName, remoteObj in pairs(remote) do
        if remoteName:lower():find(namePattern:lower()) then
            return remoteObj
        end
    end
    return nil
end

-- Auto Fishing Function
local function startFishing()
    while isFarming do
        task.wait(fishDelay)
        
        -- Simulasi cast pancing
        local castRemote = getRemote("cast") or getRemote("start") or getRemote("fish")
        if castRemote then
            if castRemote:IsA("RemoteFunction") then
                pcall(function()
                    castRemote:InvokeServer()
                end)
            else
                pcall(function()
                    castRemote:FireServer()
                end)
            end
        end
        
        -- Tunggu bentar trus reel
        task.wait(0.5)
        
        local reelRemote = getRemote("reel") or getRemote("complete") or getRemote("catch")
        if reelRemote then
            if reelRemote:IsA("RemoteFunction") then
                pcall(function()
                    reelRemote:InvokeServer()
                end)
            else
                pcall(function()
                    reelRemote:FireServer()
                end)
            end
        end
        
        -- Auto collect kalo ada
        if isAutoCollect then
            local collectRemote = getRemote("collect") or getRemote("claim")
            if collectRemote then
                pcall(function()
                    collectRemote:FireServer()
                end)
            end
        end
    end
end

-- Auto Sell Function
local function startAutoSell()
    while isAutoSelling do
        task.wait(30) -- Jual setiap 30 detik
        
        local sellRemote = getRemote("sell") or getRemote("sellall") or getRemote("sellitems")
        if sellRemote then
            if sellRemote:IsA("RemoteFunction") then
                pcall(function()
                    sellRemote:InvokeServer()
                end)
            else
                pcall(function()
                    sellRemote:FireServer()
                end)
            end
            print("✅ Auto Sell dijalankan")
        end
    end
end

-- ESP Function
local function toggleESP(enable)
    if enable then
        -- Loop untuk semua ikan
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("fish") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "FishESP"
                highlight.Parent = obj
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
            end
        end
        
        -- Monitor untuk ikan baru
        workspace.DescendantAdded:Connect(function(obj)
            if isESPEnabled and obj:IsA("Model") and obj.Name:lower():find("fish") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "FishESP"
                highlight.Parent = obj
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.OutlineColor = Color3.new(1, 1, 1)
            end
        end)
    else
        -- Hapus semua ESP
        for _, highlight in pairs(workspace:GetDescendants()) do
            if highlight.Name == "FishESP" then
                highlight:Destroy()
            end
        end
    end
end

-- Anti AFK Function
local function toggleAntiAfk(enable)
    if enable then
        -- Simulasi gerakan biar ga di-kick
        local bb = game:GetService("VirtualUser")
        player.Idled:Connect(function()
            if isAntiAfk then
                bb:CaptureController()
                bb:ClickButton2(Vector2.new())
            end
        end)
    end
end

-- Infinite Jump Function
local function toggleInfJump(enable)
    if enable then
        local oldJump = character.Humanoid.JumpPower
        character.Humanoid.JumpPower = 100
        
        UserInputService.JumpRequest:Connect(function()
            if isInfJump and character.Humanoid then
                character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        character.Humanoid.JumpPower = 50
    end
end

-- Speed & Jump Function
local function setWalkspeed(value)
    if character and character.Humanoid then
        character.Humanoid.WalkSpeed = value
    end
end

local function setJumpPower(value)
    if character and character.Humanoid then
        character.Humanoid.JumpPower = value
    end
end

-- Auto Upgrade Function
local function startAutoUpgrade()
    while isAutoUpgrade do
        task.wait(60) -- Cek tiap 60 detik
        
        local upgradeRemote = getRemote("upgrade") or getRemote("purchaserod") or getRemote("buyrod")
        if upgradeRemote then
            pcall(function()
                upgradeRemote:InvokeServer()
            end)
        end
    end
end

-- FPS Boost Function
local function toggleFpsBoost(enable)
    if enable then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        settings().Rendering.QualityLevel = 1
        for _, child in pairs(workspace:GetDescendants()) do
            if child:IsA("Decal") or child:IsA("Texture") then
                child.Transparency = 1
            end
        end
    else
        Lighting.GlobalShadows = true
        Lighting.FogEnd = 100000
        settings().Rendering.QualityLevel = 2
    end
end

-- Infinite Oxygen Function
local function toggleInfiniteOxygen(enable)
    if enable then
        if character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            local breath = Instance.new("BoolValue")
            breath.Name = "CanBreathe"
            breath.Parent = character
            breath.Value = true
        end
    end
end

-- =============================================
-- CREATE TABS
-- =============================================

-- Tab 1: Auto Farm
local FarmTab = Window:CreateTab("Auto Farm", 4483362458)

-- Section Fishing Settings
local FishingSection = FarmTab:CreateSection("⚙️ Fishing Settings")

-- Slider Delay
FarmTab:CreateSlider({
    Name = "Fishing Delay (seconds)",
    Range = {0.1, 5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = fishDelay,
    Flag = "FishDelay",
    Callback = function(value)
        fishDelay = value
    end
})

-- Toggle Auto Fish
FarmTab:CreateToggle({
    Name = "🎣 Auto Fishing",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(value)
        isFarming = value
        if value then
            task.spawn(startFishing)
            Rayfield:Notify({
                Title = "Auto Fishing",
                Content = "Auto Fishing diaktifkan!",
                Duration = 2
            })
        else
            Rayfield:Notify({
                Title = "Auto Fishing",
                Content = "Auto Fishing dinonaktifkan",
                Duration = 2
            })
        end
    end
})

-- Toggle Auto Sell
FarmTab:CreateToggle({
    Name = "💰 Auto Sell",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(value)
        isAutoSelling = value
        if value then
            task.spawn(startAutoSell)
        end
    end
})

-- Toggle Auto Collect
FarmTab:CreateToggle({
    Name = "📦 Auto Collect",
    CurrentValue = false,
    Flag = "AutoCollect",
    Callback = function(value)
        isAutoCollect = value
    end
})

-- Toggle Auto Upgrade
FarmTab:CreateToggle({
    Name = "⬆️ Auto Upgrade Rod",
    CurrentValue = false,
    Flag = "AutoUpgrade",
    Callback = function(value)
        isAutoUpgrade = value
        if value then
            task.spawn(startAutoUpgrade)
        end
    end
})

-- Toggle Fast Cast
FarmTab:CreateToggle({
    Name = "⚡ Fast Cast",
    CurrentValue = false,
    Flag = "FastCast",
    Callback = function(value)
        isFastCast = value
        if value then
            fishDelay = 0.1
        else
            fishDelay = 1.5
        end
    end
})

-- Section Auto Farm
local AutoSection = FarmTab:CreateSection("🤖 Auto Farm Features")

-- Toggle Anti AFK
FarmTab:CreateToggle({
    Name = "💤 Anti AFK",
    CurrentValue = false,
    Flag = "AntiAfk",
    Callback = function(value)
        isAntiAfk = value
        toggleAntiAfk(value)
    end
})

-- Toggle Infinite Jump
FarmTab:CreateToggle({
    Name = "🦘 Infinite Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(value)
        isInfJump = value
        toggleInfJump(value)
    end
})

-- Toggle Infinite Oxygen
FarmTab:CreateToggle({
    Name: "🌊 Infinite Oxygen",
    CurrentValue: false,
    Flag: "InfiniteOxygen",
    Callback: function(value)
        isNoOxygen = value
        toggleInfiniteOxygen(value)
    end
})

-- Tab 2: Teleport
local TeleportTab = Window:CreateTab("Teleport", 4483362458)

local TeleportSection = TeleportTab:CreateSection("📍 Teleport Locations")

-- Tombol teleport ke lokasi-lokasi penting
local locations = {
    {"🏝️ Fisherman Island", Vector3.new(0, 50, 0)},
    {"🏝️ Tropical Grove", Vector3.new(500, 50, 500)},
    {"🏝️ Esoteric Depths", Vector3.new(-500, -100, 300)},
    {"🏝️ Crystal Depths", Vector3.new(800, -200, -400)},
    {"🏝️ Pirate Cove", Vector3.new(-700, 50, -600)},
    {"🏝️ The Lost Isle", Vector3.new(1000, 100, 1000)},
    {"🏝️ Kohana Lava", Vector3.new(1500, 200, 500)},
    {"🏝️ Ancient Ruins", Vector3.new(-1000, 50, -800)},
    {"🏝️ Sell Area", Vector3.new(0, 50, 200)},
    {"🏝️ Shop Area", Vector3.new(100, 50, 100)}
}

for _, loc in ipairs(locations) do
    TeleportTab:CreateButton({
        Name = loc[1],
        Callback = function()
            if character and character.HumanoidRootPart then
                character.HumanoidRootPart.CFrame = CFrame.new(loc[2])
                Rayfield:Notify({
                    Title = "Teleport",
                    Content = "Teleport ke " .. loc[1],
                    Duration = 2
                })
            end
        end
    })
end

-- Tab 3: ESP & Visuals
local ESPTab = Window:CreateTab("ESP & Visuals", 4483362458)

local ESPSection = ESPTab:CreateSection("👁️ ESP Features")

-- Toggle Fish ESP
ESPTab:CreateToggle({
    Name = "🐟 Fish ESP",
    CurrentValue = false,
    Flag = "FishESP",
    Callback = function(value)
        isESPEnabled = value
        toggleESP(value)
    end
})

-- Toggle Player ESP
ESPTab:CreateToggle({
    Name = "👤 Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(value)
        if value then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "PlayerESP"
                    highlight.Parent = plr.Character
                    highlight.FillColor = Color3.new(0, 1, 0)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                end
            end
        else
            for _, highlight in pairs(workspace:GetDescendants()) do
                if highlight.Name == "PlayerESP" then
                    highlight:Destroy()
                end
            end
        end
    end
})

-- Toggle FPS Boost
ESPTab:CreateToggle({
    Name = "⚡ FPS Boost",
    CurrentValue = false,
    Flag = "FPSBoost",
    Callback = function(value)
        isFpsBoost = value
        toggleFpsBoost(value)
    end
})

-- Tab 4: Character
local CharacterTab = Window:CreateTab("Character", 4483362458)

local MovementSection = CharacterTab:CreateSection("🏃 Movement")

-- Slider WalkSpeed
CharacterTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    Suffix = " speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        walkSpeedValue = value
        if isWalkSpeed then
            setWalkspeed(value)
        end
    end
})

CharacterTab:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = false,
    Flag = "ToggleWalkSpeed",
    Callback = function(value)
        isWalkSpeed = value
        if value then
            setWalkspeed(walkSpeedValue)
        else
            setWalkspeed(16)
        end
    end
})

-- Slider JumpPower
CharacterTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 500},
    Increment = 1,
    Suffix = " power",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(value)
        jumpPowerValue = value
        if isJumpPower then
            setJumpPower(value)
        end
    end
})

CharacterTab:CreateToggle({
    Name = "Enable JumpPower",
    CurrentValue = false,
    Flag = "ToggleJumpPower",
    Callback = function(value)
        isJumpPower = value
        if value then
            setJumpPower(jumpPowerValue)
        else
            setJumpPower(50)
        end
    end
})

-- Tab 5: Shop & Upgrades
local ShopTab = Window:CreateTab("Shop", 4483362458)

local ShopSection = ShopTab:CreateSection("💰 Quick Buy")

-- Daftar rod yang bisa dibeli
local rods = {
    {"🎣 Starter Rod", 0},
    {"🎣 Midnight Rod", 50000},
    {"🎣 Ghost Fin Rod", 100000},
    {"🎣 Angler Rod", 150000},
    {"🎣 Abyssal Rod", 250000},
    {"🎣 Crystal Rod", 500000}
}

for _, rod in ipairs(rods) do
    ShopTab:CreateButton({
        Name = rod[1] .. " (" .. rod[2] .. " coins)",
        Callback = function()
            local buyRemote = getRemote("purchase") or getRemote("buy") or getRemote("shop")
            if buyRemote then
                pcall(function()
                    buyRemote:InvokeServer(rod[1])
                end)
            end
        end
    })
end

-- Tab 6: Settings
local SettingsTab = Window:CreateTab("Settings", 4483362458)

local UISection = SettingsTab:CreateSection("🖥️ UI Settings")

-- Tombol destroy GUI
SettingsTab:CreateButton({
    Name = "❌ Destroy GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})

-- Tombol toggle UI
SettingsTab:CreateButton({
    Name = "👁️ Toggle UI",
    Callback = function()
        Rayfield:ToggleUI()
    end
})

-- Credit
local CreditSection = SettingsTab:CreateSection("📝 Info")
SettingsTab:CreateParagraph({
    Title = "Atomic Hub - Fish It",
    Content = "Fitur Lengkap Auto Fishing\nVersion 1.0.0\n\nGunakan dengan bijak!"
})

-- Notifikasi siap
Rayfield:Notify({
    Title = "Fish It Script",
    Content = "✅ Script berhasil dimuat!",
    Duration = 3
})

-- Loop untuk maintain karakter
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    
    -- Reapply settings
    if isWalkSpeed then
        setWalkspeed(walkSpeedValue)
    end
    if isJumpPower then
        setJumpPower(jumpPowerValue)
    end
    if isNoOxygen then
        toggleInfiniteOxygen(true)
    end
end)

else
    -- Kalo salah game
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Fish It Script",
        Text = "Ini bukan game Fish It! Script hanya untuk Fish It.",
        Duration = 5
    })
end
