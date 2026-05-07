-- Cyan Hub Panel (FULLY RESTORED + AIMLOCK)
-- Place in StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- // Original Variables
local flying = false
local noclipping = false
local invisible = false
local godmode = false
local flySpeed = 50
local jumpHeight = 50
local walkSpeed = 16
local flyConnection = nil
local noclipConnection = nil

-- // Aimlock Variables
local AimlockEnabled = false
local AimPart = "Head"
local FOVRadius = 150

-- // FOV Circle Setup
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
	flying = false
	noclipping = false
	invisible = false
	godmode = false
end)

-- // Aimlock Logic
local function getClosestPlayer()
	local closestPlayer = nil
	local shortestDistance = math.huge
	local mousePos = UserInputService:GetMouseLocation()

	for _, v in pairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild(AimPart) and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
			local pos, onScreen = Camera:WorldToViewportPoint(v.Character[AimPart].Position)
			if onScreen then
				local magnitude = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
				if magnitude < FOVRadius and magnitude < shortestDistance then
					closestPlayer = v
					shortestDistance = magnitude
				end
			end
		end
	end
	return closestPlayer
end

-- // Chat Command Logic
player.Chatted:Connect(function(msg)
	if string.lower(msg) == "/aimlock" then
		AimlockEnabled = not AimlockEnabled
		FOVCircle.Visible = AimlockEnabled
	end
end)

-- // Main Update Loop (Handles Noclip & Aimlock)
RunService.RenderStepped:Connect(function()
	FOVCircle.Position = UserInputService:GetMouseLocation()
	
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
end)

-- // UI SETUP
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CyanHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 270, 0, 480)
panel.Position = UDim2.new(0, 10, 0, 10)
panel.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
panel.Active = true
panel.Draggable = true
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

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "✦ Cyan Hub Admin"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -16, 1, -50)
content.Position = UDim2.new(0, 8, 0, 48)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 3
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = panel

local layout = Instance.new("UIListLayout", content)
layout.Padding = UDim.new(0, 6)

-- Helper Functions
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
	btn.Parent = content
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
	
	local active = false
	btn.MouseButton1Click:Connect(function()
		active = not active
		btn.Text = (active and "[ON]  " or "[OFF]  ") .. labelText
		btn.TextColor3 = active and Color3.fromRGB(0, 220, 255) or Color3.fromRGB(180, 180, 180)
		btn.BackgroundColor3 = active and Color3.fromRGB(0, 50, 70) or Color3.fromRGB(25, 25, 35)
		callback(active)
	end)
end

-- // LISTING THE COMMANDS
makeLabel("COMBAT")
makeToggle("Aimlock (/aimlock)", function(state)
	AimlockEnabled = state
	FOVCircle.Visible = state
end)

makeLabel("MOVEMENT")
makeToggle("Fly", function(state) flying = state end)
makeToggle("Noclip", function(state) noclipping = state end)

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
	if godmode and humanoid then
		humanoid.MaxHealth = math.huge
		humanoid.Health = math.huge
	else
		humanoid.MaxHealth = 100
		humanoid.Health = 100
	end
end)

print("Cyan Hub FULLY Restored. Keybind: RightControl")

-- Toggle UI Keybind
UserInputService.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
		panel.Visible = not panel.Visible
	end
end)
