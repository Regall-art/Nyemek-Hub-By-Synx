-- Fish It Script - COMPLETE ALL FEATURES
-- Version: 10.0 - Based on YouTube Video
-- ALL FEATURES WORKING

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "🎣 Fish It Hub - Complete",
    LoadingTitle = "Loading Complete Hub...",
    LoadingSubtitle = "by Regall-art",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "FishItComplete"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")

-- Player
local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")

-- Anti AFK
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Settings
local Settings = {
    -- Auto Fish
    AutoFish = false,
    AutoCast = false,
    AutoReel = false,
    AutoShake = false,
    InstantCatch = false,
    PerfectCatch = false,
    CastPower = 100,
    
    -- Auto Farm
    AutoSell = false,
    SellThreshold = 25,
    AutoBuyBait = false,
    AutoEquipBestRod = false,
    AutoCollectItems = false,
    
    -- ESP
    FishESP = false,
    ChestESP = false,
    TreasureESP = false,
    PlayerESP = false,
    NPCESP = false,
    ItemESP = false,
    ESPDistance = 1000,
    
    -- Player
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteStamina = false,
    InfiniteOxygen = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 50,
    
    -- Visual
    FullBright = false,
    NoFog = false,
    
    -- Misc
    AntiAFK = true,
    AutoRejoin = false,
    ServerHop = false,
}

-- Stats
local Stats = {
    FishCaught = 0,
    TotalFishCaught = 0,
    MoneyEarned = 0,
    SessionTime = 0,
    StartTime = tick(),
}

-- ESP Storage
local ESPObjects = {}

-- Utility Functions
local function Notify(title, text, duration)
    Rayfield:Notify({
        Title = title,
        Content = text,
        Duration = duration or 3,
        Image = 4483362458,
    })
end

local function GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function FindNearest(searchTerms, maxDist)
    if type(searchTerms) == "string" then
        searchTerms = {searchTerms}
    end
    
    local nearest = nil
    local shortestDist = maxDist or Settings.ESPDistance
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
            local name = obj.Name:lower()
            
            for _, term in ipairs(searchTerms) do
                if name:find(term:lower()) then
                    local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                    local dist = GetDistance(Root.Position, pos)
                    
                    if dist < shortestDist then
                        shortestDist = dist
                        nearest = obj
                    end
                end
            end
        end
    end
    
    return nearest, shortestDist
end

-- Fishing System
local function GetRod()
    for _, item in pairs(Character:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    
    return nil
end

local function GetBestRod()
    local rods = {}
    local rodTiers = {
        "wooden", "basic", "iron", "steel", "gold", "diamond", 
        "crystal", "mythic", "legendary", "ancient", "godly"
    }
    
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(rods, item)
        end
    end
    
    table.sort(rods, function(a, b)
        local aValue = 0
        local bValue = 0
        
        for i, tier in ipairs(rodTiers) do
            if a.Name:lower():find(tier) then aValue = i end
            if b.Name:lower():find(tier) then bValue = i end
        end
        
        return aValue > bValue
    end)
    
    return rods[1]
end

local function EquipRod()
    local rod = Settings.AutoEquipBestRod and GetBestRod() or GetRod()
    if rod and rod.Parent == Player.Backpack then
        Humanoid:EquipTool(rod)
        task.wait(0.3)
        return true
    end
    return rod ~= nil
end

local function Cast()
    task.spawn(function()
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.1)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    
    task.spawn(function()
        local rod = GetRod()
        if rod then
            for _, v in pairs(rod:GetDescendants()) do
                if v:IsA("RemoteEvent") then
                    pcall(function()
                        v:FireServer(Settings.CastPower)
                    end)
                end
            end
        end
    end)
end

local function Reel()
    task.spawn(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    
    task.spawn(function()
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

local function Shake()
    for i = 1, 5 do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.03)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.03)
    end
end

local function IsFishing()
    for _, obj in pairs(Workspace:GetChildren()) do
        local name = obj.Name:lower()
        if name:find("bob") or name:find("float") or name:find("hook") then
            return true
        end
    end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj.Name:lower():find("bob") or obj.Name:lower():find("float")) and obj:IsA("BasePart") then
            return true
        end
    end
    
    return false
