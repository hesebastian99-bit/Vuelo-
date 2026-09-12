local Players = game:GetService("Players")
local player = Players.LocalPlayer

local savedCFrame = nil

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "PositionTP"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Ventana
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 130)
frame.Position = UDim2.new(0.5, -110, 0.5, -65)
frame.BackgroundTransparency = 0.15
frame.Parent = gui

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "GUARDAR POSICIÓN"
title.TextSize = 18
title.BackgroundTransparency = 1
title.Parent = frame

-- GP
local gp = Instance.new("TextButton")
gp.Size = UDim2.new(0, 90, 0, 55)
gp.Position = UDim2.new(0, 10, 0, 55)
gp.Text = "GP"
gp.TextSize = 22
gp.Parent = frame

-- IRP
local irp = Instance.new("TextButton")
irp.Size = UDim2.new(0, 90, 0, 55)
irp.Position = UDim2.new(0, 120, 0, 55)
irp.Text = "IRP"
irp.TextSize = 22
irp.Parent = frame

-- Guardar posición
gp.MouseButton1Click:Connect(function()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if root then
        savedCFrame = root.CFrame
        gp.Text = "GUARDADO"

        task.wait(1)
        gp.Text = "GP"
    end
end)

-- Ir a posición
irp.MouseButton1Click:Connect(function()
    if not savedCFrame then
        irp.Text = "SIN POS"

        task.wait(1)
        irp.Text = "IRP"
        return
    end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if root then
        root.CFrame = savedCFrame
    end
end)

-- Hacer la ventana arrastrable
local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        local connection
        connection = input.Changed:Connect(function()
            if dragging then
                local delta = input.Position - dragStart

                frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            else
                connection:Disconnect()
            end
        end)
    end
end)
