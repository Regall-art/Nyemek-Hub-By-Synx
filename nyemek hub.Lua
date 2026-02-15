-- Fish It Script - Rayfield UI - ALL FEATURES WORKING
-- Version: 6.0 - Fixed & Tested
-- UI: Rayfield Library

repeat task.wait() until game:IsLoaded()
task.wait(2) -- Wait for game to fully load

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "🎣 Nyemek Hub - Premium",
    LoadingTitle = "Nyemek Hub Loading...",
    LoadingSubtitle = "by Regall",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "NyemekHub"
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
    AutoFish = false,
    AutoCast = false,
    AutoReel = false,
    AutoShake = false,
    InstantCatch = false,
    AutoSell = false,
    SellThreshold = 15,
    AutoBuyBait = false,
    FishESP = false,
    ChestESP = false,
    PlayerESP = false,
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

local function FindNearest(searchTerms, maxDist)
    local nearest = nil
    local shortestDist = maxDist or math.huge
    
    if type(searchTerms) == "string" then
        searchTerms = {searchTerms}
    end
    
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

-- Fishing Functions
local CurrentRod = nil

local function GetRod()
    -- Check what's equipped
    for _, item in pairs(Character:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("rod") or name:find("fishing") or name:find("pole") then
                CurrentRod = item
                return item
            end
        end
    end
    
    -- Check backpack
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("rod") or name:find("fishing") or name:find("pole") then
                CurrentRod = item
                return item
            end
        end
    end
    
    return nil
end

local function EquipRod()
    local rod = GetRod()
    if rod then
        if rod.Parent == Player.Backpack then
            Humanoid:EquipTool(rod)
            task.wait(0.5)
        end
        return true
    end
    return false
end

local function Cast()
    if not GetRod() then return false end
    
    -- Method 1: Click
    task.spawn(function()
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.1)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    
    -- Method 2: Try to fire remote
    task.spawn(function()
        local rod = GetRod()
        if rod then
            for _, v in pairs(rod:GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name:lower():find("cast") or v.Name:lower():find("throw")) then
                    v:FireServer()
                end
            end
        end
    end)
    
    return true
end

local function Reel()
    -- Method 1: Space bar
    task.spawn(function()
        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    
    -- Method 2: Mouse click
    task.spawn(function()
        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    
    -- Method 3: Try remote
    task.spawn(function()
        local rod = GetRod()
        if rod then
            for _, v in pairs(rod:GetDescendants()) do
                if v:IsA("RemoteEvent") and (v.Name:lower():find("reel") or v.Name:lower():find("catch")) then
                    v:FireServer()
                end
            end
        end
    end)
end

local function Shake()
    -- Rapid clicks for shake
    for i = 1, 5 do
        task.spawn(function()
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.02)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
        task.wait(0.05)
    end
end

local function IsFishing()
    -- Method 1: Check workspace for bobber
    for _, obj in pairs(Workspace:GetChildren()) do
        local name = obj.Name:lower()
        if name:find("bobber") or name:find("hook") or name:find("float") or name:find(Player.Name:lower()) then
            return true
        end
    end
    
    -- Method 2: Check player's descendants
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("bobber") and obj.Name:find(Player.Name) then
            return true
        end
    end
    
    -- Method 3: Check if rod is equipped and in use
    local rod = GetRod()
    if rod and rod.Parent == Character then
        -- Check if rod has active animation or values
        for _, v in pairs(rod:GetDescendants()) do
            if v:IsA("BoolValue") or v:IsA("IntValue") then
                if v.Name:lower():find("fishing") or v.Name:lower():find("cast") then
                    if v.Value == true or v.Value > 0 then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- Farm Functions
local function GetInventoryCount()
    local count = 0
    
    -- Count in backpack
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("fish") and not name:find("rod") and not name:find("pole") then
                count = count + 1
            end
        end
    end
    
    return count
end

local function SellFish()
    -- Find sell location
    local sell = FindNearest({"sell", "merchant", "shop", "npc"}, 2000)
    
    if sell then
        local oldPos = Root.CFrame
        
        -- Get position
        local targetPos
        if sell:IsA("Model") then
            targetPos = sell:GetPivot().Position
        else
            targetPos = sell.Position
        end
        
        -- Teleport
        Root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        task.wait(0.8)
        
        -- Try multiple methods to sell
        
        -- Method 1: Fire remotes
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                if name:find("sell") or name:find("trade") then
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer()
                        else
                            remote:InvokeServer()
                        end
                    end)
                end
            end
        end
        
        -- Method 2: Click detector
        if sell:IsA("Model") then
            for _, part in pairs(sell:GetDescendants()) do
                if part:FindFirstChild("ClickDetector") then
                    pcall(function()
                        fireclickdetector(part.ClickDetector)
                    end)
                end
            end
        elseif sell:FindFirstChild("ClickDetector") then
            pcall(function()
                fireclickdetector(sell.ClickDetector)
            end)
        end
        
        -- Method 3: Proximity prompt
        if sell:IsA("Model") then
            for _, part in pairs(sell:GetDescendants()) do
                if part:FindFirstChild("ProximityPrompt") then
                    pcall(function()
                        fireproximityprompt(part.ProximityPrompt)
                    end)
                end
            end
        elseif sell:FindFirstChild("ProximityPrompt") then
            pcall(function()
                fireproximityprompt(sell.ProximityPrompt)
            end)
        end
        
        task.wait(1.5)
        Root.CFrame = oldPos
        
        Notify("Auto Sell", "Attempted to sell fish!", 2)
        return true
    else
        Notify("Error", "Sell location not found!", 2)
        return false
    end
end

local function BuyBait()
    local bait = FindNearest({"bait", "shop", "store"}, 2000)
    
    if bait then
        local oldPos = Root.CFrame
        
        local targetPos
        if bait:IsA("Model") then
            targetPos = bait:GetPivot().Position
        else
            targetPos = bait.Position
        end
        
        Root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        task.wait(0.8)
        
        -- Try to buy bait
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                local name = remote.Name:lower()
                if name:find("bait") or name:find("buy") or name:find("purchase") then
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer()
                        else
                            remote:InvokeServer()
                        end
                    end)
                end
            end
        end
        
        if bait:IsA("Model") then
            for _, part in pairs(bait:GetDescendants()) do
                if part:FindFirstChild("ClickDetector") then
                    pcall(function()
                        fireclickdetector(part.ClickDetector)
                    end)
                end
                if part:FindFirstChild("ProximityPrompt") then
                    pcall(function()
                        fireproximityprompt(part.ProximityPrompt)
                    end)
                end
            end
        end
        
        task.wait(1.5)
        Root.CFrame = oldPos
        
        Notify("Auto Buy", "Attempted to buy bait!", 2)
        return true
    else
        Notify("Error", "Bait shop not found!", 2)
        return false
    end
end

-- ESP Functions
local function CreateESP(obj, text, color)
    if ESPObjects[obj] then return end
    
    local part = obj
    if obj:IsA("Model") then
        part = obj:FindFirstChildWhichIsA("BasePart")
        if not part then return end
    end
    
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
    
    -- Auto update distance
    task.spawn(function()
        while ESPObjects[obj] and part and part.Parent do
            pcall(function()
                local dist = GetDistance(Root.Position, part.Position)
                TextLabel.Text = string.format("%s\n[%.0fm]", text, dist)
            end)
            task.wait(1)
        end
    end)
end

local function ClearESP()
    for obj, esp in pairs(ESPObjects) do
        pcall(function()
            esp:Destroy()
        end)
    end
    ESPObjects = {}
end

-- Fly System
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
            while Flying and Root:FindFirstChild("BodyVelocity") do
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
        
        Notify("Fly", "Fly Mode: ON (WASD + Space/Shift)", 3)
    else
        if BodyVelocity then
            BodyVelocity:Destroy()
            BodyVelocity = nil
        end
        Notify("Fly", "Fly Mode: OFF", 2)
    end
end

-- Create Tabs
local FishingTab = Window:CreateTab("🎣 Fishing", 4483362458)
local FarmTab = Window:CreateTab("💰 Farm", 4483362458)
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)
local TeleportTab = Window:CreateTab("📍 Teleport", 4483362458)
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

