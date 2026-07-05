--[[
    MM2 RAGE HUB – Mobile Optimized
    Features: ESP, Auto Shoot, Silent Aim, Kill All, Teleports, Fly, Noclip, God Mode, SpinBot, Auto Farm, Auto Collect Gun
    Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/trekers22/mmtworagescript/main/mm2_rage.lua"))()
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
local espObjects = {}
local flyEnabled = false
local spinAngle = 0

-- ===== MOBILE GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2RageHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") or game:GetService("CoreGui")

-- Main frame – bigger for touch
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 520)  -- wider
frame.Position = UDim2.new(0.5, -175, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 3
frame.BorderColor3 = Color3.fromRGB(255, 80, 80)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🔥 RAGE HUB MOBILE 🔥"
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Scrollable container (simulate scrolling with a scrolling frame)
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -40)
scrollFrame.Position = UDim2.new(0, 0, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 700)  -- adjust as needed
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = frame

local yPos = 0
local function AddButton(text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = color or Color3.fromRGB(60, 60, 90)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = scrollFrame
    btn.MouseButton1Click:Connect(callback)
    yPos = yPos + 45
    return btn
end

local function AddToggle(text, initial, callback)
    local state = initial
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
    btn.Text = text .. (state and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = scrollFrame
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        callback(state)
    end)
    yPos = yPos + 45
    return btn
end

-- ===== TOGGLES =====
local toggles = {
    ESPMurderer = false,
    ESPSheriff = false,
    ESPInnocent = false,
    ESPGun = false,
    AutoShoot = false,
    SilentAim = false,
    KillAll = false,
    AutoFarm = false,
    Noclip = false,
    Fly = false,
    InfiniteJump = false,
    GodMode = false,
    SpinBot = false,
    AutoCollectGun = false,
}

-- Add toggles
AddToggle("ESP Murderer", false, function(v) toggles.ESPMurderer = v end)
AddToggle("ESP Sheriff", false, function(v) toggles.ESPSheriff = v end)
AddToggle("ESP Innocent", false, function(v) toggles.ESPInnocent = v end)
AddToggle("ESP Gun Drop", false, function(v) toggles.ESPGun = v end)
AddToggle("Auto Shoot Murderer", false, function(v) toggles.AutoShoot = v end)
AddToggle("Silent Aim", false, function(v) toggles.SilentAim = v end)
AddToggle("Kill All (as Murderer)", false, function(v) toggles.KillAll = v end)
AddToggle("Auto Farm Coins", false, function(v) toggles.AutoFarm = v end)
AddToggle("Noclip", false, function(v) toggles.Noclip = v end)
AddToggle("Fly", false, function(v) toggles.Fly = v end)
AddToggle("Infinite Jump", false, function(v) toggles.InfiniteJump = v end)
AddToggle("God Mode", false, function(v) toggles.GodMode = v end)
AddToggle("SpinBot", false, function(v) toggles.SpinBot = v end)
AddToggle("Auto Collect Gun", false, function(v) toggles.AutoCollectGun = v end)

-- Teleport buttons
AddButton("🚀 TP to Murderer", function()
    if murderer and murderer.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = murderer.Character.HumanoidRootPart.CFrame
    end
end, Color3.fromRGB(200, 50, 50))

AddButton("🚀 TP to Sheriff", function()
    if sheriff and sheriff.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = sheriff.Character.HumanoidRootPart.CFrame
    end
end, Color3.fromRGB(50, 200, 50))

AddButton("🚀 TP to Gun", function()
    if gunDrop then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(gunDrop.Position)
    end
end, Color3.fromRGB(200, 200, 50))

AddButton("🚀 TP to Lobby", function()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
end, Color3.fromRGB(100, 100, 200))

AddButton("🚀 TP to Map", function()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
end, Color3.fromRGB(100, 200, 200))

-- Update canvas size
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)

-- ===== ROLE DETECTION =====
local function UpdateRoles()
    isMurderer = false
    isSheriff = false
    murderer = nil
    sheriff = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            if char:FindFirstChild("Knife") or (char:FindFirstChild("Backpack") and char.Backpack:FindFirstChild("Knife")) then
                murderer = player
                if player == LocalPlayer then isMurderer = true end
            end
            if char:FindFirstChild("Gun") or (char:FindFirstChild("Backpack") and char.Backpack:FindFirstChild("Gun")) then
                sheriff = player
                if player == LocalPlayer then isSheriff = true end
            end
        end
    end
    -- Check local player again
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
local function CreateESP(player, color, text)
    if not player.Character then return end
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 250, 0, 60)
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

