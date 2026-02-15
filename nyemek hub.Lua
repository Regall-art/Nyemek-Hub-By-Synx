-- Fish It Script - WORKING AUTO FISH + CUSTOMIZABLE
-- Version: 8.0 - Fully Customizable & Working
-- Auto Fish with player settings

repeat task.wait() until game:IsLoaded()
task.wait(2)

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "🎣 Fish It Hub - Customizable",
    LoadingTitle = "Loading Customizable Script...",
    LoadingSubtitle = "by Regall-art",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "FishItHub"
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
local VIM = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

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

-- Statistics
local Stats = {
    FishCaught = 0,
    TotalFishCaught = 0,
    SessionStartTime = tick(),
}

-- Settings - CUSTOMIZABLE BY PLAYER
local Settings = {
    -- Auto Fish Settings
    AutoFish = false,
    AutoCastEnabled = true,
    AutoReelEnabled = true,
    AutoShakeEnabled = true,
    
    -- Timing Settings (CUSTOMIZABLE)
    CastDelay = 2, -- Delay after casting (1-5 seconds)
    ReelDelay = 0.1, -- Delay between reels (0.05-0.5 seconds)
    ReelAmount = 15, -- How many times to reel (5-30)
    CheckDelay = 0.5, -- How often to check if fishing (0.3-2 seconds)
    
    -- Auto Sell Settings
    AutoSell = false,
    SellAt = 25, -- Sell when inventory reaches this (10-30)
    
    -- ESP
    FishESP = false,
    ChestESP = false,
    PlayerESP = false,
    
    -- Player
    WalkSpeed = 16,
    JumpPower = 50,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
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

-- Fishing Functions - FIXED & WORKING
local function GetRod()
    -- Check equipped
    for _, item in pairs(Character:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    
    -- Check backpack
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            return item
        end
    end
    
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if rod and rod.Parent == Player.Backpack then
        Humanoid:EquipTool(rod)
        task.wait(0.5)
        return true
    end
    return rod ~= nil
end

local function Cast()
    -- Just click to cast
    task.spawn(function()
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.1)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

local function Reel()
    -- Press space to reel
    task.spawn(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
end

local function Shake()
    -- Rapid clicks for shake minigame
    for i = 1, 3 do
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(0.05)
    end
end

local function IsFishing()
    -- Check if bobber exists in workspace
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name:lower():find("bob") or obj.Name:lower():find("float") or obj.Name:lower():find("hook") then
            return true
        end
    end
    
    -- Check descendants
    for _, obj in pairs(Workspace:GetDescendants()) do
        if (obj.Name:lower():find("bob") or obj.Name:lower():find("float")) and obj:IsA("BasePart") then
            return true
        end
    end
    
    return false
end

-- Count fish in inventory
local function CountFish()
    local count = 0
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            count = count + 1
        end
    end
    return count
end

-- Check if caught fish
local lastCount = 0

local function CheckCaught()
    local currentCount = CountFish()
    
    if currentCount > lastCount then
        local caught = currentCount - lastCount
        Stats.FishCaught = Stats.FishCaught + caught
        Stats.TotalFishCaught = Stats.TotalFishCaught + caught
        
        -- Notify every 25 fish
        if Stats.FishCaught >= 25 then
            Notify("🎣 Fish Caught!", string.format("Caught %d fish!\nTotal: %d", Stats.FishCaught, Stats.TotalFishCaught), 5)
            Stats.FishCaught = 0
        end
        
        lastCount = currentCount
        return true
    end
    
    lastCount = currentCount
    return false
end

-- Auto Sell
local function SellFish()
    local foundSell = nil
    
    -- Find sell NPC
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local name = obj.Name:lower()
            if name:find("sell") or name:find("merchant") then
                foundSell = obj
                break
            end
        end
    end
    
    if foundSell then
        local oldPos = Root.CFrame
        local targetPos = foundSell:IsA("Model") and foundSell:GetPivot().Position or foundSell.Position
        
        Root.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
        task.wait(1)
        
        -- Try all sell methods
        for i = 1, 3 do
            for _, v in pairs(foundSell:GetDescendants()) do
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
        lastCount = 0
    else
        Notify("Error", "Sell NPC not found!", 3)
    end
end

-- Teleport
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

-- ESP
local function CreateESP(obj, text, color)
    if ESPObjects[obj] then return end
    
    local part = obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or obj
    if not part then return end
    
    local Billboard = Instance.new("BillboardGui")
    Billboard.Parent = part
    Billboard.AlwaysOnTop = true
    Billboard.Size = UDim2.new(0, 100, 0, 50)
    Billboard.StudsOffset = Vector3.new(0, 2, 0)
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Billboard
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Text = text
    TextLabel.TextColor3 = color
    TextLabel.TextScaled = true
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextStrokeTransparency = 0.5
    
    ESPObjects[obj] = Billboard
end

local function ClearESP()
    for _, esp in pairs(ESPObjects) do
        pcall(function() esp:Destroy() end)
    end
    ESPObjects = {}
end

-- Fly
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

-- Create Tabs
local FishingTab = Window:CreateTab("🎣 Fishing", 4483362458)
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)
local FarmTab = Window:CreateTab("💰 Farm", 4483362458)
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)
local TeleportTab = Window:CreateTab("📍 Teleport", 4483362458)

-- Fishing Tab
local MainSection = FishingTab:CreateSection("🎣 Auto Fish Control")

local AutoFishToggle = FishingTab:CreateToggle({
    Name = "Enable Auto Fish",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(Value)
        Settings.AutoFish = Value
        
        if Value then
            Notify("Auto Fish", "✅ Auto Fish Enabled!\nGo to fishing spot and wait!", 5)
        else
            Notify("Auto Fish", "Auto Fish Disabled", 2)
        end
    end,
})

local ComponentsSection = FishingTab:CreateSection("Components")

local AutoCastToggle = FishingTab:CreateToggle({
    Name = "Auto Cast",
    CurrentValue = true,
    Flag = "AutoCast",
    Callback = function(Value)
        Settings.AutoCastEnabled = Value
    end,
})

local AutoReelToggle = FishingTab:CreateToggle({
    Name = "Auto Reel",
    CurrentValue = true,
    Flag = "AutoReel",
    Callback = function(Value)
        Settings.AutoReelEnabled = Value
    end,
})

local AutoShakeToggle = FishingTab:CreateToggle({
    Name = "Auto Shake (QTE)",
    CurrentValue = true,
    Flag = "AutoShake",
    Callback = function(Value)
        Settings.AutoShakeEnabled = Value
    end,
})

local StatsSection = FishingTab:CreateSection("📊 Statistics")

FishingTab:CreateLabel("Session Fish: 0")
FishingTab:CreateLabel("Total Fish: 0")
FishingTab:CreateLabel("Fish/Hour: 0")

local ManualSection = FishingTab:CreateSection("Manual Controls")

FishingTab:CreateButton({
    Name = "🎣 Cast",
    Callback = function()
        Cast()
        Notify("Cast", "Casted! 🎣", 1)
    end,
})

FishingTab:CreateButton({
    Name = "🎣 Reel (15x)",
    Callback = function()
        for i = 1, 15 do
            Reel()
            task.wait(0.1)
        end
        Notify("Reel", "Reeled 15 times! 🎣", 2)
    end,
})

FishingTab:CreateButton({
    Name = "🎣 Equip Rod",
    Callback = function()
        if EquipRod() then
            Notify("Success", "Rod equipped! ✅", 2)
        else
            Notify("Error", "No rod found! ❌", 2)
        end
    end,
})

-- Settings Tab - PLAYER CUSTOMIZATION
local TimingSection = SettingsTab:CreateSection("⏱️ Timing Settings")

SettingsTab:CreateSlider({
    Name = "Cast Delay (seconds)",
    Range = {1, 5},
    Increment = 0.5,
    CurrentValue = 2,
    Flag = "CastDelay",
    Callback = function(Value)
        Settings.CastDelay = Value
    end,
})

SettingsTab:CreateSlider({
    Name = "Reel Delay (seconds)",
    Range = {0.05, 0.5},
    Increment = 0.05,
    CurrentValue = 0.1,
    Flag = "ReelDelay",
    Callback = function(Value)
        Settings.ReelDelay = Value
    end,
})

SettingsTab:CreateSlider({
    Name = "Reel Amount (times)",
    Range = {5, 30},
    Increment = 1,
    CurrentValue = 15,
    Flag = "ReelAmount",
    Callback = function(Value)
        Settings.ReelAmount = Value
    end,
})

SettingsTab:CreateSlider({
    Name = "Check Delay (seconds)",
    Range = {0.3, 2},
    Increment = 0.1,
    CurrentValue = 0.5,
    Flag = "CheckDelay",
    Callback = function(Value)
        Settings.CheckDelay = Value
    end,
})

local PresetsSection = SettingsTab:CreateSection("🎛️ Speed Presets")

SettingsTab:CreateButton({
    Name = "⚡ Ultra Fast (Risky)",
    Callback = function()
        Settings.CastDelay = 1
        Settings.ReelDelay = 0.05
        Settings.ReelAmount = 25
        Settings.CheckDelay = 0.3
        Notify("Preset", "Ultra Fast mode! ⚡", 2)
    end,
})

SettingsTab:CreateButton({
    Name = "🔥 Fast (Balanced)",
    Callback = function()
        Settings.CastDelay = 2
        Settings.ReelDelay = 0.1
        Settings.ReelAmount = 15
        Settings.CheckDelay = 0.5
        Notify("Preset", "Fast mode! 🔥", 2)
    end,
})

SettingsTab:CreateButton({
    Name = "🐢 Safe (Legit)",
    Callback = function()
        Settings.CastDelay = 3
        Settings.ReelDelay = 0.2
        Settings.ReelAmount = 10
        Settings.CheckDelay = 1
        Notify("Preset", "Safe mode! 🐢", 2)
    end,
})

SettingsTab:CreateParagraph({Title = "ℹ️ Tips", Content = "• Ultra Fast = Fastest but risky\n• Fast = Good balance (recommended)\n• Safe = Legit looking, slower"})

-- Farm Tab
local FarmSection = FarmTab:CreateSection("💰 Auto Farm")

local AutoSellToggle = FarmTab:CreateToggle({
    Name = "Auto Sell Fish",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(Value)
        Settings.AutoSell = Value
    end,
})

local SellThresholdSlider = FarmTab:CreateSlider({
    Name = "Sell At (fish count)",
    Range = {10, 30},
    Increment = 1,
    CurrentValue = 25,
    Flag = "SellThreshold",
    Callback = function(Value)
        Settings.SellAt = Value
    end,
})

FarmTab:CreateButton({
    Name = "💰 Sell Now",
    Callback = function()
        Notify("Selling", "Teleporting to sell...", 2)
        SellFish()
    end,
})

FarmTab:CreateLabel("Current Inventory: 0 fish")

-- ESP Tab
local ESPSection = ESPTab:CreateSection("ESP")

local FishESPToggle = ESPTab:CreateToggle({
    Name = "Fish ESP",
    CurrentValue = false,
    Flag = "FishESP",
    Callback = function(Value)
        Settings.FishESP = Value
        if not Value then ClearESP() end
    end,
})

local ChestESPToggle = ESPTab:CreateToggle({
    Name = "Chest ESP",
    CurrentValue = false,
    Flag = "ChestESP",
    Callback = function(Value)
        Settings.ChestESP = Value
        if not Value then ClearESP() end
    end,
})

local PlayerESPToggle = ESPTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        Settings.PlayerESP = Value
        if not Value then ClearESP() end
    end,
})

