--// Key System

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--// URLs
local KEYS_URL = "https://raw.githubusercontent.com/r3al1tygethuzz/hard-time/main/keys.lua"
local MAIN_URL = "https://pastebin.com/raw/bu1x0pXv"

--// Prevent duplicate GUIs
pcall(function()
    game:GetService("CoreGui"):FindFirstChild("KeySystem"):Destroy()
end)

--//==================================================
--// KEY DATABASE
--//==================================================

local function loadKeys()

    local success, result = pcall(function()

        local source = game:HttpGet(KEYS_URL)

        if not source or source == "" then
            error("GitHub returned an empty file.")
        end

        local loaded = loadstring(source)

        if not loaded then
            error("Could not compile keys.lua.")
        end

        return loaded()
    end)

    if not success then
        warn("[KeySystem] Failed to load keys.lua:", result)
        return nil, tostring(result)
    end

    if type(result) ~= "table" then
        warn("[KeySystem] keys.lua did not return a table.")
        return nil, "keys.lua did not return a table."
    end

    return result
end

--//==================================================
--// VERIFY KEY
--//==================================================

local function verifyKey(inputKey)

    inputKey = tostring(inputKey or "")

    -- Remove accidental spaces
    inputKey = inputKey:gsub("^%s+", "")
    inputKey = inputKey:gsub("%s+$", "")

    if inputKey == "" then
        return false, "Please enter a key."
    end

    local keys, errorMessage = loadKeys()

    if not keys then
        return false, "Could not load key server."
    end

    local userId = tostring(LocalPlayer.UserId)
    local username = LocalPlayer.Name

    -- Try UserId first
    local account = keys[userId]

    -- Then try username
    if not account then
        account = keys[username]
    end

    if not account then
        return false, "No key is registered to this account."
    end

    if type(account) ~= "table" then
        return false, "Invalid key database entry."
    end

    -- Check key
    if tostring(account.key) ~= inputKey then
        return false, "Invalid key."
    end

    -- Check expiration
    local expires = tonumber(account.expires) or 0

    -- 0 = permanent
    if expires ~= 0 then

        local currentTime = os.time()

        if currentTime >= expires then
            return false, "This key has expired."
        end
    end

    return true, "Key verified successfully!"
end

--//==================================================
--// GUI
--//==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "KeySystem"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)

if not gui.Parent then
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--// Main window
local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(390, 245)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Color3.fromRGB(55, 55, 65)
frameStroke.Thickness = 1
frameStroke.Transparency = 0.2
frameStroke.Parent = frame

--// Top bar
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 52)
topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
topBar.BorderSizePixel = 0
topBar.Parent = frame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = topBar

-- Cover bottom rounded corners of top bar
local topCover = Instance.new("Frame")
topCover.Size = UDim2.new(1, 0, 0, 15)
topCover.Position = UDim2.new(0, 0, 1, -15)
topCover.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
topCover.BorderSizePixel = 0
topCover.Parent = topBar

--// Title
local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(18, 7)
title.Size = UDim2.new(1, -75, 0, 22)
title.Font = Enum.Font.GothamBold
title.Text = "Key Verification"
title.TextColor3 = Color3.fromRGB(245, 245, 250)
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

--// Subtitle
local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(19, 28)
subtitle.Size = UDim2.new(1, -80, 0, 18)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Enter your access key to continue"
subtitle.TextColor3 = Color3.fromRGB(145, 145, 155)
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = topBar

--// Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "Close"
closeButton.Size = UDim2.fromOffset(34, 34)
closeButton.Position = UDim2.new(1, -43, 0, 9)
closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 47)
closeButton.BorderSizePixel = 0
closeButton.Text = "×"
closeButton.Font = Enum.Font.GothamMedium
closeButton.TextSize = 22
closeButton.TextColor3 = Color3.fromRGB(220, 220, 225)
closeButton.AutoButtonColor = false
closeButton.Parent = topBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 9)
closeCorner.Parent = closeButton

closeButton.MouseEnter:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(65, 38, 42)
    closeButton.TextColor3 = Color3.fromRGB(255, 120, 125)
end)

closeButton.MouseLeave:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 47)
    closeButton.TextColor3 = Color3.fromRGB(220, 220, 225)
end)

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

--// Key textbox
local input = Instance.new("TextBox")
input.Name = "KeyInput"
input.Size = UDim2.new(1, -36, 0, 48)
input.Position = UDim2.fromOffset(18, 73)
input.BackgroundColor3 = Color3.fromRGB(29, 29, 35)
input.BorderSizePixel = 0
input.ClearTextOnFocus = false
input.PlaceholderText = "Enter your key..."
input.PlaceholderColor3 = Color3.fromRGB(105, 105, 115)
input.Text = ""
input.TextColor3 = Color3.fromRGB(235, 235, 240)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.Parent = frame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 10)
inputCorner.Parent = input

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(50, 50, 60)
inputStroke.Thickness = 1
inputStroke.Parent = input

