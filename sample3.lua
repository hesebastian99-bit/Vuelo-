local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local savedPositions = {}
local currentPoint = 0

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GP_IRP"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Panel 200x200
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 200)
frame.Position = UDim2.new(0.5, -100, 0.5, -100)
frame.BackgroundTransparency = 0.1
frame.Parent = gui

-- Contador
local counter = Instance.new("TextLabel")
counter.Size = UDim2.new(1, 0, 0, 30)
counter.Position = UDim2.new(0, 0, 0, 0)
counter.Text = "Puntos guardados: 0"
counter.TextSize = 14
counter.BackgroundTransparency = 1
counter.Parent = frame

-- Zona para mover
local dragArea = Instance.new("TextLabel")
dragArea.Size = UDim2.new(1, 0, 0, 30)
dragArea.Position = UDim2.new(0, 0, 0, 30)
dragArea.Text = "MOVER"
dragArea.TextSize = 14
dragArea.BackgroundTransparency = 1
dragArea.Parent = frame

-- Tamaño de botones
local buttonWidth = 58
local buttonHeight = 55

-- GP
local gp = Instance.new("TextButton")
gp.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
gp.Position = UDim2.new(0, 5, 0, 75)
gp.Text = "GP"
gp.TextSize = 20
gp.Parent = frame

-- IRP
local irp = Instance.new("TextButton")
irp.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
irp.Position = UDim2.new(0, 71, 0, 75)
irp.Text = "IRP"
irp.TextSize = 20
irp.Parent = frame

-- RESET
local reset = Instance.new("TextButton")
reset.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
reset.Position = UDim2.new(0, 137, 0, 75)
reset.Text = "RESET"
reset.TextSize = 15
reset.Parent = frame

-- Actualizar contador
local function updateCounter()
	counter.Text = "Puntos guardados: " .. #savedPositions
end

-- Guardar punto
gp.Activated:Connect(function()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")

	if root then
		table.insert(savedPositions, root.CFrame)

		updateCounter()

		gp.Text = "OK"

		task.delay(0.7, function()
			if gp then
				gp.Text = "GP"
			end
		end)
	end
end)

-- Ir al siguiente punto
irp.Activated:Connect(function()
	if #savedPositions == 0 then
		irp.Text = "NO POS"

		task.delay(0.8, function()
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

		task.delay(0.7, function()
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

	updateCounter()

	reset.Text = "OK"

	task.delay(0.8, function()
		if reset then
			reset.Text = "RESET"
		end
	end)
end)

-- Arrastrar con dedo o mouse
local dragging = false
local dragStart = nil
local startPosition = nil

dragArea.InputBegan:Connect(function(input)
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