-- ===== GUN DROP DETECTION =====
local function FindGunDrop()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:find("Gun") or obj.Name:find("Drop")) then
            if obj.Parent and obj.Parent:IsA("Model") and obj.Parent.Name:find("Gun") then
                gunDrop = obj
                return
            end
        end
    end
    gunDrop = nil
end

-- ===== AUTO SHOOT =====
local function AutoShoot()
    if not toggles.AutoShoot then return end
    if not murderer or not murderer.Character then return end
    if not isSheriff then return end
    
    local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local gun = LocalPlayer.Character:FindFirstChild("Gun")
    if not gun then return end
    
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
    
    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Handle") then
        tool:Activate()
        task.wait(0.1)
        tool:Deactivate()
    end
end

-- ===== SILENT AIM =====
local function SilentAim()
    if not toggles.SilentAim then return end
    if not murderer or not murderer.Character then return end
    if not isSheriff then return end
    
    local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
end

-- ===== KILL ALL =====
local function KillAll()
    if not toggles.KillAll then return end
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
    if not toggles.Noclip then return end
    if not LocalPlayer.Character then return end
    
    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- ===== FLY =====
local function Fly()
    if not toggles.Fly then
        flyEnabled = false
        return
    end
    
    if not flyEnabled then flyEnabled = true end
    
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local moveVector = Vector3.new(0, 0, 0)
    -- Use touch controls via WASD emulation or just use simple up/down with Space/Shift detection
    -- For mobile, we use the built-in movement keys if keyboard is attached, otherwise fallback to default.
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVector = moveVector - Vector3.new(0, 1, 0) end
    
    root.Velocity = moveVector * 50
end

-- ===== INFINITE JUMP =====
local function InfiniteJump()
    if not toggles.InfiniteJump then return end
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- ===== GOD MODE =====
local function GodMode()
    if not toggles.GodMode then return end
    if not LocalPlayer.Character then return end
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
end

-- ===== SPINBOT =====
local function SpinBot()
    if not toggles.SpinBot then return end
    if not LocalPlayer.Character then return end
    
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        spinAngle = spinAngle + 0.1
        root.CFrame = root.CFrame * CFrame.Angles(0, 0.1, 0)
    end
end

-- ===== AUTO COLLECT GUN =====
local function AutoCollectGun()
    if not toggles.AutoCollectGun then return end
    if not gunDrop then return end
    
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(gunDrop.Position + Vector3.new(0, 2, 0))
end

-- ===== COIN FARM =====
local function CoinFarm()
    if not toggles.AutoFarm then return end
    if not LocalPlayer.Character then return end
    
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
        UpdateRoles()
        FindGunDrop()
        
        -- ESP
        ClearESP()
        if toggles.ESPMurderer and murderer then
            CreateESP(murderer, Color3.fromRGB(255, 0, 0), "🔪 MURDERER")
        end
        if toggles.ESPSheriff and sheriff then
            CreateESP(sheriff, Color3.fromRGB(0, 255, 0), "🔫 SHERIFF")
        end
        if toggles.ESPInnocent then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player ~= murderer and player ~= sheriff then
                    CreateESP(player, Color3.fromRGB(255, 255, 255), "👤 INNOCENT")
                end
            end
        end
        if toggles.ESPGun and gunDrop then
            -- Simple indicator: highlight the gun part
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Color3.fromRGB(255, 255, 0)
            highlight.FillTransparency = 0.3
            highlight.Parent = gunDrop
            table.insert(espObjects, {nil, highlight, nil})
        end
        
        AutoShoot()
        SilentAim()
        KillAll()
        Noclip()
        Fly()
        InfiniteJump()
        GodMode()
        SpinBot()
        AutoCollectGun()
        CoinFarm()
    end
end

-- ===== KEYBINDS (optional) =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        toggles.AutoShoot = not toggles.AutoShoot
        -- Update toggle button state? We'll skip for simplicity, user can use GUI
    end
    if input.KeyCode == Enum.KeyCode.X then
        toggles.KillAll = not toggles.KillAll
    end
    if input.KeyCode == Enum.KeyCode.V then
        toggles.Fly = not toggles.Fly
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