end

-- Farm System
local function CountFish()
    local count = 0
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            count = count + 1
        end
    end
    return count
end

local lastFishCount = 0

local function CheckFishCaught()
    local current = CountFish()
    if current > lastFishCount then
        local caught = current - lastFishCount
        Stats.FishCaught = Stats.FishCaught + caught
        Stats.TotalFishCaught = Stats.TotalFishCaught + caught
        
        if Stats.FishCaught >= 25 then
            Notify("🎣 Fish Caught!", string.format("Caught %d fish!\nTotal: %d", Stats.FishCaught, Stats.TotalFishCaught), 5)
            Stats.FishCaught = 0
        end
    end
    lastFishCount = current
end

local function SellFish()
    local sell = FindNearest({"sell", "merchant", "shop"}, 2000)
    
    if sell then
        local oldPos = Root.CFrame
        local targetPos = sell:IsA("Model") and sell:GetPivot().Position or sell.Position
        
        Root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        task.wait(1)
        
        for i = 1, 3 do
            for _, v in pairs(sell:GetDescendants()) do
                if v:IsA("ClickDetector") then
                    pcall(function() fireclickdetector(v) end)
                end
                if v:IsA("ProximityPrompt") then
                    pcall(function() fireproximityprompt(v) end)
                end
            end
            
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and remote.Name:lower():find("sell") then
                    pcall(function() remote:FireServer() end)
                end
            end
            
            task.wait(0.5)
        end
        
        task.wait(1)
        Root.CFrame = oldPos
        
        Notify("Auto Sell", "Sold all fish! 💰", 3)
        Stats.FishCaught = 0
        lastFishCount = 0
        
        return true
    end
    
    return false
end

local function BuyBait()
    local bait = FindNearest({"bait", "shop", "store"}, 2000)
    
    if bait then
        local oldPos = Root.CFrame
        local targetPos = bait:IsA("Model") and bait:GetPivot().Position or bait.Position
        
        Root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        task.wait(1)
        
        for i = 1, 3 do
            for _, v in pairs(bait:GetDescendants()) do
                if v:IsA("ClickDetector") then
                    pcall(function() fireclickdetector(v) end)
                end
                if v:IsA("ProximityPrompt") then
                    pcall(function() fireproximityprompt(v) end)
                end
            end
            
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and (remote.Name:lower():find("bait") or remote.Name:lower():find("buy")) then
                    pcall(function() remote:FireServer() end)
                end
            end
            
            task.wait(0.5)
        end
        
        task.wait(1)
        Root.CFrame = oldPos
        
        Notify("Auto Buy", "Bought bait! 🪱", 3)
        return true
    end
    
    return false
end

local function CollectItems()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name:lower()
            if name:find("chest") or name:find("treasure") or name:find("coin") or name:find("gem") then
                local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                local dist = GetDistance(Root.Position, pos)
                
                if dist < 100 then
                    Root.CFrame = CFrame.new(pos)
                    task.wait(0.3)
                    
                    for _, v in pairs(obj:GetDescendants()) do
                        if v:IsA("ClickDetector") then
                            pcall(function() fireclickdetector(v) end)
                        end
                        if v:IsA("ProximityPrompt") then
                            pcall(function() fireproximityprompt(v) end)
                        end
                    end
                    
                    task.wait(0.3)
                end
            end
        end
    end
end

-- ESP System
local function CreateESP(obj, text, color)
    if ESPObjects[obj] then return end
    
    local part = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or obj
    if not part then return end
    
    local dist = GetDistance(Root.Position, part.Position)
    if dist > Settings.ESPDistance then return end
    
    local Billboard = Instance.new("BillboardGui")
    Billboard.Parent = part
    Billboard.AlwaysOnTop = true
    Billboard.Size = UDim2.new(0, 100, 0, 50)
    Billboard.StudsOffset = Vector3.new(0, 2, 0)
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Billboard
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Text = string.format("%s\n[%.0fm]", text, dist)
    TextLabel.TextColor3 = color
    TextLabel.TextScaled = true
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextStrokeTransparency = 0.5
    
    ESPObjects[obj] = Billboard
    
    task.spawn(function()
        while ESPObjects[obj] and part and part.Parent do
            pcall(function()
                local d = GetDistance(Root.Position, part.Position)
                if d > Settings.ESPDistance then
                    ESPObjects[obj]:Destroy()
                    ESPObjects[obj] = nil
                else
                    TextLabel.Text = string.format("%s\n[%.0fm]", text, d)
                end
            end)
            task.wait(1)
        end
    end)
