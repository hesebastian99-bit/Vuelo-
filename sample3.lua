-- SUPERMAN FLIGHT
-- GUI movil + vuelo + velocidad + animacion Superman

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

if not player then
    return
end

-- Eliminar version anterior
pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild("SupermanFlightGUI")
    if old then
        old:Destroy()
    end
end)

-- Variables
local flying = false
local takingOff = false
local speed = 60
local minSpeed = 10
local maxSpeed = 200

local character
local humanoid
local root
local animate

local bodyVelocity
local bodyGyro

local savedHealth = 100
local savedCollisions = {}
local motors = {}

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "SupermanFlightGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local loaded = false

pcall(function()
    gui.Parent = game:GetService("CoreGui")
    loaded = true
end)

if not loaded then
    pcall(function()
        gui.Parent = player:WaitForChild("PlayerGui")
        loaded = true
    end)
end

if not loaded then
    return
end

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(190, 55)
frame.Position = UDim2.new(0.5, -95, 0.78, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BackgroundTransparency = 0.12
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.Transparency = 0.25
stroke.Parent = frame

local flyButton = Instance.new("TextButton")
flyButton.Name = "Fly"
flyButton.Size = UDim2.fromOffset(90, 38)
flyButton.Position = UDim2.fromOffset(5, 8)
flyButton.BackgroundColor3 = Color3.fromRGB(40, 150, 255)
flyButton.TextColor3 = Color3.new(1, 1, 1)
flyButton.Text = "VOLAR"
flyButton.TextSize = 15
flyButton.Font = Enum.Font.GothamBold
flyButton.BorderSizePixel = 0
flyButton.Parent = frame

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 8)
flyCorner.Parent = flyButton

local minus = Instance.new("TextButton")
minus.Name = "Minus"
minus.Size = UDim2.fromOffset(38, 38)
minus.Position = UDim2.fromOffset(101, 8)
minus.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
minus.TextColor3 = Color3.new(1, 1, 1)
minus.Text = "-"
minus.TextSize = 22
minus.Font = Enum.Font.GothamBold
minus.BorderSizePixel = 0
minus.Parent = frame

local minusCorner = Instance.new("UICorner")
minusCorner.CornerRadius = UDim.new(0, 8)
minusCorner.Parent = minus

local plus = Instance.new("TextButton")
plus.Name = "Plus"
plus.Size = UDim2.fromOffset(38, 38)
plus.Position = UDim2.fromOffset(147, 8)
plus.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
plus.TextColor3 = Color3.new(1, 1, 1)
plus.Text = "+"
plus.TextSize = 22
plus.Font = Enum.Font.GothamBold
plus.BorderSizePixel = 0
plus.Parent = frame

local plusCorner = Instance.new("UICorner")
plusCorner.CornerRadius = UDim.new(0, 8)
plusCorner.Parent = plus

--==================================================
-- GUI MOVIBLE CON EL DEDO
--==================================================

local dragging = false
local dragStart
local startPosition
local dragInput

local function updateDrag(input)
    local delta = input.Position - dragStart

    frame.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPosition = frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

--==================================================
-- PERSONAJE
--==================================================

local function getCharacter()
    character = player.Character or player.CharacterAdded:Wait()

    humanoid = character:FindFirstChildOfClass("Humanoid")
    root = character:FindFirstChild("HumanoidRootPart")
    animate = character:FindFirstChild("Animate")

    if humanoid then
        savedHealth = humanoid.Health
    end

    return character, humanoid, root
end

getCharacter()

player.CharacterAdded:Connect(function()
    flying = false
    takingOff = false

    task.wait(1)

    getCharacter()

    flyButton.Text = "VOLAR"
    flyButton.BackgroundColor3 = Color3.fromRGB(40, 150, 255)
end)

--==================================================
-- ENCONTRAR MOTORES DE BRAZOS
--==================================================

local function findMotors()
    motors = {}

    if not character then
        return
    end

    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("Motor6D") then

            if obj.Name == "RightShoulder"
                or obj.Name == "Right Shoulder" then
                motors.RightShoulder = obj
            end

            if obj.Name == "LeftShoulder"
                or obj.Name == "Left Shoulder" then
                motors.LeftShoulder = obj
            end

            if obj.Name == "Waist" then
                motors.Waist = obj
            end
        end
    end
end

local function resetPose()
    for _, motor in pairs(motors) do
        if motor and motor.Parent then
            motor.Transform = CFrame.new()
        end
    end
end

--==================================================
-- POSE SUPERMAN
--==================================================

local function supermanPose()
    if not flying then
        return
    end

    local right = motors.RightShoulder
    local left = motors.LeftShoulder
    local waist = motors.Waist

    if right then
        right.Transform =
            CFrame.Angles(
                math.rad(-80),
                math.rad(8),
                math.rad(15)
            )
    end

    if left then
        left.Transform =
            CFrame.Angles(
                math.rad(-80),
                math.rad(-8),
                math.rad(-15)
            )
    end

    if waist then
        waist.Transform =
            CFrame.Angles(
                math.rad(12),
                0,
                0
            )
    end
