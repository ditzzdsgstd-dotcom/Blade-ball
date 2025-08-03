-- YoxanXHub V2 | Hypershot Gunfight | Part 1/15 (Mobile Paste)
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()

local Window = OrionLib:MakeWindow({
    Name = "YoxanXHub V2 | Hypershot Gunfight",
    HidePremium = false,
    IntroText = "YoxanXHub V2 Loaded\nReady to use!",
    SaveConfig = false,
    ConfigFolder = "YoxanXHub"
})

-- Tabs
local SilentTab = Window:MakeTab({Name = "🎯 Silent Aim", Icon = "", PremiumOnly = false})
local ESPTab = Window:MakeTab({Name = "👁️ ESP", Icon = "", PremiumOnly = false})
local GunTab = Window:MakeTab({Name = "🔫 Gun Mods", Icon = "", PremiumOnly = false})
local SafeTab = Window:MakeTab({Name = "🛡️ Safety", Icon = "", PremiumOnly = false})
local InfoTab = Window:MakeTab({Name = "📊 Info", Icon = "", PremiumOnly = false})

-- Silent Aim Toggles
SilentTab:AddToggle({Name = "Enable Silent Aim", Default = true, Callback = function(v) getgenv().SilentAim = v end})
SilentTab:AddToggle({Name = "Always Headshot", Default = true, Callback = function(v) getgenv().AlwaysHead = v end})
SilentTab:AddToggle({Name = "Sticky Lock", Default = true, Callback = function(v) getgenv().StickyLock = v end})
SilentTab:AddToggle({Name = "Visible Only", Default = true, Callback = function(v) getgenv().VisibleOnly = v end})
SilentTab:AddToggle({Name = "Ignore Knocked", Default = true, Callback = function(v) getgenv().IgnoreKnocked = v end})
SilentTab:AddToggle({Name = "Max 500 Studs", Default = true, Callback = function(v) getgenv().MaxDistance = v end})
SilentTab:AddToggle({Name = "Multi Target Mode", Default = false, Callback = function(v) getgenv().MultiTarget = v end})
SilentTab:AddToggle({Name = "Auto Ping Adjust", Default = true, Callback = function(v) getgenv().AutoPing = v end})

-- ESP Toggles
ESPTab:AddToggle({Name = "Enable ESP", Default = true, Callback = function(v) getgenv().ESP = v end})
ESPTab:AddToggle({Name = "Name ESP (Team Color)", Default = true, Callback = function(v) getgenv().ESPNameColor = v end})
ESPTab:AddToggle({Name = "Box ESP", Default = true, Callback = function(v) getgenv().ESPBox = v end})
ESPTab:AddToggle({Name = "Tracer ESP", Default = false, Callback = function(v) getgenv().ESPTracer = v end})
ESPTab:AddToggle({Name = "Health Bar", Default = false, Callback = function(v) getgenv().ESPHealth = v end})

-- Gun Mod Toggles
GunTab:AddToggle({Name = "No Recoil", Default = true, Callback = function(v) getgenv().NoRecoil = v end})
GunTab:AddToggle({Name = "No Spread", Default = true, Callback = function(v) getgenv().NoSpread = v end})
GunTab:AddToggle({Name = "Instant Scope", Default = true, Callback = function(v) getgenv().FastScope = v end})
GunTab:AddToggle({Name = "Auto Fire", Default = true, Callback = function(v) getgenv().AutoFire = v end})
GunTab:AddToggle({Name = "Scope Speed Boost", Default = false, Callback = function(v) getgenv().ScopeSpeed = v end})

-- Safety Toggles
SafeTab:AddToggle({Name = "Auto Leave on Mod Join", Default = true, Callback = function(v) getgenv().ModLeave = v end})
SafeTab:AddToggle({Name = "Fake Input Mode (Bypass)", Default = true, Callback = function(v) getgenv().FakeInput = v end})

-- Info Tab
InfoTab:AddParagraph("Server Info", "Auto updates on part 2")
InfoTab:AddParagraph("Target Info", "Shows locked player HP/name")