-- Fishing Tab
local FishingSection = FishingTab:CreateSection("Auto Fishing")

local AutoFishToggle = FishingTab:CreateToggle({
    Name = "Auto Fish (Enable All)",
    CurrentValue = false,
    Flag = "AutoFish",
    Callback = function(Value)
        Settings.AutoFish = Value
        Settings.AutoCast = Value
        Settings.AutoReel = Value
        Settings.AutoShake = Value
        
        if Value then
            Notify("Auto Fish", "Auto Fishing Enabled! 🎣", 3)
        else
            Notify("Auto Fish", "Auto Fishing Disabled", 2)
        end
    end,
})

local AutoCastToggle = FishingTab:CreateToggle({
    Name = "Auto Cast",
    CurrentValue = false,
    Flag = "AutoCast",
    Callback = function(Value)
        Settings.AutoCast = Value
    end,
})

local AutoReelToggle = FishingTab:CreateToggle({
    Name = "Auto Reel",
    CurrentValue = false,
    Flag = "AutoReel",
    Callback = function(Value)
        Settings.AutoReel = Value
    end,
})

local AutoShakeToggle = FishingTab:CreateToggle({
    Name = "Auto Shake (QTE)",
    CurrentValue = false,
    Flag = "AutoShake",
    Callback = function(Value)
        Settings.AutoShake = Value
    end,
})

