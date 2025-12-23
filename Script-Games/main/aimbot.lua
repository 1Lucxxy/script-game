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
    LoadingTitle = "Loading Visual",
    LoadingSubtitle = "by dafaaa",
    ConfigurationSaving = {
        Enabled = false
    }
})

-- TAB VISUAL
local VisualTab = Window:CreateTab("Visual", 4483362458)

-- SETTINGS
local Settings = {
    Enabled = false,
    Box = false,
    Line = false,
    Name = false,
    Health = false,
    Color = Color3.fromRGB(255, 0, 0)
}

-- ESP STORAGE
local ESP = {}

-- FUNCTION: CREATE DRAWING
local function NewDrawing(type, props)
    local obj = Drawing.new(type)
    for i,v in pairs(props) do
        obj[i] = v
    end
    return obj
end

-- CREATE ESP FOR PLAYER
local function CreateESP(player)
    if player == LocalPlayer then return end

    ESP[player] = {
        Box = NewDrawing("Square", {
            Thickness = 2,
            Filled = false,
            Color = Settings.Color,
            Visible = false
        }),
        Line = NewDrawing("Line", {
            Thickness = 2,
            Color = Settings.Color,
            Visible = false
        }),
        Name = NewDrawing("Text", {
            Size = 16,
            Center = true,
            Outline = true,
            Color = Settings.Color,
            Visible = false
        }),
        Health = NewDrawing("Line", {
            Thickness = 3,
            Color = Color3.fromRGB(0,255,0),
            Visible = false
        })
    }
end

-- REMOVE ESP
local function RemoveESP(player)
    if ESP[player] then
        for _,v in pairs(ESP[player]) do
            v:Remove()
        end
        ESP[player] = nil
    end
end

-- PLAYER HANDLING
for _,plr in pairs(Players:GetPlayers()) do
    CreateESP(plr)
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- UPDATE ESP
RunService.RenderStepped:Connect(function()
    for player,draw in pairs(ESP) do
        if not Settings.Enabled then
            for _,v in pairs(draw) do v.Visible = false end
            continue
        end

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and hum and hum.Health > 0 then
            local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
            if onscreen then
                local size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)

                -- BOX
                draw.Box.Size = size
                draw.Box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                draw.Box.Color = Settings.Color
                draw.Box.Visible = Settings.Box

                -- LINE
                draw.Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                draw.Line.To = Vector2.new(pos.X, pos.Y)
                draw.Line.Color = Settings.Color
                draw.Line.Visible = Settings.Line

                -- NAME
                draw.Name.Text = player.Name
                draw.Name.Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 15)
                draw.Name.Color = Settings.Color
                draw.Name.Visible = Settings.Name

                -- HEALTH BAR
                local hp = hum.Health / hum.MaxHealth
                draw.Health.From = Vector2.new(pos.X - size.X/2 - 5, pos.Y + size.Y/2)
                draw.Health.To = Vector2.new(pos.X - size.X/2 - 5, pos.Y + size.Y/2 - (size.Y * hp))
                draw.Health.Color = Color3.fromRGB(255 - (hp*255), hp*255, 0)
                draw.Health.Visible = Settings.Health
            else
                for _,v in pairs(draw) do v.Visible = false end
            end
        else
            for _,v in pairs(draw) do v.Visible = false end
        end
    end
end)

-- UI CONTROLS
VisualTab:CreateToggle({
    Name = "Enable Highlight",
    CurrentValue = false,
    Callback = function(v)
        Settings.Enabled = v
    end
})

VisualTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Callback = function(v)
        Settings.Box = v
    end
})

VisualTab:CreateToggle({
    Name = "Line ESP",
    CurrentValue = false,
    Callback = function(v)
        Settings.Line = v
    end
})

VisualTab:CreateToggle({
    Name = "Name ESP",
    CurrentValue = false,
    Callback = function(v)
        Settings.Name = v
    end
})

VisualTab:CreateToggle({
    Name = "Health Bar",
    CurrentValue = false,
    Callback = function(v)
        Settings.Health = v
    end
})

VisualTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Settings.Color,
    Callback = function(c)
        Settings.Color = c
    end
})