ESPTab:CreateButton({
    Name = "Clear All ESP",
    Callback = function()
        ClearESP()
    end,
})

-- Player Tab
local MovementSection = PlayerTab:CreateSection("Movement")

local WalkSpeedSlider = PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        Settings.WalkSpeed = Value
    end,
})

local JumpPowerSlider = PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 250},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        Settings.JumpPower = Value
    end,
})

local NoClipToggle = PlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        Settings.NoClip = Value
    end,
})

local FlySection = PlayerTab:CreateSection("Fly")

local FlyToggle = PlayerTab:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value)
        Settings.Fly = Value
        ToggleFly()
    end,
})

local FlySpeedSlider = PlayerTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        Settings.FlySpeed = Value
    end,
})

-- Teleport Tab
local TeleportSection = TeleportTab:CreateSection("Quick TP")

TeleportTab:CreateButton({
    Name = "🏪 TP to Sell",
    Callback = function()
        if FindAndTeleport({"sell", "merchant"}) then
            Notify("TP", "Teleported! ✅", 2)
        else
            Notify("Error", "Not found! ❌", 2)
        end
    end,
})

TeleportTab:CreateButton({
    Name = "🪱 TP to Bait",
    Callback = function()
        if FindAndTeleport({"bait", "shop"}) then
            Notify("TP", "Teleported! ✅", 2)
        else
            Notify("Error", "Not found! ❌", 2)
        end
    end,
})

