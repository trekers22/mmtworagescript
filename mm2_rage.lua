--[[
    MM2 RAGE HUB – Full Feature Script
    Features: Auto Shoot, ESP (Murderer/Sheriff/Gun), Kill All, Silent Aim, Teleports, Speed, Fly, Noclip, and more.
    Load with: loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/REPO/main/mm2_rage.lua"))()
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== VARIABLES =====
local murderer = nil
local sheriff = nil
local gunDrop = nil
local isMurderer = false
local isSheriff = false

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2RageHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") or game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 480)
frame.Position = UDim2.new(0.7, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.fromRGB(255, 50, 50)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🔥 MM2 RAGE HUB 🔥"
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- ===== TOGGLES =====
local toggles = {}
local toggleNames = {
    {"ESP Murderer", false},
    {"ESP Sheriff", false},
    {"ESP Innocent", false},
    {"ESP Gun Drop", false},
    {"Auto Shoot Murderer", false},
    {"Silent Aim", false},
    {"Kill All (as Murderer)", false},
    {"Auto Farm Coins", false},
    {"Noclip", false},
    {"Fly", false},
    {"Infinite Jump", false},
    {"God Mode", false},
    {"SpinBot", false},
    {"Auto Collect Gun", false},
}

local yPos = 35
for _, toggleData in ipairs(toggleNames) do
    local name = toggleData[1]
    local default = toggleData[2]
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 25)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
    btn.Text = name .. (default and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = frame
    
    toggles[name] = default
    btn.MouseButton1Click:Connect(function()
        toggles[name] = not toggles[name]
        btn.BackgroundColor3 = toggles[name] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
        btn.Text = name .. (toggles[name] and " [ON]" or " [OFF]")
    end)
    
    yPos = yPos + 28
end

-- Teleport buttons
local teleports = {
    {"TP to Murderer", "murderer"},
    {"TP to Sheriff", "sheriff"},
    {"TP to Gun", "gun"},
    {"TP to Lobby", "lobby"},
    {"TP to Map", "map"},
}

for _, tpData in ipairs(teleports) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.43, 0, 0, 25)
    btn.Position = UDim2.new(0.05 + (tpData[2] == "lobby" and 0.52 or 0), 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 80)
    btn.Text = tpData[1]
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        local target = tpData[2]
        if target == "murderer" and murderer then
            LocalPlayer.Character.HumanoidRootPart.CFrame = murderer.Character.HumanoidRootPart.CFrame
        elseif target == "sheriff" and sheriff then
            LocalPlayer.Character.HumanoidRootPart.CFrame = sheriff.Character.HumanoidRootPart.CFrame
        elseif target == "gun" and gunDrop then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(gunDrop.Position)
        elseif target == "lobby" then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
        elseif target == "map" then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        end
    end)
    
    if tpData[2] == "lobby" then
        yPos = yPos + 28
    else
        yPos = yPos + 28
    end
end

-- ===== ROLE DETECTION =====
local function UpdateRoles()
    isMurderer = false
    isSheriff = false
    murderer = nil
    sheriff = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char then
                -- Check if player has knife (murderer) or gun (sheriff)
                if char:FindFirstChild("Knife") or (char:FindFirstChild("Backpack") and char.Backpack:FindFirstChild("Knife")) then
                    murderer = player
                    isMurderer = true if player == LocalPlayer else false
                end
                if char:FindFirstChild("Gun") or (char:FindFirstChild("Backpack") and char.Backpack:FindFirstChild("Gun")) then
                    sheriff = player
                    isSheriff = true if player == LocalPlayer else false
                end
            end
        end
    end
    
    -- Check local player
    local localChar = LocalPlayer.Character
    if localChar then
        if localChar:FindFirstChild("Knife") or (localChar:FindFirstChild("Backpack") and localChar.Backpack:FindFirstChild("Knife")) then
            isMurderer = true
        end
        if localChar:FindFirstChild("Gun") or (localChar:FindFirstChild("Backpack") and localChar.Backpack:FindFirstChild("Gun")) then
            isSheriff = true
        end
    end
end

-- ===== ESP =====
local espObjects = {}

local function CreateESP(player, color, text)
    if not player.Character then return end
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.Parent = root
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text .. " " .. player.Name
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard
    
    -- Box ESP (highlight)
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = char
    
    table.insert(espObjects, {billboard, highlight, player})
end

local function ClearESP()
    for _, obj in ipairs(espObjects) do
        pcall(function()
            obj[1]:Destroy()
            obj[2]:Destroy()
        end)
    end
    espObjects = {}
end

-- ===== AUTO SHOOT =====
local function AutoShoot()
    if not toggles["Auto Shoot Murderer"] then return end
    if not murderer or not murderer.Character then return end
    if not isSheriff then return end
    
    local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    -- Get the gun
    local gun = LocalPlayer.Character:FindFirstChild("Gun")
    if not gun then return end
    
    -- Aim at target
    local direction = (targetRoot.Position - Camera.CFrame.Position).Unit
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
    
    -- Shoot
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        tool:Activate()
        task.wait(0.1)
        tool:Deactivate()
    end
end

-- ===== SILENT AIM =====
local function SilentAim()
    if not toggles["Silent Aim"] then return end
    if not murderer or not murderer.Character then return end
    if not isSheriff then return end
    
    local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
end

-- ===== KILL ALL (as Murderer) =====
local function KillAll()
    if not toggles["Kill All (as Murderer)"] then return end
    if not isMurderer then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                humanoid.Health = 0
            end
        end
    end
end

-- ===== NOCLIP =====
local function Noclip()
    if not toggles["Noclip"] then return end
    if not LocalPlayer.Character then return end
    
    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- ===== FLY =====
local flyEnabled = false
local flySpeed = 50

local function Fly()
    if not toggles["Fly"] then
        flyEnabled = false
        return
    end
    
    if not flyEnabled then
        flyEnabled = true
    end
    
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local moveVector = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector
    elseif UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector
    elseif UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0)
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0)
    end
    
    root.Velocity = moveVector * flySpeed
