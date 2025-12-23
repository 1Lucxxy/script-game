-- SERVICES
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- RAYFIELD
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Delta Visual FIX",
    LoadingTitle = "Stable Visual",
    LoadingSubtitle = "by dafaaa",
    ConfigurationSaving = { Enabled = false }
})

local VisualTab = Window:CreateTab("Visual", 4483362458)

-- SETTINGS
local Settings = {
    Enabled = false,
    TeamCheck = true,
    Color = Color3.fromRGB(255,0,0),
    ShowName = true,
    ShowDistance = true
}

-- CACHE
local Cache = {}

-- UTILS
local function IsEnemy(p)
    if not Settings.TeamCheck then return true end
    if not p.Team or not LocalPlayer.Team then return true end
    return p.Team ~= LocalPlayer.Team
end

local function ClearESP(p)
    if Cache[p] then
        for _,obj in pairs(Cache[p]) do
            if typeof(obj) == "Instance" then
                obj:Destroy()
            end
        end
        Cache[p] = nil
    end
end

-- APPLY ESP
local function ApplyESP(p)
    if p == LocalPlayer then return end
    if not Settings.Enabled then return end
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
    Cache[p].Highlight = hl

    -- BILLBOARD
    local gui = Instance.new("BillboardGui")
    gui.Adornee = hrp
    gui.Size = UDim2.fromScale(4,1)
    gui.StudsOffset = Vector3.new(0,3,0)
    gui.AlwaysOnTop = true
    gui.Parent = CoreGui
    Cache[p].Billboard = gui

    local txt = Instance.new("TextLabel")
    txt.BackgroundTransparency = 1
    txt.Size = UDim2.fromScale(1,1)
    txt.TextScaled = true
    txt.Font = Enum.Font.GothamBold
    txt.TextStrokeTransparency = 0
    txt.TextColor3 = Settings.Color
    txt.Parent = gui
    Cache[p].Text = txt

    -- UPDATE LOOP
    task.spawn(function()
        while Settings.Enabled and hum.Health > 0 do
            if not IsEnemy(p) then
                ClearESP(p)
                break
            end

            local dist = math.floor(
                (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            )

            txt.Text =
                (Settings.ShowName and p.Name or "") ..
                (Settings.ShowDistance and ("\n["..dist.."m]") or "")

            task.wait(0.25)
        end
        ClearESP(p)
    end)
end

-- PLAYER HANDLER
local function SetupPlayer(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        ApplyESP(p)
    end)
    if p.Character then
        ApplyESP(p)
    end
end

for _,p in pairs(Players:GetPlayers()) do
    SetupPlayer(p)
end

Players.PlayerRemoving:Connect(function(p)
    ClearESP(p)
end)

-- UI
VisualTab:CreateToggle({
    Name = "Enable Highlight",
    Callback = function(v)
        Settings.Enabled = v
        for _,p in pairs(Players:GetPlayers()) do
            ClearESP(p)
            if v then ApplyESP(p) end
        end
    end
})

VisualTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(v)
        Settings.TeamCheck = v
        for _,p in pairs(Players:GetPlayers()) do
            ClearESP(p)
            ApplyESP(p)
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
