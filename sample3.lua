-- ============================================
-- SCRIPT DE VUELO PARA MOVIL (CONTROL TACTIL)
-- ============================================

print("Cargando Script de Vuelo Tactil...")

-- ============================================
-- 1. CONFIGURACION INICIAL
-- ============================================
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local flightSpeed = 60
local animationPlaying = false

-- Variables para control tactil
local isTouching = false
local touchStartPos = nil
local currentTouchPos = nil

-- ============================================
-- 2. CREAR LA GUI
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlightGui"
screenGui.Parent = player.PlayerGui

-- ============================================
-- 3. PANEL DE BOTONES (ESQUINA INFERIOR DERECHA)
-- ============================================
local buttonPanel = Instance.new("Frame")
buttonPanel.Size = UDim2.new(0, 220, 0, 180)
buttonPanel.Position = UDim2.new(1, -240, 1, -200)
buttonPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
buttonPanel.BackgroundTransparency = 0.2
buttonPanel.BorderSizePixel = 2
buttonPanel.BorderColor3 = Color3.fromRGB(100, 100, 200)
buttonPanel.Parent = screenGui

-- Hacer esquinas redondeadas
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 10)
panelCorner.Parent = buttonPanel

-- ============================================
-- 4. BOTON DE VUELO
-- ============================================
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(0, 190, 0, 60)
flyButton.Position = UDim2.new(0.5, -95, 0, 15)
flyButton.Text = "ACTIVAR VUELO"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.TextScaled = true
flyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
flyButton.BorderSizePixel = 0
flyButton.ZIndex = 10
flyButton.Parent = buttonPanel

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 8)
flyCorner.Parent = flyButton

-- ============================================
-- 5. BOTONES DE VELOCIDAD
-- ============================================

-- Boton de disminuir velocidad (-)
local speedDown = Instance.new("TextButton")
speedDown.Size = UDim2.new(0, 55, 0, 45)
speedDown.Position = UDim2.new(0, 10, 0, 90)
speedDown.Text = "-"
speedDown.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDown.TextScaled = true
speedDown.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
speedDown.BorderSizePixel = 0
speedDown.ZIndex = 10
speedDown.Parent = buttonPanel

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 8)
downCorner.Parent = speedDown

-- Indicador de velocidad
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 70, 0, 35)
speedLabel.Position = UDim2.new(0.5, -35, 0, 95)
speedLabel.Text = "60"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextScaled = true
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.GothamBold
speedLabel.ZIndex = 10
speedLabel.Parent = buttonPanel

-- Boton de aumentar velocidad (+)
local speedUp = Instance.new("TextButton")
speedUp.Size = UDim2.new(0, 55, 0, 45)
speedUp.Position = UDim2.new(0, 155, 0, 90)
speedUp.Text = "+"
speedUp.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUp.TextScaled = true
speedUp.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
speedUp.BorderSizePixel = 0
speedUp.ZIndex = 10
speedUp.Parent = buttonPanel

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 8)
upCorner.Parent = speedUp

-- ============================================
-- 6. INDICADOR DE ESTADO
-- ============================================
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 150, 0, 30)
statusLabel.Position = UDim2.new(0.5, -75, 0.05, 0)
statusLabel.Text = "EN TIERRA"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.BackgroundTransparency = 1
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.GothamBold
statusLabel.ZIndex = 10
statusLabel.Parent = screenGui

-- ============================================
-- 7. ANIMACION DE VUELO
-- ============================================
local function playFlightAnimation()
    if animationPlaying then return end
    animationPlaying = true
    
    local char = player.Character
    if not char then 
        animationPlaying = false
        return 
    end
    
    local hum = char:FindFirstChild("Humanoid")
    if not hum then
        animationPlaying = false
        return
    end
    
    local success, err = pcall(function()
        local animationTrack = Instance.new("Animation")
        animationTrack.AnimationId = "rbxassetid://6161636818"
        
        local loadedAnimation = hum:LoadAnimation(animationTrack)
        if loadedAnimation then
            loadedAnimation:Play()
            print("Animacion de vuelo reproducida")
        end
    end)
    
    if not success then
        print("No se pudo cargar la animacion")
    end
    
    animationPlaying = false
end

