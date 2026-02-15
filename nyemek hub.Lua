--[[
    NYEMEK HUB - FISH IT! PREMIUM (ATOMIC VERSION)
    VIDEO REFERENCE: https://youtu.be/Ccxf3Wq0c4o
]]

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

local Window = Rayfield:CreateWindow({
   Name = "NYEMEK HUB | FISH IT! 2026",
   LoadingTitle = "Loading Blatant Features...",
   LoadingSubtitle = "by Synx",
   ConfigurationSaving = { Enabled = true, FolderName = "NyemekHub" }
})

-- // Variables //
getgenv().AutoFish = false
getgenv().BlatantMode = false
getgenv().AutoSell = false
getgenv().AutoEquip = false
getgenv().FreezeCharacter = false

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

-- // LOGIC: AUTO FISHING (BLATANT & LEGIT) //
spawn(function()
    while task.wait() do
        if getgenv().AutoFish then
            pcall(function()
                local Rod = Character:FindFirstChildOfClass("Tool")
                if Rod and Rod:FindFirstChild("Click") then
                    -- 1. Cast Rod
                    Rod.Click:FireServer()
                    
                    -- 2. Detection (Blatant/Legit)
                    if getgenv().BlatantMode then
                        task.wait(0.1) -- Fast speed like video
                    else
                        task.wait(1.5) -- Legit speed
                    end

                    -- 3. Reel Logic
                    local Event = Rod:FindFirstChild("events") or Rod:FindFirstChild("Events")
                    if Event then
                        local Reel = Event:FindFirstChild("reelfinished") or Event:FindFirstChild("Reel")
                        if Reel then
                            -- 100 = Perfect Catch
                            Reel:FireServer(100, true)
                        end
                    end
                end
            end)
        end
    end
end)

-- // TABS //
local FarmTab = Window:CreateTab("Farm", 4483362458)
local TPTab = Window:CreateTab("Teleport", 4483362458)
local ShopTab = Window:CreateTab("Shop/Events", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- // FARM TAB //
FarmTab:CreateSection("Blatant Setting")

FarmTab:CreateToggle({
   Name = "Auto Fishing (15x Speed)",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().AutoFish = Value
      getgenv().BlatantMode = Value
   end,
})

FarmTab:CreateToggle({
   Name = "Perfect Catch (Legit Mode)",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().AutoFish = Value
      getgenv().BlatantMode = false
   end,
})

FarmTab:CreateSection("Options")

FarmTab:CreateToggle({
   Name = "Auto Sell All Fish",
   CurrentValue = false,
   Callback = function(Value)
      getgenv().AutoSell = Value
      spawn(function()
          while getgenv().AutoSell do
              game:GetService("ReplicatedStorage").events.sellall:FireServer()
              task.wait(10)
          end
      end)
   end,
})

-- // TELEPORT TAB //
TPTab:CreateSection("NPC & Locations")

TPTab:CreateButton({
   Name = "TP to Merchant (Sell)",
   Callback = function()
       Character.HumanoidRootPart.CFrame = CFrame.new(460, 130, 230)
   end,
})

TPTab:CreateDropdown({
   Name = "Select Island",
   Options = {"Moosewood", "Roslit", "Terrapin", "Mushgrove"},
   Callback = function(Option)
      if Option == "Moosewood" then
          Character.HumanoidRootPart.CFrame = CFrame.new(380, 135, 250)
      elseif Option == "Roslit" then
          Character.HumanoidRootPart.CFrame = CFrame.new(-1500, 135, 600)
      end
   end,
})

-- // SHOP & EVENTS //
ShopTab:CreateSection("Auto Buy")

ShopTab:CreateToggle({
   Name = "Auto Buy Weather (Wine/Storm)",
   CurrentValue = false,
   Callback = function(Value)
       -- Logika otomatis beli item weather
   end,
})

ShopTab:CreateSection("Events")

ShopTab:CreateButton({
   Name = "Teleport to Megalodon Hun",
   Callback = function()
       -- Logika TP ke event yang sedang berlangsung
   end,
})

-- // MISC TAB //
MiscTab:CreateSection("Visual & Safety")

MiscTab:CreateButton({
   Name = "Hide Player Name (Streamer)",
   Callback = function()
       if Character:FindFirstChild("Head") and Character.Head:FindFirstChild("Nametag") then
           Character.Head.Nametag:Destroy()
       end
   end,
})

MiscTab:CreateToggle({
   Name = "Anti-AFK",
   CurrentValue = true,
   Callback = function(Value)
       local vu = game:GetService("VirtualUser")
       Player.Idled:Connect(function()
           if Value then
               vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
               task.wait(1)
               vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
           end
       end)
   end,
})

MiscTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      Character.Humanoid.WalkSpeed = Value
   end,
})

Rayfield:LoadConfiguration()
