--[[
    MM2 RAGE HUB – с плавающей кнопкой для телефона
    Нажми на кнопку "≡" в левом верхнем углу, чтобы открыть/закрыть GUI
]]

-- =====================================================
-- ВСТРОЕННАЯ LINORIALIB (минимальная версия)
-- =====================================================
local Library = {}
local Window = nil
local Notify = function(text) print("[NOTIFY] " .. text) end

local function CreateWindow(data)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LinoriaUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -225, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(255, 70, 70)
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    mainFrame.Visible = false  -- сначала скрыто

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    titleBar.BackgroundTransparency = 0.3
    titleBar.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = data.Title or "RAGE HUB"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = titleBar

    -- Tab buttons
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 35)
    tabContainer.Position = UDim2.new(0, 0, 0, 35)
    tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    tabContainer.Parent = mainFrame

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -70)
    contentFrame.Position = UDim2.new(0, 0, 0, 70)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    -- Draggable
    local dragging = false
    local dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    titleBar.InputEnded:Connect(function() dragging = false end)

    -- Плавающая кнопка для телефона
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 50)
    toggleBtn.Position = UDim2.new(0, 10, 0, 10)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
    toggleBtn.BackgroundTransparency = 0.3
    toggleBtn.BorderSizePixel = 2
    toggleBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Text = "≡"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextScaled = true
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = screenGui

    local windowVisible = false
    toggleBtn.MouseButton1Click:Connect(function()
        windowVisible = not windowVisible
        mainFrame.Visible = windowVisible
        toggleBtn.BackgroundColor3 = windowVisible and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(255, 70, 70)
    end)

    local window = {
        Frame = mainFrame,
        TabContainer = tabContainer,
        Content = contentFrame,
        Tabs = {},
        Visible = false,
        ToggleVisible = function()
            windowVisible = not windowVisible
            mainFrame.Visible = windowVisible
            toggleBtn.BackgroundColor3 = windowVisible and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(255, 70, 70)
        end,
        Unload = function()
            screenGui:Destroy()
        end
    }

    return window
end

function Library:CreateWindow(data)
    Window = CreateWindow(data)
    return Window
end

function Library:Notify(text)
    print("[NOTIFY] " .. text)
end

function Library:OnUnload(callback)
    callback()
end

