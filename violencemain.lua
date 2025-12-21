--==================================================
-- RAYFIELD UI
--==================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

--==================================================
-- SERVICES
--==================================================
local Players = game:GetService("Players")
local TeamsService = game:GetService("Teams")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--==================================================
-- WINDOW & TABS
--==================================================
local Window = Rayfield:CreateWindow({
    Name = "ESP + Misc (FINAL)",
    LoadingTitle = "Loading",
    LoadingSubtitle = "Full Version",
    ConfigurationSaving = { Enabled = false }
})
local ESPTab  = Window:CreateTab("ESP", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

--==================================================
-- HIGHLIGHT CORE (FULL COLOR, NO OUTLINE)
--==================================================
local Highlights = {}
local function addHighlight(obj, color)
    if not obj or Highlights[obj] then return end
    local h = Instance.new("Highlight")
    h.Adornee = obj
    h.FillColor = color
    h.FillTransparency = 0.8
    h.OutlineTransparency = 1
    h.Parent = obj
    Highlights[obj] = h
end
local function clearHighlights()
    for _,h in pairs(Highlights) do if h then h:Destroy() end end
    table.clear(Highlights)
end

--==================================================
-- PLAYER ESP (TEAM BASED)
--==================================================
local PlayerESPEnabled = false
local function updatePlayers()
    if not PlayerESPEnabled then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Team and plr.Character
        and plr.Character:FindFirstChild("HumanoidRootPart") then
            local t = string.lower(plr.Team.Name)
            if t == "killer" then
                addHighlight(plr.Character, Color3.fromRGB(255,0,0))
            elseif t == "survivors" then
                addHighlight(plr.Character, Color3.fromRGB(0,255,0))
            end
        end
    end
end
task.spawn(function()
    while task.wait(1) do updatePlayers() end
end)
ESPTab:CreateToggle({
    Name = "ESP Survivor & Killer",
    Callback = function(v)
        PlayerESPEnabled = v
        if not v then clearHighlights() end
    end
})

--==================================================
-- OBJECT CACHE (ANTI LAG)
--==================================================
local ModelCache = { Generator={}, Hook={}, Window={}, Gift={} }
for _,v in ipairs(workspace:GetDescendants()) do
    if v:IsA("Model") and ModelCache[v.Name] then
        table.insert(ModelCache[v.Name], v)
    end
end
local function highlightCached(name, color)
    for _,m in ipairs(ModelCache[name]) do addHighlight(m, color) end
end
ESPTab:CreateToggle({ Name="Generator", Callback=function(v)
    if v then highlightCached("Generator", Color3.fromRGB(255,255,0)) else clearHighlights() end
end})
ESPTab:CreateToggle({ Name="Hook", Callback=function(v)
    if v then highlightCached("Hook", Color3.fromRGB(255,0,255)) else clearHighlights() end
end})
ESPTab:CreateToggle({ Name="Window", Callback=function(v)
    if v then highlightCached("Window", Color3.fromRGB(0,170,255)) else clearHighlights() end
end})
ESPTab:CreateToggle({ Name="Event (Gift)", Callback=function(v)
    if v then highlightCached("Gift", Color3.fromRGB(255,165,0)) else clearHighlights() end
end})

--==================================================
-- CROSSHAIR DOT
--==================================================
local CrosshairEnabled = false
local Crosshair = Drawing.new("Circle")
Crosshair.Radius = 2
Crosshair.Filled = true
Crosshair.Color = Color3.fromRGB(255,255,255)
Crosshair.Visible = false
ESPTab:CreateToggle({
    Name="Crosshair Dot",
    Callback=function(v) CrosshairEnabled=v; Crosshair.Visible=v end
})
RunService.RenderStepped:Connect(function()
    if CrosshairEnabled then
        Crosshair.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
end)

--==================================================
-- MISC : CEK TEAM MAP
--==================================================
MiscTab:CreateButton({
    Name="Cek Team Map",
    Callback=function()
        local txt="Team di map:\n"
        for _,t in ipairs(TeamsService:GetTeams()) do
            local c=0
            for _,p in ipairs(Players:GetPlayers()) do if p.Team==t then c+=1 end end
            txt..="- "..t.Name.." : "..c.." player\n"
        end
        Rayfield:Notify({Title="Team Map",Content=txt,Duration=8})
        print(txt)
    end
})

--==================================================
-- MISC : CEK MODEL SEKITAR (5 STUDS)
--==================================================
MiscTab:CreateButton({
    Name="Cek Model Sekitar (5 studs)",
    Callback=function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local found, txt = {}, "Model sekitar:\n"
        for _,v in ipairs(workspace:GetDescendants()) do
            if v:IsA("Model") and v.PrimaryPart then
                if (v.PrimaryPart.Position-hrp.Position).Magnitude<=5 and not found[v.Name] then
                    found[v.Name]=true; txt..="- "..v.Name.."\n"
                end
            end
        end
        Rayfield:Notify({Title="Model Nearby",Content=txt,Duration=8})
        print(txt)
    end
})

--==================================================
-- MISC : LEG KORBLOX REAL (ASSET 139607718)
--==================================================
local KorbloxEnabled = false
local KorbloxMeshId = "rbxassetid://139607718"
local KorbloxPartName = "__KORBLOX_REAL_LEG__"

local function removeKorblox(char)
    for _,v in ipairs(char:GetChildren()) do
        if v.Name==KorbloxPartName then v:Destroy() end
    end
end
local function hideLeg(leg, hide)
    leg.Transparency = hide and 1 or 0
    for _,v in ipairs(leg:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("MeshPart") then
            v.Transparency = hide and 1 or 0
        end
    end
end
local function applyKorblox(char)
    if not char then return end
    removeKorblox(char)
    local leg = char:FindFirstChild("RightLowerLeg")
        or char:FindFirstChild("RightUpperLeg")
        or char:FindFirstChild("Right Leg")
    if not leg then return end
    hideLeg(leg, true)

    local part = Instance.new("Part")
    part.Name = KorbloxPartName
    part.Size = Vector3.new(1,2.4,1)
    part.CanCollide=false; part.Massless=true; part.Anchored=false
    part.CFrame = leg.CFrame * CFrame.new(0,-0.05,0)
    part.Parent = char

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = KorbloxMeshId
    mesh.Scale = Vector3.new(1.05,1.05,1.05)
    mesh.Parent = part

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = leg; weld.Part1 = part; weld.Parent = part
end
local function restoreKorblox(char)
    if not char then return end
    removeKorblox(char)
    local leg = char:FindFirstChild("RightLowerLeg")
        or char:FindFirstChild("RightUpperLeg")
        or char:FindFirstChild("Right Leg")
    if leg then hideLeg(leg, false) end
end

MiscTab:CreateToggle({
    Name="Leg Korblox (REAL)",
    Callback=function(v)
        KorbloxEnabled=v
        local char=LocalPlayer.Character
        if not char then return end
        if v then applyKorblox(char) else restoreKorblox(char) end
    end
})
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.6)
    if KorbloxEnabled then applyKorblox(char) end
end)