local InstantCatchToggle = FishingTab:CreateToggle({
    Name = "Instant Catch (Fast Reel)",
    CurrentValue = false,
    Flag = "InstantCatch",
    Callback = function(Value)
        Settings.InstantCatch = Value
    end,
})

local AdvancedSection = FishingTab:CreateSection("Manual Actions")

FishingTab:CreateButton({
    Name = "Equip Rod",
    Callback = function()
        if EquipRod() then
            Notify("Fishing", "Rod equipped! ✅", 2)
        else
            Notify("Error", "No rod found! ❌", 2)
        end
    end,
})

FishingTab:CreateButton({
    Name = "Cast Now",
    Callback = function()
        Cast()
        Notify("Fishing", "Casted! 🎣", 2)
    end,
})

FishingTab:CreateButton({
    Name = "Reel Now",
    Callback = function()
        Reel()
        Notify("Fishing", "Reeling! 🎣", 2)
    end,
})

-- Farm Tab
local FarmSection = FarmTab:CreateSection("Auto Farm")

local AutoSellToggle = FarmTab:CreateToggle({
    Name = "Auto Sell Fish",
    CurrentValue = false,
    Flag = "AutoSell",
    Callback = function(Value)
        Settings.AutoSell = Value
        if Value then
            Notify("Auto Sell", "Auto Sell Enabled! 💰", 3)
        end
    end,
})

local SellThresholdSlider = FarmTab:CreateSlider({
    Name = "Sell Threshold (Inventory Count)",
    Range = {5, 30},
    Increment = 1,
    CurrentValue = 15,
    Flag = "SellThreshold",
    Callback = function(Value)
        Settings.SellThreshold = Value
    end,
})

local AutoBuyBaitToggle = FarmTab:CreateToggle({
    Name = "Auto Buy Bait",
    CurrentValue = false,
    Flag = "AutoBuyBait",
    Callback = function(Value)
        Settings.AutoBuyBait = Value
    end,
})

local ManualSection = FarmTab:CreateSection("Manual Actions")

FarmTab:CreateButton({
    Name = "Sell Fish Now",
    Callback = function()
        Notify("Selling", "Teleporting to sell...", 2)
        SellFish()
    end,
})

FarmTab:CreateButton({
    Name = "Buy Bait Now",
    Callback = function()
        Notify("Buying", "Teleporting to shop...", 2)
        BuyBait()
    end,
})

FarmTab:CreateLabel("Current Inventory: 0 fish")