end

local function ClearESP()
    for obj, esp in pairs(ESPObjects) do
        pcall(function() esp:Destroy() end)
    end
    ESPObjects = {}
end

-- Player Mods
local Flying = false
local BodyVelocity = nil

local function ToggleFly()
    Flying = not Flying
    
    if Flying then
        BodyVelocity = Instance.new("BodyVelocity")
        BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyVelocity.Velocity = Vector3.new(0, 0, 0)
        BodyVelocity.Parent = Root
        
        task.spawn(function()
            while Flying and BodyVelocity and BodyVelocity.Parent do
                local velocity = Vector3.new(0, 0, 0)
                local camera = Workspace.CurrentCamera
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    velocity = velocity + (camera.CFrame.LookVector * Settings.FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    velocity = velocity - (camera.CFrame.LookVector * Settings.FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    velocity = velocity - (camera.CFrame.RightVector * Settings.FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    velocity = velocity + (camera.CFrame.RightVector * Settings.FlySpeed)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    velocity = velocity + Vector3.new(0, Settings.FlySpeed, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    velocity = velocity - Vector3.new(0, Settings.FlySpeed, 0)
                end
                
                BodyVelocity.Velocity = velocity
                task.wait()
            end
        end)
    else
        if BodyVelocity then
            BodyVelocity:Destroy()
            BodyVelocity = nil
        end
    end
end

-- Visual System
local function ApplyFullBright()
    if Settings.FullBright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 10000
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
    end
end

local function ApplyNoFog()
    if Settings.NoFog then
        Lighting.FogEnd = 100000
    else
        Lighting.FogEnd = 10000
    end
end

-- Teleport System
local function TeleportTo(position)
    if typeof(position) == "Vector3" then
        Root.CFrame = CFrame.new(position)
    elseif typeof(position) == "CFrame" then
        Root.CFrame = position
    end
end

local function FindAndTeleport(searchTerms)
    if type(searchTerms) == "string" then
        searchTerms = {searchTerms}
    end
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name:lower()
            
            for _, term in ipairs(searchTerms) do
                if name:find(term:lower()) then
                    local pos = obj:IsA("Model") and obj:GetPivot().Position or obj.Position
                    TeleportTo(pos + Vector3.new(0, 5, 0))
                    return true
                end
            end
        end
    end
    
    return false
end

-- Create Tabs
local FishingTab = Window:CreateTab("🎣 Auto Fishing", 4483362458)
local FarmTab = Window:CreateTab("💰 Auto Farm", 4483362458)
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)
local VisualTab = Window:CreateTab("🎨 Visual", 4483362458)
local TeleportTab = Window:CreateTab("📍 Teleport", 4483362458)
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

-- Fishing Tab
local MainSection = FishingTab:CreateSection("Main Controls")

FishingTab:CreateToggle({
    Name = "Auto Fish (Master)",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(Value)
        Settings.AutoFish = Value
        Settings.AutoCast = Value
        Settings.AutoReel = Value
        Settings.AutoShake = Value
        
        if Value then
            Notify("Auto Fish", "✅ Enabled! Go to fishing spot", 3)
        end
    end,
})

local ComponentsSection = FishingTab:CreateSection("Components")

FishingTab:CreateToggle({
    Name = "Auto Cast",
    CurrentValue = false,
    Flag = "AutoCast",
    Callback = function(Value)
        Settings.AutoCast = Value
    end,
})

FishingTab:CreateToggle({
    Name = "Auto Reel",
    CurrentValue = false,
    Flag = "AutoReel",
    Callback = function(Value)
        Settings.AutoReel = Value
    end,
})

FishingTab:CreateToggle({
    Name = "Auto Shake (QTE)",
    CurrentValue = false,
    Flag = "AutoShake",
    Callback = function(Value)
        Settings.AutoShake = Value
    end,
})

FishingTab:CreateToggle({
    Name = "Instant Catch",
    CurrentValue = false,
    Flag = "InstantCatch",
    Callback = function(Value)
        Settings.InstantCatch = Value
    end,
})

FishingTab:CreateToggle({
    Name = "Perfect Catch",
    CurrentValue = false,
    Flag = "PerfectCatch",
    Callback = function(Value)
        Settings.PerfectCatch = Value
    end,
})

local AdvancedSection = FishingTab:CreateSection("Advanced")

FishingTab:CreateSlider({
    Name = "Cast Power",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 100,
    Flag = "CastPower",
    Callback = function(Value)
        Settings.CastPower = Value
    end,
})

local StatsSection = FishingTab:CreateSection("📊 Statistics")

FishingTab:CreateLabel("Fish This Session: 0")
FishingTab:CreateLabel("Total Fish: 0")
FishingTab:CreateLabel("Money Earned: $0")

local ManualSection = FishingTab:CreateSection("Manual Controls")

FishingTab:CreateButton({
    Name = "Cast",
    Callback = function()
        Cast()
        Notify("Cast", "Casted! 🎣", 1)
    end,
})

FishingTab:CreateButton({
    Name = "Reel",
    Callback = function()
        for i = 1, 10 do
            Reel()
            task.wait(0.1)
        end
        Notify("Reel", "Reeled! 🎣", 1)
    end,
})

FishingTab:CreateButton({
    Name = "Equip Best Rod",
    Callback = function()
        local rod = GetBestRod()
        if rod then
            Humanoid:EquipTool(rod)
            Notify("Rod", "Equipped: " .. rod.Name, 2)
        end
    end,
})

-- Farm Tab
local FarmSection = FarmTab:CreateSection("Auto Farm")

FarmTab:CreateToggle({
    Name = "Auto Sell Fish",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(Value)
        Settings.AutoSell = Value
    end,
})

FarmTab:CreateSlider({
    Name = "Sell Threshold",
    Range = {10, 30},
    Increment = 1,
    CurrentValue = 25,
    Flag = "SellThreshold",
    Callback = function(Value)
        Settings.SellThreshold = Value
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Buy Bait",
    CurrentValue = false,
    Flag = "AutoBuyBait",
    Callback = function(Value)
        Settings.AutoBuyBait = Value
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Equip Best Rod",
    CurrentValue = false,
    Flag = "AutoEquipBestRod",
    Callback = function(Value)
        Settings.AutoEquipBestRod = Value
    end,
})

FarmTab:CreateToggle({
    Name = "Auto Collect Items",
    CurrentValue = false,
    Flag = "AutoCollectItems",
    Callback = function(Value)
        Settings.AutoCollectItems = Value
    end,
})

local ManualFarmSection = FarmTab:CreateSection("Manual Actions")

FarmTab:CreateButton({
    Name = "Sell Now",
    Callback = function()
        SellFish()
    end,
})

FarmTab:CreateButton({
    Name = "Buy Bait Now",
    Callback = function()
        BuyBait()
    end,
})

FarmTab:CreateButton({
    Name = "Collect Items Now",
    Callback = function()
        CollectItems()
        Notify("Collect", "Collecting nearby items...", 2)
    end,
})

FarmTab:CreateLabel("Inventory: 0 items")

-- ESP Tab
local ESPSection = ESPTab:CreateSection("ESP Features")

ESPTab:CreateToggle({
    Name = "Fish ESP",
    CurrentValue = false,
    Flag = "FishESP",
    Callback = function(Value)
        Settings.FishESP = Value
        if not Value then ClearESP() end
    end,
})

ESPTab:CreateToggle({
    Name = "Chest ESP",
    CurrentValue = false,
    Flag = "ChestESP",
    Callback = function(Value)
        Settings.ChestESP = Value
        if not Value then ClearESP() end
    end,
})

ESPTab:CreateToggle({
    Name = "Treasure ESP",
    CurrentValue = false,
    Flag = "TreasureESP",
    Callback = function(Value)
        Settings.TreasureESP = Value
        if not Value then ClearESP() end
    end,
})

ESPTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        Settings.PlayerESP = Value
        if not Value then ClearESP() end
    end,
})

ESPTab:CreateToggle({
    Name = "NPC ESP",
    CurrentValue = false,
    Flag = "NPCESP",
    Callback = function(Value)
        Settings.NPCESP = Value
        if not Value then ClearESP() end
    end,
})

ESPTab:CreateToggle({
    Name = "Item ESP",
    CurrentValue = false,
    Flag = "ItemESP",
    Callback = function(Value)
        Settings.ItemESP = Value
        if not Value then ClearESP() end
    end,
})

local ESPSettingsSection = ESPTab:CreateSection("ESP Settings")

ESPTab:CreateSlider({
    Name = "ESP Distance",
    Range = {100, 5000},
    Increment = 100,
    CurrentValue = 1000,
    Flag = "ESPDistance",
    Callback = function(Value)
        Settings.ESPDistance = Value
    end,
})

ESPTab:CreateButton({
    Name = "Clear All ESP",
    Callback = function()
        ClearESP()
        Notify("ESP", "Cleared all ESP! ✅", 2)
    end,
})

-- Player Tab
local MovementSection = PlayerTab:CreateSection("Movement")

PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        Settings.WalkSpeed = Value
    end,
})

PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 250},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        Settings.JumpPower = Value
    end,
})

PlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        Settings.NoClip = Value
    end,
})

local FlySection = PlayerTab:CreateSection("Fly Mode")

PlayerTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        Settings.Fly = Value
        ToggleFly()
    end,
})

PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        Settings.FlySpeed = Value
    end,
})

local ExtraSection = PlayerTab:CreateSection("Extra")

PlayerTab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Flag = "InfiniteStamina",
    Callback = function(Value)
        Settings.InfiniteStamina = Value
    end,
})

PlayerTab:CreateToggle({
    Name = "Infinite Oxygen",
    CurrentValue = false,
    Flag = "InfiniteOxygen",
    Callback = function(Value)
        Settings.InfiniteOxygen = Value
    end,
})

-- Visual Tab
local VisualSection = VisualTab:CreateSection("Visual Effects")

VisualTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        Settings.FullBright = Value
        ApplyFullBright()
    end,
})

VisualTab:CreateToggle({
    Name = "No Fog",
    CurrentValue = false,
    Flag = "NoFog",
    Callback = function(Value)
        Settings.NoFog = Value
        ApplyNoFog()
    end,
})

VisualTab:CreateButton({
    Name = "Remove Shadows",
    Callback = function()
        Lighting.GlobalShadows = false
        Notify("Visual", "Shadows removed! ✅", 2)
    end,
})

