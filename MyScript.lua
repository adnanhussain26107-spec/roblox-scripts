-- TALENTLESS Piano GUI
-- Executor-ready, Discord popup removed, Minimize + Close buttons, Draggable

local NotificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/hellohellohell012321/TALENTLESS/main/notif_lib.lua"))()
local ContentProvider = game:GetService("ContentProvider")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Preload assets
local assetsToPreload = {
    "rbxassetid://76156993128854",
    "rbxassetid://137655053511068",
    "rbxassetid://70452176150315",
    "rbxassetid://1524549907",
    "rbxassetid://6493287948",
    "rbxassetid://104269922408932",
}
ContentProvider:PreloadAsync(assetsToPreload)

-- Play sound helper
local function playSound(soundId, loudness)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://"..soundId
    sound.Parent = player.Character or player
    sound.Volume = loudness or 1
    sound:Play()
end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "TALENTLESS_GUI"

-- Main frame
local frame = Instance.new("Frame")
frame.Name = "frame"
frame.Parent = ScreenGui
frame.BackgroundColor3 = Color3.fromRGB(33,33,41)
frame.Position = UDim2.new(0.5,0,0.5,0)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Size = UDim2.new(0,475,0,272)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,4)

-- Title
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,50)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundColor3 = Color3.fromRGB(50,57,73)
title.Text = "TALENTLESS"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 46
title.TextScaled = true
Instance.new("UICorner", title).CornerRadius = UDim.new(0,4)

-- Minimize button
local MinBtn = Instance.new("TextButton", frame)
MinBtn.Size = UDim2.new(0,30,0,30)
MinBtn.Position = UDim2.new(1,-70,0,10)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextScaled = true
MinBtn.TextColor3 = Color3.fromRGB(255,255,100)

-- Close button
local CloseBtn = Instance.new("TextButton", frame)
CloseBtn.Size = UDim2.new(0,30,0,30)
CloseBtn.Position = UDim2.new(1,-35,0,10)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true
CloseBtn.TextColor3 = Color3.fromRGB(255,100,100)

-- Search frame
local searchframe = Instance.new("Frame", frame)
searchframe.Position = UDim2.new(0.05,0,0.12,0)
searchframe.Size = UDim2.new(0,400,0,35)
searchframe.BackgroundColor3 = Color3.fromRGB(50,57,73)
searchframe.BorderSizePixel = 0

local searchbar = Instance.new("TextBox", searchframe)
searchbar.Size = UDim2.new(1,-10,1,-10)
searchbar.Position = UDim2.new(0,5,0,5)
searchbar.BackgroundColor3 = Color3.fromRGB(96,102,121)
searchbar.TextColor3 = Color3.fromRGB(255,255,255)
searchbar.PlaceholderText = "search..."
searchbar.ClearTextOnFocus = false
searchbar.Text = ""
searchbar.Font = Enum.Font.SourceSansBold
searchbar.TextScaled = true

-- Scroll frame for songs
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.new(0.05,0,0.25,0)
scroll.Size = UDim2.new(0,400,0,180)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local listLayout = Instance.new("UIListLayout", scroll)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0,10)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Toggle button
local toggle = Instance.new("TextButton", ScreenGui)
toggle.Size = UDim2.new(0,136,0,40)
toggle.Position = UDim2.new(0,0,0.5,0)
toggle.AnchorPoint = Vector2.new(0,0.5)
toggle.BackgroundColor3 = Color3.fromRGB(50,57,73)
toggle.BorderSizePixel = 4
toggle.Text = "toggle ui"
toggle.TextColor3 = Color3.fromRGB(255,255,255)
toggle.TextSize = 29
toggle.Font = Enum.Font.SourceSansBold

toggle.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    playSound(frame.Visible and 70452176150315 or 1524549907,0.1)
end)

-- Dragging frame
local dragging
local dragInput
local dragStart
local startPos
local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X,
                               startPos.Y.Scale, startPos.Y.Offset+delta.Y)
end
frame.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then dragging=false end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input==dragInput and dragging then update(input) end
end)

-- Minimize
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        frame.Size = UDim2.new(0,475,0,60)
        scroll.Visible = false
        searchframe.Visible = false
    else
        frame.Size = UDim2.new(0,475,0,272)
        scroll.Visible = true
        searchframe.Visible = true
    end
end)

-- Close
CloseBtn.MouseButton1Click:Connect(function()
    frame:Destroy()
    toggle:Destroy()
end)

-- Function to create a song button with favorite
local function newSongButton(name)
    local btn = Instance.new("TextButton")
    btn.Parent = scroll
    btn.Size = UDim2.new(0,350,0,30)
    btn.BackgroundColor3 = Color3.fromRGB(76,82,101)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextScaled = true
    btn.Text = name
    
    local favButton = Instance.new("ImageButton", btn)
    favButton.AnchorPoint = Vector2.new(0,0.5)
    favButton.Position = UDim2.new(0,0,0.5,0)
    favButton.Size = UDim2.new(0,25,0,25)
    favButton.Image = "rbxassetid://76156993128854"
    favButton.BackgroundTransparency = 1
    
    return btn
end

-- Example songs
local songs = {"505","7 WEEKS & 3 DAYS","A THOUSAND MILES","ALONE","ASTRONAMIA"}
for _,song in ipairs(songs) do
    newSongButton(song)
end

-- Filter songs by search
searchbar:GetPropertyChangedSignal("Text"):Connect(function()
    local query = searchbar.Text:lower()
    for _,child in pairs(scroll:GetChildren()) do
        if child:IsA("TextButton") then
            child.Visible = child.Text:lower():find(query) and true or false
        end
    end
end)

-- MIDI spoof option (only for specific game)
local gameId = game.GameId
if gameId == 3929033413 then
    local spoofMidiPlz = false
    local spoofMidi = Instance.new("TextButton", frame)
    spoofMidi.Size = UDim2.new(0,103,0,20)
    spoofMidi.Position = UDim2.new(0.68,0,0.9,0)
    spoofMidi.BackgroundTransparency = 1
    spoofMidi.Font = Enum.Font.SourceSansItalic
    spoofMidi.Text = "spoof midi [ ]"
    spoofMidi.TextColor3 = Color3.fromRGB(255,255,255)
    spoofMidi.TextSize = 23
    
    spoofMidi.MouseButton1Click:Connect(function()
        spoofMidiPlz = not spoofMidiPlz
        spoofMidi.Text = spoofMidiPlz and "spoof midi [x]" or "spoof midi [ ]"
        NotificationLibrary:SendNotification("Success", "MIDI spoofing "..(spoofMidiPlz and "on" or "off"),5)
    end)
end