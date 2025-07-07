local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local replicated = game:GetService("ReplicatedStorage")
local events = replicated:WaitForChild("Events")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local camera = Workspace.CurrentCamera

local function getHumanoid()
	local character = player.Character or player.CharacterAdded:Wait()
	return character:WaitForChild("Humanoid")
end

local humanoid = getHumanoid()

local suitSaves = player:WaitForChild("SuitSaves")
for _, v in ipairs(suitSaves:GetChildren()) do
	if v:IsA("BoolValue") then
		v.Value = true
	end
end

local function updateLevelLoop()
	while true do
		local stats = player:FindFirstChild("STATS")
		if stats then
			local level = stats:FindFirstChild("Level")
			if level and level:IsA("IntValue") then
				level.Value = 999
			end
		end
		task.wait(1)
	end
end
spawn(updateLevelLoop)

player.CharacterAdded:Connect(function()
	humanoid = getHumanoid()
	spawn(updateLevelLoop)
end)

local ui = Instance.new("ScreenGui")
ui.Name = "SpeedMenu"
ui.ResetOnSpawn = false
ui.IgnoreGuiInset = true
ui.Parent = playerGui

local btn3 = Instance.new("TextButton")
btn3.Size = UDim2.new(0, 30, 0, 30)
btn3.Position = UDim2.new(1, -40, 0, 10)
btn3.Text = "3"
btn3.TextScaled = true
btn3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
btn3.BackgroundTransparency = 0.4
btn3.TextColor3 = Color3.new(1, 1, 1)
btn3.BorderSizePixel = 0
btn3.Parent = ui
Instance.new("UICorner", btn3).CornerRadius = UDim.new(1, 0)

btn3.MouseButton1Click:Connect(function()
	local emoteGui = playerGui:FindFirstChild("Emoteui")
	if emoteGui then
		local container3 = emoteGui:FindFirstChild("container3")
		if container3 then
			container3.Visible = true
		end
	end
end)

local menuToggle = Instance.new("TextButton")
menuToggle.Size = UDim2.new(0, 30, 0, 30)
menuToggle.Position = UDim2.new(1, -80, 0, 10)
menuToggle.Text = "M"
menuToggle.TextScaled = true
menuToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
menuToggle.BackgroundTransparency = 0.4
menuToggle.TextColor3 = Color3.new(1, 1, 1)
menuToggle.BorderSizePixel = 0
menuToggle.Parent = ui
Instance.new("UICorner", menuToggle).CornerRadius = UDim.new(1, 0)

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 180, 0, 325)
menuFrame.Position = UDim2.new(1, -200, 0, 20)
menuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
menuFrame.BackgroundTransparency = 1
menuFrame.Visible = false
menuFrame.Parent = ui
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 12)

local medkitBtn = Instance.new("TextButton")
medkitBtn.Size = UDim2.new(1, -20, 0, 35)
medkitBtn.Position = UDim2.new(0, 10, 0, 10)
medkitBtn.Text = "Medkit"
medkitBtn.TextScaled = true
medkitBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
medkitBtn.BackgroundTransparency = 0.4
medkitBtn.TextColor3 = Color3.new(1, 1, 1)
medkitBtn.BorderSizePixel = 0
medkitBtn.Parent = menuFrame
Instance.new("UICorner", medkitBtn).CornerRadius = UDim.new(1, 0)

local coilBtn = Instance.new("TextButton")
coilBtn.Size = UDim2.new(1, -20, 0, 35)
coilBtn.Position = UDim2.new(0, 10, 0, 55)
coilBtn.Text = "Speed Coil"
coilBtn.TextScaled = true
coilBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
coilBtn.BackgroundTransparency = 0.4
coilBtn.TextColor3 = Color3.new(1, 1, 1)
coilBtn.BorderSizePixel = 0
coilBtn.Parent = menuFrame
Instance.new("UICorner", coilBtn).CornerRadius = UDim.new(1, 0)

