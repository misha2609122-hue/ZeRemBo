 local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Переменные
local p1, p2 = nil, nil
local selectionPart = nil
local isRunning = false
local draggingMenu = false
local dragOffset = Vector2.new()

-- Создание интерфейса
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZoneRunner_Fixed"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

local menu = Instance.new("Frame", screenGui)
menu.Size = UDim2.new(0, 120, 0, 60)
menu.Position = UDim2.new(0, 50, 0, 50)
menu.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
menu.BackgroundTransparency = 0.5
menu.BorderSizePixel = 0
menu.Active = true

local runButton = Instance.new("TextButton", menu)
runButton.Size = UDim2.new(0.8, 0, 0.6, 0)
runButton.Position = UDim2.new(0.1, 0, 0.2, 0)
runButton.Text = "START"
runButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
runButton.TextColor3 = Color3.new(1, 1, 1)

-- Функция создания визуального бокса
local function updateBox()
    if not p1 or not p2 or not selectionPart then return end
    local center = (p1 + p2) / 2
    local size = Vector3.new(math.abs(p1.X - p2.X), 1, math.abs(p1.Z - p2.Z))
    selectionPart.Size = size
    selectionPart.CFrame = CFrame.new(center.X, p1.Y + 0.5, center.Z)
end

-- ЛОГИКА МЫШИ
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mPos = UserInputService:GetMouseLocation()
        local menuPos = menu.AbsolutePosition
        local menuSize = menu.AbsoluteSize
        
        -- Проверка: нажали на меню или на мир?
        if mPos.X >= menuPos.X and mPos.X <= menuPos.X + menuSize.X and
           mPos.Y >= menuPos.Y + 36 and mPos.Y <= menuPos.Y + menuSize.Y + 36 then
            draggingMenu = true
            dragOffset = menu.AbsolutePosition - mPos
        else
            -- Если уже есть зона — удаляем её
            if p1 then
                p1, p2 = nil, nil
                if selectionPart then selectionPart:Destroy() selectionPart = nil end
                isRunning = false
                runButton.Text = "START"
            else
                -- Если нажали на поверхность
                if mouse.Target then
                    p1 = mouse.Hit.p
                    selectionPart = Instance.new("Part")
                    selectionPart.Anchored = true
                    selectionPart.CanCollide = false
                    selectionPart.Transparency = 0.5
                    selectionPart.Color = Color3.new(0, 1, 0)
                    selectionPart.Material = Enum.Material.Neon
                    selectionPart.Parent = workspace
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMenu = false
        if p1 and not p2 then
            p2 = mouse.Hit.p
            updateBox()
        end
    end
end)

-- Обновление в реальном времени
RunService.RenderStepped:Connect(function()
    if draggingMenu then
        local mPos = UserInputService:GetMouseLocation()
        menu.Position = UDim2.new(0, mPos.X + dragOffset.X, 0, mPos.Y + dragOffset.Y - 36)
    end
    
    -- Тянем зону пока зажата кнопка
    if p1 and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) and not draggingMenu then
        p2 = mouse.Hit.p
        updateBox()
    end
end)

-- Рандомный бег
runButton.MouseButton1Click:Connect(function()
    if not p1 or not p2 then return end
    isRunning = not isRunning
    runButton.Text = isRunning and "STOP" or "START"
    
    task.spawn(function()
        while isRunning and p1 and p2 do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local minX = math.min(p1.X, p2.X)
                local maxX = math.max(p1.X, p2.X)
                local minZ = math.min(p1.Z, p2.Z)
                local maxZ = math.max(p1.Z, p2.Z)
                
                -- Генерация случайной точки внутри
                local target = Vector3.new(
                    math.random(minX * 100, maxX * 100) / 100,
                    p1.Y + 3.5,
                    math.random(minZ * 100, maxZ * 100) / 100
                )
                hrp.CFrame = CFrame.new(target)
            end
            task.wait(0.01) -- Максимальная скорость телепортов
        end
    end)
end)
