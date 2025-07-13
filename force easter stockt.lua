-- Force Easter Stock Buyer (For Inactive Events)
-- Attempts to bypass event restrictions and force purchase

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Get the Easter stock event
local gameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local buyEasterStockEvent = gameEvents:WaitForChild("BuyEasterStock")

-- Configuration
local FORCE_BUY = false
local BUY_DELAY = 0.5
local BUY_AMOUNT = 1

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ForceEasterStockGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 280)
mainFrame.Position = UDim2.new(0, 10, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
title.Text = "🚫 FORCE Easter Stock Buyer 🚫"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 50)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Event Inactive - Ready to Force"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Attempt Count Label
local attemptLabel = Instance.new("TextLabel")
attemptLabel.Size = UDim2.new(1, -20, 0, 25)
attemptLabel.Position = UDim2.new(0, 10, 0, 80)
attemptLabel.BackgroundTransparency = 1
attemptLabel.Text = "Attempts: 0"
attemptLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
attemptLabel.TextScaled = true
attemptLabel.Font = Enum.Font.Gotham
attemptLabel.Parent = mainFrame

-- Method Label
local methodLabel = Instance.new("TextLabel")
methodLabel.Size = UDim2.new(1, -20, 0, 25)
methodLabel.Position = UDim2.new(0, 10, 0, 110)
methodLabel.BackgroundTransparency = 1
methodLabel.Text = "Method: Multi-Bypass"
methodLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
methodLabel.TextScaled = true
methodLabel.Font = Enum.Font.Gotham
methodLabel.Parent = mainFrame

-- Amount Input
local amountFrame = Instance.new("Frame")
amountFrame.Size = UDim2.new(1, -20, 0, 30)
amountFrame.Position = UDim2.new(0, 10, 0, 140)
amountFrame.BackgroundTransparency = 1
amountFrame.Parent = mainFrame

local amountLabel = Instance.new("TextLabel")
amountLabel.Size = UDim2.new(0.3, 0, 1, 0)
amountLabel.Position = UDim2.new(0, 0, 0, 0)
amountLabel.BackgroundTransparency = 1
amountLabel.Text = "Amount:"
amountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
amountLabel.TextScaled = true
amountLabel.Font = Enum.Font.Gotham
amountLabel.Parent = amountFrame

local amountInput = Instance.new("TextBox")
amountInput.Size = UDim2.new(0.7, 0, 1, 0)
amountInput.Position = UDim2.new(0.3, 0, 0, 0)
amountInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
amountInput.Text = tostring(BUY_AMOUNT)
amountInput.TextColor3 = Color3.fromRGB(255, 255, 255)
amountInput.TextScaled = true
amountInput.Font = Enum.Font.Gotham
amountInput.Parent = amountFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 6)
inputCorner.Parent = amountInput

-- Force Buy Button
local forceButton = Instance.new("TextButton")
forceButton.Size = UDim2.new(0.45, 0, 0, 35)
forceButton.Position = UDim2.new(0.05, 0, 0, 180)
forceButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
forceButton.Text = "FORCE BUY"
forceButton.TextColor3 = Color3.fromRGB(255, 255, 255)
forceButton.TextScaled = true
forceButton.Font = Enum.Font.GothamBold
forceButton.Parent = mainFrame

local forceCorner = Instance.new("UICorner")
forceCorner.CornerRadius = UDim.new(0, 8)
forceCorner.Parent = forceButton

-- Auto Force Toggle
local autoForceToggle = Instance.new("TextButton")
autoForceToggle.Size = UDim2.new(0.45, 0, 0, 35)
autoForceToggle.Position = UDim2.new(0.5, 0, 0, 180)
autoForceToggle.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
autoForceToggle.Text = "AUTO: OFF"
autoForceToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoForceToggle.TextScaled = true
autoForceToggle.Font = Enum.Font.GothamBold
autoForceToggle.Parent = mainFrame

local autoForceCorner = Instance.new("UICorner")
autoForceCorner.CornerRadius = UDim.new(0, 8)
autoForceCorner.Parent = autoForceToggle

-- Spam Force Button
local spamButton = Instance.new("TextButton")
spamButton.Size = UDim2.new(0.9, 0, 0, 30)
spamButton.Position = UDim2.new(0.05, 0, 0, 225)
spamButton.BackgroundColor3 = Color3.fromRGB(150, 0, 150)
spamButton.Text = "SPAM FORCE (200x)"
spamButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spamButton.TextScaled = true
spamButton.Font = Enum.Font.GothamBold
spamButton.Parent = mainFrame

local spamCorner = Instance.new("UICorner")
spamCorner.CornerRadius = UDim.new(0, 8)
spamCorner.Parent = spamButton

