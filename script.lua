if getgenv().LoadedUI then
	getgenv().LoadedUI:Destroy()
end

getgenv().LoadedUI = Instance.new("ScreenGui", game.CoreGui)
getgenv().LoadedUI.Name = "LoadedUI_Rayfield"

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local player = game.Players.LocalPlayer
local replicated = game:GetService("ReplicatedStorage")
local events = replicated:WaitForChild("Events")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- 📁 Автовыбор Puzzle/Party
local function getPuzzleFolder()
	local puzzles = workspace:FindFirstChild("Puzzle") and workspace.Puzzle:FindFirstChild("Puzzles")
	if puzzles and #puzzles:GetChildren() == 1 and puzzles:FindFirstChild("ElevatorStuff") then
		local party = workspace:FindFirstChild("Party")
		if party then
			return party
		end
	end
	return puzzles
end

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoid()
	return getCharacter():WaitForChild("Humanoid")
end

local function getHRP()
	return getCharacter():WaitForChild("HumanoidRootPart")
end

local speedValue = 16
local speedLoopEnabled = false
local godmodeEnabled = false
local levelLoopRunning = false
local puzzleColor = Color3.fromRGB(255, 255, 0)
local npcColor = Color3.fromRGB(255, 0, 0)
local elevatorColor = Color3.fromRGB(0, 255, 0)
local espEnabled = false

local function unlockAllSuits()
	local suitSaves = player:FindFirstChild("SuitSaves")
	if suitSaves then
		for _, v in ipairs(suitSaves:GetChildren()) do
			if v:IsA("BoolValue") then
				v.Value = true
			end
		end
	end
end

local function updateLevelLoop()
	while levelLoopRunning do
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

-- Телепорт лицом к позиции (targetCFrame) с небольшой высотой
local function teleportFaceToCFrame(targetCFrame)
	local hrp = getHRP()
	if not hrp then return end

	local pos = targetCFrame.Position + Vector3.new(0, 3, 0)
	hrp.CFrame = CFrame.new(pos, targetCFrame.Position)
end

local function teleportToElevatorFloorFace()
	local elevator = workspace:FindFirstChild("Elevators") and workspace.Elevators:FindFirstChild("Level0Elevator")
	if not elevator then return end

	local floorPart = elevator:FindFirstChild("Floor")
	if not floorPart or not floorPart:IsA("BasePart") then return end

	teleportFaceToCFrame(floorPart.CFrame)
end

local function teleportToModel(model)
	if not model or not model:IsA("Model") then return end

	local pivot = model:GetPivot()
	local forward = pivot.LookVector
	local targetPos = pivot.Position - forward * 4 + Vector3.new(0, 3, 0)

	getHRP().CFrame = CFrame.new(targetPos, pivot.Position)
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = getHumanoid()
end

local function simulateHoldPrompt(prompt, duration)
	if prompt and prompt:IsA("ProximityPrompt") then
		prompt:InputHoldBegin()
		task.wait(duration or 3.5)
		prompt:InputHoldEnd()
	end
end

local function findPromptInModel(model)
	for _, desc in ipairs(model:GetDescendants()) do
		if desc:IsA("ProximityPrompt") then
			return desc
		end
	end
	return nil
end

-- Обновленная функция телепорта лицом к пазлам и взаимодействия с ними
local function handleAllPuzzlePrompts()
	local puzzlesFolder = getPuzzleFolder()
	if not puzzlesFolder then return end

	for _, model in ipairs(puzzlesFolder:GetDescendants()) do
		if model:IsA("Model") then
			local pivot = model:GetPivot()
			teleportFaceToCFrame(pivot)
			task.wait(1)
			local prompt = findPromptInModel(model)
			if prompt then
				simulateHoldPrompt(prompt, 6)
				task.wait(1.5)
			end
		end
	end
end

