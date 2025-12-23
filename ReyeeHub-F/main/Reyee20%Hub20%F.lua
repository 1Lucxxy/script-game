--==================================================
-- TEXT MAP / GAME SELECTOR (ANTI BUG VERSION)
--==================================================

local CoreGui = game:GetService("CoreGui")

-- Hapus GUI lama
pcall(function()
    CoreGui:FindFirstChild("TextMapSelector"):Destroy()
end)

--==============================
-- GUI
--==============================
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "TextMapSelector"
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 280, 0, 240)
Frame.Position = UDim2.new(0.5, -140, 0.5, -120)
Frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,40)
Title.Text = "SELECT MAP / GAME"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = Color3.new(1,1,1)
Title.BackgroundTransparency = 1

local List = Instance.new("Frame", Frame)
List.Position = UDim2.new(0,15,0,45)
List.Size = UDim2.new(1,-30,1,-55)
List.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", List)
Layout.Padding = UDim.new(0,12)

--==============================
-- MAP LIST (FORMAT AMAN)
-- GANTI NAMA & LINK DI SINI
--==============================
local Maps = {
    ["DESERT"] = "https://raw.githubusercontent.com/USER/REPO/main/desert.lua",
    ["CITY"]   = "https://raw.githubusercontent.com/USER/REPO/main/city.lua",
    ["SNOW"]   = "https://raw.githubusercontent.com/USER/REPO/main/snow.lua",
    ["tes"] = "https://raw.githubusercontent.com/USER/REPO/main/forest.lua"
}

print("TOTAL MAP:", table.getn(Maps)) -- debug

--==============================
-- CREATE TEXT SELECTOR
--==============================
for name, url in pairs(Maps) do
    local Btn = Instance.new("TextButton", List)
    Btn.Size = UDim2.new(1,0,0,30)
    Btn.Text = name
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 13
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.TextColor3 = Color3.fromRGB(220,220,220)
    Btn.BackgroundTransparency = 1
    Btn.AutoButtonColor = false

    Btn.MouseEnter:Connect(function()
        Btn.TextColor3 = Color3.fromRGB(0,170,255)
    end)

    Btn.MouseLeave:Connect(function()
        Btn.TextColor3 = Color3.fromRGB(220,220,220)
    end)

    Btn.MouseButton1Click:Connect(function()
        Btn.Text = "Loading..."

        -- 🔴 TUTUP GUI DULU (PASTI CLOSE)
        ScreenGui:Destroy()

        -- 🔵 LOADSTRING DI THREAD BARU (ANTI FREEZE)
        task.spawn(function()
            local ok, err = pcall(function()
                local src = game:HttpGet(url)
                loadstring(src)()
            end)

            if not ok then
                warn("Load error:", err)
            end
        end)
    end)
end