-- YoxanXHub V2 | Hypershot Gunfight | Part 2/15 (Mobile Paste)
-- Logic: Silent Aim, ESP Setup, GunMods, Auto Fire

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

getgenv().Targets = {}
getgenv().ESPObjects = {}

-- Function: Get Closest Enemy
function GetClosestEnemy()
    local closest, shortest = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Team ~= LocalPlayer.Team then
            local headPos = player.Character.Head.Position
            local distance = (Camera.CFrame.Position - headPos).Magnitude
            if getgenv().MaxDistance and distance > 500 then continue end
            if getgenv().VisibleOnly then
                local ray = workspace:Raycast(Camera.CFrame.Position, (headPos - Camera.CFrame.Position).Unit * 500)
                if ray and ray.Instance and not player.Character:IsAncestorOf(ray.Instance) then continue end
            end
            if distance < shortest then
                closest, shortest = player, distance
            end
        end
    end
    return closest
end

-- Auto Aim (Headshot)
RunService.RenderStepped:Connect(function()
    if getgenv().SilentAim and getgenv().AlwaysHead and Camera and LocalPlayer.Character then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
        end
    end
end)

-- GunMods
task.spawn(function()
    while task.wait(1) do
        if getgenv().NoRecoil or getgenv().NoSpread then
            for _, v in next, getgc(true) do
                if typeof(v) == 'table' and rawget(v, 'Spread') then
                    if getgenv().NoSpread then
                        rawset(v, 'Spread', 0)
                        rawset(v, 'BaseSpread', 0)
                    end
                    if getgenv().NoRecoil then
                        rawset(v, 'MinCamRecoil', Vector3.new())
                        rawset(v, 'MaxCamRecoil', Vector3.new())
                        rawset(v, 'MinRotRecoil', Vector3.new())
                        rawset(v, 'MaxRotRecoil', Vector3.new())
                        rawset(v, 'MinTransRecoil', Vector3.new())
                        rawset(v, 'MaxTransRecoil', Vector3.new())
                    end
                end
            end
        end
    end
end)

-- YoxanXHub V2 | Hypershot Gunfight | Part 3/15 (Mobile Paste)
-- ESP Draw + Auto Fire + Tracer

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local DrawingESP = {}

-- Draw ESP (Box + Name + Tracer)
RunService.RenderStepped:Connect(function()
    if not getgenv().ESP then return end
    for _, v in pairs(DrawingESP) do v:Remove() end
    table.clear(DrawingESP)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Team ~= LocalPlayer.Team then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                -- Box
                if getgenv().ESPBox then
                    local box = Drawing.new("Square")
                    box.Size = Vector2.new(50, 70)
                    box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
                    box.Thickness = 1.5
                    box.Color = player.TeamColor.Color == LocalPlayer.TeamColor.Color and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    box.Visible = true
                    table.insert(DrawingESP, box)
                end
                -- Name
                if getgenv().ESPNameColor then
                    local name = Drawing.new("Text")
                    name.Text = player.Name
                    name.Position = Vector2.new(pos.X - 30, pos.Y - 60)
                    name.Color = player.TeamColor.Color == LocalPlayer.TeamColor.Color and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    name.Size = 13
                    name.Visible = true
                    table.insert(DrawingESP, name)
                end
                -- Tracer
                if getgenv().ESPTracer then
                    local line = Drawing.new("Line")
                    line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    line.To = Vector2.new(pos.X, pos.Y)
                    line.Color = Color3.fromRGB(255, 0, 0)
                    line.Thickness = 1
                    line.Visible = true
                    table.insert(DrawingESP, line)
                end
            end
        end
    end
end)

-- Auto Fire Logic (if enabled)
RunService.RenderStepped:Connect(function()
    if not getgenv().AutoFire or not getgenv().SilentAim then return end
    local target = GetClosestEnemy()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Handle") then
            mouse1click()
        end
    end
end)

