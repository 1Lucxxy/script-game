-- SERVICES
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- RAYFIELD
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Delta Visual MAX",
    LoadingTitle = "Visual Loading",
    LoadingSubtitle = "by dafaaa",
    ConfigurationSaving = { Enabled = false }
})

local VisualTab = Window:CreateTab("Visual", 4483362458)

-- SETTINGS
local Settings = {
    Enabled = false,
    TeamCheck = true,

    ShowName = true,
    ShowDistance = true,
    Highlight = true,
    Box = true,
    Line = true,

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
        for _,obj in pairs(Cache[p]) do
            if typeof(obj) == "RBXScriptConnection" then
                obj:Disconnect()
            elseif typeof(obj) == "Instance" then
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
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not hrp or not hum or not myHRP or hum.Health <= 0 then return end

    -- 🔴 HIGHLIGHT BODY
    if Settings.Highlight then
        local hl = Instance.new("Highlight")
        hl.Adornee = char
        hl.Parent = CoreGui
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillColor = Settings.Color
        hl.FillTransparency = 0.8
        hl.OutlineTransparency = 1
        Cache[p].Highlight = hl
    end

    -- 📦 BOX (3D)
    if Settings.Box then
        local box = Instance.new("SelectionBox")
        box.Adornee = char
        box.Color3 = Settings.Color
        box.LineThickness = 0.05
        box.SurfaceTransparency = 1
        box.Parent = CoreGui
        Cache[p].Box = box
    end

    -- 📏 LINE (3D BEAM)
    if Settings.Line then
        local att0 = Instance.new("Attachment", myHRP)
        local att1 = Instance.new("Attachment", hrp)

        local beam = Instance.new("Beam")
        beam.Attachment0 = att0
        beam.Attachment1 = att1
        beam.Width0 = 0.1
        beam.Width1 = 0.1
        beam.Color = ColorSequence.new(Settings.Color)
        beam.FaceCamera = true
        beam.Parent = CoreGui

        Cache[p].Beam = beam
        Cache[p].Att0 = att0
        Cache[p].Att1 = att1
    end

    -- 🏷️ NAME + DISTANCE
    local gui = Instance.new("BillboardGui")
    gui.Adornee = hrp
    gui.Size = UDim2.fromScale(5, 2)
    gui.StudsOffset = Vector3.new(0, 4, 0)
    gui.AlwaysOnTop = true
    gui.Parent = CoreGui
    Cache[p].Gui = gui

    local txt = Instance.new("TextLabel")
    txt.BackgroundTransparency = 1
    txt.Size = UDim2.fromScale(1, 1)
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBlack
    txt.TextStrokeTransparency = 0
    txt.TextColor3 = Settings.Color
    txt.Parent = gui
    Cache[p].Text = txt

    Cache[p].Loop = task.spawn(function()
        while Settings.Enabled and hum.Health > 0 do
            if not IsEnemy(p) then break end

            local dist = math.floor((myHRP.Position - hrp.Position).Magnitude)
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
Players.PlayerRemoving:Connect(ClearESP)

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

VisualTab:CreateToggle({ Name = "Body Highlight", CurrentValue = true, Callback = function(v) Settings.Highlight = v end })
VisualTab:CreateToggle({ Name = "Box Highlight", CurrentValue = true, Callback = function(v) Settings.Box = v end })
VisualTab:CreateToggle({ Name = "Line (Beam)", CurrentValue = true, Callback = function(v) Settings.Line = v end })

VisualTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Settings.Color,
    Callback = function(c)
        Settings.Color = c
        ClearAll()
        if Settings.Enabled then
            for _,p in pairs(Players:GetPlayers()) do
                ApplyESP(p)
            end
        end
    end
})

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
