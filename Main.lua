-- Cyan Hub Panel
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local noclipping = false
local invisible = false
local godmode = false
local AimlockEnabled = false
local espEnabled = false
local infJumpEnabled = false
local AimPart = "Head"
local FOVRadius = 150
local flySpeed = 50
local flyConnection = nil
local savedTeleportPos = nil

local currentSpeed = 16
local currentJumpPower = 50

local mobileUp = false
local mobileDown = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Transparency = 1
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = false

player.CharacterAdded:Connect(function(c)
	character = c
	humanoid = c:WaitForChild("Humanoid")
	rootPart = c:WaitForChild("HumanoidRootPart")
	humanoid.WalkSpeed = currentSpeed
	humanoid.JumpPower = currentJumpPower
end)

UserInputService.JumpRequest:Connect(function()
	if infJumpEnabled and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

local espObjects = {}

local function removeESP(p)
	if espObjects[p] then
		for _, obj in pairs(espObjects[p]) do obj:Remove() end
		espObjects[p] = nil
	end
end

local function createESP(p)
	if p == player then return end
	removeESP(p)
	local box = Drawing.new("Square")
	box.Thickness = 1
	box.Color = Color3.fromRGB(0, 200, 255)
	box.Transparency = 1
	box.Filled = false
	box.Visible = false
	local nameLbl = Drawing.new("Text")
	nameLbl.Size = 14
	nameLbl.Color = Color3.fromRGB(0, 200, 255)
	nameLbl.Transparency = 1
	nameLbl.Center = true
	nameLbl.Outline = true
	nameLbl.Visible = false
	nameLbl.Text = p.Name
	local healthLbl = Drawing.new("Text")
	healthLbl.Size = 12
	healthLbl.Color = Color3.fromRGB(0, 255, 100)
	healthLbl.Transparency = 1
	healthLbl.Center = true
	healthLbl.Outline = true
	healthLbl.Visible = false
	local distLbl = Drawing.new("Text")
	distLbl.Size = 12
	distLbl.Color = Color3.fromRGB(255, 220, 0)
	distLbl.Transparency = 1
	distLbl.Center = true
	distLbl.Outline = true
	distLbl.Visible = false
	espObjects[p] = {box, nameLbl, healthLbl, distLbl}
end

local function updateESP()
	for _, p in pairs(Players:GetPlayers()) do
		if p == player then continue end
		if not espObjects[p] and espEnabled then createESP(p) end
		if espObjects[p] then
			local char = p.Character
			local box = espObjects[p][1]
			local nameLbl = espObjects[p][2]
			local healthLbl = espObjects[p][3]
			local distLbl = espObjects[p][4]
			if not espEnabled or not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
				box.Visible = false
				nameLbl.Visible = false
				healthLbl.Visible = false
				distLbl.Visible = false
				continue
			end
			local hrp = char.HumanoidRootPart
			local hum = char.Humanoid
			local rootPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
			if not onScreen then
				box.Visible = false
				nameLbl.Visible = false
				healthLbl.Visible = false
				distLbl.Visible = false
				continue
			end
			local head = char:FindFirstChild("Head")
			local topPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.7, 0)) or rootPos
			local botPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
			local height = math.abs(topPos.Y - botPos.Y)
			local width = height * 0.5
			local x = rootPos.X - width / 2
			local y = topPos.Y
			box.Size = Vector2.new(width, height)
			box.Position = Vector2.new(x, y)
			box.Visible = true
			nameLbl.Position = Vector2.new(rootPos.X, y - 16)
			nameLbl.Text = p.Name
			nameLbl.Visible = true
			local hp = math.floor((hum.Health / hum.MaxHealth) * 100)
			healthLbl.Position = Vector2.new(rootPos.X, y + height + 2)
			healthLbl.Text = "HP: " .. hp .. "%"
			healthLbl.Color = Color3.fromRGB(math.floor(255*(1-hum.Health/hum.MaxHealth)), math.floor(255*(hum.Health/hum.MaxHealth)), 0)
			healthLbl.Visible = true
			local dist = math.floor((rootPart.Position - hrp.Position).Magnitude)
			distLbl.Position = Vector2.new(rootPos.X, y + height + 14)
			distLbl.Text = dist .. " studs"
			distLbl.Visible = true
		end
	end
end

Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

local function isVisible(targetPart)
	local origin = Camera.CFrame.Position
	local destination = targetPart.Position
	local direction = (destination - origin).Unit * (destination - origin).Magnitude
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {player.Character, Camera}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local result = workspace:Raycast(origin, direction, raycastParams)
	if result then return result.Instance:IsDescendantOf(targetPart.Parent) end
	return false
end

local function getClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = math.huge
	local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild(AimPart) and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
			local targetPart = v.Character[AimPart]
			local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
			if onScreen and isVisible(targetPart) then
				local magnitude = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
				if magnitude < FOVRadius and magnitude < shortestDistance then
					closestPlayer = v
					shortestDistance = magnitude
				end
			end
		end
	end
	return closestPlayer