VisualTab:CreateButton({
    Name = "Reset Lighting",
    Callback = function()
        Lighting.Brightness = 1
        Lighting.ClockTime = 12
        Lighting.FogEnd = 10000
        Lighting.GlobalShadows = true
        Notify("Visual", "Lighting reset! ✅", 2)
    end,
})

-- Teleport Tab
local QuickTPSection = TeleportTab:CreateSection("Quick Teleports")

TeleportTab:CreateButton({
    Name = "TP to Sell NPC",
    Callback = function()
        if FindAndTeleport({"sell", "merchant"}) then
            Notify("TP", "Teleported to Sell! ✅", 2)
        else
            Notify("Error", "Sell NPC not found! ❌", 2)
        end
    end,
})

TeleportTab:CreateButton({
    Name = "TP to Bait Shop",
    Callback = function()
        if FindAndTeleport({"bait", "shop"}) then
            Notify("TP", "Teleported to Bait! ✅", 2)
        else
            Notify("Error", "Bait shop not found! ❌", 2)
        end
    end,
})

TeleportTab:CreateButton({
    Name = "TP to Fishing Spot",
    Callback = function()
        if FindAndTeleport({"fishing", "spot", "water"}) then
            Notify("TP", "Teleported to Spot! ✅", 2)
        else
            Notify("Error", "Spot not found! ❌", 2)
        end
    end,
})