local function handleElevatorDoor()
	local elevator = workspace:FindFirstChild("Elevators") and workspace.Elevators:FindFirstChild("Level0Elevator")
	if not elevator then return end

	local door = elevator:FindFirstChild("Door") or elevator:FindFirstChildWhichIsA("Model")
	if not door then return end

	local pivot = door:GetPivot()
	local forward = pivot.LookVector
	local targetPos = pivot.Position - forward * 5 + Vector3.new(0, 3, 0)

	getHRP().CFrame = CFrame.new(targetPos, pivot.Position)
	camera.CameraType = Enum.CameraType.Custom
	camera.CameraSubject = getHumanoid()

	task.wait(1)
	local prompt = findPromptInModel(door)
	if prompt then
		simulateHoldPrompt(prompt, 2)
	end
end

local function teleportToFirstPuzzle()
	local puzzlesFolder = getPuzzleFolder()
	if not puzzlesFolder then return end
	for _, item in ipairs(puzzlesFolder:GetDescendants()) do
		if item:IsA("Model") then
			teleportToModel(item)
			break
		end
	end
end

-- 🔍 ESP
local beamFolder
local espObjects = {}

local function clearESP()
	if beamFolder then beamFolder:Destroy() end
	beamFolder = nil
	espObjects = {}
	RunService:UnbindFromRenderStep("ESPUpdate")
end

local function createESPBox(part, color)
	local adorn = Instance.new("BoxHandleAdornment")
	adorn.Adornee = part
	adorn.AlwaysOnTop = true
	adorn.ZIndex = 10
	adorn.Size = part.Size
	adorn.Transparency = 0.5
	adorn.Color3 = color or Color3.new(1,1,1)
	adorn.Parent = beamFolder
	return adorn
end

local function drawESP()
	clearESP()
	beamFolder = Instance.new("Folder", workspace)
	beamFolder.Name = "BeamESPFolder"

	local function addESP(part, type)
		local color = (
			type == "Puzzle" and puzzleColor or
			type == "NPC" and npcColor or
			type == "Elevator" and elevatorColor or
			Color3.new(1,1,1)
		)
		local box = createESPBox(part, color)
		if box then
			table.insert(espObjects, {part = part, box = box, type = type})
		end
	end

	local puzzlesFolder = getPuzzleFolder()
	if puzzlesFolder then
		for _, model in ipairs(puzzlesFolder:GetDescendants()) do
			if model:IsA("Model") then
				local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
				if part then addESP(part, "Puzzle") end
			end
		end
	end

	local npcs = workspace:FindFirstChild("NPCS")
	if npcs then
		for _, model in ipairs(npcs:GetChildren()) do
			if model:IsA("Model") then
				local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
				if part then addESP(part, "NPC") end
			end
		end
	end

	local elevators = workspace:FindFirstChild("Elevators")
	if elevators then
		local level0 = elevators:FindFirstChild("Level0Elevator")
		if level0 then
			for _, part in ipairs(level0:GetDescendants()) do
				if part:IsA("BasePart") then
					addESP(part, "Elevator")
				end
			end
		end
	end

	RunService:BindToRenderStep("ESPUpdate", 301, function()
		for i = #espObjects, 1, -1 do
			local obj = espObjects[i]
			local part, box = obj.part, obj.box
			if part and part.Parent and box then
				box.Adornee = part
				box.Size = part.Size
				-- Цвет не меняем здесь, он задан при создании
			else
				box:Destroy()
				table.remove(espObjects, i)
			end
		end
	end)
end

-- 🔁 ESP постоянный цикл
task.spawn(function()
	while true do
		if espEnabled then
			drawESP()
		else
			clearESP()
		end
		task.wait(1)
	end
end)

-- 🧱 Интерфейс
local Window = Rayfield:CreateWindow({
	Name = "Game Hub",
	LoadingTitle = "Loading...",
	LoadingSubtitle = "Made by @plet_farmyt",
	ConfigurationSaving = { Enabled = false },
	KeySystem = false
})