TeleportTab:CreateButton({
    Name = "🎣 TP to Spot",
    Callback = function()
        if FindAndTeleport({"fishing", "spot", "water"}) then
            Notify("TP", "Teleported! ✅", 2)
        else
            Notify("Error", "Not found! ❌", 2)
        end
    end,
})

local LocationSection = TeleportTab:CreateSection("Locations")

local locations = {
    {name = "Spawn", pos = CFrame.new(0, 10, 0)},
    {name = "Beach", pos = CFrame.new(100, 10, 0)},
    {name = "Pier", pos = CFrame.new(200, 15, 50)},
    {name = "Lake", pos = CFrame.new(-150, 10, 200)},
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

-- MAIN AUTO FISH LOOP - WORKING
task.spawn(function()
    print("🎣 Starting Auto Fish Loop...")
    
    while task.wait(Settings.CheckDelay) do
        pcall(function()
            -- Update character
            if not Character or not Character.Parent then
                Character = Player.Character
                if Character then
                    Humanoid = Character:WaitForChild("Humanoid")
                    Root = Character:WaitForChild("HumanoidRootPart")
                end
            end
            
            if Settings.AutoFish and Character then
                -- Equip rod if needed
                local rod = GetRod()
                if not rod or rod.Parent ~= Character then
                    EquipRod()
                    task.wait(0.5)
                end
                
                local fishing = IsFishing()
                
                -- Cast if not fishing
                if not fishing and Settings.AutoCastEnabled then
                    Cast()
                    task.wait(Settings.CastDelay)
                end
                
                -- Reel if fishing
                if fishing then
                    if Settings.AutoShakeEnabled then
                        Shake()
                        task.wait(0.3)
                    end
                    
                    if Settings.AutoReelEnabled then
                        for i = 1, Settings.ReelAmount do
                            Reel()
                            task.wait(Settings.ReelDelay)
                        end
                    end
                    
                    task.wait(0.5)
                    CheckCaught()
                end
            end
            
            -- Player mods
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

-- Auto Sell Loop
task.spawn(function()
    while task.wait(10) do
        pcall(function()
            if Settings.AutoSell then
                local count = CountFish()
                if count >= Settings.SellAt then
                    Notify("Auto Sell", string.format("Selling %d fish...", count), 3)
                    SellFish()
                end
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
            
            if Settings.ChestESP then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("chest") or obj.Name:lower():find("treasure")) and not ESPObjects[obj] then
                        CreateESP(obj, "Chest", Color3.fromRGB(255, 215, 0))
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
            
            if not (Settings.FishESP or Settings.ChestESP or Settings.PlayerESP) then
                ClearESP()
            end
        end)
    end
end)

-- Character respawn
Player.CharacterAdded:Connect(function(char)
    task.wait(1)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    Root = char:WaitForChild("HumanoidRootPart")
end)

-- Success
Notify("Fish It Script", "✅ Loaded!\n⚙️ Fully Customizable\n🎣 Auto Fish Ready!", 5)

print("════════════════════════════════════════")
print("✅ Fish It Script v8.0")
print("⚙️ Fully Customizable")
print("🎣 Auto Fish: WORKING")
print("👤 User: " .. Player.Name)
print("════════════════════════════════════════")