-- Variables
local attemptCount = 0
local autoForceConnection
local lastAttemptTime = 0

-- Functions
local function updateStatus(text, color)
    statusLabel.Text = "Status: " .. text
    statusLabel.TextColor3 = color
end

local function forceBuyEasterStock(amount)
    local currentTime = tick()
    if currentTime - lastAttemptTime < 0.05 then
        return false
    end
    
    lastAttemptTime = currentTime
    amount = amount or BUY_AMOUNT
    attemptCount = attemptCount + 1
    attemptLabel.Text = "Attempts: " .. attemptCount
    
    local methods = {
        -- Method 1: Direct FireServer
        function()
            buyEasterStockEvent:FireServer(amount)
        end,
        
        -- Method 2: With different parameters
        function()
            buyEasterStockEvent:FireServer(amount, true)
        end,
        
        -- Method 3: With player parameter
        function()
            buyEasterStockEvent:FireServer(player, amount)
        end,
        
        -- Method 4: With bypass flag
        function()
            buyEasterStockEvent:FireServer({amount = amount, bypass = true})
        end,
        
        -- Method 5: Raw RemoteEvent fire
        function()
            local args = {amount}
            buyEasterStockEvent:FireServer(unpack(args))
        end,
        
        -- Method 6: Try InvokeServer if it exists
        function()
            if buyEasterStockEvent.InvokeServer then
                buyEasterStockEvent:InvokeServer(amount)
            end
        end,
        
        -- Method 7: Force with Easter flag
        function()
            buyEasterStockEvent:FireServer(amount, "Easter", true)
        end,
        
        -- Method 8: Bypass with multiple parameters
        function()
            buyEasterStockEvent:FireServer(amount, player.UserId, tick(), true)
        end
    }
    
    local success = false
    for i, method in ipairs(methods) do
        local ok, err = pcall(method)
        if ok then
            success = true
            methodLabel.Text = "Method: " .. i .. " Success"
            methodLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            break
        end
    end
    
    if success then
        updateStatus("Force attempt sent! (" .. amount .. ")", Color3.fromRGB(0, 255, 0))
    else
        updateStatus("All methods failed", Color3.fromRGB(255, 100, 100))
    end
    
    return success
end

local function startAutoForce()
    if autoForceConnection then return end
    
    FORCE_BUY = true
    autoForceToggle.Text = "AUTO: ON"
    autoForceToggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    updateStatus("Auto forcing...", Color3.fromRGB(255, 255, 0))
    
    autoForceConnection = RunService.Heartbeat:Connect(function()
        if tick() % BUY_DELAY < 0.1 then
            forceBuyEasterStock(BUY_AMOUNT)
        end
    end)
end

local function stopAutoForce()
    if not autoForceConnection then return end
    
    FORCE_BUY = false
    autoForceToggle.Text = "AUTO: OFF"
    autoForceToggle.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    updateStatus("Auto force stopped", Color3.fromRGB(255, 255, 0))
    
    autoForceConnection:Disconnect()
    autoForceConnection = nil
end

-- Event Connections
forceButton.MouseButton1Click:Connect(function()
    local amount = tonumber(amountInput.Text) or 1
    BUY_AMOUNT = amount
    forceBuyEasterStock(amount)
end)

autoForceToggle.MouseButton1Click:Connect(function()
    if FORCE_BUY then
        stopAutoForce()
    else
        startAutoForce()
    end
end)

spamButton.MouseButton1Click:Connect(function()
    updateStatus("Spam forcing 200x...", Color3.fromRGB(255, 0, 255))
    for i = 1, 200 do
        spawn(function()
            wait(i * 0.01)
            forceBuyEasterStock(1)
        end)
    end
end)

amountInput.FocusLost:Connect(function()
    local newAmount = tonumber(amountInput.Text)
    if newAmount and newAmount > 0 then
        BUY_AMOUNT = newAmount
    else
        amountInput.Text = tostring(BUY_AMOUNT)
    end
end)

-- Keyboard shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        forceBuyEasterStock(BUY_AMOUNT)
    elseif input.KeyCode == Enum.KeyCode.G then
        if FORCE_BUY then
            stopAutoForce()
        else
            startAutoForce()
        end
    elseif input.KeyCode == Enum.KeyCode.H then
        for i = 1, 100 do
            spawn(function()
                wait(i * 0.005)
                forceBuyEasterStock(1)
            end)
        end
    end
end)

print("🚫 Force Easter Stock Buyer Loaded!")
print("⚠️  WARNING: This attempts to bypass inactive event restrictions")
print("📖 Controls:")
print("   • F = Force buy once")
print("   • G = Toggle auto force")
print("   • H = Spam force 100x")
print("🔥 Ready to force inactive Easter stock purchases!")