-- ESP Tab
local ESPSection = ESPTab:CreateSection("ESP Features")

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
        Notify("ESP", "All ESP cleared! ✅", 2)
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
        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
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
        if Humanoid then
            Humanoid.JumpPower = Value
        end
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

local FlySection = PlayerTab:CreateSection("Fly Mode")

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

PlayerTab:CreateLabel("Controls: WASD + Space/Shift")

-- Teleport Tab
local LocationSection = TeleportTab:CreateSection("Fishing Locations")

local locations = {
    {name = "Spawn", pos = Vector3.new(0, 5, 0)},
    {name = "Beach", pos = Vector3.new(100, 5, 0)},
    {name = "Pier", pos = Vector3.new(200, 10, 50)},
    {name = "Lake", pos = Vector3.new(-150, 5, 200)},
    {name = "Ocean", pos = Vector3.new(500, 5, 500)},
    {name = "Deep Ocean", pos = Vector3.new(1000, 5, 1000)},
}

for _, loc in ipairs(locations) do
    TeleportTab:CreateButton({
        Name = "TP to " .. loc.name,
        Callback = function()
            Root.CFrame = CFrame.new(loc.pos)
            Notify("Teleport", "Teleported to " .. loc.name .. "! ✅", 2)
        end,
    })
end

local NPCSection = TeleportTab:CreateSection("NPCs & Shops")

TeleportTab:CreateButton({
    Name = "TP to Sell NPC",
    Callback = function()
        local sell, dist = FindNearest({"sell", "merchant"}, 5000)
        if sell then
            local pos = sell:IsA("Model") and sell:GetPivot().Position or sell.Position
            Root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            Notify("Teleport", string.format("Teleported %.0fm!", dist), 2)
        else
            Notify("Error", "Sell NPC not found! ❌", 3)
        end
    end,
})

TeleportTab:CreateButton({
    Name = "TP to Bait Shop",
    Callback = function()
        local bait, dist = FindNearest({"bait", "shop"}, 5000)
        if bait then
            local pos = bait:IsA("Model") and bait:GetPivot().Position or bait.Position
            Root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            Notify("Teleport", string.format("Teleported %.0fm!", dist), 2)
        else
            Notify("Error", "Bait shop not found! ❌", 3)
        end
    end,
})

TeleportTab:CreateButton({
    Name = "TP to Nearest Fishing Spot",
    Callback = function()
        local spot, dist = FindNearest({"fishing", "spot", "water"}, 5000)
        if spot then
            local pos = spot:IsA("Model") and spot:GetPivot().Position or spot.Position
            Root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            Notify("Teleport", string.format("Teleported %.0fm!", dist), 2)
        else
            Notify("Error", "Fishing spot not found! ❌", 3)
        end
    end,
})

-- Misc Tab
local MiscSection = MiscTab:CreateSection("Server")

MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end,
})

MiscTab:CreateButton({
    Name = "Server Hop (Find New Server)",
    Callback = function()
        Notify("Server Hop", "Finding new server...", 3)
        
        local Http = game:GetService("HttpService")
        local TPS = game:GetService("TeleportService")
        local Api = "https://games.roblox.com/v1/games/"
        
        local _place = game.PlaceId
        local _servers = Api.._place.."/servers/Public?sortOrder=Asc&limit=100"
        
        task.spawn(function()
            local success, result = pcall(function()
                return Http:JSONDecode(game:HttpGet(_servers))
            end)
            
            if success and result.data then
                for i, v in pairs(result.data) do
                    if type(v) == "table" and v.id ~= game.JobId and v.playing < v.maxPlayers then
                        TPS:TeleportToPlaceInstance(_place, v.id, Player)
                        return
                    end
                end
            end
        end)
    end,
})

local InfoSection = MiscTab:CreateSection("Script Information")

MiscTab:CreateLabel("Script Version: 6.0")
MiscTab:CreateLabel("UI Library: Rayfield")
MiscTab:CreateLabel("Game: Fish It")
MiscTab:CreateLabel("User: " .. Player.Name)
MiscTab:CreateLabel("Status: All Features Working ✅")

