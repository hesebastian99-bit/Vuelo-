local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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
gui.Name = "FlightGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(165, 45)
frame.Position = UDim2.new(0.5, -82, 0.75, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

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

-- Iniciar vuelo
local function startFlight()
	if flying then return end

	character = player.Character
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")

	flying = true
	flyButton.Text = "PARAR"

	humanoid.PlatformStand = true

	velocity = Instance.new("BodyVelocity")
	velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	velocity.Velocity = Vector3.zero
	velocity.Parent = root

	gyro = Instance.new("BodyGyro")
	gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	gyro.P = 50000
	gyro.Parent = root
end

-- Detener vuelo
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

	if humanoid then
		humanoid.PlatformStand = false
	end
end

flyButton.MouseButton1Click:Connect(function()
	if flying then
		stopFlight()
	else
		startFlight()
	end
end)

minusButton.MouseButton1Click:Connect(function()
	speed = math.max(minSpeed, speed - 10)
end)

plusButton.MouseButton1Click:Connect(function()
	speed = math.min(maxSpeed, speed + 10)
end)

-- Movimiento usando el joystick normal de Roblox
RunService.RenderStepped:Connect(function()
	if not flying or not velocity or not root then
		return
	end

	local moveDirection = humanoid.MoveDirection

	if moveDirection.Magnitude > 0 then
		velocity.Velocity = moveDirection * speed
	else
		velocity.Velocity = Vector3.zero
	end

	gyro.CFrame = workspace.CurrentCamera.CFrame
end)

-- Respawn
player.CharacterAdded:Connect(function(newCharacter)
	stopFlight()

	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")
end)
