 -- MOBILE FLIGHT GUI
-- Touch controls + draggable GUI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Root = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera

local Flying = false
local Speed = 60
local MinSpeed = 10
local MaxSpeed = 250

local BV
local BG

local Gui = Instance.new("ScreenGui")
Gui.Name = "MobileFlight"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

-- Main GUI
local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(250, 260)
Main.Position = UDim2.new(0.5, -125, 0.5, -130)
Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0,12)
Corner.Parent = Main

-- Drag system
local dragging = false
local dragStart
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragStart = dragStart or input.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,35)
Title.BackgroundTransparency = 1
Title.Text = "MOBILE FLIGHT"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.Parent = Main

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1,0,0,25)
Status.Position = UDim2.fromOffset(0,35)
Status.BackgroundTransparency = 1
Status.Text = "OFF"
Status.TextColor3 = Color3.fromRGB(255,80,80)
Status.TextSize = 14
Status.Font = Enum.Font.Gotham
Status.Parent = Main

-- Fly button
local Fly = Instance.new("TextButton")
Fly.Size = UDim2.fromOffset(210,38)
Fly.Position = UDim2.fromOffset(20,65)
Fly.BackgroundColor3 = Color3.fromRGB(50,50,60)
Fly.Text = "FLY"
Fly.TextColor3 = Color3.new(1,1,1)
Fly.TextSize = 16
Fly.Font = Enum.Font.GothamBold
Fly.Parent = Main

local FlyCorner = Instance.new("UICorner")
FlyCorner.CornerRadius = UDim.new(0,9)
FlyCorner.Parent = Fly

-- Joystick
local StickBase = Instance.new("Frame")
StickBase.Size = UDim2.fromOffset(100,100)
StickBase.Position = UDim2.fromOffset(20,125)
StickBase.BackgroundColor3 = Color3.fromRGB(45,45,55)
StickBase.BorderSizePixel = 0
StickBase.Active = true
StickBase.Parent = Main

local StickCorner = Instance.new("UICorner")
StickCorner.CornerRadius = UDim.new(1,0)
StickCorner.Parent = StickBase

local Stick = Instance.new("Frame")
Stick.Size = UDim2.fromOffset(45,45)
Stick.Position = UDim2.new(0.5,-22.5,0.5,-22.5)
Stick.BackgroundColor3 = Color3.fromRGB(110,110,125)
Stick.BorderSizePixel = 0
Stick.Active = true
Stick.Parent = StickBase

local StickCorner2 = Instance.new("UICorner")
StickCorner2.CornerRadius = UDim.new(1,0)
StickCorner2.Parent = Stick

local StickInput = nil
local StickVector = Vector2.zero

local function updateJoystick(input)
    local center = StickBase.AbsolutePosition +
        StickBase.AbsoluteSize / 2

    local delta = Vector2.new(
        input.Position.X - center.X,
        input.Position.Y - center.Y
    )

    local radius = 27
    if delta.Magnitude > radius then
        delta = delta.Unit * radius
    end

    Stick.Position = UDim2.new(
        0.5,
        delta.X - 22.5,
        0.5,
        delta.Y - 22.5
    )

    StickVector = Vector2.new(
        delta.X / radius,
        delta.Y / radius
    )
end

