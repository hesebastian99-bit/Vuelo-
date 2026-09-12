local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- CONFIGURACIÓN
local checkpointFolder = workspace:WaitForChild("Checkpoints")

local speeds = {
	[1] = 0.8, -- Lento
	[2] = 0.3, -- Rápido
	[3] = 0.08 -- Rapidísimo
}

local speedLevel = 1
local playing = false

local checkpoints = {}

--------------------------------------------------
-- DETECTAR CHECKPOINTS
--------------------------------------------------

local function getNumber(part)
	local number = tonumber(string.match(part.Name, "%d+"))
	return number
end

local function findCheckpoints()
	checkpoints = {}

	for _, object in ipairs(checkpointFolder:GetChildren()) do
		if object:IsA("BasePart") then
			table.insert(checkpoints, object)
		end
	end

	table.sort(checkpoints, function(a, b)
		local aNumber = getNumber(a)
		local bNumber = getNumber(b)

		if aNumber and bNumber then
			return aNumber < bNumber
		elseif aNumber then
			return true
		elseif bNumber then
			return false
		end

		return a.Position.X < b.Position.X
	end)
end

findCheckpoints()

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "CheckpointController"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 170, 0, 65)
frame.Position = UDim2.new(0.5, -85, 0.75, 0)
frame.BackgroundTransparency = 0.15
frame.Parent = gui

local play = Instance.new("TextButton")
play.Size = UDim2.new(0, 80, 0, 28)
play.Position = UDim2.new(0, 3, 0, 3)
play.Text = "PLAY"
play.TextSize = 14
play.Parent = frame

local pause = Instance.new("TextButton")
pause.Size = UDim2.new(0, 80, 0, 28)
pause.Position = UDim2.new(0, 87, 0, 3)
pause.Text = "PAUSA"
pause.TextSize = 14
pause.Parent = frame

local minus = Instance.new("TextButton")
minus.Size = UDim2.new(0, 45, 0, 28)
minus.Position = UDim2.new(0, 3, 0, 34)
minus.Text = "-"
minus.TextSize = 18
minus.Parent = frame

local speed = Instance.new("TextLabel")
speed.Size = UDim2.new(0, 70, 0, 28)
speed.Position = UDim2.new(0, 50, 0, 34)
speed.Text = "1"
speed.TextSize = 18
speed.BackgroundTransparency = 1
speed.Parent = frame

local plus = Instance.new("TextButton")
plus.Size = UDim2.new(0, 45, 0, 28)
plus.Position = UDim2.new(0, 122, 0, 34)
plus.Text = "+"
plus.TextSize = 18
plus.Parent = frame

--------------------------------------------------
-- CAMBIAR VELOCIDAD
--------------------------------------------------

minus.Activated:Connect(function()
	if speedLevel > 1 then
		speedLevel -= 1
		speed.Text = tostring(speedLevel)
	end
end)

plus.Activated:Connect(function()
	if speedLevel < 3 then
		speedLevel += 1
		speed.Text = tostring(speedLevel)
	end
end)

--------------------------------------------------
-- PLAY
--------------------------------------------------

play.Activated:Connect(function()
	if playing then
		return
	end

	findCheckpoints()

	if #checkpoints == 0 then
		play.Text = "SIN CP"
		task.wait(1)
		play.Text = "PLAY"
		return
	end

	playing = true

	for _, checkpoint in ipairs(checkpoints) do
		if not playing then
			break
		end

		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")

		if root and checkpoint and checkpoint.Parent then
			root.CFrame = checkpoint.CFrame + Vector3.new(0, 4, 0)
		end

		task.wait(speeds[speedLevel])
	end

	playing = false
end)

--------------------------------------------------
-- PAUSA
--------------------------------------------------

pause.Activated:Connect(function()
	playing = false
end)