input.Focused:Connect(function()
    inputStroke.Color = Color3.fromRGB(100, 100, 110)
end)

input.FocusLost:Connect(function()
    inputStroke.Color = Color3.fromRGB(50, 50, 60)
end)

--// Verify button
local verifyButton = Instance.new("TextButton")
verifyButton.Name = "Verify"
verifyButton.Size = UDim2.new(1, -36, 0, 45)
verifyButton.Position = UDim2.fromOffset(18, 131)
verifyButton.BackgroundColor3 = Color3.fromRGB(65, 105, 255)
verifyButton.BorderSizePixel = 0
verifyButton.Text = "Verify Key"
verifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
verifyButton.Font = Enum.Font.GothamBold
verifyButton.TextSize = 14
verifyButton.AutoButtonColor = false
verifyButton.Parent = frame

local verifyCorner = Instance.new("UICorner")
verifyCorner.CornerRadius = UDim.new(0, 10)
verifyCorner.Parent = verifyButton

verifyButton.MouseEnter:Connect(function()
    verifyButton.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
end)

verifyButton.MouseLeave:Connect(function()
    verifyButton.BackgroundColor3 = Color3.fromRGB(65, 105, 255)
end)

--// Status
local status = Instance.new("TextLabel")
status.Name = "Status"
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(18, 185)
status.Size = UDim2.new(1, -36, 0, 22)
status.Font = Enum.Font.Gotham
status.Text = "Waiting for key..."
status.TextColor3 = Color3.fromRGB(135, 135, 145)
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Center
status.Parent = frame

--// User information
local userLabel = Instance.new("TextLabel")
userLabel.BackgroundTransparency = 1
userLabel.Position = UDim2.fromOffset(18, 212)
userLabel.Size = UDim2.new(1, -36, 0, 20)
userLabel.Font = Enum.Font.Gotham
userLabel.Text = "User: " .. LocalPlayer.Name
userLabel.TextColor3 = Color3.fromRGB(90, 90, 100)
userLabel.TextSize = 10
userLabel.TextXAlignment = Enum.TextXAlignment.Center
userLabel.Parent = frame

--//==================================================
--// DRAGGING
--//==================================================

local dragging = false
local dragStart
local startPosition

local function updateDrag(inputObject)

    local delta = inputObject.Position - dragStart

    frame.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end

topBar.InputBegan:Connect(function(inputObject)

    if inputObject.UserInputType == Enum.UserInputType.MouseButton1
        or inputObject.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = inputObject.Position
        startPosition = frame.Position

        inputObject.Changed:Connect(function()

            if inputObject.UserInputState == Enum.UserInputState.End then
                dragging = false
            end

        end)
    end
end)

UserInputService.InputChanged:Connect(function(inputObject)

    if dragging and (
        inputObject.UserInputType == Enum.UserInputType.MouseMovement
        or inputObject.UserInputType == Enum.UserInputType.Touch
    ) then

        updateDrag(inputObject)
    end
end)

--//==================================================
--// VERIFY
--//==================================================

local checking = false

local function performVerification()

    if checking then
        return
    end

    checking = true

    verifyButton.Text = "Checking..."
    verifyButton.BackgroundColor3 = Color3.fromRGB(50, 80, 190)

    status.Text = "Connecting to key server..."
    status.TextColor3 = Color3.fromRGB(160, 160, 170)

    local valid, message = verifyKey(input.Text)

    if not valid then

        status.Text = message
        status.TextColor3 = Color3.fromRGB(255, 105, 110)

        verifyButton.Text = "Verify Key"
        verifyButton.BackgroundColor3 = Color3.fromRGB(65, 105, 255)

        checking = false
        return
    end

    -- Success
    status.Text = "✓ Key verified!"
    status.TextColor3 = Color3.fromRGB(100, 220, 145)

    verifyButton.Text = "Verified"
    verifyButton.BackgroundColor3 = Color3.fromRGB(50, 160, 100)

    task.wait(0.7)

    gui:Destroy()

    --// Load main script ONLY after verification
    local success, result = pcall(function()

        local source = game:HttpGet(MAIN_URL)

        if not source or source == "" then
            error("Main script returned an empty response.")
        end

        local mainFunction = loadstring(source)

        if not mainFunction then
            error("Could not compile main script.")
        end

        return mainFunction()
    end)

    if not success then
        warn("[KeySystem] Main script failed to load:", result)
    end
end

verifyButton.MouseButton1Click:Connect(performVerification)

input.FocusLost:Connect(function(enterPressed)

    if enterPressed then
        performVerification()
    end
end)