StickBase.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        StickInput = input
        updateJoystick(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if StickInput and input == StickInput then
        updateJoystick(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input == StickInput then
        StickInput = nil
        StickVector = Vector2.zero

        Stick:TweenPosition(
            UDim2.new(0.5,-22.5,0.5,-22.5),
            "Out",
            "Quad",
            0.1,
            true
        )
    end
end)

-- Up button
local Up = Instance.new("TextButton")
Up.Size = UDim2.fromOffset(50,45)
Up.Position = UDim2.fromOffset(140,125)
Up.BackgroundColor3 = Color3.fromRGB(50,50,60)
Up.Text = "UP"
Up.TextColor3 = Color3.new(1,1,1)
Up.TextSize = 14
Up.Font = Enum.Font.GothamBold
Up.Parent = Main

-- Down button
local Down = Instance.new("TextButton")
Down.Size = UDim2.fromOffset(50,45)
Down.Position = UDim2.fromOffset(195,125)
Down.BackgroundColor3 = Color3.fromRGB(50,50,60)
Down.Text = "DOWN"
Down.TextColor3 = Color3.new(1,1,1)
Down.TextSize = 12
Down.Font = Enum.Font.GothamBold
Down.Parent = Main

local GoingUp = false
local GoingDown = false

Up.MouseButton1Down:Connect(function()
    GoingUp = true
end)

Up.MouseButton1Up:Connect(function()
    GoingUp = false
end)

Down.MouseButton1Down:Connect(function()
    GoingDown = true
end)

Down.MouseButton1Up:Connect(function()
    GoingDown = false
end)

-- Speed
local SpeedText = Instance.new("TextLabel")
SpeedText.Size = UDim2.fromOffset(120,30)
SpeedText.Position = UDim2.fromOffset(65,215)
SpeedText.BackgroundTransparency = 1
SpeedText.Text = "Speed: "..Speed
SpeedText.TextColor3 = Color3.new(1,1,1)
SpeedText.TextSize = 14
SpeedText.Font = Enum.Font.GothamBold
SpeedText.Parent = Main

local Minus = Instance.new("TextButton")
Minus.Size = UDim2.fromOffset(40,30)
Minus.Position = UDim2.fromOffset(20,215)
Minus.Text = "-"
Minus.TextSize = 20
Minus.TextColor3 = Color3.new(1,1,1)
Minus.BackgroundColor3 = Color3.fromRGB(50,50,60)
Minus.Parent = Main

local Plus = Instance.new("TextButton")
Plus.Size = UDim2.fromOffset(40,30)
Plus.Position = UDim2.fromOffset(190,215)
Plus.Text = "+"
Plus.TextSize = 20
Plus.TextColor3 = Color3.new(1,1,1)
Plus.BackgroundColor3 = Color3.fromRGB(50,50,60)
Plus.Parent = Main

Plus.MouseButton1Click:Connect(function()
    Speed = math.min(Speed + 10, MaxSpeed)
    SpeedText.Text = "Speed: "..Speed
end)

Minus.MouseButton1Click:Connect(function()
    Speed = math.max(Speed - 10, MinSpeed)
    SpeedText.Text = "Speed: "..Speed
end)

-- Start flight
local function StartFlight()
    if Flying then return end

    Flying = true

    Status.Text = "ON"
    Status.TextColor3 = Color3.fromRGB(80,255,100)
    Fly.Text = "STOP"

    Humanoid.PlatformStand = true

    BV = Instance.new("BodyVelocity")
    BV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
    BV.Velocity = Vector3.zero
    BV.Parent = Root

    BG = Instance.new("BodyGyro")
    BG.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
    BG.P = 90000
    BG.Parent = Root
end

-- Stop flight
local function StopFlight()
    Flying = false

    Status.Text = "OFF"
    Status.TextColor3 = Color3.fromRGB(255,80,80)
    Fly.Text = "FLY"

    if BV then
        BV:Destroy()
        BV = nil
    end

    if BG then
        BG:Destroy()
        BG = nil
    end

    Humanoid.PlatformStand = false
end

Fly.MouseButton1Click:Connect(function()
    if Flying then
        StopFlight()
    else
        StartFlight()
    end
end)

-- Flight movement
RunService.RenderStepped:Connect(function()
    if not Flying or not BV or not BG then
        return
    end

    local forward = Camera.CFrame.LookVector
    local right = Camera.CFrame.RightVector

    local direction =
        (right * StickVector.X) +
        (forward * -StickVector.Y)

    local vertical = 0

    if GoingUp then
        vertical = vertical + 1
    end

    if GoingDown then
        vertical = vertical - 1
    end

    direction = direction + Vector3.new(0,vertical,0)

    BV.Velocity = direction * Speed

    BG.CFrame = Camera.CFrame
end)

-- Respawn
Player.CharacterAdded:Connect(function(char)
    StopFlight()

    Character = char
    Humanoid = Character:WaitForChild("Humanoid")
    Root = Character:WaitForChild("HumanoidRootPart")
end)