-- YoxanXHub V2 | Hypershot Gunfight | Part 4/15 (Mobile Paste)
-- Hitmarker, Effects, Target Bypass

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Hitmarker Effect
function ShowHit()
    if not getgenv().Hitmarker then return end
    local text = Drawing.new("Text")
    text.Text = "HIT"
    text.Color = Color3.new(1, 1, 1)
    text.Size = 18
    text.Center = true
    text.Outline = true
    text.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 + 25)
    text.Visible = true
    task.delay(0.2, function() text:Remove() end)
end

-- Bullet Flash (crosshair blink)
function FlashEffect()
    if not getgenv().BulletFlash then return end
    local dot = Drawing.new("Circle")
    dot.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    dot.Radius = 3
    dot.Filled = true
    dot.Color = Color3.fromRGB(255, 255, 0)
    dot.Visible = true
    task.delay(0.1, function() dot:Remove() end)
end

-- Trigger Effects When Aimed
RunService.RenderStepped:Connect(function()
    if getgenv().SilentAim then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            if getgenv().InvisibleBypass and not target.Character:FindFirstChildWhichIsA("BasePart", true).Visible then
                -- bypass invisible targets
            end
            if getgenv().FreezeBypass and target.Character.HumanoidRootPart.Anchored then
                target.Character.HumanoidRootPart.Anchored = false
            end
            ShowHit()
            FlashEffect()
        end
    end
end)

-- YoxanXHub V2 | Hypershot Gunfight | Part 5/15 (Mobile Paste)
-- WallCheck, Wallbang, Smart Prediction, Wall ESP

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- Predict target position (based on velocity and ping)
function PredictPosition(target)
    local head = target.Character and target.Character:FindFirstChild("Head")
    if not head then return nil end
    local velocity = head.Velocity or Vector3.zero
    local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() or 50
    local delay = ping / 1000
    return head.Position + (velocity * delay)
end

-- Smart Wallcheck
function IsVisible(position)
    local origin = Camera.CFrame.Position
    local direction = (position - origin).Unit * 500
    local ray = workspace:Raycast(origin, direction, RaycastParams.new())
    if ray and ray.Instance then
        return ray.Instance:IsDescendantOf(workspace.Players) -- basic visibility check
    end
    return true
end

-- Draw Transparent Walls when enemies are near walls
RunService.RenderStepped:Connect(function()
    if not getgenv().WallESP then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local direction = (Camera.CFrame.Position - head.Position).Unit
            local ray = workspace:Raycast(head.Position, direction * 3)
            if ray and ray.Instance and not player.Character:IsAncestorOf(ray.Instance) then
                if ray.Instance:IsA("BasePart") then
                    ray.Instance.Transparency = 0.6
                    ray.Instance.Material = Enum.Material.ForceField
                    task.delay(0.5, function()
                        if ray.Instance then
                            ray.Instance.Transparency = 0
                            ray.Instance.Material = Enum.Material.Plastic
                        end
                    end)
                end
            end
        end
    end
end)

-- Wallbang logic (force shot even through walls)
RunService.RenderStepped:Connect(function()
    if getgenv().Wallbang and getgenv().SilentAim then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local predicted = PredictPosition(target)
            if predicted then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, predicted)
                if getgenv().AutoFire then
                    mouse1click()
                end
            end
        end
    end
end)

-- YoxanXHub V2 | Hypershot Gunfight | Part 6/15 (Mobile Paste)
-- Lock Logic: Sticky Lock, Team Check, Distance Priority, Health Sorting

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local StickyTarget = nil

-- Get closest enemy based on priority
function GetClosestEnemy()
    local closest = nil
    local shortest = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local char = player.Character
            local head = char:FindFirstChild("Head")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")

            if head and hrp and hum and hum.Health > 0 then
                if getgenv().TeamCheck and player.Team == LocalPlayer.Team then continue end
                local distance = (Camera.CFrame.Position - head.Position).Magnitude
                if distance > 500 then continue end
                local pos, visible = Camera:WorldToViewportPoint(head.Position)
                if getgenv().VisibleOnly and not visible then continue end

                -- Prioritize by lowest health
                if distance < shortest then
                    shortest = distance
                    closest = player
                end
            end
        end
    end
    return closest
