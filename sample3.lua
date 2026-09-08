-- Script de Vuelo - Version Mejorada
print("Cargando vuelo...")

local player = game.Players.LocalPlayer
local userInput = game:GetService("UserInputService")
local guiService = game:GetService("GuiService")
local runService = game:GetService("RunService")

local flying = false
local flightSpeed = 5
local maxSpeed = 30
local isTouching = false
local touchStartPos, currentTouchPos = nil, nil
local rotationAngle = 0
local gyroActive = false

-- Variables del personaje
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Funcion para actualizar personaje
local function updateCharacter(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    if flying then
        task.wait(0.5)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        humanoid.PlatformStand = true
        gyroActive = true
    end
end
player.CharacterAdded:Connect(updateCharacter)

-- Crear GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlightGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Panel Principal
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 180, 0, 160)
panel.Position = UDim2.new(0.5, -90, 0.5, -80)
panel.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
panel.BackgroundTransparency = 0.15
panel.BorderSizePixel = 2
panel.BorderColor3 = Color3.fromRGB(150, 150, 255)
panel.Active = true
panel.Draggable = true
panel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 12)
panelCorner.Parent = panel

-- Boton Volar
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0, 160, 0, 45)
flyButton.Position = UDim2.new(0.5, -80, 0, 12)
flyButton.Text = "VOLAR"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextScaled = true
flyButton.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
flyButton.BorderSizePixel = 0
flyButton.ZIndex = 10
flyButton.Parent = panel

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 8)
flyCorner.Parent = flyButton

-- Botones de velocidad (rango 0-30)
local speedDown = Instance.new("TextButton")
speedDown.Size = UDim2.new(0, 45, 0, 40)
speedDown.Position = UDim2.new(0, 10, 0, 72)
speedDown.Text = "-"
speedDown.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDown.TextScaled = true
speedDown.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
speedDown.BorderSizePixel = 0
speedDown.ZIndex = 10
speedDown.Parent = panel

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 8)
downCorner.Parent = speedDown

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 50, 0, 35)
speedLabel.Position = UDim2.new(0.5, -25, 0, 75)
speedLabel.Text = "5"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextScaled = true
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.GothamBold
speedLabel.ZIndex = 10
speedLabel.Parent = panel

local speedUp = Instance.new("TextButton")
speedUp.Size = UDim2.new(0, 45, 0, 40)
speedUp.Position = UDim2.new(0, 125, 0, 72)
speedUp.Text = "+"
speedUp.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUp.TextScaled = true
speedUp.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
speedUp.BorderSizePixel = 0
speedUp.ZIndex = 10
speedUp.Parent = panel

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 8)
upCorner.Parent = speedUp

-- Control de velocidad (0-30)
local function changeSpeed(amount)
    flightSpeed = math.clamp(flightSpeed + amount, 0, 30)
    speedLabel.Text = math.floor(flightSpeed)
    print("Velocidad: " .. flightSpeed)
end

-- Funcion principal de vuelo
local function toggleFlight()
    flying = not flying
    
    if flying then
        flyButton.Text = "ATERRIZAR"
        flyButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        humanoid.PlatformStand = true
        gyroActive = true
        rotationAngle = 0
        
        -- Crear BodyGyro para giro
        local gyro = Instance.new("BodyGyro")
        gyro.MaxTorque = Vector3.new(4000, 0, 4000)
        gyro.P = 3000
        gyro.Parent = rootPart
        rootPart.BodyGyro = gyro
        
        print("Vuelo ACTIVADO - Velocidad: " .. flightSpeed)
    else
        flyButton.Text = "VOLAR"
        flyButton.BackgroundColor3 = Color3.fromRGB(60, 140, 255)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid.PlatformStand = false
        gyroActive = false
        
        if rootPart then
            rootPart.Velocity = Vector3.new(0, -5, 0)
            if rootPart:FindFirstChild("BodyGyro") then
                rootPart.BodyGyro:Destroy()
            end
        end
        print("Vuelo DESACTIVADO")
    end
end

-- Control tactil
local function onTouchBegan(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        local guiObject = guiService:GetGuiObjectAtPosition(input.Position)
        if guiObject and guiObject:IsDescendantOf(panel) then return end
        
        isTouching = true
        touchStartPos = input.Position
        currentTouchPos = input.Position
    end
end

local function onTouchMoved(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch and isTouching then
        currentTouchPos = input.Position
    end
end

local function onTouchEnded(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        isTouching = false
        touchStartPos, currentTouchPos = nil, nil
        if rootPart and flying then
            rootPart.Velocity = Vector3.new(0, rootPart.Velocity.Y, 0)
        end
    end
end

userInput.TouchBegan:Connect(onTouchBegan)
userInput.TouchMoved:Connect(onTouchMoved)
userInput.TouchEnded:Connect(onTouchEnded)

-- Sistema de vuelo mejorado (con giro y movimiento real)
coroutine.wrap(function()
    while true do
        task.wait()
        
        if flying and rootPart and humanoid then
            -- Mantener gravedad en 0
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
            humanoid.PlatformStand = true
            
            -- Actualizar giro (BodyGyro)
            if rootPart:FindFirstChild("BodyGyro") and gyroActive then
                local camera = workspace.CurrentCamera
                local lookVector = camera.CFrame.LookVector
                local upVector = camera.CFrame.UpVector
                
                -- Orientar al personaje en direccion de vuelo
                if isTouching and touchStartPos and currentTouchPos then
                    local delta = currentTouchPos - touchStartPos
                    if delta.Magnitude > 5 then
                        local angle = math.atan2(-delta.Y, delta.X)
                        local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
                        
                        -- Girar suavemente
                        local targetCFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + direction)
                        rootPart.BodyGyro.CFrame = targetCFrame
                    end
                end
            end
            
            -- Movimiento tactil
            if isTouching and touchStartPos and currentTouchPos then
                local delta = currentTouchPos - touchStartPos
                local magnitude = math.min(delta.Magnitude / 100, 1)
                
                if magnitude > 0.05 and flightSpeed > 0 then
                    local camera = workspace.CurrentCamera
                    local forward = camera.CFrame.LookVector
                    local right = camera.CFrame.RightVector
                    
                    local angle = math.atan2(-delta.Y, delta.X)
                    local xMove = math.cos(angle) * magnitude
                    local zMove = math.sin(angle) * magnitude
                    
                    local moveDirection = (right * xMove + forward * zMove) * (flightSpeed * 2)
                    
                    -- Movimiento vertical (arrastre vertical)
                    local verticalInput = -delta.Y / 150
                    if math.abs(verticalInput) > 0.2 then
                        moveDirection = Vector3.new(
                            moveDirection.X,
                            verticalInput * flightSpeed * 1.5,
                            moveDirection.Z
                        )
                    else
                        moveDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z)
                    end
                    
                    rootPart.Velocity = moveDirection
                else
                    rootPart.Velocity = Vector3.new(0, 0, 0)
                end
            else
                -- Si no se toca, flotar quieto
                rootPart.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)()

-- Conexion de botones
flyButton.MouseButton1Click:Connect(toggleFlight)
speedUp.MouseButton1Click:Connect(function() changeSpeed(1) end)
speedDown.MouseButton1Click:Connect(function() changeSpeed(-1) end)

print("Script listo! Velocidad 0-30. Toca VOLAR y arrastra para moverte.")
