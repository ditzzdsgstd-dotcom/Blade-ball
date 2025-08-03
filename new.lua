local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
local Window = OrionLib:MakeWindow({
    Name = "YoxanXHub V2 | Hypershot Gunfight",
    HidePremium = false,
    SaveConfig = false,
    IntroText = "YoxanXHub V2 Loaded",
    IntroIcon = "rbxassetid://7733964646",
    ConfigFolder = "YoxanXGunfight"
})

-- Tabs
local AimbotTab = Window:MakeTab({Name = "Aimbot", Icon = "🎯", PremiumOnly = false})
local ESPTab = Window:MakeTab({Name = "ESP", Icon = "👁️", PremiumOnly = false})
local VisualTab = Window:MakeTab({Name = "Visual", Icon = "🎨", PremiumOnly = false})
local GunTab = Window:MakeTab({Name = "GunMods", Icon = "🔫", PremiumOnly = false})
local SafetyTab = Window:MakeTab({Name = "Safety", Icon = "🛡️", PremiumOnly = false})
local InfoTab = Window:MakeTab({Name = "Info", Icon = "📊", PremiumOnly = false})
local UtilityTab = Window:MakeTab({Name = "Utility", Icon = "⚙️", PremiumOnly = false})

-- Aimbot Toggles
AimbotTab:AddToggle({Name = "Silent Aim", Default = false, Callback = function(v) getgenv().SilentAim = v end})
AimbotTab:AddToggle({Name = "Auto Headshot", Default = false, Callback = function(v) getgenv().AutoHeadshot = v end})
AimbotTab:AddToggle({Name = "Prediction", Default = false, Callback = function(v) getgenv().UsePrediction = v end})
AimbotTab:AddToggle({Name = "Wallbang", Default = false, Callback = function(v) getgenv().Wallbang = v end})

-- ESP
ESPTab:AddToggle({Name = "Enable ESP", Default = false, Callback = function(v) getgenv().ESPEnabled = v end})
ESPTab:AddToggle({Name = "Enemy = Red / Friend = Green", Default = true, Callback = function(v) getgenv().ColorESP = v end})
ESPTab:AddToggle({Name = "Health ESP", Default = false, Callback = function(v) getgenv().HealthESP = v end})
ESPTab:AddToggle({Name = "Weapon ESP", Default = false, Callback = function(v) getgenv().WeaponESP = v end})

-- Visual
VisualTab:AddToggle({Name = "Custom Crosshair", Default = false, Callback = function(v) getgenv().CrosshairFX = v end})
VisualTab:AddToggle({Name = "Hit Marker Effect", Default = false, Callback = function(v) getgenv().HitFX = v end})
VisualTab:AddToggle({Name = "Show FPS/Ping", Default = false, Callback = function(v) getgenv().ShowStats = v end})

-- GunMods
GunTab:AddToggle({Name = "Anti Recoil", Default = false, Callback = function(v) getgenv().AntiRecoil = v end})
GunTab:AddToggle({Name = "Anti Spread", Default = false, Callback = function(v) getgenv().AntiSpread = v end})
GunTab:AddToggle({Name = "No Muzzle Flash/Smoke", Default = false, Callback = function(v) getgenv().NoMuzzle = v end})
GunTab:AddToggle({Name = "Instant Scope In", Default = false, Callback = function(v) getgenv().ScopeSpeed = v end})

-- Safety
SafetyTab:AddToggle({Name = "Auto Leave on Admin Join", Default = true, Callback = function(v) getgenv().AutoLeaveAdmin = v end})
SafetyTab:AddToggle({Name = "Anti Kick Basic", Default = true, Callback = function(v) getgenv().AntiKick = v end})

-- Info
InfoTab:AddToggle({Name = "Show Top Player Info", Default = false, Callback = function(v) getgenv().ShowTop = v end})
InfoTab:AddToggle({Name = "Server Region Tracker", Default = false, Callback = function(v) getgenv().RegionInfo = v end})