end

player.Chatted:Connect(function(msg)
	if string.lower(msg) == "/aimlock" then
		AimlockEnabled = not AimlockEnabled
		FOVCircle.Visible = AimlockEnabled
	end
end)

RunService.RenderStepped:Connect(function()
	FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	if AimlockEnabled then
		local target = getClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild(AimPart) then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character[AimPart].Position)
		end
	end
	if noclipping and character then
		for _, part in pairs(character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
	if godmode and humanoid then
		humanoid.Health = humanoid.MaxHealth
	end
	updateESP()
end)

local function startFly()
	if not character or not rootPart then return end
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
		local dir = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
		if mobileUp then dir = dir + Vector3.new(0, 1, 0) end
		if mobileDown then dir = dir - Vector3.new(0, 1, 0) end
		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude > 0 then
			dir = dir + Vector3.new(moveDir.X, 0, moveDir.Z)
		end
		vel.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
		gyro.CFrame = Camera.CFrame
	end)
end

local function stopFly()
	humanoid.PlatformStand = false
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	if rootPart:FindFirstChild("FlyVel") then rootPart.FlyVel:Destroy() end
	if rootPart:FindFirstChild("FlyGyro") then rootPart.FlyGyro:Destroy() end
end

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CyanHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player.PlayerGui

local mobileControls = Instance.new("Frame")
mobileControls.Size = UDim2.new(0, 110, 0, 50)
mobileControls.Position = UDim2.new(1, -120, 1, -160)
mobileControls.BackgroundTransparency = 1
mobileControls.Visible = false
mobileControls.Parent = screenGui

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 50, 0, 50)
upBtn.Position = UDim2.new(0, 0, 0, 0)
upBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 210)
upBtn.TextColor3 = Color3.new(1, 1, 1)
upBtn.Text = "▲"
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 20
upBtn.BorderSizePixel = 0
upBtn.Parent = mobileControls
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 8)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 50, 0, 50)
downBtn.Position = UDim2.new(0, 58, 0, 0)
downBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 140)
downBtn.TextColor3 = Color3.new(1, 1, 1)
downBtn.Text = "▼"
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 20
downBtn.BorderSizePixel = 0
downBtn.Parent = mobileControls
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 8)

upBtn.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then mobileUp = true end
end)
upBtn.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then mobileUp = false end
end)
downBtn.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then mobileDown = true end
end)
downBtn.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then mobileDown = false end
end)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 100, 0, 30)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 220)
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.Text = "✦ Cyan Hub"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.BorderSizePixel = 0
toggleBtn.Visible = false
toggleBtn.Parent = screenGui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 270, 0, 580)
panel.Position = UDim2.new(0, 10, 0, 10)
panel.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
panel.Active = true
panel.Draggable = true
panel.Visible = true
panel.Parent = screenGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 2

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 170, 210)
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

local uiPad = Instance.new("UIPadding", content)
uiPad.PaddingTop = UDim.new(0, 4)
uiPad.PaddingBottom = UDim.new(0, 4)

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

local function makeButton(labelText, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.BackgroundColor3 = color
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = labelText
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.BorderSizePixel = 0
	btn.Parent = content
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
	btn.MouseButton1Click:Connect(callback)
	return btn
end

local function makeStepper(labelText, defaultVal, minVal, maxVal, step, onChange)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 36)
	row.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	row.BorderSizePixel = 0
	row.Parent = content
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5, 0, 1, 0)
	lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row

	local minusBtn = Instance.new("TextButton")
	minusBtn.Size = UDim2.new(0, 28, 0, 26)
	minusBtn.Position = UDim2.new(1, -96, 0.5, -13)
	minusBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 140)
	minusBtn.TextColor3 = Color3.new(1,1,1)
	minusBtn.Text = "−"
	minusBtn.Font = Enum.Font.GothamBold
	minusBtn.TextSize = 16
	minusBtn.BorderSizePixel = 0
	minusBtn.Parent = row
	Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 5)

	local valLbl = Instance.new("TextLabel")
	valLbl.Size = UDim2.new(0, 36, 0, 26)
	valLbl.Position = UDim2.new(1, -64, 0.5, -13)
	valLbl.BackgroundTransparency = 1
	valLbl.Text = tostring(defaultVal)
	valLbl.TextColor3 = Color3.fromRGB(0, 220, 255)
	valLbl.Font = Enum.Font.GothamBold
	valLbl.TextSize = 13
	valLbl.Parent = row

	local plusBtn = Instance.new("TextButton")
	plusBtn.Size = UDim2.new(0, 28, 0, 26)
	plusBtn.Position = UDim2.new(1, -30, 0.5, -13)
	plusBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 190)
	plusBtn.TextColor3 = Color3.new(1,1,1)
	plusBtn.Text = "+"
	plusBtn.Font = Enum.Font.GothamBold
	plusBtn.TextSize = 16
	plusBtn.BorderSizePixel = 0
	plusBtn.Parent = row
	Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 5)

	local val = defaultVal
	minusBtn.MouseButton1Click:Connect(function()
		val = math.max(minVal, val - step)
		valLbl.Text = tostring(val)
		onChange(val)
	end)
	plusBtn.MouseButton1Click:Connect(function()
		val = math.min(maxVal, val + step)
		valLbl.Text = tostring(val)
		onChange(val)
	end)
