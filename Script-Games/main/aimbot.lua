-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- LOAD RAYFIELD
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- WINDOW
local Window = Rayfield:CreateWindow({
    Name = "Visual ESP",
    LoadingTitle = "Visual Loading",
    LoadingSubtitle = "by dafaaa",
    ConfigurationSaving = { Enabled = false }
})

local VisualTab = Window:CreateTab("Visual", 4483362458)

-- SETTINGS
local Settings = {
    Enabled = false,
    TeamCheck = true,

    Box = false,
    Line = false,
    Name = false,
    Health = false,
    Distance = false,
    Skeleton = false,

    Color = Color3.fromRGB(255,0,0)
}

-- STORAGE
local ESP = {}

-- UTILS
local function New(type, props)
    local obj = Drawing.new(type)
    for i,v in pairs(props) do obj[i] = v end
    return obj
end

local function IsEnemy(player)
    if not Settings.TeamCheck then return true end
    if player.Team == nil or LocalPlayer.Team == nil then return true end
    return player.Team ~= LocalPlayer.Team
end

-- CREATE ESP
local function CreateESP(player)
    if player == LocalPlayer then return end

    ESP[player] = {
        Box = New("Square",{Thickness=2,Filled=false,Visible=false}),
        Line = New("Line",{Thickness=2,Visible=false}),
        Name = New("Text",{Size=15,Center=true,Outline=true,Visible=false}),
        Distance = New("Text",{Size=14,Center=true,Outline=true,Visible=false}),
        Health = New("Line",{Thickness=3,Visible=false}),
        Skeleton = {}
    }
end

-- REMOVE ESP
local function RemoveESP(player)
    if ESP[player] then
        for _,v in pairs(ESP[player]) do
            if typeof(v) == "table" then
                for _,l in pairs(v) do l:Remove() end
            elseif typeof(v) == "userdata" then
                v:Remove()
            end
        end
        ESP[player] = nil
    end
end

-- SKELETON
local Bones = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"}
}

local function UpdateSkeleton(player,char,color)
    ESP[player].Skeleton = ESP[player].Skeleton or {}
    for i,bone in ipairs(Bones) do
        local p1 = char:FindFirstChild(bone[1])
        local p2 = char:FindFirstChild(bone[2])
        if p1 and p2 then
            local v1,on1 = Camera:WorldToViewportPoint(p1.Position)
            local v2,on2 = Camera:WorldToViewportPoint(p2.Position)
            if on1 and on2 then
                local line = ESP[player].Skeleton[i] or New("Line",{Thickness=1})
                line.From = Vector2.new(v1.X,v1.Y)
                line.To = Vector2.new(v2.X,v2.Y)
                line.Color = color
                line.Visible = true
                ESP[player].Skeleton[i] = line
            end
        end
    end
end

-- PLAYER HANDLING
for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- MAIN LOOP (OPTIMIZED)
RunService.RenderStepped:Connect(function()
    for player,draw in pairs(ESP) do
        if not Settings.Enabled or not IsEnemy(player) then
            for _,v in pairs(draw) do
                if typeof(v)=="userdata" then v.Visible=false end
            end
            continue
        end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and hum and hum.Health>0 then
            local pos,on = Camera:WorldToViewportPoint(hrp.Position)
            if on then
                local size = Vector2.new(2000/pos.Z,3000/pos.Z)
                local color = Settings.Color
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position-hrp.Position).Magnitude)

                -- BOX
                draw.Box.Position = Vector2.new(pos.X-size.X/2,pos.Y-size.Y/2)
                draw.Box.Size = size
                draw.Box.Color = color
                draw.Box.Visible = Settings.Box

                -- LINE
                draw.Line.From = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y)
                draw.Line.To = Vector2.new(pos.X,pos.Y)
                draw.Line.Color = color
                draw.Line.Visible = Settings.Line

                -- NAME
                draw.Name.Text = player.Name
                draw.Name.Position = Vector2.new(pos.X,pos.Y-size.Y/2-14)
                draw.Name.Color = color
                draw.Name.Visible = Settings.Name

                -- DISTANCE
                draw.Distance.Text = dist.."m"
                draw.Distance.Position = Vector2.new(pos.X,pos.Y+size.Y/2+2)
                draw.Distance.Color = color
                draw.Distance.Visible = Settings.Distance

                -- HEALTH
                local hp = hum.Health/hum.MaxHealth
                draw.Health.From = Vector2.new(pos.X-size.X/2-5,pos.Y+size.Y/2)
                draw.Health.To = Vector2.new(pos.X-size.X/2-5,pos.Y+size.Y/2-(size.Y*hp))
                draw.Health.Color = Color3.fromRGB(255-(hp*255),hp*255,0)
                draw.Health.Visible = Settings.Health

                -- SKELETON
                if Settings.Skeleton then
                    UpdateSkeleton(player,char,color)
                end
            end
        end
    end
end)

-- UI
VisualTab:CreateToggle({Name="Enable Visual",Callback=function(v)Settings.Enabled=v end})
VisualTab:CreateToggle({Name="Team Check",CurrentValue=true,Callback=function(v)Settings.TeamCheck=v end})
VisualTab:CreateToggle({Name="Box ESP",Callback=function(v)Settings.Box=v end})
VisualTab:CreateToggle({Name="Line ESP",Callback=function(v)Settings.Line=v end})
VisualTab:CreateToggle({Name="Name ESP",Callback=function(v)Settings.Name=v end})
VisualTab:CreateToggle({Name="Distance ESP",Callback=function(v)Settings.Distance=v end})
VisualTab:CreateToggle({Name="Health Bar",Callback=function(v)Settings.Health=v end})
VisualTab:CreateToggle({Name="Skeleton ESP",Callback=function(v)Settings.Skeleton=v end})
VisualTab:CreateColorPicker({
    Name="ESP Color",
    Color=Settings.Color,
    Callback=function(c)Settings.Color=c end
})
