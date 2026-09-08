local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local flying = false
local speed = 60
local minSpeed = 10
local maxSpeed = 250

local velocity
local gyro

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MobileFlight"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(165, 45)
frame.Position = UDim2.new(0.5, -82, 0.75, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Arrastrar GUI con el dedo
local dragging = false
local dragStart
local startPosition

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPosition = frame.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.Touch then
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
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

local function createButton(text, position)
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(50, 35)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Text = text
	button.TextSize = 13
	button.Font = Enum.Font.GothamBold
	button.BorderSizePixel = 0
	button.Parent = frame

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 7)
	c.Parent = button

	return button
end

local flyButton = createButton("VOLAR", UDim2.fromOffset(5, 5))
local minusButton = createButton("-", UDim2.fromOffset(57, 5))
local plusButton = createButton("+", UDim2.fromOffset(110, 5))

-- Vuelo
local function startFlight()
	if flying then return end

	character = player.Character
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")

	flying = true
	flyButton.Text = "PARAR"

	velocity = Instance.new("BodyVelocity")
	velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	velocity.Velocity = Vector3.zero
	velocity.Parent = root

	gyro = Instance.new("BodyGyro")
	gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	gyro.P = 50000
	gyro.Parent = root
end

local function stopFlight()
	flying = false
	flyButton.Text = "VOLAR"

	if velocity then
		velocity:Destroy()
		velocity = nil
	end

	if gyro then
		gyro:Destroy()
		gyro = nil
	end
end

flyButton.Activated:Connect(function()
	if flying then
		stopFlight()
	else
		startFlight()
	end
end)

minusButton.Activated:Connect(function()
	speed = math.max(minSpeed, speed - 10)
end)

plusButton.Activated:Connect(function()
	speed = math.min(maxSpeed, speed + 10)
end)

-- Movimiento completo
RunService.RenderStepped:Connect(function()
	if not flying or not velocity or not root then
		return
	end

	local camera = workspace.CurrentCamera
	local move = humanoid.MoveDirection

	if move.Magnitude > 0 then
		-- El joystick normal controla la dirección
		-- La cámara determina también la dirección vertical
		local direction = camera.CFrame.LookVector

		-- Mantiene la dirección horizontal del joystick
		local horizontal = Vector3.new(move.X, 0, move.Z)

		-- Inclinación de cámara para subir/bajar
		local vertical = direction.Y

		local finalDirection = Vector3.new(
			horizontal.X,
			vertical,
			horizontal.Z
		)

		if finalDirection.Magnitude > 0 then
			velocity.Velocity = finalDirection.Unit * speed
		else
			velocity.Velocity = Vector3.zero
		end
	else
		velocity.Velocity = Vector3.zero
	end

	-- Orientación del personaje
	gyro.CFrame = camera.CFrame
end)

-- Respawn
player.CharacterAdded:Connect(function(newCharacter)
	stopFlight()

	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")
end)
