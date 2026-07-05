--[[
    MM2 RAGE HUB V3 – Built from Open Source Best Practices
    Features: Octree Coin Farm, Kill Aura, Silent Aim, ESP, Teleports, Walkspeed, Server Hop, Fling, Hitbox
    Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/trekers22/mmtworagescript/main/mm2_rage.lua"))()
]]

-- ===== SERVICES =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===== UI LIBRARY (LinoriaLib) =====
local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- ===== VARIABLES =====
local murderer = nil
local sheriff = nil
local gunDrop = nil
local isMurderer = false
local isSheriff = false
local espObjects = {}
local flyEnabled = false
local spinAngle = 0
local killAuraEnabled = false
local silentAimEnabled = false
local autoShootEnabled = false
local farmEnabled = false
local walkspeedValue = 16
local hitboxSize = 2

-- ===== OCTREE COIN FARM (from Zyn-ic/MM2-AutoFarm) =====
local Octree = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sleitnick/rbxts-octo-tree/main/src/init.lua", true))()
local coinOctree = Octree.new()
local coinList = {}

local function BuildCoinOctree()
    coinOctree:Clear()
    coinList = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "Coin_Server" then
            coinOctree:Insert(obj, obj.Position)
            table.insert(coinList, obj)
        end
    end
end

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") and obj.Name == "Coin_Server" then
        coinOctree:Insert(obj, obj.Position)
        table.insert(coinList, obj)
    end
end)
Workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("BasePart") and obj.Name == "Coin_Server" then
        coinOctree:Remove(obj)
        for i, coin in ipairs(coinList) do
            if coin == obj then table.remove(coinList, i) break end
        end
    end
end)
BuildCoinOctree()

-- ===== ROLE DETECTION =====
local function UpdateRoles()
    isMurderer = false
    isSheriff = false
    murderer = nil
    sheriff = nil

    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            -- Check Backpack for tools (more reliable)
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
    -- Re-check local player
    local localChar = LocalPlayer.Character
    if localChar then
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if localChar:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
            isMurderer = true
        end
        if localChar:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")) then
            isSheriff = true
        end
    end
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

-- ===== ESP (with DepthMode) =====
local function CreateESP(player, color, text)
    if not player.Character then return end
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Highlight with AlwaysOnTop
    local highlight = Instance.new("Highlight")
    highlight.FillColor = color
    highlight.FillTransparency = 0.35
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char

    -- Billboard label
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

-- ===== KILL AURA =====
local function KillAura()
    if not killAuraEnabled then return end
    if not isMurderer then return end

    local closestPlayer = nil
    local closestDist = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestPlayer = player
                end
            end
        end
    end

    if closestPlayer and closestDist < 20 then
        local humanoid = closestPlayer.Character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 then
            humanoid.Health = 0
        end
    end
end

-- ===== SILENT AIM =====
local function SilentAim()
    if not silentAimEnabled then return end
    if not murderer or not murderer.Character then return end

    local targetRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    if isSheriff then
        -- Sheriff: aim gun at murderer
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
    elseif isMurderer then
        -- Murderer: aim knife at nearest player
        local closestPlayer = nil
        local closestDist = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPlayer = player
                    end
                end
            end
        end
        if closestPlayer and closestDist < 20 then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestPlayer.Character.HumanoidRootPart.Position)
        end
    end
end

-- ===== AUTO SHOOT (Sheriff) =====
local function AutoShoot()
    if not autoShootEnabled then return end
    if not isSheriff then return end
    if not murderer or not murderer.Character then return end

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

-- ===== COIN FARM (Octree-based) =====
local function FarmCoins()
    if not farmEnabled then return end
    if not LocalPlayer.Character then return end

    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Find nearest coin using Octree
    local nearest = coinOctree:GetNearest(root.Position, 200)
    if nearest and nearest.Object and nearest.Object.Parent then
        local coin = nearest.Object
        local tween = TweenService:Create(
            root,
            TweenInfo.new(0.15, Enum.EasingStyle.Linear),
            {CFrame = CFrame.new(coin.Position + Vector3.new(0, 2, 0))}
        )
        tween:Play()
        tween.Completed:Wait()
        -- Remove coin from Octree after collection
        coinOctree:Remove(coin)
        for i, c in ipairs(coinList) do
            if c == coin then table.remove(coinList, i) break end
        end
        task.wait(0.05)
    end
end

-- ===== WALKSPEED =====
local function SetWalkspeed()
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = walkspeedValue
    end
end

-- ===== HITBOX SIZE =====
local function SetHitbox()
    if not LocalPlayer.Character then return end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.HitboxSize = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    end
end

-- ===== SERVER HOP =====
local function ServerHop()
    local servers = {}
    for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100")).data) do
        if v.playing ~= v.maxPlayers and v.id ~= game.JobId then
            table.insert(servers, v.id)
        end
    end
    if #servers > 0 then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
    end
end

-- ===== FLING MURDERER =====
local function FlingMurderer()
    if not murderer or not murderer.Character then return end
    local root = murderer.Character:FindFirstChild("HumanoidRootPart")
    if root then
        root.Velocity = Vector3.new(0, 1000, 0)
    end
end

-- ===== UI =====
local Window = Library:CreateWindow({
    Title = 'MM2 Rage Hub V3',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.1
})

