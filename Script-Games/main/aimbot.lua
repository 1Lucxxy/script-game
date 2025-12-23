-- SERVICES
local Players = game:GetService("Players")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Delta Visual FINAL",
    LoadingTitle = "Stable Visual",
    LoadingSubtitle = "by dafaaa",
    ConfigurationSaving = { Enabled = false }
})

local VisualTab = Window:CreateTab("Visual", 4483362458)

-- SETTINGS (MASTER)
local Settings = {
    Enabled = false,
    TeamCheck = true,
    ShowName = true,
    ShowDistance = true,
    Color = Color3.fromRGB(255, 0, 0)
}

-- CACHE
local Cache = {}

-- ================= UTILS =================

local function IsEnemy(p)
    if not Settings.TeamCheck then return true end
    if not p.Team or not LocalPlayer.Team then return true end
    return p.Team ~= LocalPlayer.Team
end

local function ClearESP(p)
    if Cache[p] then
        if Cache[p].Loop then
            task.cancel(Cache[p].Loop)
        end
        for _,obj in pairs(Cache[p]) do
            if typeof(obj) == "Instance" then
                obj:Destroy()
            end
        end
        Cache[p] = nil
    end
end

local function ClearAll()
    for _,p in pairs(Players:GetPlayers()) do
        ClearESP(p)
    end
end

-- ================= APPLY ESP =================

local function ApplyESP(p)
    if not Settings.Enabled then return end
    if p == LocalPlayer then return end
    if not IsEnemy(p) then return end
    if not p.Character then return end

    ClearESP(p)
    Cache[p] = {}

    local char = p.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    -- HIGHLIGHT (STABLE)
    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.Parent = CoreGui
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.OutlineTransparency = 1
    hl.FillColor = Settings.Color
    hl.FillTransparency = 0.8
    Cache[p].Highlight = hl

    -- BILLBOARD
    local gui = Instance.new("BillboardGui")
    gui.Adornee = hrp
    gui.Size = UDim2.fromScale(5, 1.4)
    gui.StudsOffset = Vector3.new(0, 3.6, 0)
    gui.AlwaysOnTop = true
    gui.Parent = CoreGui
    Cache[p].Billboard = gui

    local txt = Instance.new("TextLabel")
    txt.BackgroundTransparency = 1
    txt.Size = UDim2.fromScale(1, 1)
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    txt.TextStrokeTransparency = 0
    txt.TextColor3 = Settings.Color
    txt.Parent = gui
    Cache[p].Text = txt

    -- LOOP (MASTER SAFE)
    Cache[p].Loop = task.spawn(function()
        while Settings.Enabled and hum.Health > 0 do
            if not Settings.Enabled or not IsEnemy(p) then
                break
            end

            local dist = math.floor(
                (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            )

            txt.Text =
                (Settings.ShowName and p.Name or "") ..
                (Settings.ShowDistance and ("\n[" .. dist .. "m]") or "")

            task.wait(0.25)
        end
        ClearESP(p)
    end)
end

-- ================= PLAYER HANDLER =================

local function SetupPlayer(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.4)
        if Settings.Enabled then
            ApplyESP(p)
        end
    end)

    if p.Character and Settings.Enabled then
        ApplyESP(p)
    end
end

for _,p in pairs(Players:GetPlayers()) do
    SetupPlayer(p)
end

Players.PlayerAdded:Connect(SetupPlayer)
Players.PlayerRemoving:Connect(function(p)
    ClearESP(p)
end)

-- ================= UI =================

VisualTab:CreateToggle({
    Name = "Enable Highlight (MASTER)",
    Callback = function(v)
        Settings.Enabled = v
        ClearAll()
        if v then
            for _,p in pairs(Players:GetPlayers()) do
                ApplyESP(p)
            end
        end
    end
})

VisualTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(v)
        Settings.TeamCheck = v
        if Settings.Enabled then
            ClearAll()
            for _,p in pairs(Players:GetPlayers()) do
                ApplyESP(p)
            end
        end
    end
})

VisualTab:CreateToggle({
    Name = "Show Name",
    CurrentValue = true,
    Callback = function(v)
        Settings.ShowName = v
    end
})

VisualTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Callback = function(v)
        Settings.ShowDistance = v
    end
})

VisualTab:CreateColorPicker({
    Name = "Highlight Color",
    Color = Settings.Color,
    Callback = function(c)
        Settings.Color = c
        for _,data in pairs(Cache) do
            if data.Highlight then
                data.Highlight.FillColor = c
            end
            if data.Text then
                data.Text.TextColor3 = c
            end
        end
    end
})

-- 🔄 REFRESH BUTTON
VisualTab:CreateButton({
    Name = "Refresh Highlight",
    Callback = function()
        if not Settings.Enabled then return end
        ClearAll()
        for _,p in pairs(Players:GetPlayers()) do
            ApplyESP(p)
        end
    end
})

-- ================= COMBAT TAB =================
local CombatTab = Window:CreateTab("Combat", 4483362458)

local Combat = {
    AimHead = false,
    AimBody = false,
    POV = false,
    ShowCircle = false,
    Radius = 150,
    Priority = "Crosshair",
    Smooth = 0.15,
    TeamCheck = false
}

-- ================= POV CIRCLE =================
local Circle = Drawing.new("Circle")
Circle.Visible = false
Circle.Filled = false
Circle.Thickness = 1
Circle.NumSides = 64
Circle.Color = Color3.fromRGB(255,255,255)
Circle.Transparency = 1

-- ================= TEAM CHECK =================
local function IsValidTarget(plr)
    if plr == LocalPlayer then return false end
    if Combat.TeamCheck and plr.Team == LocalPlayer.Team then return false end
    return true
end

-- ================= GET TARGET =================
local function GetTarget()
    local best, bestVal = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _,plr in ipairs(Players:GetPlayers()) do
        if IsValidTarget(plr) and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local part =
                Combat.AimHead and plr.Character:FindFirstChild("Head") or
                Combat.AimBody and plr.Character:FindFirstChild("HumanoidRootPart")

            if hum and part and hum.Health > 0 then
                local pos, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    local dist = (Vector2.new(pos.X,pos.Y) - center).Magnitude
                    if not Combat.POV or dist <= Combat.Radius then
                        local val = Combat.Priority == "Crosshair" and dist
                            or Combat.Priority == "Distance" and
                            (part.Position - Camera.CFrame.Position).Magnitude
                            or hum.Health

                        if val < bestVal then
                            bestVal = val
                            best = part
                        end
                    end
                end
            end
        end
    end

    return best
end

-- ================= AIM LOOP =================
RunService.RenderStepped:Connect(function()
    if not (Combat.AimHead or Combat.AimBody) then return end
    local target = GetTarget()
    if target then
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(Camera.CFrame.Position, target.Position),
            Combat.Smooth
        )
    end
end)

-- ================= POV UPDATE =================
RunService.RenderStepped:Connect(function()
    Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    Circle.Radius = Combat.Radius
    Circle.Visible = Combat.ShowCircle and Combat.POV
end)