local MainTab     = Window:CreateTab("Main", 4483362458)
local ItemsTab    = Window:CreateTab("Items", 4483362361)
local ESPTab      = Window:CreateTab("ESP", 4483362457)
local PlayerTab   = Window:CreateTab("Player", 4483362006)
local EmoteTab    = Window:CreateTab("Emote", 4483363000)
local SettingsTab = Window:CreateTab("Settings", 4483362706)

-- 📌 Main
MainTab:CreateButton({ Name = "Unlock All", Callback = function()
	unlockAllSuits()
	levelLoopRunning = true
	task.spawn(updateLevelLoop)
end })

MainTab:CreateButton({ Name = "Lvl Complete", Callback = function()
	task.spawn(function()
		handleAllPuzzlePrompts()
		task.wait(1)
		teleportToElevatorFloorFace()
	end)
end })

MainTab:CreateButton({ Name = "Teleport to Puzzle", Callback = teleportToFirstPuzzle })
MainTab:CreateButton({ Name = "Teleport to Elevator Floor", Callback = teleportToElevatorFloorFace })

-- 🎒 Items
ItemsTab:CreateButton({ Name = "Medkit", Callback = function()
	events:WaitForChild("MedkitEvent"):FireServer({player})
end })

ItemsTab:CreateButton({ Name = "Speed Coil", Callback = function()
	events:WaitForChild("SpeedCoilEvent"):FireServer({player})
end })

ItemsTab:CreateButton({ Name = "Vest", Callback = function()
	events:WaitForChild("VestEvent"):FireServer({player})
end })

-- 👁 ESP
ESPTab:CreateToggle({
	Name = "ESP Toggle",
	CurrentValue = false,
	Callback = function(state)
		espEnabled = state
	end,
})

ESPTab:CreateColorPicker({
	Name = "Puzzle ESP Color",
	Color = puzzleColor,
	Callback = function(newColor)
		puzzleColor = newColor
	end,
})

ESPTab:CreateColorPicker({
	Name = "NPC ESP Color",
	Color = npcColor,
	Callback = function(newColor)
		npcColor = newColor
	end,
})

ESPTab:CreateColorPicker({
	Name = "Elevator ESP Color",
	Color = elevatorColor,
	Callback = function(newColor)
		elevatorColor = newColor
	end,
})

-- 🧍 Player
PlayerTab:CreateToggle({
	Name = "WalkSpeed Loop",
	CurrentValue = false,
	Callback = function(state)
		speedLoopEnabled = state
	end,
})

PlayerTab:CreateSlider({
	Name = "WalkSpeed",
	Range = {16, 80},
	Increment = 1,
	CurrentValue = 16,
	Callback = function(val)
		speedValue = val
	end,
})

PlayerTab:CreateToggle({
	Name = "Godmode",
	CurrentValue = false,
	Callback = function(state)
		godmodeEnabled = state
	end,
})

-- 🎭 Emote
EmoteTab:CreateButton({
	Name = "Show Emote 3 Page",
	Callback = function()
		local playerGui = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
		local emoteGui = playerGui:FindFirstChild("Emoteui")
		if emoteGui then
			local container3 = emoteGui:FindFirstChild("container3")
			if container3 then
				container3.Visible = true
			else
				warn("container3 не найден в Emoteui")
			end
		else
			warn("Emoteui не найден в PlayerGui")
		end
	end,
})

-- ⚙ Settings
SettingsTab:CreateParagraph({
	Title = "Info",
	Content = "Script made by @plet_farmyt"
})

-- 🔁 Pet Loops
task.spawn(function()
	while true do
		if speedLoopEnabled then
			local hum = getHumanoid()
			if hum then
				hum.WalkSpeed = speedValue
			end
		end
		task.wait(0.2)
	end
end)

task.spawn(function()
	while true do
		if godmodeEnabled then
			events:WaitForChild("VestEvent"):FireServer({player})
		end
		task.wait(0.7)
	end
end)
