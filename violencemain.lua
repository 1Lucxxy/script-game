-- =======================
-- SERVICES
-- =======================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- =======================
-- LOAD RAYFIELD
-- =======================
local Rayfield = loadstring(game:HttpGet(
"https://raw.githubusercontent.com/shlexware/Rayfield/main/source"
))()

local Window = Rayfield:CreateWindow({
	Name = "Visual Hub",
	LoadingTitle = "Loading Visual",
	LoadingSubtitle = "Rayfield",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "VisualHub",
		FileName = "VisualConfig"
	}
})

-- =======================
-- HIGHLIGHT STORAGE
-- =======================
local HL = {
	Survivor = {},
	Killer = {},
	Generator = {},
	Hook = {},
	Window = {},
	Gift = {}
}

-- =======================
-- HIGHLIGHT UTILS
-- =======================
local function addHL(model, color, store)
	if not model or model:FindFirstChild("RF_HL") then return end

	local h = Instance.new("Highlight")
	h.Name = "RF_HL"
	h.Adornee = model
	h.FillColor = color
	h.OutlineColor = Color3.new(1,1,1)
	h.FillTransparency = 0.45
	h.OutlineTransparency = 0
	h.Parent = model

	table.insert(store, h)
end

local function clearHL(store)
	for _, h in pairs(store) do
		if h and h.Parent then
			h:Destroy()
		end
	end
	table.clear(store)
end

-- =======================
-- TEAM HIGHLIGHT
-- =======================
local SurvivorOn = false
local KillerOn = false

local function refreshPlayers()
	clearHL(HL.Survivor)
	clearHL(HL.Killer)

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer and plr.Character and plr.Team then
			if SurvivorOn and plr.Team.Name == "Survivor" then
				addHL(plr.Character, Color3.fromRGB(0,255,0), HL.Survivor)
			end
			if KillerOn and plr.Team.Name == "Killer" then
				addHL(plr.Character, Color3.fromRGB(255,0,0), HL.Killer)
			end
		end
	end
end

Players.PlayerAdded:Connect(function()
	task.wait(1)
	refreshPlayers()
end)

Players.PlayerRemoving:Connect(refreshPlayers)

-- =======================
-- MODEL NAME HIGHLIGHT
-- =======================
local function highlightModel(name, color, state, store)
	clearHL(store)
	if not state then return end

	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj.Name == name then
			addHL(obj, color, store)
		end
	end
end

-- =======================
-- CROSSHAIR
-- =======================
local CrossGui = Instance.new("ScreenGui")
CrossGui.Name = "RF_Crosshair"
CrossGui.ResetOnSpawn = false
CrossGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Dot = Instance.new("Frame")
Dot.Size = UDim2.fromOffset(6,6)
Dot.Position = UDim2.fromScale(0.5,0.5)
Dot.AnchorPoint = Vector2.new(0.5,0.5)
Dot.BackgroundColor3 = Color3.new(1,1,1)
Dot.BorderSizePixel = 0
Dot.Parent = CrossGui

Instance.new("UICorner", Dot).CornerRadius = UDim.new(1,0)

CrossGui.Enabled = false

-- =======================
-- VISUAL TAB
-- =======================
local VisualTab = Window:CreateTab("Visual", 4483362458)

VisualTab:CreateToggle({
	Name = "Highlight Survivor (Green)",
	Callback = function(v)
		SurvivorOn = v
		refreshPlayers()
	end
})

VisualTab:CreateToggle({
	Name = "Highlight Killer (Red)",
	Callback = function(v)
		KillerOn = v
		refreshPlayers()
	end
})

VisualTab:CreateToggle({
	Name = "Highlight Generator",
	Callback = function(v)
		highlightModel("Generator", Color3.fromRGB(255,255,0), v, HL.Generator)
	end
})

VisualTab:CreateToggle({
	Name = "Highlight Hook",
	Callback = function(v)
		highlightModel("Hook", Color3.fromRGB(255,0,255), v, HL.Hook)
	end
})

VisualTab:CreateToggle({
	Name = "Highlight Window",
	Callback = function(v)
		highlightModel("Window", Color3.fromRGB(0,170,255), v, HL.Window)
	end
})

VisualTab:CreateToggle({
	Name = "Highlight Event / Gift",
	Callback = function(v)
		highlightModel("Gift", Color3.fromRGB(255,215,0), v, HL.Gift)
	end
})

VisualTab:CreateToggle({
	Name = "Crosshair (Small Dot)",
	Callback = function(v)
		CrossGui.Enabled = v
	end
})
