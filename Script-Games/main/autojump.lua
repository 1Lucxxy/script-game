-- Load Rayfield
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Window
local Window = Rayfield:CreateWindow({
   Name = "Bunny Hop",
   LoadingTitle = "Rayfield Interface",
   LoadingSubtitle = "by ChatGPT",
   ConfigurationSaving = {
      Enabled = false
   }
})

-- Tab
local Tab = Window:CreateTab("Movement", 4483362458)

-- Variables
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer
local Character, Humanoid

local BunnyHop = false

-- Character loader
local function SetupChar()
    Character = Player.Character or Player.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
end
SetupChar()
Player.CharacterAdded:Connect(SetupChar)

-- Bunny Hop Logic
RunService.RenderStepped:Connect(function()
    if BunnyHop and Humanoid and Humanoid.FloorMaterial ~= Enum.Material.Air then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Toggle
Tab:CreateToggle({
    Name = "Bunny Hop",
    CurrentValue = false,
    Flag = "BunnyHopToggle",
    Callback = function(Value)
        BunnyHop = Value
    end,
})