local vestBtn = Instance.new("TextButton")
vestBtn.Size = UDim2.new(1, -20, 0, 35)
vestBtn.Position = UDim2.new(0, 10, 0, 100)
vestBtn.Text = "Vest"
vestBtn.TextScaled = true
vestBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
vestBtn.BackgroundTransparency = 0.4
vestBtn.TextColor3 = Color3.new(1, 1, 1)
vestBtn.BorderSizePixel = 0
vestBtn.Parent = menuFrame
Instance.new("UICorner", vestBtn).CornerRadius = UDim.new(1, 0)

local godmodeBtn = Instance.new("TextButton")
godmodeBtn.Size = UDim2.new(1, -20, 0, 35)
godmodeBtn.Position = UDim2.new(0, 10, 0, 145)
godmodeBtn.Text = "Godmode: OFF"
godmodeBtn.TextScaled = true
godmodeBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
godmodeBtn.BackgroundTransparency = 0.4
godmodeBtn.TextColor3 = Color3.new(1, 1, 1)
godmodeBtn.BorderSizePixel = 0
godmodeBtn.Parent = menuFrame
Instance.new("UICorner", godmodeBtn).CornerRadius = UDim.new(1, 0)

local lvlCompleteBtn = Instance.new("TextButton")
lvlCompleteBtn.Size = UDim2.new(1, -20, 0, 35)
lvlCompleteBtn.Position = UDim2.new(0, 10, 0, 190)
lvlCompleteBtn.Text = "Lvl Complete"
lvlCompleteBtn.TextScaled = true
lvlCompleteBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
lvlCompleteBtn.BackgroundTransparency = 0.4
lvlCompleteBtn.TextColor3 = Color3.new(1, 1, 1)
lvlCompleteBtn.BorderSizePixel = 0
lvlCompleteBtn.Parent = menuFrame
Instance.new("UICorner", lvlCompleteBtn).CornerRadius = UDim.new(1, 0)

local speedLoopToggle = Instance.new("TextButton")
speedLoopToggle.Size = UDim2.new(1, -20, 0, 35)
speedLoopToggle.Position = UDim2.new(0, 10, 0, 235)
speedLoopToggle.Text = "Speed Loop: ON"
speedLoopToggle.TextScaled = true
speedLoopToggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
speedLoopToggle.BackgroundTransparency = 0.4
speedLoopToggle.TextColor3 = Color3.new(1, 1, 1)
speedLoopToggle.BorderSizePixel = 0
speedLoopToggle.Parent = menuFrame
Instance.new("UICorner", speedLoopToggle).CornerRadius = UDim.new(1, 0)

local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(1, -20, 0, 35)
speedInput.Position = UDim2.new(0, 10, 0, 280)
speedInput.PlaceholderText = "Enter speed (16-80)"
speedInput.ClearTextOnFocus = false
speedInput.Text = "16"
speedInput.TextScaled = true
speedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedInput.TextColor3 = Color3.new(1, 1, 1)
speedInput.BorderSizePixel = 0
speedInput.Parent = menuFrame
Instance.new("UICorner", speedInput).CornerRadius = UDim.new(1, 0)

local speedLoopEnabled = true
local godmodeEnabled = false
local speedValue = 16

speedInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local num = tonumber(speedInput.Text)
		if num and num >= 16 and num <= 80 then
			speedValue = num
		else
			speedInput.Text = tostring(speedValue)
		end
	end
end)

speedLoopToggle.MouseButton1Click:Connect(function()
	speedLoopEnabled = not speedLoopEnabled
	speedLoopToggle.Text = speedLoopEnabled and "Speed Loop: ON" or "Speed Loop: OFF"
end)

spawn(function()
	while true do
		if speedLoopEnabled and humanoid and humanoid.Parent then
			humanoid.WalkSpeed = speedValue
		end
		task.wait(0.2)
	end
end)

godmodeBtn.MouseButton1Click:Connect(function()
	godmodeEnabled = not godmodeEnabled
	godmodeBtn.Text = godmodeEnabled and "Godmode: ON" or "Godmode: OFF"
end)

spawn(function()
	while true do
		if godmodeEnabled then
			events:WaitForChild("VestEvent"):FireServer({player})
		end
		task.wait(0.7)
	end
end)

