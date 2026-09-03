--[[
    MM2 ULTIMATE CHEAT ENGINE v3.0 – MOBILE EDITION
    ALL IN ONE SCRIPT:
    - Splash: "GoHo Cheats" + "Made By Yajobs"
    - Full GUI with tabs (touch-optimized, larger buttons)
    - Aimbot (silent, vischeck, FOV slider)
    - Spinbot (full rotation, horizontal/vertical)
    - ESP (box, name, health, distance)
    - Crate Forger (insert any item, animate)
    - Auto-Collect (coins, weapons)
    - Mobile touch controls (on-screen aim button, trigger button)
    - F1 toggle disabled – use close button or gesture
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = Player:GetMouse()

-- Detect mobile
local isMobile = UserInputService.TouchEnabled or (not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled)

-- ============================================
-- CONFIG
-- ============================================

local Config = {
    Aimbot = {
        Enabled = true,
        Silent = true,
        Smooth = 0.15,
        FOV = 90,
        HitPart = "Head",
        VisCheck = true,
        TeamCheck = true
    },
    Spinbot = {
        Enabled = false,
        Speed = 20,
        Desync = true,
        Horizontal = true,
        Vertical = true
    },
    ESP = {
        Enabled = true,
        Box = true,
        Name = true,
        Health = true,
        Distance = true,
        Tracer = false
    },
    CrateForger = {
        Enabled = true,
        ItemName = "Chroma Laser",
        CrateType = 1
    },
    AutoCollect = {
        Enabled = false,
        Coins = true,
        Weapons = true,
        Radius = 50
    },
    Mobile = {
        ShowAimButton = true,
        ShowTriggerButton = true,
        ButtonSize = 80,
        ButtonOpacity = 0.6
    }
}

-- ============================================
-- UTILITIES
-- ============================================

local function isAlive(char)
    if not char then return false end
    local hum = char:FindFirstChild("Humanoid")
    return hum and hum.Health > 0
end

local function getClosestPlayer()
    local closest, closestDist = nil, math.huge
    local localPos = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not localPos then return nil end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player and plr.Character and isAlive(plr.Character) then
            local targetPos = plr.Character:FindFirstChild("HumanoidRootPart")
            if targetPos then
                local dist = (localPos.Position - targetPos.Position).Magnitude
                if dist < closestDist then
                    closest = plr
                    closestDist = dist
                end
            end
        end
    end
    return closest
end

local function isVisible(targetPos)
    local ray = Ray.new(Camera.CFrame.Position, (targetPos - Camera.CFrame.Position).Unit * 1000)
    local hit, pos = Workspace:FindPartOnRay(ray, Player.Character, false, true)
    if hit then
        local distToTarget = (targetPos - Camera.CFrame.Position).Magnitude
        local distToHit = (pos - Camera.CFrame.Position).Magnitude
        return distToHit > distToTarget - 2
    end
    return true
end

local function createParticleExplosion(parent, position, color, count)
    count = count or 30
    for i = 1, count do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(4, 12), 0, math.random(4, 12))
        particle.Position = UDim2.new(0, position.X + math.random(-10, 10), 0, position.Y + math.random(-10, 10))
        particle.BackgroundColor3 = color
        particle.BackgroundTransparency = 0.3
        particle.BorderSizePixel = 0
        particle.Parent = parent
        local targetX = position.X + math.random(-200, 200)
        local targetY = position.Y + math.random(-200, 200)
        local tween = TweenService:Create(particle, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, targetX, 0, targetY),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0)
        })
        tween:Play()
        tween.Completed:Connect(function() particle:Destroy() end)
    end
end

-- ============================================
-- SPLASH SCREEN (Mobile Optimized)
-- ============================================

local splashGui = Instance.new("ScreenGui")
splashGui.Name = "SplashScreen"
splashGui.ResetOnSpawn = false
splashGui.Parent = Player:WaitForChild("PlayerGui")