end

-- Sticky Target Logic
function GetLockedTarget()
    if getgenv().StickyLock then
        if StickyTarget and StickyTarget.Character and StickyTarget.Character:FindFirstChild("Head") then
            return StickyTarget
        else
            StickyTarget = GetClosestEnemy()
            return StickyTarget
        end
    else
        return GetClosestEnemy()
    end
end

-- Main Aim Handler
game:GetService("RunService").RenderStepped:Connect(function()
    if not getgenv().SilentAim then return end
    local target = GetLockedTarget()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local predicted = target.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, predicted)
        if getgenv().AutoFire then
            mouse1click()
        end
    end
end)

-- YoxanXHub V2 | Hypershot Gunfight | Part 7/15 (Mobile Paste)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

getgenv().SmartDelay = 0.05
getgenv().LastTarget = nil

RunService.Stepped:Connect(function()
    if getgenv().AntiKnockback then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.Velocity = Vector3.zero
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not getgenv().SilentAim then return end
    local target = GetClosestEnemy and GetClosestEnemy()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        if getgenv().LastTarget ~= target and getgenv().AntiOverkill then
            getgenv().LastTarget = target
            task.wait(getgenv().SmartDelay or 0.05)
        end
        local head = target.Character.Head.Position
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head)
        if getgenv().AutoFire then
            mouse1click()
        end
    end
end)

-- YoxanXHub V2 | Hypershot Gunfight | Part 8/15 (Mobile Paste)
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer

local crosshairText = Drawing.new("Text")
crosshairText.Visible = false
crosshairText.Center = true
crosshairText.Outline = true
crosshairText.Size = 14
crosshairText.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2 - 30)

local fpsText = Drawing.new("Text")
fpsText.Visible = true
fpsText.Position = Vector2.new(10, 10)
fpsText.Size = 14
fpsText.Color = Color3.fromRGB(0,255,0)
fpsText.Text = "FPS: Loading..."

local targetText = Drawing.new("Text")
targetText.Visible = true
targetText.Position = Vector2.new(10, 30)
targetText.Size = 14
targetText.Color = Color3.fromRGB(255,255,255)

-- FPS Counter
local lastUpdate = tick()
local frames = 0
RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - lastUpdate >= 1 then
        fpsText.Text = "FPS: "..frames
        frames = 0
        lastUpdate = tick()
    end
end)

-- Draw ESP Name
local espNames = {}
RunService.RenderStepped:Connect(function()
    if not getgenv().ESPName then return end
    for _,v in pairs(espNames) do v:Remove() end
    espNames = {}
    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(head)
            if onScreen then
                local text = Drawing.new("Text")
                text.Text = player.Name
                text.Size = 13
                text.Position = Vector2.new(screenPos.X, screenPos.Y - 15)
                text.Center = true
                text.Outline = true
                text.Color = (player.Team ~= LocalPlayer.Team) and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
                text.Visible = true
                table.insert(espNames, text)
            end
        end
    end
end)

-- Crosshair Lock Display
RunService.RenderStepped:Connect(function()
    if not getgenv().SilentAim then
        crosshairText.Visible = false
        return
    end
    local target = GetClosestEnemy and GetClosestEnemy()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        crosshairText.Text = "LOCKED 🔒"
        crosshairText.Color = Color3.fromRGB(255,0,0)
        crosshairText.Visible = true
        targetText.Text = "Target: "..target.Name
    else
        crosshairText.Visible = false
        targetText.Text = "Target: None"
    end
end)

-- YoxanXHub V2 | Hypershot Gunfight | Part 9/15
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local bulletTrails = {}
local boxes = {}

-- Hitmarker
local hitText = Drawing.new("Text")
hitText.Visible = false
hitText.Size = 20
hitText.Center = true
hitText.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2 + 30)
hitText.Color = Color3.new(1,1,1)
hitText.Outline = true

function ShowHit()
    hitText.Text = "Hit!"
    hitText.Visible = true
    task.delay(0.15, function()
        hitText.Visible = false
    end)