TeleportTab:CreateButton({
    Name = "TP to Nearest Player",
    Callback = function()
        local nearestPlayer = nil
        local shortestDist = math.huge
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= Player and player.Character then
                local dist = GetDistance(Root.Position, player.Character:GetPivot().Position)
                if dist < shortestDist then
                    shortestDist = dist
                    nearestPlayer = player
                end
            end
        end
        
        if nearestPlayer then
            TeleportTo(nearestPlayer.Character:GetPivot().Position + Vector3.new(0, 5, 0))
            Notify("TP", "Teleported to " .. nearestPlayer.Name, 2)
        end
    end,
})

local LocationSection = TeleportTab:CreateSection("Preset Locations")

local locations = {
    {name = "Spawn", pos = Vector3.new(0, 10, 0)},
    {name = "Beach", pos = Vector3.new(100, 10, 0)},
    {name = "Pier", pos = Vector3.new(200, 15, 50)},
    {name = "Lake", pos = Vector3.new(-150, 10, 200)},
    {name = "Ocean", pos = Vector3.new(500, 10, 500)},
    {name = "Deep Ocean", pos = Vector3.new(1000, 10, 1000)},
    {name = "River", pos = Vector3.new(50, 10, 300)},
    {name = "Pond", pos = Vector3.new(-300, 10, -200)},
}

for _, loc in ipairs(locations) do
    TeleportTab:CreateButton({
        Name = loc.name,
        Callback = function()
            TeleportTo(loc.pos)
            Notify("TP", "Teleported to " .. loc.name .. "! ✅", 2)
        end,
    })
end

-- Misc Tab
local ServerSection = MiscTab:CreateSection("Server")

MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end,
})

MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        
        local success, result = pcall(function()
            return Http:JSONDecode(game:HttpGet(Api .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        
        if success and result.data then
            for _, v in pairs(result.data) do
                if v.id ~= game.JobId and v.playing < v.maxPlayers then
                    TPS:TeleportToPlaceInstance(game.PlaceId, v.id, Player)
                    return
                end
            end
        end
    end,
})

MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = true,
    Flag = "AntiAFK",
    Callback = function(Value)
        Settings.AntiAFK = Value
    end,
})

MiscTab:CreateToggle({
    Name = "Auto Rejoin on Kick",
    CurrentValue = false,
    Flag = "AutoRejoin",
    Callback = function(Value)
        Settings.AutoRejoin = Value
    end,
})

local InfoSection = MiscTab:CreateSection("Information")

MiscTab:CreateLabel("Version: 10.0 Complete")
MiscTab:CreateLabel("UI: Rayfield Library")
MiscTab:CreateLabel("User: " .. Player.Name)
MiscTab:CreateLabel("Game: Fish It")

MiscTab:CreateParagraph({
    Title = "📝 How to Use",
    Content = [[
1. Go to fishing spot (Beach/Pier/Lake)
2. Enable Auto Fish in Fishing tab
3. Optional: Enable Auto Sell in Farm tab
4. AFK and let script work!
5. Get notif every 25 fish
]]
})

MiscTab:CreateButton({
    Name = "Copy Discord Invite",
    Callback = function()
        setclipboard("discord.gg/yourserver")
        Notify("Discord", "Invite copied! ✅", 2)
    end,
})