-- Dark overlay
local splashBack = Instance.new("Frame")
splashBack.Size = UDim2.new(1, 0, 1, 0)
splashBack.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
splashBack.BackgroundTransparency = 0.2
splashBack.Parent = splashGui

-- Glow ring (bigger for mobile)
local glowRing = Instance.new("Frame")
glowRing.Size = UDim2.new(0, 350, 0, 350)
glowRing.Position = UDim2.new(0.5, -175, 0.5, -200)
glowRing.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
glowRing.BackgroundTransparency = 0.9
glowRing.BorderSizePixel = 0
glowRing.Parent = splashBack

local ringTween = TweenService:Create(glowRing, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {
    BackgroundTransparency = 0.7,
    Size = UDim2.new(0, 400, 0, 400)
})
ringTween:Play()

-- Main Title: GoHo Cheats (larger for mobile)
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 600, 0, 150)
titleLabel.Position = UDim2.new(0.5, -300, 0.5, -75)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "GoHo Cheats"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 150, 255)
titleLabel.TextStrokeTransparency = 0.3
titleLabel.Parent = splashBack

-- Title glow
local titleGlow = Instance.new("Frame")
titleGlow.Size = UDim2.new(0, 700, 0, 180)
titleGlow.Position = UDim2.new(0.5, -350, 0.5, -95)
titleGlow.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
titleGlow.BackgroundTransparency = 0.9
titleGlow.BorderSizePixel = 0
titleGlow.Parent = splashBack

local glowTween = TweenService:Create(titleGlow, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true), {
    BackgroundTransparency = 0.85,
    Size = UDim2.new(0, 750, 0, 200)
})
glowTween:Play()

-- Made By Yajobs – bottom left, larger for mobile
local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(0, 250, 0, 40)
creditLabel.Position = UDim2.new(0, 20, 1, -55)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "Made By Yajobs"
creditLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
creditLabel.TextScaled = true
creditLabel.Font = Enum.Font.Gotham
creditLabel.TextXAlignment = Enum.TextXAlignment.Left
creditLabel.Parent = splashBack

-- Version
local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(0, 120, 0, 25)
versionLabel.Position = UDim2.new(0.5, -60, 1, -40)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "v3.0"
versionLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
versionLabel.TextScaled = true
versionLabel.Font = Enum.Font.Gotham
versionLabel.Parent = splashBack

-- Loading bar (bigger for touch)
local loadBar = Instance.new("Frame")
loadBar.Size = UDim2.new(0, 400, 0, 8)
loadBar.Position = UDim2.new(0.5, -200, 0.5, 100)
loadBar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
loadBar.BorderSizePixel = 0
loadBar.Parent = splashBack

local loadFill = Instance.new("Frame")
loadFill.Size = UDim2.new(0, 0, 1, 0)
loadFill.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
loadFill.BorderSizePixel = 0
loadFill.Parent = loadBar

-- Loading text
local loadText = Instance.new("TextLabel")
loadText.Size = UDim2.new(0, 250, 0, 30)
loadText.Position = UDim2.new(0.5, -125, 0.5, 120)
loadText.BackgroundTransparency = 1
loadText.Text = "Loading..."
loadText.TextColor3 = Color3.fromRGB(150, 150, 180)
loadText.TextScaled = true
loadText.Font = Enum.Font.Gotham
loadText.Parent = splashBack

-- Tap to skip
local skipText = Instance.new("TextLabel")
skipText.Size = UDim2.new(0, 200, 0, 30)
skipText.Position = UDim2.new(0.5, -100, 0.5, 160)
skipText.BackgroundTransparency = 1
skipText.Text = "Tap to skip"
skipText.TextColor3 = Color3.fromRGB(80, 80, 100)
skipText.TextScaled = true
skipText.Font = Enum.Font.Gotham
skipText.Parent = splashBack

-- Animate loading
local loadStep = 0
local loadConnection = RunService.RenderStepped:Connect(function()
    loadStep = loadStep + 0.008
    if loadStep >= 1 then
        loadStep = 1
        loadConnection:Disconnect()
        task.wait(0.5)
        splashGui:Destroy()
        createMainMenu()
    end
    loadFill.Size = UDim2.new(loadStep, 0, 1, 0)
    loadText.Text = "Loading " .. string.rep(".", math.floor(loadStep * 15) % 4 + 1)
end)

