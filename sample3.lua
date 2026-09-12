locallocal Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Velocidad inicial
local timeSpeed = 1

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "TimeSpeed"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Guía
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 55)
frame.Position = UDim2.new(0.5, -75, 0.5, -27)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Texto de velocidad
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 70, 0, 20)
speedLabel.Position = UDim2.new(0, 40, 0, 3)
speedLabel.Text = "Velocidad: 1x"
speedLabel.TextSize = 11
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.BackgroundTransparency = 1
speedLabel.Parent = frame

-- Botón -
local minus = Instance.new("TextButton")
minus.Size = UDim2.new(0, 35, 0, 25)
minus.Position = UDim2.new(0, 15, 0, 27)
minus.Text = "-"
minus.TextSize = 18
minus.TextColor3 = Color3.fromRGB(255, 255, 255)
minus.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
minus.BorderSizePixel = 0
minus.Parent = frame

local minusCorner = Instance.new("UICorner")
minusCorner.CornerRadius = UDim.new(0, 5)
minusCorner.Parent = minus

-- Botón +
local plus = Instance.new("TextButton")
plus.Size = UDim2.new(0, 35, 0, 25)
plus.Position = UDim2.new(0, 100, 0, 27)
plus.Text = "+"
plus.TextSize = 18
plus.TextColor3 = Color3.fromRGB(255, 255, 255)
plus.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
plus.BorderSizePixel = 0
plus.Parent = frame

local plusCorner = Instance.new("UICorner")
plusCorner.CornerRadius = UDim.new(0, 5)
plusCorner.Parent = plus

-- Actualizar texto
local function updateSpeed()
	speedLabel.Text = "Velocidad: " .. timeSpeed .. "x"
end

-- Bajar velocidad
minus.Activated:Connect(function()
	if timeSpeed > 1 then
		timeSpeed = timeSpeed - 1
		updateSpeed()
	end
end)

-- Subir velocidad
plus.Activated:Connect(function()
	if timeSpeed < 10 then
		timeSpeed = timeSpeed + 1
		updateSpeed()
	end
end)