end

-- SECTIONS
makeLabel("COMBAT")
makeToggle("Aimlock (/aimlock to toggle)", function(state)
	AimlockEnabled = state
	FOVCircle.Visible = state
end)
makeToggle("ESP", function(state)
	espEnabled = state
	if not state then
		for p in pairs(espObjects) do removeESP(p) end
	end
end)

makeLabel("MOVEMENT")
makeToggle("Fly", function(state)
	flying = state
	if state then
		startFly()
		mobileControls.Visible = true
	else
		stopFly()
		mobileControls.Visible = false
		mobileUp = false
		mobileDown = false
	end
end)
makeToggle("Noclip", function(state)
	noclipping = state
	if not state and character then
		for _, p in pairs(character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = true end
		end
	end
end)

-- Shift Lock
local shiftLockEnabled = false

local function enableShiftLock()
	RunService:BindToRenderStep("ShiftLock", Enum.RenderPriority.Camera.Value + 1, function()
		if not shiftLockEnabled then return end
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z))
		end
	end)
	local UserGameSettings = UserSettings():GetService("UserGameSettings")
	UserGameSettings.RotationType = Enum.RotationType.CameraRelative
end

local function disableShiftLock()
	RunService:UnbindFromRenderStep("ShiftLock")
	local UserGameSettings = UserSettings():GetService("UserGameSettings")
	UserGameSettings.RotationType = Enum.RotationType.MovementRelative
end

makeToggle("Infinite Jump", function(state)
	infJumpEnabled = state
end)
makeToggle("Shift Lock", function(state)
	shiftLockEnabled = state
	if state then enableShiftLock() else disableShiftLock() end
end)

makeLabel("SPEED")
makeStepper("Walk Speed", currentSpeed, 4, 500, 4, function(val)
	currentSpeed = val
	if humanoid then humanoid.WalkSpeed = val end
end)

makeLabel("JUMP POWER")
makeStepper("Jump Power", currentJumpPower, 10, 500, 10, function(val)
	currentJumpPower = val
	if humanoid then humanoid.JumpPower = val end
end)

makeLabel("TELEPORT")

local tpStatusLbl = Instance.new("TextLabel")
tpStatusLbl.Size = UDim2.new(1, 0, 0, 20)
tpStatusLbl.BackgroundTransparency = 1
tpStatusLbl.Text = "No position saved"
tpStatusLbl.TextColor3 = Color3.fromRGB(120, 120, 120)
tpStatusLbl.Font = Enum.Font.Gotham
tpStatusLbl.TextSize = 11
tpStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
tpStatusLbl.Parent = content
local tpPad = Instance.new("UIPadding", tpStatusLbl)
tpPad.PaddingLeft = UDim.new(0, 6)

makeButton("Set Teleport", Color3.fromRGB(0, 110, 80), function()
	if rootPart then
		savedTeleportPos = rootPart.CFrame
		local pos = savedTeleportPos.Position
		tpStatusLbl.Text = string.format("Saved: %.0f, %.0f, %.0f", pos.X, pos.Y, pos.Z)
		tpStatusLbl.TextColor3 = Color3.fromRGB(0, 200, 255)
	end
end)

makeButton("Teleport", Color3.fromRGB(80, 0, 130), function()
	if savedTeleportPos and rootPart then
		rootPart.CFrame = savedTeleportPos
	else
		tpStatusLbl.Text = "Set a position first!"
		tpStatusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
	end
end)

makeLabel("PLAYER")
makeToggle("Invisible", function(state)
	invisible = state
	if character then
		for _, v in pairs(character:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("Decal") then
				v.Transparency = state and 1 or 0
			end
		end
	end
end)
makeToggle("Godmode", function(state)
	godmode = state
	if state and humanoid then
		humanoid.MaxHealth = 9e9
		humanoid.Health = 9e9
	elseif humanoid then
		humanoid.MaxHealth = 100
		humanoid.Health = 100
	end
end)

hideBtn.MouseButton1Click:Connect(function()
	panel.Visible = false
	toggleBtn.Visible = true
end)

closeBtn.MouseButton1Click:Connect(function()
	for p in pairs(espObjects) do removeESP(p) end
	FOVCircle:Remove()
	screenGui:Destroy()
end)

toggleBtn.MouseButton1Click:Connect(function()
	panel.Visible = true
	toggleBtn.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
		panel.Visible = not panel.Visible
		toggleBtn.Visible = not panel.Visible
	end
end)

print("Cyan Hub Loaded!")
