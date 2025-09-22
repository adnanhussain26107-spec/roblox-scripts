-- Childhood GUI Script
-- Features: Draggable, Minimizable, Closable
-- Buttons: Double Jump + 2x Speed + AutoKill (toggle if holding tool)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Childhood"
ScreenGui.Parent = player:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 250)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, -60, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Childhood"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold

local CloseBtn = Instance.new("TextButton", Frame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255,100,100)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextScaled = true

local MinBtn = Instance.new("TextButton", Frame)
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255,255,100)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextScaled = true

local Content = Instance.new("Frame", Frame)
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 40)
Content.BackgroundTransparency = 1

-- Button creator
local function createButton(name, y)
	local btn = Instance.new("TextButton", Content)
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.Position = UDim2.new(0, 0, 0, y)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(200,200,200)
	btn.Font = Enum.Font.Gotham
	btn.TextScaled = true
	btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", btn).Color = Color3.fromRGB(100,100,100)
	return btn
end

local DoubleJumpBtn = createButton("Double Jump", 0)
local SpeedBtn = createButton("2x Speed", 50)
local AutoKillBtn = createButton("AutoKill", 100)

-- Animate buttons
local function animateButton(btn)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80,80,80)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60,60,60)}):Play()
	end)
end

animateButton(DoubleJumpBtn)
animateButton(SpeedBtn)
animateButton(AutoKillBtn)

-- Close w/ fade
CloseBtn.MouseButton1Click:Connect(function()
	local tween = TweenService:Create(Frame, TweenInfo.new(0.4), {BackgroundTransparency = 1})
	tween:Play()
	for _, obj in pairs(Frame:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			TweenService:Create(obj, TweenInfo.new(0.4), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
		end
	end
	tween.Completed:Wait()
	ScreenGui:Destroy()
end)

-- Minimize w/ shrink
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		TweenService:Create(Frame, TweenInfo.new(0.4), {Size = UDim2.new(0, 300, 0, 40)}):Play()
		Content.Visible = false
	else
		TweenService:Create(Frame, TweenInfo.new(0.4), {Size = UDim2.new(0, 300, 0, 250)}):Play()
		task.wait(0.4)
		Content.Visible = true
	end
end)

-- Double Jump
local doubleJumpEnabled = false
local canDouble = false

DoubleJumpBtn.MouseButton1Click:Connect(function()
	doubleJumpEnabled = not doubleJumpEnabled
	DoubleJumpBtn.Text = doubleJumpEnabled and "Double Jump ✅" or "Double Jump"
end)

humanoid.StateChanged:Connect(function(_, new)
	if new == Enum.HumanoidStateType.Freefall and doubleJumpEnabled then
		canDouble = true
	end
end)

UserInputService.JumpRequest:Connect(function()
	if canDouble and doubleJumpEnabled and humanoid:GetState() ~= Enum.HumanoidStateType.Seated then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		canDouble = false
	end
end)

-- Speed Boost
local normalSpeed = humanoid.WalkSpeed
local speedEnabled = false

SpeedBtn.MouseButton1Click:Connect(function()
	speedEnabled = not speedEnabled
	if speedEnabled then
		humanoid.WalkSpeed = normalSpeed * 2
		SpeedBtn.Text = "2x Speed ✅"
	else
		humanoid.WalkSpeed = normalSpeed
		SpeedBtn.Text = "2x Speed"
	end
end)

-- AutoKill toggle
local autoKillEnabled = false
AutoKillBtn.MouseButton1Click:Connect(function()
	autoKillEnabled = not autoKillEnabled
	AutoKillBtn.Text = autoKillEnabled and "AutoKill ✅" or "AutoKill"
end)

-- AutoKill loop (only if holding a tool)
RunService.RenderStepped:Connect(function()
	if autoKillEnabled and char and char:FindFirstChild("HumanoidRootPart") then
		local toolEquipped = char:FindFirstChildOfClass("Tool") -- checks if holding any tool
		if toolEquipped then
			for _, otherPlayer in pairs(game.Players:GetPlayers()) do
				if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") then
					local targetHumanoid = otherPlayer.Character.Humanoid
					local distance = (char.HumanoidRootPart.Position - otherPlayer.Character.HumanoidRootPart.Position).Magnitude
					if distance <= 50 then
						targetHumanoid.Health = 0
					end
				end
			end
		end
	end
end)

-- Reset speed on respawn
player.CharacterAdded:Connect(function(c)
	char = c
	humanoid = c:WaitForChild("Humanoid")
	if speedEnabled then
		humanoid.WalkSpeed = normalSpeed * 2
	end
end)