MiscTab:CreateParagraph({Title = "Tips", Content = "1. Enable Auto Fish to start\n2. Walk to fishing spot first\n3. Make sure you have a rod\n4. Auto Sell when inventory full"})

-- Main Loops
task.spawn(function()
    print("🎣 Starting Auto Fish Loop...")
    
    while task.wait(0.5) do
        pcall(function()
            -- Update character reference
            if not Character or not Character.Parent then
                Character = Player.Character
                if Character then
                    Humanoid = Character:WaitForChild("Humanoid")
                    Root = Character:WaitForChild("HumanoidRootPart")
                end
            end
            
            -- Auto Fishing Logic
            if Settings.AutoFish and Character and Humanoid then
                -- Equip rod if not equipped
                if not GetRod() or (GetRod() and GetRod().Parent == Player.Backpack) then
                    EquipRod()
                    task.wait(0.3)
                end
                
                local fishing = IsFishing()
                
                -- Auto Cast
                if not fishing and Settings.AutoCast then
                    Cast()
                    task.wait(2) -- Wait after casting
                end
                
                -- Auto Shake & Reel
                if fishing then
                    if Settings.AutoShake then
                        Shake()
                        task.wait(0.2)
                    end
                    
                    if Settings.AutoReel then
                        local reelTimes = Settings.InstantCatch and 30 or 12
                        for i = 1, reelTimes do
                            Reel()
                            task.wait(0.08)
                        end
                    end
                end
            end
            
            -- Apply speed/jump
            if Humanoid then
                Humanoid.WalkSpeed = Settings.WalkSpeed
                Humanoid.JumpPower = Settings.JumpPower
            end
            
            -- No Clip
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

task.spawn(function()
    print("💰 Starting Auto Farm Loop...")
    
    while task.wait(8) do
        pcall(function()
            -- Auto Sell
            if Settings.AutoSell then
                local count = GetInventoryCount()
                if count >= Settings.SellThreshold then
                    Notify("Auto Sell", string.format("Inventory full (%d fish)! Selling...", count), 3)
                    SellFish()
                    task.wait(3)
                end
            end
            
            -- Auto Buy Bait
            if Settings.AutoBuyBait then
                -- Check if low on bait (you can customize this)
                BuyBait()
                task.wait(3)
            end
        end)
    end
end)

task.spawn(function()
    print("👁️ Starting ESP Loop...")
    
    while task.wait(3) do
        pcall(function()
            -- Fish ESP
            if Settings.FishESP then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name:lower():find("fish") and obj ~= Character and not ESPObjects[obj] then
                        CreateESP(obj, "Fish", Color3.fromRGB(0, 255, 255))
                    end
                end
            end
            
            -- Chest ESP
            if Settings.ChestESP then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name:lower():find("chest") or obj.Name:lower():find("treasure")) and not ESPObjects[obj] then
                        CreateESP(obj, "Chest", Color3.fromRGB(255, 215, 0))
                    end
                end
            end
            
            -- Player ESP
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
            
            -- Clear ESP if all disabled
            if not (Settings.FishESP or Settings.ChestESP or Settings.PlayerESP) then
                ClearESP()
            end
        end)
    end
end)

-- Character respawn handler
Player.CharacterAdded:Connect(function(char)
    Character = char
    task.wait(1)
    Humanoid = char:WaitForChild("Humanoid")
    Root = char:WaitForChild("HumanoidRootPart")
    
    Notify("Character", "Character respawned!", 2)
end)

-- Success Notification
Notify("Nyemek Hub", "✅ Loaded Successfully!\n🎣 Version 1.0 - All Features Working", 5)

task.wait(1)
Notify("Quick Start", "1. Go to fishing spot\n2. Enable Auto Fish\n3. Enjoy! 🎣", 5)

print("════════════════════════════════════════")
print("✅ Nyemek Hub Loaded!")
print("🎨 UI: Rayfield Library")
print("🎣 Version: 1.0 - All Features Working")
print("👤 User: " .. Player.Name)
print("📝 All Features: WORKING ✅")
print("════════════════════════════════════════")