end

--==================================================
-- COLISIONES
--==================================================

local function disableCollisions()
    savedCollisions = {}

    if not character then
        return
    end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            savedCollisions[part] = part.CanCollide
            part.CanCollide = false
        end
    end
end

local function restoreCollisions()
    for part, value in pairs(savedCollisions) do
        if part and part.Parent then
            part.CanCollide = value
        end
    end

    savedCollisions = {}
end

--==================================================
-- DESACTIVAR ANIMACIONES DE CAMINAR
--==================================================

local function disableAnimations()
    if animate then
        animate.Disabled = true
    end
end

local function enableAnimations()
    if animate and animate.Parent then
        animate.Disabled = false
    end
end

--==================================================
-- DESPEGUE + VUELTA
--==================================================

local function takeoff()
    if not humanoid or not root then
        return false
    end

    takingOff = true

    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

    root.AssemblyLinearVelocity = Vector3.new(0, 45, 0)

    local start = tick()
    local duration = 0.55

    while tick() - start < duration do
        if not root or not root.Parent then
            takingOff = false
            return false
        end

        local elapsed = tick() - start
        local rotation = math.rad(720) * (elapsed / duration)

        root.CFrame =
            CFrame.new(root.Position)
            * CFrame.Angles(rotation, 0, 0)

        RunService.Heartbeat:Wait()
    end

    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

    takingOff = false

    return true
end

--==================================================
-- EMPEZAR A VOLAR
--==================================================

local function startFlying()
    if flying or takingOff then
        return
    end

    getCharacter()

    if not character or not humanoid or not root then
        return
    end

    findMotors()

    savedHealth = humanoid.Health

    disableAnimations()
    disableCollisions()

    humanoid.AutoRotate = false

    local success = takeoff()

    if not success then
        enableAnimations()
        restoreCollisions()
        humanoid.AutoRotate = true
        return
    end

    flying = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "SupermanVelocity"
    bodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
    bodyVelocity.P = 30000
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "SupermanGyro"
    bodyGyro.MaxTorque = Vector3.new(1000000, 1000000, 1000000)
    bodyGyro.P = 30000
    bodyGyro.D = 1000
    bodyGyro.Parent = root

    flyButton.Text = "PARAR"
    flyButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
end

--==================================================
-- PARAR DE VOLAR
--==================================================

local function stopFlying()
    if not flying and not takingOff then
        return
    end

    flying = false
    takingOff = false

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    resetPose()
    restoreCollisions()
    enableAnimations()

    if humanoid and humanoid.Parent then
        humanoid.AutoRotate = true

        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)

        if humanoid.Health > 0 and savedHealth > 0 then
            humanoid.Health = math.min(savedHealth, humanoid.MaxHealth)
        end
    end

    flyButton.Text = "VOLAR"
    flyButton.BackgroundColor3 = Color3.fromRGB(40, 150, 255)
end

--==================================================
-- CONTROL DEL VUELO
--==================================================

RunService.RenderStepped:Connect(function()
    if not flying then
        return
    end

    if not character
        or not character.Parent
        or not humanoid
        or not root
        or not root.Parent then

        stopFlying()
        return
    end

    -- Mantener vida local
    if humanoid.Health > 0 and humanoid.Health < savedHealth then
        humanoid.Health = savedHealth
    end

    local camera = workspace.CurrentCamera

    if not camera then
        return
    end

    local joystick = humanoid.MoveDirection
    local cameraLook = camera.CFrame.LookVector

    local horizontal

    if joystick.Magnitude > 0.05 then
        horizontal = Vector3.new(
            joystick.X,
            0,
            joystick.Z
        )
    else
        horizontal = Vector3.new(0, 0, 0)
    end

    local vertical = 0

    if joystick.Magnitude > 0.05 then
        vertical = cameraLook.Y * speed
    end

    local velocity =
        horizontal * speed
        + Vector3.new(0, vertical, 0)

    if bodyVelocity then
        bodyVelocity.Velocity = velocity
    end

    -- Mirar hacia donde apunta la camara
    local flatLook = Vector3.new(
        cameraLook.X,
        0,
        cameraLook.Z
    )

    if flatLook.Magnitude > 0.01 and bodyGyro then
        flatLook = flatLook.Unit

        bodyGyro.CFrame =
            CFrame.lookAt(
                root.Position,
                root.Position + flatLook
            )
            * CFrame.Angles(math.rad(-10), 0, 0)
    end

    -- Pose Superman constantemente
    supermanPose()
end)

--==================================================
-- BOTONES
--==================================================

flyButton.Activated:Connect(function()
    if flying then
        stopFlying()
    else
        startFlying()
    end
end)

minus.Activated:Connect(function()
    speed = math.max(minSpeed, speed - 10)
end)

plus.Activated:Connect(function()
    speed = math.min(maxSpeed, speed + 10)
end)

--==================================================
-- SI MUERE EL PERSONAJE
--==================================================

if humanoid then
    humanoid.Died:Connect(function()
        flying = false
        takingOff = false

        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end

        if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
        end

        resetPose()
    end)
end