-- Utility
UtilityTab:AddButton({Name = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer) end})
UtilityTab:AddToggle({Name = "UI Keybind: RightShift", Default = true, Callback = function(v) OrionLib:ToggleUI() end})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local function IsVisible(part)
    if not part then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
    return result and result.Instance and result.Instance:IsDescendantOf(part.Parent)
end

local function IsShielded(char)
    return char:FindFirstChild("ForceField") or char:FindFirstChild("Shield")
end

local function GetClosestTarget()
    local shortest = math.huge
    local selected = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            if getgenv().InvisibleBypass and not p.Character:FindFirstChildOfClass("MeshPart") then continue end
            if getgenv().IgnoreShielded and IsShielded(p.Character) then continue end
            if getgenv().Wallcheck and not IsVisible(head) then continue end
            if (head.Position - Camera.CFrame.Position).Magnitude > 500 and getgenv().MaxDistance then continue end
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < shortest then
                    shortest = dist
                    selected = p
                end
            end
        end
    end
    return selected
end

-- Silent Aim Target Lock Loop
RunService.RenderStepped:Connect(function()
    if not getgenv().SilentAim then return end
    if not getgenv().YoxanX_Target or not getgenv().YoxanX_Target.Character or not getgenv().YoxanX_Target.Character:FindFirstChild("Head") then
        getgenv().YoxanX_Target = GetClosestTarget()
    end
end)

-- Hit Prediction (basic + ping scale)
function GetPredictedPosition(targetPart)
    if not targetPart then return nil end
    local velocity = targetPart.Velocity or Vector3.zero
    local ping = game.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
    local delay = ping / 1000 + 0.05
    return targetPart.Position + (velocity * delay)
end

-- Exposed for bullet use in part 3/10
getgenv().YoxanX_Headshot = function()
    local target = getgenv().YoxanX_Target
    if target and target.Character and target.Character:FindFirstChild("Head") then
        return GetPredictedPosition(target.Character.Head)
    end
    return nil
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Mouse = LocalPlayer:GetMouse()

-- Simulate Bullet Fire
function FireToPosition(position)
    local remote = ReplicatedStorage:FindFirstChild("ShootEvent") or ReplicatedStorage:FindFirstChildOfClass("RemoteEvent")
    if remote and typeof(position) == "Vector3" then
        remote:FireServer(position)
    end
end

-- Smart Delay
local lastShot = tick()
function CanShoot()
    return (tick() - lastShot) >= 0.05
end

-- AutoFire Headshot Loop
RunService.RenderStepped:Connect(function()
    if not getgenv().SilentAim or not getgenv().AutoHeadshot then return end
    local headPos = getgenv().YoxanX_Headshot()
    if headPos and CanShoot() then
        FireToPosition(headPos)
        lastShot = tick()

        if getgenv().HitFX then
            local gui = Instance.new("BillboardGui", game.CoreGui)
            gui.Size = UDim2.new(0,100,0,40)
            gui.Adornee = nil
            gui.AlwaysOnTop = true
            gui.StudsOffset = Vector3.new(0, 1.5, 0)
            local label = Instance.new("TextLabel", gui)
            label.Size = UDim2.new(1,0,1,0)
            label.BackgroundTransparency = 1
            label.Text = "HIT!"
            label.TextColor3 = Color3.fromRGB(255,0,0)
            label.TextScaled = true
            game.Debris:AddItem(gui, 0.4)
        end

        if getgenv().AntiOverkill then
            local hum = getgenv().YoxanX_Target and getgenv().YoxanX_Target.Character and getgenv().YoxanX_Target.Character:FindFirstChild("Humanoid")
            if hum and hum.Health <= 0 then
                getgenv().YoxanX_Target = nil
            end
        end
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local espFolder = Instance.new("Folder", game.CoreGui)
espFolder.Name = "YoxanX_ESP"

function CreateESP(player)
    if espFolder:FindFirstChild(player.Name) then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.Adornee = nil
    billboard.Parent = espFolder

    local nameLabel = Instance.new("TextLabel", billboard)
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Text = ""

    local hpBar = Instance.new("Frame", billboard)
    hpBar.AnchorPoint = Vector2.new(0.5, 1)
    hpBar.Position = UDim2.new(0.5, 0, 1, 0)
    hpBar.Size = UDim2.new(0.6, 0, 0.1, 0)
    hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
end

function UpdateESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            CreateESP(plr)
            local gui = espFolder:FindFirstChild(plr.Name)
            local head = plr.Character.Head
            local human = plr.Character:FindFirstChildOfClass("Humanoid")
            if gui and gui:IsA("BillboardGui") and head then
                gui.Adornee = head
                local label = gui:FindFirstChildOfClass("TextLabel")
                local hpBar = gui:FindFirstChildOfClass("Frame")
                label.Text = plr.Name .. " [" .. math.floor(human.Health) .. "]"
                if human.Health <= 0 then
                    gui:Destroy()
                else
                    if LocalPlayer.Team ~= nil and plr.Team ~= nil and plr.Team == LocalPlayer.Team then
                        label.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
                    else
                        label.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
                    end
                    hpBar.Size = UDim2.new(math.clamp(human.Health / human.MaxHealth, 0, 1), 0, 0.1, 0)
                    hpBar.BackgroundColor3 = Color3.fromRGB(255 - human.Health*2, human.Health*2, 0)
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if getgenv().ESP_Enabled then
        pcall(UpdateESP)
    else
        for _, v in pairs(espFolder:GetChildren()) do v:Destroy() end
    end
end)

