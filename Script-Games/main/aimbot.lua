-- SERVICES
local Players = game:GetService("Players")
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

local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Drawing = Drawing

-- ================= COMBAT SETTINGS =================
local Combat = {
    AimHead = false,
    AimBody = false,
    POV = false,
    ShowCircle = false,
    POVRadius = 150,
    Priority = "Crosshair", -- Crosshair / Distance / Health
    Smoothness = 0.15
}

-- ================= POV CIRCLE (VISUAL) =================
local POVCircle = Drawing.new("Circle")
POVCircle.Visible = false
POVCircle.Color = Color3.fromRGB(255,255,255)
POVCircle.Thickness = 1
POVCircle.NumSides = 100
POVCircle.Filled = false
POVCircle.Transparency = 1
POVCircle.Radius = Combat.POVRadius

-- ================= TARGET SELECT =================
local function GetTarget()
    local bestTarget
    local bestValue = math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and IsEnemy(p) and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local part =
                Combat.AimHead and p.Character:FindFirstChild("Head")
                or Combat.AimBody and p.Character:FindFirstChild("HumanoidRootPart")

            if hum and part and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if not Combat.POV or screenDist <= Combat.POVRadius then
                        local value
                        if Combat.Priority == "Crosshair" then
                            value = screenDist
                        elseif Combat.Priority == "Distance" then
                            value = (part.Position - Camera.CFrame.Position).Magnitude
                        elseif Combat.Priority == "Health" then
                            value = hum.Health
                        end

                        if value < bestValue then
                            bestValue = value
                            bestTarget = part
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

-- ================= AIM LOOP =================
RunService.RenderStepped:Connect(function()
    if not (Combat.AimHead or Combat.AimBody) then return end

    local target = GetTarget()
    if target then
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(Camera.CFrame.Position, target.Position),
            Combat.Smoothness
        )
    end
end)

-- ================= POV UPDATE =================
RunService.RenderStepped:Connect(function()
    POVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    POVCircle.Radius = Combat.POVRadius
    POVCircle.Visible = Combat.ShowCircle and Combat.POV
end)

-- ================= UI COMBAT =================
CombatTab:CreateToggle({
    Name = "Aim Head",
    Callback = function(v)
        Combat.AimHead = v
        if v then Combat.AimBody = false end
    end
})

CombatTab:CreateToggle({
    Name = "Aim Body",
    Callback = function(v)
        Combat.AimBody = v
        if v then Combat.AimHead = false end
    end
})

CombatTab:CreateToggle({
    Name = "Enable POV (FOV)",
    Callback = function(v)
        Combat.POV = v
    end
})

CombatTab:CreateToggle({
    Name = "Show POV Circle",
    Callback = function(v)
        Combat.ShowCircle = v
    end
})

CombatTab:CreateSlider({
    Name = "POV Radius",
    Range = {50, 350},
    Increment = 10,
    CurrentValue = 150,
    Callback = function(v)
        Combat.POVRadius = v
    end
})

CombatTab:CreateDropdown({
    Name = "Target Priority",
    Options = {"Crosshair", "Distance", "Health"},
    CurrentOption = "Crosshair",
    Callback = function(v)
        Combat.Priority = v
    end
})

