-- Third Party Script Selector Executor (Scrollable)

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScriptSelectorGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 260)
Frame.Position = UDim2.new(0.5, -160, 0.5, -130)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Select Script"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.new(1,1,1)
Title.Parent = Frame

-- ScrollingFrame
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -50)
Scroll.Position = UDim2.new(0, 10, 0, 45)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ScrollBarImageTransparency = 0
Scroll.ScrollBarThickness = 6
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.Parent = Frame

-- UIListLayout (auto rapih)
local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 10)
Layout.Parent = Scroll

-- SCRIPT LIST (TAMBAH DI SINI)
local Scripts = {
    {
        Name = "Chilli Hub",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/tienkhanh1/spicy/main/Chilli.lua"))() 
        end
    },
    {
        Name = "Lennon Hub",
        Callback = function()
            loadstring(game:HttpGet("https://pastefy.app/MJw2J4T6/raw"))()
        end
    },
    {
        Name = "Mirranda Hub",
        Callback = function()
            loadstring(game:HttpGet("https://pastefy.app/JJVhs3rK/raw"))()
        end
    },
    {
        Name = "Kurd Hub",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Ninja10908/S4/refs/heads/main/Kurdhub"))()
        end
    },
    {
        Name ="Invisible",
        Callback = function()
            loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/550a5d09159b57910ec10b1d96b45298.lua"))()
        end
    }
}

-- Create Buttons
for _, data in ipairs(Scripts) do
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Button.Text = data.Name
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Parent = Scroll

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

    Button.MouseButton1Click:Connect(function()
        pcall(data.Callback)
        ScreenGui:Destroy()
    end)
end

-- Auto resize canvas
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
end)