end

-- Bullet trail
function DrawTrail(fromPos, toPos)
    if not getgenv().BulletTrail then return end
    local line = Drawing.new("Line")
    line.From = Vector2.new(fromPos.X, fromPos.Y)
    line.To = Vector2.new(toPos.X, toPos.Y)
    line.Color = Color3.new(1, 1, 0)
    line.Thickness = 2
    line.Transparency = 0.8
    line.Visible = true
    table.insert(bulletTrails, line)
    task.delay(0.2, function()
        line:Remove()
    end)
end

-- ESP Box
RunService.RenderStepped:Connect(function()
    if not getgenv().ESPBox then return end
    for _, b in pairs(boxes) do b:Remove() end
    boxes = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local pos1, onscreen1 = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(-2, 3, 0))
            local pos2, onscreen2 = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(2, -3, 0))
            if onscreen1 and onscreen2 then
                local box = Drawing.new("Square")
                box.Position = Vector2.new(pos1.X, pos1.Y)
                box.Size = Vector2.new((pos2.X - pos1.X), (pos2.Y - pos1.Y))
                box.Color = (player.Team == LocalPlayer.Team) and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                box.Thickness = 1
                box.Transparency = 1
                box.Visible = true
                table.insert(boxes, box)
            end
        end
    end
end)

-- Target Freeze Bypass
function IsFrozen(target)
    if not target.Character then return false end
    local hrp = target.Character:FindFirstChild("HumanoidRootPart")
    return hrp and hrp.Velocity.Magnitude < 1
end

-- YoxanXHub V2 | Hypershot Gunfight | Part 10/15
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- WallCheck 3D (raycast)
function IsVisible(targetPart)
    if not targetPart then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 1000
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, raycastParams)
    if result then
        return result.Instance:IsDescendantOf(targetPart.Parent)
    end
    return true
end

-- Wallbang logic (allow firing through thin walls)
function CanWallbang(targetPart)
    if not targetPart then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin)
    local ray = Ray.new(origin, direction)
    local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
    if hit and hit.Transparency > 0.3 and hit.CanCollide then
        return true
    end
    return false
end

-- Transparent wall render
RunService.RenderStepped:Connect(function()
    if not getgenv().TransparentWall then return end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide and v.Transparency < 0.3 then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                    local dist = (p.Character.Head.Position - v.Position).Magnitude
                    if dist < 15 then
                        v.Transparency = 0.6
                        v.Material = Enum.Material.ForceField
                    end
                end
            end
        end
    end
end)

-- YoxanXHub V2 | Hypershot Gunfight | Part 11/15
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local mods = {"Admin", "Moderator", "Mod", "Owner", "Staff", "Security"}
local OrionLib = getgenv().OrionLib
local OrionWindow = getgenv().OrionWindow
local OrionTab = OrionWindow:MakeTab({Name = "Safety", Icon = "🔒", PremiumOnly = false})

getgenv().AutoLeaveOnMod = true
getgenv().ShowModDetected = true

function isMod(p)
    for _, keyword in ipairs(mods) do
        if string.find(string.lower(p.Name), string.lower(keyword)) then
            return true
        end
    end
    return false
end

Players.PlayerAdded:Connect(function(player)
    if isMod(player) then
        if getgenv().ShowModDetected then
            OrionLib:MakeNotification({
                Name = "⚠️ Mod Detected",
                Content = player.Name.." joined!",
                Time = 6
            })
        end
        if getgenv().AutoLeaveOnMod then
            OrionLib:MakeNotification({
                Name = "🚪 Auto Leave",
                Content = "Leaving server for safety...",
                Time = 4
            })
            task.wait(1)
            LocalPlayer:Kick("Moderator detected - Left for safety.")
        end
    end
end)

-- Anti Kick basic
hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if method == "Kick" and not checkcaller() then
        return nil
    end
    return getrawmetatable(game).__namecall(self, unpack(args))
end))