-- ============================================
-- 8. SISTEMA DE VUELO CON CONTROL TACTIL
-- ============================================
local function toggleFlight()
    flying = not flying
    
    if flying then
        -- ACTIVAR VUELO
        statusLabel.Text = "VOLANDO"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        flyButton.Text = "DETENER VUELO"
        flyButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        humanoid.PlatformStand = true
        
        playFlightAnimation()
        print("Vuelo ACTIVADO - Toca y arrastra para volar")
        
        -- Bucle principal de vuelo
        spawn(function()
            while flying do
                local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if root and isTouching and touchStartPos and currentTouchPos then
                    local camera = workspace.CurrentCamera
                    local lookVector = camera.CFrame.LookVector
                    local rightVector = camera.CFrame.RightVector
                    
                    local delta = currentTouchPos - touchStartPos
                    local magnitude = math.min(delta.Magnitude / 100, 1)
                    
                    if magnitude > 0.05 then
                        local angle = math.atan2(-delta.Y, delta.X)
                        
                        local forward = lookVector
                        local right = rightVector
                        
                        local xMove = math.cos(angle) * magnitude
                        local zMove = math.sin(angle) * magnitude
                        
                        local moveDirection = (right * xMove + forward * zMove) * flightSpeed
                        moveDirection = Vector3.new(moveDirection.X, root.Velocity.Y, moveDirection.Z)
                        
                        root.Velocity = moveDirection
                    else
                        root.Velocity = Vector3.new(0, 0, 0)
                    end
                elseif flying and root and not isTouching then
                    root.Velocity = Vector3.new(0, 0, 0)
                end
                task.wait(0.05)
            end
        end)
        
        -- Bucle para subir/bajar con toques verticales
        spawn(function()
            while flying do
                if isTouching and touchStartPos and currentTouchPos then
                    local delta = currentTouchPos - touchStartPos
                    local verticalMovement = -delta.Y / 100
                    
                    if math.abs(verticalMovement) > 0.3 then
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            if math.abs(delta.X) < math.abs(delta.Y) then
                                root.Velocity = Vector3.new(root.Velocity.X, verticalMovement * flightSpeed * 0.8, root.Velocity.Z)
                            end
                        end
                    end
                end
                task.wait(0.05)
            end
        end)
        
    else
        -- DESACTIVAR VUELO
        statusLabel.Text = "EN TIERRA"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        flyButton.Text = "ACTIVAR VUELO"
        flyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
        
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        humanoid.PlatformStand = false
        
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.Velocity = Vector3.new(0, -5, 0)
        end
        
        print("Vuelo DESACTIVADO")
    end
end

-- ============================================
-- 9. FUNCIONES DE VELOCIDAD
-- ============================================
local function changeSpeed(amount)
    flightSpeed = math.clamp(flightSpeed + amount, 10, 200)
    speedLabel.Text = math.floor(flightSpeed)
    print("Velocidad: " .. flightSpeed)
end

-- ============================================
-- 10. CONTROL TACTIL
-- ============================================
local function onTouchBegan(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        local guiObject = game:GetService("GuiService"):GetGuiObjectAtPosition(input.Position)
        if guiObject and guiObject:IsDescendantOf(buttonPanel) then
            return
        end
        
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
        touchStartPos = nil
        currentTouchPos = nil
        
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root and flying then
            root.Velocity = Vector3.new(0, root.Velocity.Y, 0)
        end
    end
end

local userInput = game:GetService("UserInputService")
userInput.TouchBegan:Connect(onTouchBegan)
userInput.TouchMoved:Connect(onTouchMoved)
userInput.TouchEnded:Connect(onTouchEnded)

-- ============================================
-- 11. CONECTAR BOTONES
-- ============================================
flyButton.MouseButton1Click:Connect(toggleFlight)
speedUp.MouseButton1Click:Connect(function() changeSpeed(10) end)
speedDown.MouseButton1Click:Connect(function() changeSpeed(-10) end)

-- ============================================
-- 12. MANTENER PERSONAJE ACTUALIZADO
-- ============================================
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    if flying then
        task.wait(0.5)
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        humanoid.PlatformStand = true
    end
    print("Personaje actualizado")
end)

-- ============================================
-- 13. MENSAJE DE INICIO
-- ============================================
print("Script de Vuelo Tactil Cargado!")
print("Toca y arrastra en la pantalla para volar")
print("Presiona el boton para activar/desactivar")
print("Usa + y - para cambiar velocidad")

-- Notificacion de inicio
local notification = Instance.new("TextLabel")
notification.Size = UDim2.new(0, 280, 0, 40)
notification.Position = UDim2.new(0.5, -140, 0.15, 0)
notification.Text = "Toca el boton para volar!"
notification.TextColor3 = Color3.fromRGB(255, 255, 255)
notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notification.BackgroundTransparency = 0.5
notification.BorderSizePixel = 2
notification.BorderColor3 = Color3.fromRGB(100, 200, 255)
notification.TextScaled = true
notification.Font = Enum.Font.GothamBold
notification.ZIndex = 10
notification.Parent = screenGui

local notifCorner = Instance.new("UICorner")
notifCorner.CornerRadius = UDim.new(0, 8)
notifCorner.Parent = notification

task.wait(4)
notification:TweenSize(UDim2.new(0, 280, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.5, true)
task.wait(0.5)
notification:Destroy()