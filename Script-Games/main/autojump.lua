-- BunnyHop Script (Xeno Friendly)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- CONFIG
local bunnyHop = false
local jumpCooldown = false

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 170, 0, 60)
frame.Position = UDim2.new(0, 20, 0.5, -30)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(1, -10, 1, -10)
btn.Position = UDim2.new(0, 5, 0, 5)
btn.Text = "Auto Jump : OFF"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 15
btn.TextColor3 = Color3.fromRGB(255,80,80)
btn.BackgroundColor3 = Color3.fromRGB(35,35,35)

-- Toggle
local function toggle()
	bunnyHop = not bunnyHop
	if bunnyHop then
		btn.Text = "BUNNYHOP : ON"
		btn.TextColor3 = Color3.fromRGB(80,255,80)
	else
		btn.Text = "BUNNYHOP : OFF"
		btn.TextColor3 = Color3.fromRGB(255,80,80)
	end
end

btn.MouseButton1Click:Connect(toggle)

-- Keybind X
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.X then
		toggle()
	end
end)

-- Bunny Hop Logic
RunService.Heartbeat:Connect(function()
	if not bunnyHop then return end
	if humanoid.FloorMaterial ~= Enum.Material.Air and not jumpCooldown then
		jumpCooldown = true
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		task.delay(0.15, function()
			jumpCooldown = false
		end)
	end
end)
