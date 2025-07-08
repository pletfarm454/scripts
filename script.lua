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

local function teleportToModel(model, look)
    if not model or not model:IsA("Model") then return end
    local pos = model:GetPivot().Position + Vector3.new(0, 3, 0)
    local dir = look == "down" and Vector3.new(0, -1, 0)
        or look == "forward" and model:GetPivot().LookVector
        or Vector3.new(0, 0, -1)
    getHRP().CFrame = CFrame.new(pos, pos + dir)
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

local function handleAllPuzzlePrompts()
    local puzzlesFolder = workspace:FindFirstChild("Puzzle") and workspace.Puzzle:FindFirstChild("Puzzles")
    if not puzzlesFolder then return end
    for _, model in ipairs(puzzlesFolder:GetDescendants()) do
        if model:IsA("Model") then
            teleportToModel(model, "down")
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
    local door = workspace:FindFirstChild("Elevators")
        and workspace.Elevators:FindFirstChild("Level0Elevator")
        and workspace.Elevators.Level0Elevator:FindFirstChild("Door")
    if not door then return end
    teleportToModel(door, "forward")
    task.wait(1)
    local prompt = findPromptInModel(door)
    if prompt then
        simulateHoldPrompt(prompt, 2)
    end
end

local function teleportToFirstPuzzle()
    local puzzlesFolder = workspace:FindFirstChild("Puzzle") and workspace.Puzzle:FindFirstChild("Puzzles")
    if not puzzlesFolder then return end
    for _, item in ipairs(puzzlesFolder:GetDescendants()) do
        if item:IsA("Model") then
            teleportToModel(item, "down")
            break
        end
    end
end

local beamFolder
local espObjects = {}

local function clearESP()
    if beamFolder then beamFolder:Destroy() end
    beamFolder = nil
    espObjects = {}
    RunService:UnbindFromRenderStep("ESPUpdate")
end

local function createESPBox(part)
    local adorn = Instance.new("BoxHandleAdornment")
    adorn.Adornee = part
    adorn.AlwaysOnTop = true
    adorn.ZIndex = 10
    adorn.Size = part.Size
    adorn.Transparency = 0.5
    adorn.Color3 = Color3.new(1,1,1)
    adorn.Parent = beamFolder
    return adorn
end

local function drawESP()
    clearESP()
    beamFolder = Instance.new("Folder", workspace)
    beamFolder.Name = "BeamESPFolder"

    local function addESP(part, type)
        local box = createESPBox(part)
        if box then
            table.insert(espObjects, {part = part, box = box, type = type})
        end
    end

    local puzzlesFolder = workspace:FindFirstChild("Puzzle") and workspace.Puzzle:FindFirstChild("Puzzles")
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
                box.Transparency = 0.5
                box.Color3 = (
                    obj.type == "Puzzle" and puzzleColor or
                    obj.type == "NPC" and npcColor or
                    obj.type == "Elevator" and elevatorColor or
                    Color3.new(1,1,1)
                )
            else
                box:Destroy()
                table.remove(espObjects, i)
            end
        end
    end)
end

-- Новый таск для обновления ESP каждый N секунд
local espUpdateTask = nil

local function startESPUpdateLoop()
    if espUpdateTask then return end
    espUpdateTask = task.spawn(function()
        while espEnabled do
            drawESP()
            task.wait(1) -- обновлять раз в секунду
        end
        clearESP()
        espUpdateTask = nil
    end)
end

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

-- 📌 MainTab
MainTab:CreateButton({ Name = "Unlock All", Callback = function()
    unlockAllSuits()
    levelLoopRunning = true
    task.spawn(updateLevelLoop)
end })

MainTab:CreateButton({ Name = "Lvl Complete", Callback = function()
    task.spawn(function()
        handleAllPuzzlePrompts()
        handleElevatorDoor()
    end)
end })

MainTab:CreateButton({ Name = "Teleport to Puzzle", Callback = teleportToFirstPuzzle })
MainTab:CreateButton({ Name = "Teleport to Elevator", Callback = handleElevatorDoor })

-- 🎒 ItemsTab
ItemsTab:CreateButton({ Name = "Medkit", Callback = function()
    events:WaitForChild("MedkitEvent"):FireServer({player})
end })

ItemsTab:CreateButton({ Name = "Speed Coil", Callback = function()
    events:WaitForChild("SpeedCoilEvent"):FireServer({player})
end })

ItemsTab:CreateButton({ Name = "Vest", Callback = function()
    events:WaitForChild("VestEvent"):FireServer({player})
end })

-- 👁 ESPTab
ESPTab:CreateToggle({
    Name = "ESP Toggle",
    CurrentValue = false,
    Callback = function(state)
        espEnabled = state
        if state then
            startESPUpdateLoop()
        else
            clearESP()
        end
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

-- 🧍 PlayerTab
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

-- === FOV Loop и слайдер ===
local fovLoopEnabled = false
local fovValue = 70  -- стандартное значение FOV
local fovMin = 70
local fovMax = 120
local fovStep = 1

PlayerTab:CreateToggle({
    Name = "FOV Loop",
    CurrentValue = false,
    Callback = function(state)
        fovLoopEnabled = state
    end,
})

PlayerTab:CreateSlider({
    Name = "FOV",
    Range = {70, 120},
    Increment = 1,
    CurrentValue = 70,
    Callback = function(val)
        fovValue = val
        if not fovLoopEnabled then
            camera.FieldOfView = fovValue
        end
    end,
})

task.spawn(function()
    local direction = 1
    while true do
        if fovLoopEnabled then
            fovValue = fovValue + direction * fovStep
            if fovValue >= fovMax then
                fovValue = fovMax
                direction = -1
            elseif fovValue <= fovMin then
                fovValue = fovMin
                direction = 1
            end
            camera.FieldOfView = fovValue
        else
            camera.FieldOfView = fovValue
        end
        task.wait(0.03)
    end
end)

-- 🎭 EmoteTab
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

-- ⚙ SettingsTab
SettingsTab:CreateParagraph({
    Title = "Info",
    Content = "Script made by @plet_farmyt"
})

-- Обновление скорости ходьбы
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

-- Постоянное включение Godmode (использует VestEvent)
task.spawn(function()
    while true do
        if godmodeEnabled then
            events:WaitForChild("VestEvent"):FireServer({player})
        end
        task.wait(0.7)
    end
end)