-- Tap to skip
splashBack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        loadStep = 1
        loadFill.Size = UDim2.new(1, 0, 1, 0)
        loadConnection:Disconnect()
        task.wait(0.3)
        splashGui:Destroy()
        createMainMenu()
    end
end)

-- ============================================
-- MAIN MENU – MOBILE OPTIMIZED (larger UI)
-- ============================================

local screenGui
local mainFrame
local forgeBtn
local forgeStatus

function createMainMenu()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MM2Ultimate"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = Player:WaitForChild("PlayerGui")

    -- Main frame – bigger for mobile
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 650)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -325)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(80, 200, 255)
    mainFrame.ClipsDescendants = false
    mainFrame.Parent = screenGui

    -- Title Bar (taller for touch)
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 55)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(0, 300, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "⚡ GoHo v3.0"
    titleText.TextColor3 = Color3.fromRGB(80, 200, 255)
    titleText.TextScaled = true
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar

    -- Made By Yajobs in title bar
    local titleCredit = Instance.new("TextLabel")
    titleCredit.Size = UDim2.new(0, 160, 1, 0)
    titleCredit.Position = UDim2.new(1, -170, 0, 0)
    titleCredit.BackgroundTransparency = 1
    titleCredit.Text = "by Yajobs"
    titleCredit.TextColor3 = Color3.fromRGB(120, 120, 150)
    titleCredit.TextScaled = true
    titleCredit.Font = Enum.Font.Gotham
    titleCredit.TextXAlignment = Enum.TextXAlignment.Right
    titleCredit.Parent = titleBar

    -- Close button (bigger for touch)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 45, 0, 45)
    closeBtn.Position = UDim2.new(1, -50, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    closeBtn.TouchTap:Connect(function()
        screenGui:Destroy()
    end)

    -- Tabs (bigger buttons for mobile)
    local tabButtons = {}
    local tabContents = {}
    local activeTab = 1
    local tabs = {"Aimbot", "Spinbot", "ESP", "Crate", "Collect"}

    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 50)
    tabBar.Position = UDim2.new(0, 0, 0, 55)
    tabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    tabBar.BorderSizePixel = 0
    tabBar.Parent = mainFrame

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 44)
        btn.Position = UDim2.new(0, 2 + (i-1) * 102, 0, 3)
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(60, 150, 200) or Color3.fromRGB(30, 30, 50)
        btn.BorderSizePixel = 0
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tabBar
        tabButtons[i] = btn

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, -10, 1, -115)
        content.Position = UDim2.new(0, 5, 0, 110)
        content.BackgroundTransparency = 1
        content.Visible = i == 1
        content.Parent = mainFrame
        tabContents[i] = content

        btn.MouseButton1Click:Connect(function()
            activeTab = i
            for j, c in ipairs(tabContents) do
                c.Visible = j == i
                tabButtons[j].BackgroundColor3 = j == i and Color3.fromRGB(60, 150, 200) or Color3.fromRGB(30, 30, 50)
            end
        end)
        btn.TouchTap:Connect(function()
            activeTab = i
            for j, c in ipairs(tabContents) do
                c.Visible = j == i
                tabButtons[j].BackgroundColor3 = j == i and Color3.fromRGB(60, 150, 200) or Color3.fromRGB(30, 30, 50)
            end
        end)
    end

    -- Build tabs
    buildAimbotTab(tabContents[1])
    buildSpinbotTab(tabContents[2])
    buildEspTab(tabContents[3])
    buildCrateTab(tabContents[4])
    buildCollectTab(tabContents[5])

    -- Mobile touch controls (on-screen buttons)
    if isMobile then
        createMobileControls()
    end

    -- Drag (touch drag supported)
    local dragging, dragStart, dragOffset
    mainFrame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and input.Position.Y - mainFrame.AbsolutePosition.Y < 55 then
            dragging = true
            dragStart = input.Position
            dragOffset = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(dragOffset.X.Scale, dragOffset.X.Offset + delta.X, dragOffset.Y.Scale, dragOffset.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Aimbot + Spinbot + AutoCollect loops
    RunService.RenderStepped:Connect(function()
        -- Aimbot
        if Config.Aimbot.Enabled and Player.Character then
            local target = getClosestPlayer()
            if target and target.Character then
                local targetPart = target.Character:FindFirstChild(Config.Aimbot.HitPart) or target.Character:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    local targetPos = targetPart.Position
                    if (not Config.Aimbot.VisCheck or isVisible(targetPos)) then
                        local screenPos, onScreen = Camera:WorldToScreenPoint(targetPos)
                        if onScreen then
                            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            local maxFOV = (Config.Aimbot.FOV / 180) * math.min(Camera.ViewportSize.X, Camera.ViewportSize.Y) / 2
                            if dist <= maxFOV and Config.Aimbot.Silent then
                                local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
                                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Aimbot.Smooth)
                            end
                        end
                    end
                end
            end
        end

        -- Spinbot
        if Config.Spinbot.Enabled and Player.Character then
            local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local spinAngle = (tick() * Config.Spinbot.Speed * 2 * math.pi) % (2 * math.pi)
                if Config.Spinbot.Horizontal then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, spinAngle, 0)
                end
                if Config.Spinbot.Vertical then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(math.sin(spinAngle) * 0.3, 0, 0)
                end
            end
        end

        -- AutoCollect
        if Config.AutoCollect.Enabled and Player.Character then
            local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:match("Coin") or obj.Name:match("Knife") or obj.Name:match("Gun")) then
                        if (obj.Position - hrp.Position).Magnitude <= Config.AutoCollect.Radius then
                            local remote = ReplicatedStorage:FindFirstChild("CollectItem") or ReplicatedStorage:FindFirstChild("Pickup")
                            if remote then remote:FireServer(obj) end
                        end
                    end
                end
            end
        end
    end)
