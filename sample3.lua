local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Puntos guardados
local savedPositions = {}
local currentPoint = 0

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GP_IRP"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- GUÍA HORIZONTAL PEQUEÑA
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 55)
frame.Position = UDim2.new(0.5, -75, 0.5, -27)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.Parent = gui

-- Bordes redondeados
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Puntos
local counter = Instance.new("TextLabel")
counter.Size = UDim2.new(0, 28, 0, 45)
counter.Position = UDim2.new(0, 3, 0, 5)
counter.Text = "P:0"
counter.TextSize = 11
counter.TextColor3 = Color3.fromRGB(255, 255, 255)
counter.BackgroundTransparency = 1
counter.Parent = frame

-- GP
local gp = Instance.new("TextButton")
gp.Size = UDim2.new(0, 27, 0, 35)
gp.Position = UDim2.new(0, 33, 0, 10)
gp.Text = "GP"
gp.TextSize = 12
gp.TextColor3 = Color3.fromRGB(255, 255, 255)
gp.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
gp.BorderSizePixel = 0
gp.Parent = frame

local gpCorner = Instance.new("UICorner")
gpCorner.CornerRadius = UDim.new(0, 6)
gpCorner.Parent = gp

-- IRP
local irp = Instance.new("TextButton")
irp.Size = UDim2.new(0, 27, 0, 35)
irp.Position = UDim2.new(0, 63, 0, 10)
irp.Text = "IRP"
irp.TextSize = 11
irp.TextColor3 = Color3.fromRGB(255, 255, 255)
irp.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
irp.BorderSizePixel = 0
irp.Parent = frame

local irpCorner = Instance.new("UICorner")
irpCorner.CornerRadius = UDim.new(0, 6)
irpCorner.Parent = irp

-- RESET
local reset = Instance.new("TextButton")
reset.Size = UDim2.new(0, 38, 0, 35)
reset.Position = UDim2.new(0, 93, 0, 10)
reset.Text = "RESET"
reset.TextSize = 9
reset.TextColor3 = Color3.fromRGB(255, 255, 255)
reset.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
reset.BorderSizePixel = 0
reset.Parent = frame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = reset

-- Guardar punto
gp.Activated:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if root then
		table.insert(savedPositions, root.CFrame)

		counter.Text = "P:" .. #savedPositions

		gp.Text = "OK"

		task.delay(0.6, function()
			if gp then
				gp.Text = "GP"
			end
		end)
	end
end)

-- Ir al siguiente punto
irp.Activated:Connect(function()
	if #savedPositions == 0 then
		irp.Text = "NO"

		task.delay(0.6, function()
			if irp then
				irp.Text = "IRP"
			end
		end)

		return
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if root then
		currentPoint = currentPoint + 1

		if currentPoint > #savedPositions then
			currentPoint = 1
		end

		root.CFrame = savedPositions[currentPoint]

		irp.Text = tostring(currentPoint)

		task.delay(0.6, function()
			if irp then
				irp.Text = "IRP"
			end
		end)
	end
end)

-- RESET
reset.Activated:Connect(function()
	savedPositions = {}
	currentPoint = 0
	counter.Text = "P:0"

	reset.Text = "OK"

	task.delay(0.6, function()
		if reset then
			reset.Text = "RESET"
		end
	end)
end)

-- MOVER: arrastrar toda la guía
local dragging = false
local dragStart
local startPosition

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPosition = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end

	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta = input.Position - dragStart

		frame.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = false
	end
end)
