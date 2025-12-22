--==================================
-- RAYFIELD LOAD
--==================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--==================================
-- SERVICES
--==================================
local Players = game:GetService("Players")
local TeamsService = game:GetService("Teams")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--==================================
-- WINDOW & TABS
--==================================
local Window = Rayfield:CreateWindow({
    Name = "ESP Highlight (Ultimate)",
    LoadingTitle = "ESP System",
    LoadingSubtitle = "Final Stable Version",
    ConfigurationSaving = { Enabled = false }
})

local ESPTab    = Window:CreateTab("ESP", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local MiscTab   = Window:CreateTab("Misc", 4483362458)

--==================================
-- HIGHLIGHT SYSTEM (CATEGORY SAFE)
--==================================
local Highlights = {} -- [instance] = {highlight, category}

local function addHighlight(obj, color, category)
    if not obj or Highlights[obj] then return end
    local h = Instance.new("Highlight")
    h.Adornee = obj
    h.FillColor = color
    h.FillTransparency = 0.8
    h.OutlineTransparency = 1
    h.Parent = obj
    Highlights[obj] = {highlight = h, category = category}
end

local function removeCategory(category)
    for obj,data in pairs(Highlights) do
        if data.category == category then
            data.highlight:Destroy()
            Highlights[obj] = nil
        end
    end
end

--==================================
-- PLAYER ESP (SURVIVOR & KILLER)
--==================================
local PlayerESPEnabled = false

local function updatePlayers()
    if not PlayerESPEnabled then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer
        and plr.Team
        and plr.Character
        and plr.Character:FindFirstChild("HumanoidRootPart") then
            local t = string.lower(plr.Team.Name)
            if t == "killer" then
                addHighlight(plr.Character, Color3.fromRGB(255,0,0), "Player")
            elseif t == "survivors" then
                addHighlight(plr.Character, Color3.fromRGB(0,255,0), "Player")
            end
        end
    end
end

task.spawn(function()
    while task.wait(1) do
        updatePlayers()
    end
end)

ESPTab:CreateToggle({
    Name = "Highlight Survivor & Killer",
    Callback = function(v)
        PlayerESPEnabled = v
        if not v then removeCategory("Player") end
    end
})

--==================================
-- OBJECT ESP
--==================================
local ObjectESPEnabled = {
    Generator=false,
    Hook=false,
    Window=false,
    Gift=false
}

local ObjectColors = {
    Generator = Color3.fromRGB(255,255,0),
    Hook      = Color3.fromRGB(255,0,255),
    Window    = Color3.fromRGB(0,170,255),
    Gift      = Color3.fromRGB(255,140,0)
}

local function scanObjects()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and ObjectESPEnabled[v.Name] then
            addHighlight(v, ObjectColors[v.Name], v.Name)
        end
    end
end

for name,_ in pairs(ObjectESPEnabled) do
    ESPTab:CreateToggle({
        Name = "Highlight "..name,
        Callback = function(v)
            ObjectESPEnabled[name] = v
            if v then scanObjects() else removeCategory(name) end
        end
    })
end

workspace.DescendantAdded:Connect(function(v)
    if v:IsA("Model") and ObjectESPEnabled[v.Name] then
        addHighlight(v, ObjectColors[v.Name], v.Name)
    end
end)

--==================================
-- CROSSHAIR DOT
--==================================
local CrosshairEnabled = false
local Crosshair = Drawing.new("Circle")
Crosshair.Radius = 2
Crosshair.Filled = true
Crosshair.Thickness = 1
Crosshair.Color = Color3.fromRGB(255,255,255)
Crosshair.Visible = false

ESPTab:CreateToggle({
    Name="Crosshair Dot",
    Callback=function(v)
        CrosshairEnabled = v
        Crosshair.Visible = v
    end
})

RunService.RenderStepped:Connect(function()
    if CrosshairEnabled then
        Crosshair.Position = Vector2.new(
            Camera.ViewportSize.X/2,
            Camera.ViewportSize.Y/2
        )
    end
end)

--==================================
-- PLAYER TAB : WALKSPEED TOGGLE
--==================================
local WalkSpeedEnabled = false

PlayerTab:CreateToggle({
    Name = "WalkSpeed (64)",
    Callback = function(v)
        WalkSpeedEnabled = v
    end
})

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = WalkSpeedEnabled and 64 or 16
    end
end)

--==================================
-- PLAYER TAB : INVISIBLE (NON-VISUAL)
--==================================
local InvisibleManual = false
local InvisibleAuto = false
local AutoInvisibleEnabled = false
local KillerDistance = 25

local function applyInvisible()
    local char = LocalPlayer.Character
    if not char then return end
    local state = InvisibleManual or InvisibleAuto
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = not state
        end
    end
end

PlayerTab:CreateToggle({
    Name="Invisible (Logic Only)",
    Callback=function(v)
        InvisibleManual = v
        applyInvisible()
    end
})

PlayerTab:CreateToggle({
    Name="Auto Invisible (Killer Near)",
    Callback=function(v)
        AutoInvisibleEnabled = v
        if not v then
            InvisibleAuto = false
            applyInvisible()
        end
    end
})

task.spawn(function()
    while task.wait(0.4) do
        if not AutoInvisibleEnabled then continue end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local near = false
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer
            and plr.Team
            and string.lower(plr.Team.Name) == "killer"
            and plr.Character
            and plr.Character:FindFirstChild("HumanoidRootPart") then
                if (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude <= KillerDistance then
                    near = true
                    break
                end
            end
        end

        if near ~= InvisibleAuto then
            InvisibleAuto = near
            applyInvisible()
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyInvisible()
end)

--==================================
-- MISC : CEK TEAM MAP
--==================================
MiscTab:CreateButton({
    Name="Cek Team (Map)",
    Callback=function()
        local result = "Team di map:\n"
        local teams = TeamsService:GetTeams()
        if #teams == 0 then
            result = "Tidak ada TeamService"
        else
            for _,t in ipairs(teams) do
                local c = 0
                for _,p in ipairs(Players:GetPlayers()) do
                    if p.Team == t then c += 1 end
                end
                result ..= "- "..t.Name.." : "..c.." player\n"
            end
        end
        Rayfield:Notify({Title="Cek Team", Content=result, Duration=8})
    end
})
