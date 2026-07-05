--[[
    MM2 RAGE HUB V2 – Professional Grade
    Features: ESP (Murderer/Sheriff/Innocent/Gun), Silent Aim, Auto Shoot, Kill All, 
    Teleports, Auto Farm, Noclip, Fly, Infinite Jump, God Mode, SpinBot, Auto Collect Gun
    Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/trekers22/mmtworagescript/main/mm2_rage.lua"))()
--]]

-- Services
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
local farmCooldown = 0.1

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

-- ===== PROFESSIONAL GUI (Using LinoriaLib style) =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MM2RageHubV2"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

-- Main frame with gradient style
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 520)
frame.Position = UDim2.new(0.5, -190, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
frame.BackgroundTransparency = 0.08
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = screenGui

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
titleBar.BackgroundTransparency = 0.3
titleBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "🔥 RAGE HUB V2 🔥"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Make draggable
local dragging = false
local dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)

-- Scrollable content
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -40)
scrollFrame.Position = UDim2.new(0, 0, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 70, 70)
scrollFrame.Parent = frame

local function AddSection(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.9, 0, 0, 25)
    label.Position = UDim2.new(0.05, 0, 0, scrollFrame.CanvasSize.Y.Offset)
    label.BackgroundTransparency = 1
    label.Text = "─── " .. text .. " ───"
    label.TextColor3 = Color3.fromRGB(255, 200, 100)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = scrollFrame
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollFrame.CanvasSize.Y.Offset + 30)
end

local function AddToggle(text, key, default)
    local y = scrollFrame.CanvasSize.Y.Offset
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(40, 40, 50)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Text = text .. (default and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = scrollFrame
    toggles[key] = default
    btn.MouseButton1Click:Connect(function()
        toggles[key] = not toggles[key]
        btn.BackgroundColor3 = toggles[key] and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(40, 40, 50)
        btn.Text = text .. (toggles[key] and " [ON]" or " [OFF]")
    end)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, y + 37)
end

local function AddButton(text, callback, color)
    local y = scrollFrame.CanvasSize.Y.Offset
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.43, 0, 0, 32)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.BackgroundColor3 = color or Color3.fromRGB(50, 50, 80)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = scrollFrame
    btn.MouseButton1Click:Connect(callback)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, y + 37)
    return btn
end

-- ===== BUILD UI =====
AddSection("ESP")
AddToggle("ESP Murderer", "ESPMurderer", false)
AddToggle("ESP Sheriff", "ESPSheriff", false)
AddToggle("ESP Innocent", "ESPInnocent", false)
AddToggle("ESP Gun Drop", "ESPGun", false)

AddSection("COMBAT")
AddToggle("Auto Shoot Murderer", "AutoShoot", false)
AddToggle("Silent Aim", "SilentAim", false)
AddToggle("Kill All (as Murderer)", "KillAll", false)
AddToggle("SpinBot", "SpinBot", false)

AddSection("MOVEMENT")
AddToggle("Noclip", "Noclip", false)
AddToggle("Fly", "Fly", false)
AddToggle("Infinite Jump", "InfiniteJump", false)

AddSection("MISC")
AddToggle("God Mode", "GodMode", false)
AddToggle("Auto Farm Coins", "AutoFarm", false)
AddToggle("Auto Collect Gun", "AutoCollectGun", false)

AddSection("TELEPORT")
AddButton("TP Murderer", function()
    if murderer and murderer.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = murderer.Character.HumanoidRootPart.CFrame
    end
end, Color3.fromRGB(200, 40, 40))
AddButton("TP Sheriff", function()
    if sheriff and sheriff.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = sheriff.Character.HumanoidRootPart.CFrame
    end
end, Color3.fromRGB(40, 200, 40))
AddButton("TP Gun", function()
    if gunDrop then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(gunDrop.Position)
    end
end, Color3.fromRGB(200, 200, 40))
AddButton("TP Lobby", function()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
end, Color3.fromRGB(100, 100, 200))

-- ===== ROLE DETECTION =====
local function UpdateRoles()
    isMurderer = false
    isSheriff = false
    murderer = nil
    sheriff = nil
    
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            -- Check for knife (murderer)
            if char:FindFirstChild("Knife") or (char:FindFirstChild("Backpack") and char.Backpack:FindFirstChild("Knife")) then
                murderer = player
                if player == LocalPlayer then isMurderer = true end
            end
            -- Check for gun (sheriff)
            if char:FindFirstChild("Gun") or (char:FindFirstChild("Backpack") and char.Backpack:FindFirstChild("Gun")) then
                sheriff = player
                if player == LocalPlayer then isSheriff = true end
            end
        end
    end
end

-- ===== ESP =====
local function CreateESP(player, color, text)
    if not player.Character then return end
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 250, 0, 50)
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
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.FillTransparency = 0.35
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

-- ===== COIN FARM (SMOOTH) =====
local function CoinFarm()
    if not toggles.AutoFarm then return end
    if not LocalPlayer.Character then return end
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Coin_Server" then
            local tween = TweenService:Create(
                LocalPlayer.Character.HumanoidRootPart,
                TweenInfo.new(0.15, Enum.EasingStyle.Linear),
                {CFrame = CFrame.new(obj.Position + Vector3.new(0, 2, 0))}
            )
            tween:Play()
            tween.Completed:Wait()
            task.wait(0.05)
        end
    end
end

-- ===== MAIN LOOP =====
local function MainLoop()
    while task.wait(0.1) do
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

-- ===== KEYBINDS =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        toggles.AutoShoot = not toggles.AutoShoot
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

print("🔥 RAGE HUB V2 LOADED – ENJOY, BITCH")