menuToggle.MouseButton1Click:Connect(function()
	if menuFrame.Visible then
		local outTween = TweenService:Create(menuFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1, Position = UDim2.new(1, -200, 0, 20)})
		outTween:Play()
		outTween.Completed:Wait()
		menuFrame.Visible = false
	else
		menuFrame.Visible = true
		local inTween = TweenService:Create(menuFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0.3, Position = UDim2.new(1, -200, 0, 50)})
		inTween:Play()
	end
end)

medkitBtn.MouseButton1Click:Connect(function()
	events:WaitForChild("MedkitEvent"):FireServer({player})
end)

coilBtn.MouseButton1Click:Connect(function()
	events:WaitForChild("SpeedCoilEvent"):FireServer({player})
end)

vestBtn.MouseButton1Click:Connect(function()
	events:WaitForChild("VestEvent"):FireServer({player})
end)

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function getHRP()
	local char = getCharacter()
	return char:WaitForChild("HumanoidRootPart")
end

local function teleportToModel(model, look)
	if not model or not model:IsA("Model") then return end

	local hrp = getHRP()
	local pos = model:GetPivot().Position + Vector3.new(0, 3, 0)

	local dir
	if look == "down" then
		dir = Vector3.new(0, -1, 0)
	elseif look == "forward" then
		dir = model:GetPivot().LookVector
	else
		dir = Vector3.new(0, 0, -1)
	end

	hrp.CFrame = CFrame.new(pos, pos + dir)
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = CFrame.new(pos, pos + dir)
end

local function simulateHoldPrompt(prompt, duration)
	if not prompt or not prompt:IsA("ProximityPrompt") then
		return
	end
	prompt:InputHoldBegin()
	task.wait(duration or 3.5)
	prompt:InputHoldEnd()
end

local function findPromptInModel(model)
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("ProximityPrompt") then
			return desc
		end
	end
	return nil
end

local function handleAllPuzzlePrompts()
	local puzzlesFolder = Workspace:FindFirstChild("Puzzle") and Workspace.Puzzle:FindFirstChild("Puzzles")
	if not puzzlesFolder then
		return
	end

	local puzzles = puzzlesFolder:GetChildren()
	if #puzzles == 0 then
		return
	end

	for _, model in ipairs(puzzles) do
		if model:IsA("Model") then
			teleportToModel(model, "down")
			task.wait(1)

			local prompt = findPromptInModel(model)
			if prompt then
				simulateHoldPrompt(prompt, 3.5)
				task.wait(1.5)
			end
		end
	end
end

local function handleElevatorDoor()
	local door = Workspace:FindFirstChild("Elevators") 
		and Workspace.Elevators:FindFirstChild("Level0Elevator") 
		and Workspace.Elevators.Level0Elevator:FindFirstChild("Door")
		and Workspace.Elevators.Level0Elevator.Door:FindFirstChild("DoorOpen")

	if not door then
		return
	end

	teleportToModel(door, "forward")
	task.wait(1)

	local prompt = findPromptInModel(door)
	if prompt then
		simulateHoldPrompt(prompt, 2)
	end
end

local function resetCamera()
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = getCharacter():FindFirstChild("Humanoid")
end

lvlCompleteBtn.MouseButton1Click:Connect(function()
	spawn(function()
		handleAllPuzzlePrompts()
		handleElevatorDoor()
		resetCamera()
	end)
end)

local creditLabel = Instance.new("TextLabel")
creditLabel.Size = UDim2.new(0, 200, 0, 25)
creditLabel.Position = UDim2.new(1, -210, 1, -30)
creditLabel.AnchorPoint = Vector2.new(0, 0)
creditLabel.BackgroundTransparency = 1
creditLabel.Text = "Made by @plet_farmyt"
creditLabel.TextColor3 = Color3.new(1, 1, 1)
creditLabel.TextScaled = true
creditLabel.Font = Enum.Font.Gotham
creditLabel.TextXAlignment = Enum.TextXAlignment.Right
creditLabel.Parent = ui