-- ESP Tab
local espTab = Window:AddTab('ESP')
local espGroup = espTab:AddLeftGroupbox('ESP Toggles')
espGroup:AddToggle('ESP Murderer', { Text = 'Show Murderer', Default = false }, function(v)
    _G.ESP_Murderer = v
end)
espGroup:AddToggle('ESP Sheriff', { Text = 'Show Sheriff', Default = false }, function(v)
    _G.ESP_Sheriff = v
end)
espGroup:AddToggle('ESP Innocent', { Text = 'Show Innocent', Default = false }, function(v)
    _G.ESP_Innocent = v
end)
espGroup:AddToggle('ESP Gun Drop', { Text = 'Show Gun Drop', Default = false }, function(v)
    _G.ESP_Gun = v
end)

-- Combat Tab
local combatTab = Window:AddTab('Combat')
local combatGroup = combatTab:AddLeftGroupbox('Combat')
combatGroup:AddToggle('Kill Aura', { Text = 'Auto Kill Nearest (Murderer)', Default = false }, function(v)
    killAuraEnabled = v
end)
combatGroup:AddToggle('Silent Aim', { Text = 'Silent Aim (Murderer/Sheriff)', Default = false }, function(v)
    silentAimEnabled = v
end)
combatGroup:AddToggle('Auto Shoot', { Text = 'Auto Shoot Murderer (Sheriff)', Default = false }, function(v)
    autoShootEnabled = v
end)
combatGroup:AddToggle('Fling Murderer', { Text = 'Fling Murderer (Troll)', Default = false }, function(v)
    if v then FlingMurderer() end
end)

-- Movement Tab
local moveTab = Window:AddTab('Movement')
local moveGroup = moveTab:AddLeftGroupbox('Teleports')
moveGroup:AddButton('TP to Murderer', function()
    if murderer and murderer.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = murderer.Character.HumanoidRootPart.CFrame
    end
end)
moveGroup:AddButton('TP to Sheriff', function()
    if sheriff and sheriff.Character then
        LocalPlayer.Character.HumanoidRootPart.CFrame = sheriff.Character.HumanoidRootPart.CFrame
    end
end)
moveGroup:AddButton('TP to Gun', function()
    if gunDrop then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(gunDrop.Position)
    end
end)
moveGroup:AddButton('TP to Lobby', function()
    LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 100, 0)
end)
moveGroup:AddButton('Kill All (as Murderer)', function()
    if isMurderer then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    humanoid.Health = 0
                end
            end
        end
    end
end)

local moveGroup2 = moveTab:AddRightGroupbox('Settings')
moveGroup2:AddSlider('Walkspeed', { Text = 'Walkspeed', Default = 16, Min = 1, Max = 120, Rounding = 1 }, function(v)
    walkspeedValue = v
    SetWalkspeed()
end)
moveGroup2:AddSlider('Hitbox Size', { Text = 'Hitbox Size', Default = 2, Min = 0.5, Max = 10, Rounding = 1 }, function(v)
    hitboxSize = v
    SetHitbox()
end)
moveGroup2:AddButton('Server Hop', function()
    ServerHop()
end)
moveGroup2:AddButton('Rejoin', function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end)

-- Farm Tab
local farmTab = Window:AddTab('Farm')
local farmGroup = farmTab:AddLeftGroupbox('Coin Farm')
farmGroup:AddToggle('Auto Farm Coins', { Text = 'Farm Coins (Octree-based)', Default = false }, function(v)
    farmEnabled = v
    if v then
        BuildCoinOctree()
    end
end)
farmGroup:AddButton('Rescan Coins', function()
    BuildCoinOctree()
end)

-- ===== MAIN LOOP =====
local function MainLoop()
    while task.wait(0.1) do
        UpdateRoles()
        FindGunDrop()
        SetWalkspeed()
        SetHitbox()

        -- ESP
        ClearESP()
        if _G.ESP_Murderer and murderer then
            CreateESP(murderer, Color3.fromRGB(255, 0, 0), '🔪 MURDERER')
        end
        if _G.ESP_Sheriff and sheriff then
            CreateESP(sheriff, Color3.fromRGB(0, 0, 255), '🔫 SHERIFF')
        end
        if _G.ESP_Innocent then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player ~= murderer and player ~= sheriff then
                    CreateESP(player, Color3.fromRGB(255, 255, 255), '👤 INNOCENT')
                end
            end
        end
        if _G.ESP_Gun and gunDrop then
            local highlight = Instance.new('Highlight')
            highlight.FillColor = Color3.fromRGB(255, 255, 0)
            highlight.FillTransparency = 0.3
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = gunDrop
            table.insert(espObjects, {nil, highlight, nil})
        end

        -- Combat
        KillAura()
        SilentAim()
        AutoShoot()

        -- Farm
        FarmCoins()
    end
end

-- ===== KEYBINDS =====
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        autoShootEnabled = not autoShootEnabled
        Library:Notify('Auto Shoot: ' .. (autoShootEnabled and 'ON' or 'OFF'))
    end
    if input.KeyCode == Enum.KeyCode.X then
        killAuraEnabled = not killAuraEnabled
        Library:Notify('Kill Aura: ' .. (killAuraEnabled and 'ON' or 'OFF'))
    end
    if input.KeyCode == Enum.KeyCode.V then
        farmEnabled = not farmEnabled
        Library:Notify('Auto Farm: ' .. (farmEnabled and 'ON' or 'OFF'))
        if farmEnabled then BuildCoinOctree() end
    end
end)

-- ===== START =====
coroutine.wrap(MainLoop)()

-- ===== CLEANUP =====
Library:OnUnload(function()
    ClearESP()
end)

print('🔥 MM2 RAGE HUB V3 LOADED – Built from Open Source')
