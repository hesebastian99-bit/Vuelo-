-- LobbyPointTeleporter.lua
-- Roblox / Luau
-- Los puntos deben estar en Workspace > RespawnPoints
-- Ejemplo: Point1, Point2, Point3, Point4...

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local pointsFolder = workspace:WaitForChild("RespawnPoints")

-- Velocidades del 1 al 10.
-- Mientras mayor sea el número, más rápido será el recorrido.
local speeds = {
	2.00, -- 1
	1.50, -- 2
	1.15, -- 3
	0.90, -- 4
	0.70, -- 5
	0.50, -- 6
	0.35, -- 7
	0.25, -- 8
	0.15, -- 9
	0.05  -- 10: Súper rápido
}

local speedLevel = 1
local running = false
local paused = false

local function getPoints()
	local points = {}

	for _, obj in ipairs(pointsFolder:GetChildren()) do
		if obj:IsA("BasePart") then
			table.insert(points, obj)

		elseif obj:IsA("Model") then
			local part = obj.PrimaryPart
				or obj:FindFirstChildWhichIsA("BasePart", true)

			if part then
				table.insert(points, part)
			end
		end
	end

	table.sort(points, function(a, b)
		local numberA = tonumber(a.Name:match("%d+")) or math.huge
		local numberB = tonumber(b.Name:match("%d+")) or math.huge

		return numberA < numberB
	end)

	return points
end

local function teleportTo(part)
	local character = player.Character
		or player.CharacterAdded:Wait()

	local root = character:FindFirstChild("HumanoidRootPart")

	if root then
		root.CFrame = part.CFrame + Vector3.new(0, 3, 0)
	end
end

-- Crear interfaz

local gui = Instance.new("ScreenGui")
gui.Name = "LobbyPointTeleporter"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(220, 105)
frame.Position = UDim2.new(0.5, -110, 0.8, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

local function createButton(text, x, y, width)
	local button = Instance.new("TextButton")

	button.Text = text
	button.Size = UDim2.fromOffset(width, 40)
	button.Position = UDim2.fromOffset(x, y)

	button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 18
	button.Font = Enum.Font.GothamBold
	button.BorderSizePixel = 0

	button.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = button

	return button
end

-- Primera fila

local playButton = createButton("PLAY", 8, 8, 100)
local pauseButton = createButton("PAUSA", 112, 8, 100)

-- Segunda fila

local minusButton = createButton("-", 8, 55, 55)
local speedLabel = createButton("1", 66, 55, 88)
local plusButton = createButton("+", 162, 55, 50)

speedLabel.Active = false

-- Actualizar número de velocidad

local function updateSpeed()
	speedLabel.Text = tostring(speedLevel)
end

-- Velocidad -

minusButton.MouseButton1Click:Connect(function()
	if speedLevel > 1 then
		speedLevel -= 1
		updateSpeed()
	end
end)

-- Velocidad +

plusButton.MouseButton1Click:Connect(function()
	if speedLevel < 10 then
		speedLevel += 1
		updateSpeed()
	end
end)

-- Pausar / continuar

pauseButton.MouseButton1Click:Connect(function()
	paused = not paused

	if paused then
		pauseButton.Text = "CONTINUAR"
	else
		pauseButton.Text = "PAUSA"
	end
end)

-- Iniciar recorrido

playButton.MouseButton1Click:Connect(function()
	if running then
		return
	end

	running = true
	paused = false
	pauseButton.Text = "PAUSA"

	task.spawn(function()
		while running do

			local points = getPoints()

			if #points == 0 then
				warn("No se encontraron puntos en Workspace.RespawnPoints")
				running = false
				break
			end

			for _, point in ipairs(points) do

				if not running then
					break
				end

				while paused and running do
					task.wait(0.1)
				end

				if not running then
					break
				end

				teleportTo(point)

				task.wait(speeds[speedLevel])
			end
		end
	end)
end)

updateSpeed()