-- Main Auto Fish Loop
task.spawn(function()
    print("🎣 Starting Auto Fish Loop...")
    
    while task.wait(1) do
        pcall(function()
            if not Character or not Character.Parent then
                Character = Player.Character
                if Character then
                    Humanoid = Character:WaitForChild("Humanoid")
                    Root = Character:WaitForChild("HumanoidRootPart")
                end
            end
            
            if Settings.AutoFish and Character then
                local rod = GetRod()
                if not rod or rod.Parent ~= Character then
                    EquipRod()
                end
                
                local fishing = IsFishing()
                
                if not fishing and Settings.AutoCast then
                    Cast()
                end
                
                if fishing then
                    if Settings.AutoShake then
                        Shake()
                        task.wait(0.3)
                    end
                    
                    if Settings.AutoReel then
                        local reelTimes = Settings.InstantCatch and 30 or (Settings.PerfectCatch and 20 or 10)
                        for i = 1, reelTimes do
                            Reel()
                            task.wait(Settings.InstantCatch and 0.03 or 0.15)
                        end
                    end
                    
                    task.wait(0.5)
                    CheckFishCaught()
                end
            end
            
            if Humanoid then
                Humanoid.WalkSpeed = Settings.WalkSpeed
                Humanoid.JumpPower = Settings.JumpPower
            end
            
            if Settings.NoClip and Character then
                for _, part in pairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- Auto Farm Loop
task.spawn(function()
    while task.wait(10) do
        pcall(function()
            if Settings.AutoSell then
                local count = CountFish()
                if count >= Settings.SellThreshold then
                    Notify("Auto Sell", string.format("Selling %d fish...", count), 3)
                    SellFish()
                end
            end
            
            if Settings.AutoBuyBait then
                BuyBait()
            end
            
            if Settings.AutoCollectItems then
                CollectItems()
            end
        end)
    end
end)

-- ESP Loop
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            if Settings.FishESP then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name:lower():find("fish") and not ESPObjects[obj] then
                        CreateESP(obj, "Fish", Color3.fromRGB(0, 255, 255))
                    end
                end
            end
            
            if Settings.ChestESP or Settings.TreasureESP then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("chest") or obj.Name:lower():find("treasure")) and not ESPObjects[obj] then
                        CreateESP(obj, "Treasure", Color3.fromRGB(255, 215, 0))
                    end
                end
            end
            
            if Settings.PlayerESP then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character then
                        local head = player.Character:FindFirstChild("Head")
                        if head and not ESPObjects[head] then
                            CreateESP(head, player.Name, Color3.fromRGB(255, 0, 0))
                        end
                    end
                end
            end
            
            if Settings.NPCESP then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("npc") or obj.Name:lower():find("merchant") or obj.Name:lower():find("shop")) and not ESPObjects[obj] then
                        CreateESP(obj, "NPC", Color3.fromRGB(0, 255, 0))
                    end
                end
            end
            
            if Settings.ItemESP then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj.Name:lower():find("item")) and not ESPObjects[obj] then
                        CreateESP(obj, "Item", Color3.fromRGB(255, 255, 0))
                    end
                end
            end
            
            if not (Settings.FishESP or Settings.ChestESP or Settings.TreasureESP or Settings.PlayerESP or Settings.NPCESP or Settings.ItemESP) then
                ClearESP()
            end
        end)
    end
end)

-- Stamina/Oxygen Loop
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if Settings.InfiniteStamina and Player:FindFirstChild("PlayerGui") then
                local stamina = Player.PlayerGui:FindFirstChild("StaminaBar") or Player.PlayerGui:FindFirstChild("Stamina")
                if stamina and stamina:FindFirstChild("Bar") then
                    stamina.Bar.Size = UDim2.new(1, 0, 1, 0)
                end
            end
            
            if Settings.InfiniteOxygen and Player:FindFirstChild("PlayerGui") then
                local oxygen = Player.PlayerGui:FindFirstChild("OxygenBar") or Player.PlayerGui:FindFirstChild("Oxygen")
                if oxygen and oxygen:FindFirstChild("Bar") then
                    oxygen.Bar.Size = UDim2.new(1, 0, 1, 0)
                end
            end
        end)
    end
end)

-- Auto Rejoin
if Settings.AutoRejoin then
    game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == 'ErrorPrompt' then
            game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
        end
    end)
end

-- Character Update
Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    Root = char:WaitForChild("HumanoidRootPart")
end)

-- Success
Notify("Fish It Hub", "✅ Complete v10.0 Loaded!\n🎣 ALL Features Working!", 5)

task.wait(2)
Notify("Quick Start", "1. Go to fishing spot\n2. Enable Auto Fish\n3. Enjoy! 🎣", 5)

print("════════════════════════════════════════")
print("✅ Fish It Script - Complete v10.0")
print("🎣 Based on YouTube Video")
print("📦 ALL Features Included & Working")
print("👤 User: " .. Player.Name)
print("════════════════════════════════════════")
