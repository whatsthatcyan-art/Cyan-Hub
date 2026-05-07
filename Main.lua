-- Cyan Hub Panel
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local noclipping = false
local invisible = false
local godmode = false
local flySpeed = 50
local jumpHeight = 50
local walkSpeed = 16
local flyConnection = nil
local noclipConnection = nil

player.CharacterAdded:Connect(function(c)
	character = c
	humanoid = c:WaitForChild("Humanoid")
	rootPart = c:WaitForChild("HumanoidRootPart")
	flying = false
	noclipping = false
	invisible = false
	godmode = false
end)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CyanHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 100, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 220)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Text = "Cyan Hub"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.BorderSizePixel = 0
toggleBtn.Visible = false
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 270, 0, 480)
panel.Position = UDim2.new(0, 10, 0, 10)
panel.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
panel.BorderSizePixel = 0
panel.Parent = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 2

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 170, 210)
titleBar.BorderSizePixel = 0
titleBar.Parent = panel
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local tbFix = Instance.new("Frame")
tbFix.Size = UDim2.new(1, 0, 0.5, 0)
tbFix.Position = UDim2.new(0, 0, 0.5, 0)
tbFix.BackgroundColor3 = Color3.fromRGB(0, 170, 210)
tbFix.BorderSizePixel = 0
tbFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "✦ Cyan Hub"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(0, 28, 0, 24)
hideBtn.Position = UDim2.new(1, -62, 0.5, -12)
hideBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
hideBtn.TextColor3 = Color3.new(1, 1, 1)
hideBtn.Text = "—"
hideBtn.Font = Enum.Font.GothamBold
hideBtn.TextSize = 14
hideBtn.BorderSizePixel = 0
hideBtn.Parent = titleBar
Instance.new("UICorner", hideBtn).CornerRadius = UDim.new(0, 5)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -16, 1, -50)
content.Position = UDim2.new(0, 8, 0, 48)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = panel

local layout = Instance.new("UIListLayout", content)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local padding = Instance.new("UIPadding", content)
padding.PaddingTop = UDim.new(0, 4)
padding.PaddingBottom = UDim.new(0, 4)

local function makeLabel(text)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 18)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(0, 200, 255)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = content
end

local function makeToggle(labelText, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	btn.TextColor3 = Color3.fromRGB(180, 180, 180)
	btn.Text = "[OFF]  " .. labelText
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.BorderSizePixel = 0
	btn.Parent = content
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
	local pad = Instance.new("UIPadding", btn)
	pad.PaddingLeft = UDim.new(0, 10)

	local active = false
	btn.MouseButton1Click:Connect(function()
		active = not active
		btn.Text = (active and "[ON]  " or "[OFF]  ") .. labelText
		btn.TextColor3 = active and Color3.fromRGB(0, 220, 255) or Color3.fromRGB(180, 180, 180)
		btn.BackgroundColor3 = active and Color3.fromRGB(0, 50, 70) or Color3.fromRGB(25, 25, 35)
		callback(active)
	end)
end

-- Fixed slider using InputBegan/Changed on the track itself
local function makeSlider(labelText, minVal, maxVal, default, callback)
	local holder = Instance.new("Frame")
	holder.Size = UDim2.new(1, 0, 0, 54)
	holder.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	holder.BorderSizePixel = 0
	holder.Parent = content
	Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 7)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -10, 0, 22)
	lbl.Position = UDim2.new(0, 10, 0, 4)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText .. ": " .. default
	lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 12
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = holder

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, -20, 0, 8)
	track.Position = UDim2.new(0, 10, 0, 34)
	track.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
	track.BorderSizePixel = 0
	track.Parent = holder
	Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
	fill.BorderSizePixel = 0
	fill.Parent = track
	Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = UDim2.new((default - minVal) / (maxVal - minVal), -8, 0.5, -8)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.Parent = track
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local dragging = false

	local function updateSlider(inputX)
		local trackAbs = track.AbsolutePosition
		local trackSize = track.AbsoluteSize
		local rel = math.clamp((inputX - trackAbs.X) / trackSize.X, 0, 1)
		local val = math.floor(minVal + rel * (maxVal - minVal))
		fill.Size = UDim2.new(rel, 0, 1, 0)
		knob.Position = UDim2.new(rel, -8, 0.5, -8)
		lbl.Text = labelText .. ": " .. val
		callback(val)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or
			input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateSlider(input.Position.X)
		end
	end)

	knob.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or
			input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
			input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or
			input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- ===================== FEATURES =====================

makeLabel("  MOVEMENT")

makeToggle("Fly", function(on)
	flying = on
	if on then
		humanoid.PlatformStand = true
		local vel = Instance.new("BodyVelocity", rootPart)
		vel.Name = "FlyVel"
		vel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		vel.Velocity = Vector3.zero
		local gyro = Instance.new("BodyGyro", rootPart)
		gyro.Name = "FlyGyro"
		gyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		gyro.P = 1e4

		flyConnection = RunService.Heartbeat:Connect(function()
			if not flying then return end
			local cam = workspace.CurrentCamera
			local dir = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
			vel.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
			gyro.CFrame = cam.CFrame
		end)
	else
		humanoid.PlatformStand = false
		if flyConnection then flyConnection:Disconnect() flyConnection = nil end
		if rootPart:FindFirstChild("FlyVel") then rootPart.FlyVel:Destroy() end
		if rootPart:FindFirstChild("FlyGyro") then rootPart.FlyGyro:Destroy() end
	end
end)

makeToggle("Noclip", function(on)
	noclipping = on
	if on then
		noclipConnection = RunService.Stepped:Connect(function()
			for _, p in ipairs(character:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end)
	else
		if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
		for _, p in ipairs(character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = true end
		end
	end
end)

makeLabel("  SPEED")
makeSlider("Walk Speed", 16, 300, 16, function(val)
	walkSpeed = val
	humanoid.WalkSpeed = val
end)

makeLabel("  FLY SPEED")
makeSlider("Fly Speed", 10, 300, 50, function(val)
	flySpeed = val
end)

makeLabel("  JUMP")
makeSlider("Jump Height", 50, 500, 50, function(val)
	jumpHeight = val
	humanoid.JumpHeight = val
end)

makeLabel("  MISC")

makeToggle("Invisible", function(on)
	invisible = on
	for _, p in ipairs(character:GetDescendants()) do
		if p:IsA("BasePart") or p:IsA("Decal") then
			p.Transparency = on and 1 or 0
		end
	end
	if on then rootPart.Transparency = 1 end
end)

makeToggle("Godmode", function(on)
	godmode = on
	if on then
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
	else
		humanoid.MaxHealth = 100
		humanoid.Health = 100
	end
end)

-- ===================== PANEL CONTROLS =====================

hideBtn.MouseButton1Click:Connect(function()
	panel.Visible = false
	toggleBtn.Visible = true
end)

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

toggleBtn.MouseButton1Click:Connect(function()
	panel.Visible = true
	toggleBtn.Visible = false
end)

-- Draggable panel
local draggingPanel = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingPanel = true
		dragStart = input.Position
		startPos = panel.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingPanel and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		panel.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingPanel = false
	end
end)
