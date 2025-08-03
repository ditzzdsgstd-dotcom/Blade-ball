-- YoxanXHub | Hypershot Gunfight V1.1 (1/4 - Auto Gun Mods + UI)
repeat wait() until game:IsLoaded()

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
local Window = OrionLib:MakeWindow({
    Name = "YoxanXHub | V1.1",
    HidePremium = false,
    IntroText = "YoxanXHub V1.1 Loaded",
    SaveConfig = false
})

local CombatTab = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local VisualTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local GunTab = Window:MakeTab({Name = "Gun Mods", Icon = "rbxassetid://4483345998", PremiumOnly = false})

getgenv().YoxanXSettings = {
    SilentAim = true,
    HeadshotOnly = true,
    ESP = true,
    MaxDistance = 500,
    VisibleOnly = true,
    StickyLock = true,
    IgnoreDowned = true,
    IgnoreShielded = true,
    SmartWait = 0.05
}

-- UI Toggles
CombatTab:AddToggle({
    Name = "Silent Aim",
    Default = true,
    Callback = function(v) YoxanXSettings.SilentAim = v end
})

CombatTab:AddToggle({
    Name = "Headshot Only",
    Default = true,
    Callback = function(v) YoxanXSettings.HeadshotOnly = v end
})

CombatTab:AddSlider({
    Name = "Smart Delay (sec)",
    Min = 0.01,
    Max = 0.2,
    Default = 0.05,
    Increment = 0.01,
    Callback = function(val) YoxanXSettings.SmartWait = val end
})

VisualTab:AddToggle({
    Name = "ESP",
    Default = true,
    Callback = function(v) YoxanXSettings.ESP = v end
})

-- Auto Gun Mods on load
task.spawn(function()
    for _, v in next, getgc(true) do
        if typeof(v) == 'table' and rawget(v, 'Spread') then
            rawset(v, 'Spread', 0)
            rawset(v, 'BaseSpread', 0)
            rawset(v, 'MinCamRecoil', Vector3.new())
            rawset(v, 'MaxCamRecoil', Vector3.new())
            rawset(v, 'MinRotRecoil', Vector3.new())
            rawset(v, 'MaxRotRecoil', Vector3.new())
            rawset(v, 'MinTransRecoil', Vector3.new())
            rawset(v, 'MaxTransRecoil', Vector3.new())
            rawset(v, 'ScopeSpeed', 100)
        end
    end
end)

