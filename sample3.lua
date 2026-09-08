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

local savedMotors = {}

-- GUI

local gui = Instance.new("ScreenGui")
gui.Name = "SupermanFlight"
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

-- Mover la GUI con el dedo

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

-- Botones

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

-- Guardar las articulaciones originales

local function saveMotors()
	savedMotors = {}

	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("Motor6D") then
			savedMotors[obj] = obj.C0
		end
	end
end

-- Pose Superman

local function supermanPose()
	if not character then return end

	local upperTorso = character:FindFirstChild("UpperTorso")
	local lowerTorso = character:FindFirstChild("LowerTorso")

	if not upperTorso then
		upperTorso = character:FindFirstChild("Torso")
	end

	if not upperTorso then return end

	local rightShoulder = upperTorso:FindFirstChild("RightShoulder")
	local leftShoulder = upperTorso:FindFirstChild("LeftShoulder")

	local rightHip
	local leftHip

	if lowerTorso then
		rightHip = lowerTorso:FindFirstChild("RightHip")
		leftHip = lowerTorso:FindFirstChild("LeftHip")
	end

	-- Brazos hacia adelante

	if rightShoulder then
		rightShoulder.C0 =
			CFrame.new(1, 0.5, 0) *
			CFrame.Angles(math.rad(-80), 0, math.rad(10))
	end

	if leftShoulder then
		leftShoulder.C0 =
			CFrame.new(-1, 0.5, 0) *
			CFrame.Angles(math.rad(-80), 0, math.rad(-10))
	end

	-- Piernas ligeramente hacia atrás

	if rightHip then
		rightHip.C0 =
			CFrame.new(0.5, -1, 0) *
			CFrame.Angles(math.rad(15), 0, 0)
	end

	if leftHip then
		leftHip.C0 =
			CFrame.new(-0.5, -1, 0) *
			CFrame.Angles(math.rad(15), 0, 0)
	end
end

-- Restaurar pose normal

local function normalPose()
	for motor, c0 in pairs(savedMotors) do
		if motor and motor.Parent then
			motor.C0 = c0
		end
	end
end

-- Protección de vida local

local savedHealth = 100

local function protectHealth()
	if humanoid and humanoid.Health > 0 then
		if humanoid.MaxHealth > 0 then
			humanoid.Health = humanoid.MaxHealth
		end
	end
end

-- Activar vuelo

local function startFlight()
	if flying then return end

	character = player.Character
	if not character then return end

	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")

	saveMotors()

	flying = true
	flyButton.Text = "PARAR"

	savedHealth = humanoid.Health

	velocity = Instance.new("BodyVelocity")
	velocity.MaxForce = Vector3.new(
		math.huge,
		math.huge,
		math.huge
	)
	velocity.Velocity = Vector3.zero
	velocity.Parent = root

	gyro = Instance.new("BodyGyro")
	gyro.MaxTorque = Vector3.new(
		math.huge,
		math.huge,
		math.huge
	)
	gyro.P = 50000
	gyro.D = 1000
	gyro.Parent = root

	supermanPose()
end

-- Desactivar vuelo

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

	normalPose()
end

-- Botón volar

flyButton.Activated:Connect(function()
	if flying then
		stopFlight()
	else
		startFlight()
	end
end)

-- Velocidad -

minusButton.Activated:Connect(function()
	speed = math.max(minSpeed, speed - 10)
end)

-- Velocidad +

plusButton.Activated:Connect(function()
	speed = math.min(maxSpeed, speed + 10)
end)

-- Vuelo

RunService.RenderStepped:Connect(function()
	if not flying then
		return
	end

	if not character or not humanoid or not root then
		return
	end

	if not velocity or not gyro then
		return
	end

	-- Mantener vida mientras está volando

	protectHealth()

	-- Movimiento del joystick normal de Roblox

	local moveDirection = humanoid.MoveDirection
	local camera = workspace.CurrentCamera

	if moveDirection.Magnitude > 0 then

		local cameraLook = camera.CFrame.LookVector
		local cameraRight = camera.CFrame.RightVector

		local forwardAmount =
			moveDirection:Dot(Vector3.new(cameraLook.X, 0, cameraLook.Z))

		local rightAmount =
			moveDirection:Dot(Vector3.new(cameraRight.X, 0, cameraRight.Z))

		local horizontal =
			Vector3.new(cameraLook.X, 0, cameraLook.Z).Unit * forwardAmount
			+
			Vector3.new(cameraRight.X, 0, cameraRight.Z).Unit * rightAmount

		-- La inclinación de la cámara permite subir y bajar

		local vertical = cameraLook.Y

		local direction = Vector3.new(
			horizontal.X,
			vertical,
			horizontal.Z
		)

		if direction.Magnitude > 0 then
			velocity.Velocity = direction.Unit * speed
		end

	else
		velocity.Velocity = Vector3.zero
	end

	-- Mirar hacia donde apunta la cámara

	gyro.CFrame = camera.CFrame

	-- Mantener pose Superman

	supermanPose()
end)

-- Respawn

player.CharacterAdded:Connect(function(newCharacter)

	stopFlight()

	character = newCharacter

	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")

	savedMotors = {}

end)
