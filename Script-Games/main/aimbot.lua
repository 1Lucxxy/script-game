-- Rayfield Library
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

-- Settings
local AimbotEnabled = false
local Smoothness = 0.2

-- UI
local Window = Rayfield:CreateWindow({
    Name = "Basic Aimbot",
    LoadingTitle = "Loading",
    LoadingSubtitle = "Step 1",
    ConfigurationSaving = { Enabled = false }
})

local CombatTab = Window:CreateTab("Combat", 4483362458)

CombatTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(v)
        AimbotEnabled = v
    end
})

CombatTab:CreateSlider({
    Name = "Smoothness",
    Range = {0, 1},
    Increment = 0.05,
    CurrentValue = 0.2,
    Callback = function(v)
        Smoothness = v
    end
})

-- Get closest player to mouse
local function GetClosestPlayer()
    local closestPart = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local humanoid = player.Character:FindFirstChild("Humanoid")

            if head and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPart = head
                    end
                end
            end
        end
    end

    return closestPart
end

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if not AimbotEnabled then return end

    local target = GetClosestPlayer()
    if target then
        local newCF = CFrame.new(Camera.CFrame.Position, target.Position)
        Camera.CFrame = Camera.CFrame:Lerp(newCF, Smoothness)
    end
end)