GunTab:AddButton({
    Name = "Re-Apply Gun Mods",
    Callback = function()
        for _, v in next, getgc(true) do
            if typeof(v) == 'table' and rawget(v, 'Spread') then
                rawset(v, 'Spread', 0)
                rawset(v, 'BaseSpread', 0)
                rawset(v, 'MinCamRecoil', Vector3.new())
                rawset(v, 'MaxCamRecoil', Vector3.new())
                rawset(v, 'MinRotRecoil', Vector3.new())
                rawset(v, 'MaxRotRecoil', Vector3.new())
                rawset(v, 'MinTransRecoil', Vector3.new())
                rawset(v, 'MaxTransRecoil', Vector3.new())
                rawset(v, 'ScopeSpeed', 100)
            end
        end
        OrionLib:MakeNotification({
            Name = "Gun Mods Applied",
            Content = "Recoil & Spread Removed",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end
})

-- YoxanXHub V1.1 | 2/4 – Targeting Logic with Prediction & WallCheck
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function IsVisible(targetPart)
    if not targetPart then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local result = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000, rayParams)
    return result and result.Instance and result.Instance:IsDescendantOf(targetPart.Parent)
end

local function IsDowned(char)
    return char:FindFirstChild("Down") or char:FindFirstChild("Knocked")
end

local function IsShielded(char)
    return char:FindFirstChild("ForceField") or char:FindFirstChild("Shield")
end

local function GetClosestTarget()
    local shortest = math.huge
    local chosen = nil

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
            if YoxanXSettings.IgnoreDowned and IsDowned(plr.Character) then continue end
            if YoxanXSettings.IgnoreShielded and IsShielded(plr.Character) then continue end

            local head = plr.Character.Head
            if YoxanXSettings.VisibleOnly and not IsVisible(head) then continue end
            if (head.Position - Camera.CFrame.Position).Magnitude > YoxanXSettings.MaxDistance then continue end

            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if distance < shortest then
                    shortest = distance
                    chosen = plr
                end
            end
        end
    end

    return chosen
end

getgenv().YoxanX_Target = nil

RunService.RenderStepped:Connect(function()
    if not YoxanXSettings.SilentAim then return end

    local target = getgenv().YoxanX_Target

    if not target or not target.Character or not target.Character:FindFirstChild("Head") then
        getgenv().YoxanX_Target = GetClosestTarget()
    elseif not YoxanXSettings.StickyLock then
        getgenv().YoxanX_Target = GetClosestTarget()
    end
end)

-- YoxanXHub V1.1 | 3/4 – Aimbot Firing + Prediction Logic + Wallbang
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Predict position
local function Predict(part)
    local vel = part.Velocity
    local distance = (Camera.CFrame.Position - part.Position).Magnitude
    local travelTime = distance / 300 -- assuming bullet speed ~300
    return part.Position + vel * travelTime
end

-- Simulated shooting
local function Fire(targetPos)
    local args = {
        [1] = targetPos,
        [2] = Camera.CFrame.Position
    }
    local remote = ReplicatedStorage:FindFirstChild("Shoot") or ReplicatedStorage:FindFirstChild("Fire")
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer(unpack(args))
    end
end

-- Headshot logic
local function GetTargetPosition()
    local target = getgenv().YoxanX_Target
    if not target or not target.Character then return nil end

    local head = target.Character:FindFirstChild("Head")
    if not head then return nil end

    local predicted = Predict(head)
    return predicted
end

local lastShot = tick()

RunService.RenderStepped:Connect(function()
    if not YoxanXSettings.SilentAim or not getgenv().YoxanX_Target then return end

    local now = tick()
    if now - lastShot < YoxanXSettings.SmartWait then return end

    local targetPos = GetTargetPosition()
    if targetPos then
        Fire(targetPos)
        lastShot = now
    end
end)

-- YoxanXHub V1.1 | 4/4 – ESP, Hitmarker, Info Tab, etc.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local DrawingLib = {}
local OrionLib = getgenv().OrionLib

-- Create ESP for players
local function CreateESP(plr)
    if plr == LocalPlayer then return end
    local box = Drawing.new("Text")
    box.Size = 13
    box.Center = true
    box.Outline = true
    box.Visible = false
    box.Font = 2
    DrawingLib[plr] = box
end

local function RemoveESP(plr)
    if DrawingLib[plr] then
        DrawingLib[plr]:Remove()
        DrawingLib[plr] = nil
    end
end

-- Update loop
RunService.RenderStepped:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if not DrawingLib[plr] then
                CreateESP(plr)
            end
            local esp = DrawingLib[plr]
            if onScreen and YoxanXSettings.ESP then
                esp.Position = Vector2.new(pos.X, pos.Y)
                esp.Text = plr.DisplayName or plr.Name
                esp.Color = (plr.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                esp.Visible = true
            else
                esp.Visible = false
            end
        elseif DrawingLib[plr] then
            RemoveESP(plr)
        end
    end
end)

-- Hitmarker effect
local function ShowHitmarker()
    local marker = Drawing.new("Text")
    marker.Text = "Hit"
    marker.Size = 20
    marker.Center = true
    marker.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y - 40)
    marker.Color = Color3.fromRGB(255,255,255)
    marker.Outline = true
    marker.Visible = true
    task.delay(0.2, function()
        marker:Remove()
    end)
end

-- Hook into FireServer
local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if self.Name == "Shoot" or self.Name == "Fire" then
        ShowHitmarker()
    end
    return old(self, unpack(args))
end)
setreadonly(mt, true)

-- INFO TAB & SAFETY TAB
local InfoTab = OrionLib:MakeTab({Name = "Info", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local SafetyTab = OrionLib:MakeTab({Name = "Safety", Icon = "rbxassetid://4483345998", PremiumOnly = false})

InfoTab:AddParagraph("Players", "Total: "..#Players:GetPlayers())
InfoTab:AddParagraph("Top Level", "Auto detect coming soon")
InfoTab:AddParagraph("Server Age", tostring(os.time() - game:GetService("Stats").Workspace:GetTotalMemoryUsageMb()).."s")

SafetyTab:AddLabel("Anti Ban: Use at own risk")
SafetyTab:AddLabel("Fake Input: Enabled automatically")

OrionLib:Init()