end

-- ============================================
-- MOBILE CONTROLS (On-Screen Buttons)
-- ============================================

function createMobileControls()
    local controlGui = Instance.new("ScreenGui")
    controlGui.Name = "MobileControls"
    controlGui.ResetOnSpawn = false
    controlGui.Parent = Player:WaitForChild("PlayerGui")

    -- Aim Button (bottom right)
    local aimBtn = Instance.new("TextButton")
    aimBtn.Size = UDim2.new(0, 80, 0, 80)
    aimBtn.Position = UDim2.new(1, -100, 1, -120)
    aimBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    aimBtn.BackgroundTransparency = 0.4
    aimBtn.BorderSizePixel = 2
    aimBtn.BorderColor3 = Color3.fromRGB(255, 100, 100)
    aimBtn.Text = "🎯"
    aimBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimBtn.TextScaled = true
    aimBtn.Font = Enum.Font.GothamBold
    aimBtn.Parent = controlGui

    -- Hold to aim
    local isAiming = false
    aimBtn.TouchBegan:Connect(function()
        isAiming = true
        Config.Aimbot.Enabled = true
        aimBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        aimBtn.BorderColor3 = Color3.fromRGB(255, 255, 100)
    end)
    aimBtn.TouchEnded:Connect(function()
        isAiming = false
        Config.Aimbot.Enabled = false
        aimBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        aimBtn.BorderColor3 = Color3.fromRGB(255, 100, 100)
    end)
    aimBtn.TouchTap:Connect(function()
        -- Toggle mode if tapped instead of held
        if not isAiming then
            Config.Aimbot.Enabled = not Config.Aimbot.Enabled
            aimBtn.BackgroundColor3 = Config.Aimbot.Enabled and Color3.fromRGB(255, 200, 50) or Color3.fromRGB(255, 50, 50)
            aimBtn.BorderColor3 = Config.Aimbot.Enabled and Color3.fromRGB(25