-- Inisialisasi toggle UI
getgenv().GunMod_Settings = {
    NoRecoil = true,
    NoSpread = true,
    InstantScope = true,
    ScopeSpeed = true,
    AutoFire = false,
}

-- GunMods Runtime Patch
local function ApplyGunMods()
    for _, v in next, getgc(true) do
        if typeof(v) == 'table' and rawget(v, 'Spread') then
            if getgenv().GunMod_Settings.NoSpread then
                rawset(v, 'Spread', 0)
                rawset(v, 'BaseSpread', 0)
            end
            if getgenv().GunMod_Settings.NoRecoil then
                rawset(v, 'MinCamRecoil', Vector3.new())
                rawset(v, 'MaxCamRecoil', Vector3.new())
                rawset(v, 'MinRotRecoil', Vector3.new())
                rawset(v, 'MaxRotRecoil', Vector3.new())
                rawset(v, 'MinTransRecoil', Vector3.new())
                rawset(v, 'MaxTransRecoil', Vector3.new())
            end
            if getgenv().GunMod_Settings.ScopeSpeed then
                rawset(v, 'ScopeSpeed', 100)
            end
        end
    end
end

-- Trigger GunMods patching after load
task.spawn(function()
    while true do
        if getgenv().GunMod_Settings then
            ApplyGunMods()
        end
        task.wait(2.5) -- Interval update
    end
end)

--[[ 
    Part 6/10 – YoxanXHub V2 | Safety Tab
    Auto detects moderators/admins and leaves.
    Auto reconnect if kicked or crashed.
]]

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local PlaceId = game.PlaceId

-- Admin Detector
local ModeratorList = {"Admin", "Moderator", "Mod", "Dev", "Developer", "Owner"}
local function IsSuspicious(player)
    for _, keyword in pairs(ModeratorList) do
        if string.find(player.Name:lower(), keyword:lower()) or string.find(player.DisplayName:lower(), keyword:lower()) then
            return true
        end
    end
    return false
end

-- Auto Leave if suspicious user joins
Players.PlayerAdded:Connect(function(plr)
    task.wait(1)
    if IsSuspicious(plr) then
        game.StarterGui:SetCore("SendNotification", {
            Title = "YoxanXHub Warning",
            Text = "Suspicious user joined. Leaving...",
            Duration = 4
        })
        task.wait(3)
        TeleportService:Teleport(PlaceId, Players.LocalPlayer)
    end
end)

-- Rejoin if kicked
local CoreGui = game:GetService("CoreGui")
game:GetService("GuiService").ErrorMessageChanged:Connect(function(msg)
    if msg and msg ~= "" then
        task.wait(1)
        TeleportService:Teleport(PlaceId, Players.LocalPlayer)
    end
end)