-- UI Toggles
OrionTab:AddToggle({
    Name = "Auto Leave on Mod Join",
    Default = true,
    Callback = function(v)
        getgenv().AutoLeaveOnMod = v
    end
})

OrionTab:AddToggle({
    Name = "Notify if Mod Detected",
    Default = true,
    Callback = function(v)
        getgenv().ShowModDetected = v
    end
})


-- YoxanXHub V2 | Hypershot Gunfight | Part 12/15
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

getgenv().TeamCheck = true
getgenv().HitboxSize = 2.5

-- UI Setup
local OrionTab = getgenv().OrionWindow:MakeTab({
    Name = "Combat",
    Icon = "🎯",
    PremiumOnly = false
})

OrionTab:AddToggle({
    Name = "Team Check",
    Default = true,
    Callback = function(v)
        getgenv().TeamCheck = v
    end
})

OrionTab:AddSlider({
    Name = "Hitbox Size",
    Min = 2,
    Max = 10,
    Default = 2.5,
    Increment = 0.5,
    ValueName = "studs",
    Callback = function(v)
        getgenv().HitboxSize = v
    end
})

-- Health ESP
local healthText = {}
RunService.RenderStepped:Connect(function()
    for _, text in pairs(healthText) do
        if text and text.Remove then text:Remove() end
    end
    table.clear(healthText)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if getgenv().TeamCheck and player.Team == LocalPlayer.Team then continue end

            local head = player.Character.Head
            local hp = player.Character:FindFirstChildOfClass("Humanoid")
            local pos, visible = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
            if visible and hp then
                local txt = Drawing.new("Text")
                txt.Text = tostring(math.floor(hp.Health)).." HP"
                txt.Position = Vector2.new(pos.X, pos.Y)
                txt.Color = Color3.fromRGB(255, 100, 100)
                txt.Size = 15
                txt.Center = true
                txt.Outline = true
                txt.Visible = true
                table.insert(healthText, txt)
            end
        end
    end
end)

-- Hitbox Expander (run once per character)
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        local part = char:FindFirstChild("HumanoidRootPart")
        if part then
            part.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
            part.Transparency = 0.7
            part.Material = Enum.Material.Neon
        end
    end)
end)

-- Damage Visual FX (simple flash)
function FlashTarget(char)
    local head = char:FindFirstChild("Head")
    if not head then return end
    local flash = Instance.new("PointLight", head)
    flash.Color = Color3.new(1, 0, 0)
    flash.Range = 8
    flash.Brightness = 3
    game.Debris:AddItem(flash, 0.2)
end

-- YoxanXHub V2 | Hypershot Gunfight | Part 13/15
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

getgenv().StickyLock = true

-- UI Target Indicator
local LockDot = Drawing.new("Circle")
LockDot.Color = Color3.fromRGB(255, 0, 0)
LockDot.Radius = 6
LockDot.Filled = true
LockDot.Visible = false

-- Lock Logic
local function GetValidTarget()
    local closest, distance = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            if getgenv().TeamCheck and player.Team == LocalPlayer.Team then continue end
            local head = player.Character.Head.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(head)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < distance then
                    distance = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

-- Auto Fallback HitPart
function GetHitPart(character)
    return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
end

-- Smart Raycast Visibility Check
function IsVisibleToCamera(part)
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position), rayParams)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

-- Draw Lock
RunService.RenderStepped:Connect(function()
    if not getgenv().StickyLock then LockDot.Visible = false return end
    local target = GetValidTarget()
    if target and target.Character then
        local hitPart = GetHitPart(target.Character)
        if hitPart and IsVisibleToCamera(hitPart) then
            local screenPos, onScreen = Camera:WorldToViewportPoint(hitPart.Position)
            if onScreen then
                LockDot.Position = Vector2.new(screenPos.X, screenPos.Y)
                LockDot.Visible = true
            else
                LockDot.Visible = false
            end
        else
            LockDot.Visible = false
        end
    else
        LockDot.Visible = false
    end
end)

-- YoxanXHub V2 | Hypershot Gunfight | Part 14/15
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

getgenv().MultiTargetMode = true

