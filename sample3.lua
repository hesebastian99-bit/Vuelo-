local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local savedPosition = nil

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GP_IRP"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Panel
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 190, 0, 125)
frame.Position = UDim2.new(0.5, -95, 0.5, -60)
frame.BackgroundTransparency = 0.1
frame.Parent = gui

-- Zona para agarrar y mover
local dragArea = Instance.new("TextLabel")
dragArea.Size = UDim2.new(1, 0, 0, 35)
dragArea.Position = UDim2.new(0, 0, 0, 0)
dragArea.Text = "MOVER"
dragArea.TextSize = 16
dragArea.BackgroundTransparency = 1
dragArea.Parent = frame

-- GP
local gp = Instance.new("TextButton")
gp.Size = UDim2.new(0, 80, 0, 60)
gp.Position = UDim2.new(0, 10, 0, 50)
gp.Text = "GP"
gp.TextSize = 24
gp.Parent = frame

-- IRP
local irp = Instance.new("TextButton")
irp.Size = UDim2.new(0, 80, 0, 60)
irp.Position = UDim2.new(0, 100, 0, 50)
irp.Text = "IRP"
irp.TextSize = 24
irp.Parent = frame

-- Guardar posición
gp.Activated:Connect(function()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if root then
        savedPosition = root.CFrame
        gp.Text = "OK"

        task.delay(1, function()
            gp.Text = "GP"
        end)
    end
end)

-- Ir a posición
irp.Activated:Connect(function()
    if not savedPosition then
        irp.Text = "NO POS"

        task.delay(1, function()
            irp.Text = "IRP"
        end)

        return
    end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if root then
        root.CFrame = savedPosition
    end
end)

-- ARRÁSTRALO CON EL DEDO
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