-- Server Region Info
local function GetRegion()
    local url = "https://ipapi.co/json/"
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local data = HttpService:JSONDecode(response)
        print("[YoxanXHub] Region:", data.country_name)
    else
        warn("[YoxanXHub] Failed to fetch region.")
    end
end
task.spawn(GetRegion)

-- Crash Protection
local function HandleError()
    while true do
        if not pcall(function() return Players.LocalPlayer.Character end) then
            warn("[YoxanXHub] Character not loaded! Recovering...")
            task.wait(2)
            TeleportService:Teleport(PlaceId, Players.LocalPlayer)
        end
        task.wait(5)
    end
end
task.spawn(HandleError)

-- Info Tab Data Grabber (YoxanXHub V2 - Part 7/10)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Container table
getgenv().YoxanX_InfoData = {
    PlayerCount = 0,
    TopKiller = "",
    TopLevel = "",
    PlayersInfo = {},
}

local function UpdateInfoTab()
    local data = getgenv().YoxanX_InfoData
    data.PlayerCount = #Players:GetPlayers()

    local topKills = -1
    local topLevel = -1
    local topKillerName = ""
    local topLevelName = ""

    data.PlayersInfo = {}

    for _, plr in pairs(Players:GetPlayers()) do
        local char = plr.Character
        local kills = 0
        local level = 0
        local team = (plr.Team and plr.Team.Name) or "Unknown"

        -- Try grab kills/level if available
        pcall(function()
            kills = plr.leaderstats.Kills.Value
            level = plr.leaderstats.Level.Value
        end)

        if kills > topKills then
            topKills = kills
            topKillerName = plr.Name .. " [" .. tostring(kills) .. "]"
        end

        if level > topLevel then
            topLevel = level
            topLevelName = plr.Name .. " [" .. tostring(level) .. "]"
        end

        table.insert(data.PlayersInfo, {
            Name = plr.Name,
            Display = plr.DisplayName,
            Team = team,
            Kills = kills,
            Level = level
        })
    end

    data.TopKiller = topKillerName
    data.TopLevel = topLevelName
end

-- Periodic update
while true do
    pcall(UpdateInfoTab)
    task.wait(5)
end

-- Info Tab Data Grabber (YoxanXHub V2 - Part 7/10)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Container table
getgenv().YoxanX_InfoData = {
    PlayerCount = 0,
    TopKiller = "",
    TopLevel = "",
    PlayersInfo = {},
}

local function UpdateInfoTab()
    local data = getgenv().YoxanX_InfoData
    data.PlayerCount = #Players:GetPlayers()

    local topKills = -1
    local topLevel = -1
    local topKillerName = ""
    local topLevelName = ""

    data.PlayersInfo = {}

    for _, plr in pairs(Players:GetPlayers()) do
        local char = plr.Character
        local kills = 0
        local level = 0
        local team = (plr.Team and plr.Team.Name) or "Unknown"

        -- Try grab kills/level if available
        pcall(function()
            kills = plr.leaderstats.Kills.Value
            level = plr.leaderstats.Level.Value
        end)

        if kills > topKills then
            topKills = kills
            topKillerName = plr.Name .. " [" .. tostring(kills) .. "]"
        end

        if level > topLevel then
            topLevel = level
            topLevelName = plr.Name .. " [" .. tostring(level) .. "]"
        end

        table.insert(data.PlayersInfo, {
            Name = plr.Name,
            Display = plr.DisplayName,
            Team = team,
            Kills = kills,
            Level = level
        })
    end

    data.TopKiller = topKillerName
    data.TopLevel = topLevelName
end

-- Periodic update
while true do
    pcall(UpdateInfoTab)
    task.wait(5)
end

OrionLib:MakeNotification({
    Name = "YoxanXHub V2 Loaded",
    Content = "All core UI toggles ready. Continue to 2/10...",
    Image = "rbxassetid://7733964646",
    Time = 4
})