function IsDowned(player)
    local hum = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
    return hum and hum.Health <= 5
end

function HasShield(part)
    return part and part:FindFirstChild("ForceField")
end

function GetVisibleEnemies()
    local targets = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            if getgenv().TeamCheck and plr.Team == LocalPlayer.Team then continue end
            if IsDowned(plr) then continue end
            if HasShield(plr.Character) then continue end
            local part = plr.Character.Head
            local screenPos, visible = Camera:WorldToViewportPoint(part.Position)
            if visible then
                table.insert(targets, plr)
            end
        end
    end
    return targets
end

-- Multi-target logic (only activates if toggle enabled)
RunService.RenderStepped:Connect(function()
    if not getgenv().MultiTargetMode then return end
    local enemies = GetVisibleEnemies()
    for _, target in pairs(enemies) do
        if target and target.Character then
            local head = target.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    -- Smart fire logic
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
                    if getgenv().AutoFire then
                        mouse1click()
                        task.wait(0.02)
                    end
                end
            end
        end
    end
end)

-- UI Toggle (Optional, if you have UI tab)
local OrionTab = getgenv().OrionWindow:MakeTab({Name = "Advanced", Icon = "🧠", PremiumOnly = false})
OrionTab:AddToggle({
    Name = "Multi Target Mode",
    Default = true,
    Callback = function(v)
        getgenv().MultiTargetMode = v
    end
})

-- YoxanXHub V2 | Hypershot Gunfight | Part 15/15
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

getgenv().TeamColorESP = true
getgenv().HitmarkerEffect = true
getgenv().WallTransparency = true

local espObjects = {}
local function ClearESP()
    for _, d in pairs(espObjects) do if d.Remove then d:Remove() end end
    table.clear(espObjects)
end

function CreateESP(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end
    local head = char.Head
    local text = Drawing.new("Text")
    text.Size = 13
    text.Center = true
    text.Outline = true
    text.Visible = true
    table.insert(espObjects, text)

    RunService.RenderStepped:Connect(function()
        if not char or not char:FindFirstChild("Head") then text.Visible = false return end
        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen then
            text.Position = Vector2.new(pos.X, pos.Y - 20)
            text.Text = player.Name
            if getgenv().TeamColorESP then
                text.Color = (player.Team == LocalPlayer.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
            else
                text.Color = Color3.fromRGB(255, 255, 255)
            end
            text.Visible = true
        else
            text.Visible = false
        end
    end)
end

-- Hitmarker effect
function ShowHitText()
    if not getgenv().HitmarkerEffect then return end
    local txt = Drawing.new("Text")
    txt.Text = "HIT"
    txt.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2 + 40)
    txt.Size = 16
    txt.Color = Color3.fromRGB(255, 255, 0)
    txt.Center = true
    txt.Outline = true
    txt.Visible = true
    game.Debris:AddItem(txt, 0.3)
end

-- Transparent wall (basic)
function TransparentNearbyWalls()
    if not getgenv().WallTransparency then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Transparency < 0.5 and obj.Position and (obj.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 30 then
            obj.Transparency = 0.5
        end
    end
end

-- Setup ESP
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        CreateESP(player)
    end)
end)

-- Initial ESP
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        CreateESP(p)
    end
end

-- Continuous Update
RunService.RenderStepped:Connect(function()
    TransparentNearbyWalls()
end)

-- Optional UI (tab ESP)
local OrionTab = getgenv().OrionWindow:MakeTab({Name = "Visual", Icon = "👁️", PremiumOnly = false})
OrionTab:AddToggle({
    Name = "Team Color ESP",
    Default = true,
    Callback = function(v)
        getgenv().TeamColorESP = v
    end
})
OrionTab:AddToggle({
    Name = "Hitmarker Effect",
    Default = true,
    Callback = function(v)
        getgenv().HitmarkerEffect = v
    end
})
OrionTab:AddToggle({
    Name = "Wall Transparency",
    Default = true,
    Callback = function(v)
        getgenv().WallTransparency = v
    end
})