end

-- ===== INFINITE JUMP =====
local function InfiniteJump()
    if not toggles["Infinite Jump"] then return end
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- ===== GOD MODE =====
local function GodMode()
    if not toggles["God Mode"] then return end
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
end

-- ===== SPINBOT =====
local spinAngle = 0

local function SpinBot()
    if not toggles["SpinBot"] then return end
    if not LocalPlayer.Character then return end
    
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        spinAngle = spinAngle + 0.1
        root.CFrame = root.CFrame * CFrame.Angles(0, 0.1, 0)
    end
end

-- ===== AUTO COLLECT GUN =====
local function AutoCollectGun()
    if not toggles["Auto Collect Gun"] then return end
    if not gunDrop then return end
    
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(gunDrop.Position + Vector3.new(0, 2, 0))
end

-- ===== COIN FARM =====
local function CoinFarm()
    if not toggles["Auto Farm Coins"] then return end
    -- Use the existing coin farmer logic here (from previous scripts)
    -- Simplified: find and collect coins
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Coin_Server" then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))
            task.wait(0.05)
        end
    end
end

-- ===== MAIN LOOP =====
local function MainLoop()
    while wait(0.1) do
        -- Update roles
        UpdateRoles()
        
        -- ESP
        ClearESP()
        if toggles["ESP Murderer"] and murderer then
            CreateESP(murderer, Color3.fromRGB(255, 0, 0), "🔪 MURDERER")
        end
        if toggles["ESP Sheriff"] and sheriff then
            CreateESP(sheriff, Color3.fromRGB(0, 255, 0), "🔫 SHERIFF")
        end
        if toggles["ESP Innocent"] then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player ~= murderer and player ~= sheriff then
                    CreateESP(player, Color3.fromRGB(255, 255, 255), "👤 INNOCENT")
                end
            end
        end
        
        -- Auto Shoot
        AutoShoot()
        
        -- Silent Aim
        SilentAim()
        
        -- Kill All
        KillAll()
        
        -- Noclip
        Noclip()
        
        -- Fly
        Fly()
        
        -- Infinite Jump
        InfiniteJump()
        
        -- God Mode
        GodMode()
        
        -- SpinBot
        SpinBot()
        
        -- Auto Collect Gun
        AutoCollectGun()
        
        -- Coin Farm
        CoinFarm()
    end
end

-- ===== KEYBINDS =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        toggles["Auto Shoot Murderer"] = not toggles["Auto Shoot Murderer"]
    end
    if input.KeyCode == Enum.KeyCode.X then
        toggles["Kill All (as Murderer)"] = not toggles["Kill All (as Murderer)"]
    end
    if input.KeyCode == Enum.KeyCode.V then
        toggles["Fly"] = not toggles["Fly"]
    end
end)

-- ===== START =====
coroutine.wrap(MainLoop)()

-- ===== CLEANUP =====
screenGui.AncestryChanged:Connect(function()
    if not screenGui.Parent then
        ClearESP()
    end
end)