-- Добавляем методы AddTab и элементы (как в прошлом скрипте)
function Window:AddTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.Parent = self.TabContainer

    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabFrame.ScrollBarThickness = 6
    tabFrame.Visible = false
    tabFrame.Parent = self.Content

    local tabObj = { Frame = tabFrame, Buttons = {} }
    self.Tabs[name] = tabObj

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.Tabs) do t.Frame.Visible = false end
        tabFrame.Visible = true
        for _, b in ipairs(self.TabContainer:GetChildren()) do
            if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(200, 200, 200) end
        end
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    if #self.Tabs == 1 then
        tabFrame.Visible = true
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    local function AddGroupbox(title, side)
        local group = Instance.new("Frame")
        group.Size = UDim2.new(0.48, 0, 0, 200)
        group.Position = UDim2.new(side == "left" and 0.01 or 0.51, 0, 0, 0)
        group.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        group.BackgroundTransparency = 0.3
        group.BorderSizePixel = 1
        group.BorderColor3 = Color3.fromRGB(60, 60, 80)
        group.Parent = tabFrame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 25)
        label.BackgroundTransparency = 1
        label.Text = "─── " .. title .. " ───"
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.Parent = group

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, -25)
        container.Position = UDim2.new(0, 0, 0, 25)
        container.BackgroundTransparency = 1
        container.Parent = group

        local y = 0
        local methods = {}

        function methods:AddToggle(text, default, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.9, 0, 0, 28)
            btn.Position = UDim2.new(0.05, 0, 0, y)
            btn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 50, 60)
            btn.Text = text .. (default and " [ON]" or " [OFF]")
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            btn.Parent = container
            local state = default or false
            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 50, 60)
                btn.Text = text .. (state and " [ON]" or " [OFF]")
                callback(state)
            end)
            y = y + 32
            container.Size = UDim2.new(1, 0, 0, y)
            group.Size = UDim2.new(0.48, 0, 0, y + 30)
        end

        function methods:AddButton(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.9, 0, 0, 28)
            btn.Position = UDim2.new(0.05, 0, 0, y)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextScaled = true
            btn.Font = Enum.Font.Gotham
            btn.Parent = container
            btn.MouseButton1Click:Connect(callback)
            y = y + 32
            container.Size = UDim2.new(1, 0, 0, y)
            group.Size = UDim2.new(0.48, 0, 0, y + 30)
        end

        function methods:AddSlider(text, data, callback)
            local default = data.Default or 16
            local min = data.Min or 1
            local max = data.Max or 120
            local rounding = data.Rounding or 1

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.9, 0, 0, 20)
            label.Position = UDim2.new(0.05, 0, 0, y)
            label.BackgroundTransparency = 1
            label.Text = text .. ": " .. default
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextScaled = true
            label.Font = Enum.Font.Gotham
            label.Parent = container

            local slider = Instance.new("TextBox")
            slider.Size = UDim2.new(0.9, 0, 0, 25)
            slider.Position = UDim2.new(0.05, 0, 0, y + 22)
            slider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            slider.Text = tostring(default)
            slider.TextColor3 = Color3.fromRGB(255, 255, 255)
            slider.TextScaled = true
            slider.Font = Enum.Font.Gotham
            slider.Parent = container
            slider.FocusLost:Connect(function()
                local val = tonumber(slider.Text) or default
                val = math.clamp(val, min, max)
                if rounding then val = math.round(val / rounding) * rounding end
                slider.Text = tostring(val)
                label.Text = text .. ": " .. val
                callback(val)
            end)

            y = y + 52
            container.Size = UDim2.new(1, 0, 0, y)
            group.Size = UDim2.new(0.48, 0, 0, y + 30)
        end

        function methods:AddLabel(text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(0.9, 0, 0, 20)
            label.Position = UDim2.new(0.05, 0, 0, y)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextScaled = true
            label.Font = Enum.Font.Gotham
            label.Parent = container
            y = y + 25
            container.Size = UDim2.new(1, 0, 0, y)
            group.Size = UDim2.new(0.48, 0, 0, y + 30)
            return { SetColor = function() end }
        end

        return methods
    end

    function tabObj:AddLeftGroupbox(title)
        return AddGroupbox(title, "left")
    end

    function tabObj:AddRightGroupbox(title)
        return AddGroupbox(title, "right")
    end

    return tabObj
end

-- =====================================================
-- ОСНОВНАЯ ЛОГИКА MM2 RAGE HUB
-- =====================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local murderer = nil
local sheriff = nil
local gunDrop = nil
local isMurderer = false
local isSheriff = false
local espObjects = {}
local espEnabled = { Murderer = false, Sheriff = false, Innocent = false, Gun = false }
local killAura = false
local silentAim = false
local autoShoot = false
local farmEnabled = false
local walkspeedValue = 16
local hitboxSize = 2

-- ===== GUI =====
local Window = Library:CreateWindow({ Title = "🔥 MM2 RAGE HUB" })

-- Вкладка ESP
local espTab = Window:AddTab("ESP")
local espLeft = espTab:AddLeftGroupbox("ESP Toggles")
espLeft:AddToggle("ESP Murderer", false, function(v) espEnabled.Murderer = v end)
espLeft:AddToggle("ESP Sheriff", false, function(v) espEnabled.Sheriff = v end)
espLeft:AddToggle("ESP Innocent", false, function(v) espEnabled.Innocent = v end)
espLeft:AddToggle("ESP Gun Drop", false, function(v) espEnabled.Gun = v end)

-- Вкладка Combat
local combatTab = Window:AddTab("Combat")
local combatLeft = combatTab:AddLeftGroupbox("Combat")
combatLeft:AddToggle("Kill Aura", false, function(v) killAura = v end)
combatLeft:AddToggle("Silent Aim", false, function(v) silentAim = v end)
combatLeft:AddToggle("Auto Shoot", false, function(v) autoShoot = v end)
combatLeft:AddButton("Fling Murderer", function()
    if murderer and murderer.Character then
        local root = murderer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.Velocity = Vector3.new(0, 1000, 0) end
    end
end)

-- Вкладка Movement
local moveTab = Window:AddTab("Movement")
local moveLeft = moveTab:AddLeftGroupbox("Teleports")
moveLeft:AddButton("TP to Murderer", function()
    if murderer and murderer.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = murderer.Character.HumanoidRootPart.CFrame
    end
end)
moveLeft:AddButton("TP to Sheriff", function()
    if sheriff and sheriff.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = sheriff.Character.HumanoidRootPart.CFrame
    end
end)
moveLeft:AddButton("TP to Gun", function()
    if gunDrop then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(gunDrop.Position)
    end
end)
moveLeft:AddButton("TP to Lobby", function()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
end)
moveLeft:AddButton("Kill All", function()
    if isMurderer then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then humanoid.Health = 0 end
            end
        end
    end
end)

local moveRight = moveTab:AddRightGroupbox("Settings")
moveRight:AddSlider("Walkspeed", { Default = 16, Min = 1, Max = 120, Rounding = 1 }, function(v)
    walkspeedValue = v
    if LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed = v end
    end
end)
moveRight:AddSlider("Hitbox Size", { Default = 2, Min = 0.5, Max = 10, Rounding = 0.5 }, function(v)
    hitboxSize = v
    if LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChild("Humanoid")
        if h then h.HitboxSize = Vector3.new(v, v, v) end
    end
end)
moveRight:AddButton("Server Hop", function()
    local servers = {}
    local data = game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
    for _, v in ipairs(data.data) do
        if v.playing ~= v.maxPlayers and v.id ~= game.JobId then
            table.insert(servers, v.id)
        end
    end
    if #servers > 0 then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
    end
end)
moveRight:AddButton("Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

-- Вкладка Farm
local farmTab = Window:AddTab("Farm")
local farmLeft = farmTab:AddLeftGroupbox("Coin Farm")
farmLeft:AddToggle("Auto Farm Coins", false, function(v)
    farmEnabled = v
end)

-- Вкладка Settings
local settingsTab = Window:AddTab("Settings")
local settingsLeft = settingsTab:AddLeftGroupbox("GUI Controls")
settingsLeft:AddButton("Toggle GUI", function()
    Window:ToggleVisible()
end)
settingsLeft:AddButton("Unload GUI", function()
    Window:Unload()
end)
settingsLeft:AddLabel("Кнопка ≡ в левом верхнем углу")

-- ===== ОСНОВНЫЕ ФУНКЦИИ =====
local function UpdateRoles()
    isMurderer = false
    isSheriff = false
    murderer = nil
    sheriff = nil

    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            local backpack = player:FindFirstChild("Backpack")
            if char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
                murderer = player
                if player == LocalPlayer then isMurderer = true end
            end
            if char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")) then
                sheriff = player
                if player == LocalPlayer then isSheriff = true end
            end
        end
    end
end

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

local function CreateESP(player, color, text)
    if not player.Character then return end
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.FillTransparency = 0.35
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char
    table.insert(espObjects, highlight)

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
    table.insert(espObjects, billboard)
end

local function ClearESP()
    for _, obj in ipairs(espObjects) do
        pcall(obj.Destroy, obj)
    end
    espObjects = {}
end

local function KillAuraFunc()
    if not killAura then return end
    if not isMurderer then return end

    local closest = nil
    local closestDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = player
                end
            end
        end
    end
    if closest and closestDist < 20 then
        local h = closest.Character:FindFirstChild("Humanoid")
        if h and h.Health > 0 then h.Health = 0 end
    end
end

local function SilentAimFunc()
    if not silentAim then return end
    if not murderer or not murderer.Character then return end

    local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    if isSheriff then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
    elseif isMurderer then
        local closest = nil
        local closestDist = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = player
                    end
                end
            end
        
