-- GeneraMonedas.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Crear GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GeneraGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 130, 0, 55)
frame.Position = UDim2.new(0.5, -65, 0.5, -27)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 110, 0, 35)
button.Position = UDim2.new(0.5, -55, 0.5, -17)
button.Text = "Genera"
button.TextSize = 16
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
button.BorderSizePixel = 0
button.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = button

-- Botón compatible con celular
button.Activated:Connect(function()
	local remote = ReplicatedStorage:FindFirstChild("GeneraMonedas")

	if remote then
		remote:FireServer()
	end
end)
