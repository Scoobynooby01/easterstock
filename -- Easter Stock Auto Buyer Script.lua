-- Easter Stock Auto Buyer Script
-- For Roblox Executors

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Get the BuyEasterStock event
local buyEasterStockEvent = ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("BuyEasterStock")

-- Configuration
local AUTO_BUY = false
local BUY_DELAY = 1 -- Seconds between purchases
local BUY_AMOUNT = 1 -- Amount to buy each time

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EasterStockBuyerGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 220)
mainFrame.Position = UDim2.new(0, 10, 0, 200)
mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
title.Text = "🐰 Easter Stock Buyer 🥚"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 0, 45)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Purchase Count Label
local countLabel = Instance.new("TextLabel")
countLabel.Size = UDim2.new(1, -20, 0, 25)
countLabel.Position = UDim2.new(0, 10, 0, 75)
countLabel.BackgroundTransparency = 1
countLabel.Text = "Purchases: 0"
countLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
countLabel.TextScaled = true
countLabel.Font = Enum.Font.Gotham
countLabel.Parent = mainFrame

-- Buy Amount Input
local amountLabel = Instance.new("TextLabel")
amountLabel.Size = UDim2.new(0.5, -5, 0, 25)
amountLabel.Position = UDim2.new(0, 10, 0, 105)
amountLabel.BackgroundTransparency = 1
amountLabel.Text = "Amount:"
amountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
amountLabel.TextScaled = true
amountLabel.Font = Enum.Font.Gotham
amountLabel.TextXAlignment = Enum.TextXAlignment.Left
amountLabel.Parent = mainFrame

local amountInput = Instance.new("TextBox")
amountInput.Size = UDim2.new(0.5, -5, 0, 25)
amountInput.Position = UDim2.new(0.5, 5, 0, 105)
amountInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
amountInput.Text = tostring(BUY_AMOUNT)
amountInput.TextColor3 = Color3.fromRGB(255, 255, 255)
amountInput.TextScaled = true
amountInput.Font = Enum.Font.Gotham
amountInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 5)
inputCorner.Parent = amountInput

-- Single Buy Button
local buyButton = Instance.new("TextButton")
buyButton.Size = UDim2.new(0.45, 0, 0, 30)
buyButton.Position = UDim2.new(0.05, 0, 0, 140)
buyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
buyButton.Text = "BUY NOW"
buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
buyButton.TextScaled = true
buyButton.Font = Enum.Font.GothamBold
buyButton.Parent = mainFrame

local buyCorner = Instance.new("UICorner")
buyCorner.CornerRadius = UDim.new(0, 6)
buyCorner.Parent = buyButton

-- Auto Buy Toggle
local autoToggle = Instance.new("TextButton")
autoToggle.Size = UDim2.new(0.45, 0, 0, 30)
autoToggle.Position = UDim2.new(0.5, 0, 0, 140)
autoToggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
autoToggle.Text = "AUTO: OFF"
autoToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
autoToggle.TextScaled = true
autoToggle.Font = Enum.Font.GothamBold
autoToggle.Parent = mainFrame

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 6)
autoCorner.Parent = autoToggle

-- Max Buy Button
local maxBuyButton = Instance.new("TextButton")
maxBuyButton.Size = UDim2.new(0.9, 0, 0, 25)
maxBuyButton.Position = UDim2.new(0.05, 0, 0, 185)
maxBuyButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
maxBuyButton.Text = "BUY MAX (100x)"
maxBuyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
maxBuyButton.TextScaled = true
maxBuyButton.Font = Enum.Font.GothamBold
maxBuyButton.Parent = mainFrame

local maxCorner = Instance.new("UICorner")
maxCorner.CornerRadius = UDim.new(0, 6)
maxCorner.Parent = maxBuyButton

-- Variables
local purchaseCount = 0
local autoBuyConnection
local lastBuyTime = 0

-- Functions
local function updateStatus(text, color)
    statusLabel.Text = "Status: " .. text
    statusLabel.TextColor3 = color
end

local function buyEasterStock(amount)
    local currentTime = tick()
    if currentTime - lastBuyTime < 0.1 then -- Prevent spam
        return false
    end
    
    lastBuyTime = currentTime
    amount = amount or BUY_AMOUNT
    
    local success, errorMsg = pcall(function()
        -- Try different firing methods
        if buyEasterStockEvent.FireServer then
            buyEasterStockEvent:FireServer(amount)
        elseif buyEasterStockEvent.InvokeServer then
            buyEasterStockEvent:InvokeServer(amount)
        else
            -- Try direct fire
            buyEasterStockEvent:Fire(amount)
        end
    end)
    
    if success then
        purchaseCount = purchaseCount + amount
        countLabel.Text = "Purchases: " .. purchaseCount
        updateStatus("Purchased " .. amount .. " stocks!", Color3.fromRGB(0, 255, 0))
        return true
    else
        updateStatus("Purchase failed: " .. tostring(errorMsg), Color3.fromRGB(255, 0, 0))
        return false
    end
end

local function startAutoBuy()
    if autoBuyConnection then return end
    
    AUTO_BUY = true
    autoToggle.Text = "AUTO: ON"
    autoToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    updateStatus("Auto buying...", Color3.fromRGB(255, 255, 0))
    
    autoBuyConnection = RunService.Heartbeat:Connect(function()
        if tick() % BUY_DELAY < 0.1 then
            buyEasterStock(BUY_AMOUNT)
        end
    end)
end

local function stopAutoBuy()
    if not autoBuyConnection then return end
    
    AUTO_BUY = false
    autoToggle.Text = "AUTO: OFF"
    autoToggle.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    updateStatus("Auto buy stopped", Color3.fromRGB(255, 255, 0))
    
    autoBuyConnection:Disconnect()
    autoBuyConnection = nil
end

-- Event Connections
buyButton.MouseButton1Click:Connect(function()
    local amount = tonumber(amountInput.Text) or 1
    BUY_AMOUNT = amount
    buyEasterStock(amount)
end)

autoToggle.MouseButton1Click:Connect(function()
    if AUTO_BUY then
        stopAutoBuy()
    else
        startAutoBuy()
    end
end)

maxBuyButton.MouseButton1Click:Connect(function()
    for i = 1, 100 do
        spawn(function()
            wait(i * 0.01) -- Small delay to prevent overwhelming
            buyEasterStock(1)
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
    
    if input.KeyCode == Enum.KeyCode.B then
        buyEasterStock(BUY_AMOUNT)
    elseif input.KeyCode == Enum.KeyCode.V then
        if AUTO_BUY then
            stopAutoBuy()
        else
            startAutoBuy()
        end
    elseif input.KeyCode == Enum.KeyCode.M then
        for i = 1, 50 do
            spawn(function()
                wait(i * 0.02)
                buyEasterStock(1)
            end)
        end
    end
end)

-- Error handling for missing event
if not buyEasterStockEvent then
    updateStatus("Event not found!", Color3.fromRGB(255, 0, 0))
    warn("BuyEasterStock event not found in ReplicatedStorage.GameEvents")
end

print("🐰 Easter Stock Buyer Loaded!")
print("📖 Controls:")
print("   • Click 'BUY NOW' or press B to buy once")
print("   • Click 'AUTO: OFF/ON' or press V to toggle auto-buy")
print("   • Click 'BUY MAX' or press M for rapid buying")
print("   • Adjust amount in the input box")
print("✅ Ready to purchase Easter stocks!")