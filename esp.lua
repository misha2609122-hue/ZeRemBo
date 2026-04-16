local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Состояние
local espActive = false
local draggingMenu = false
local dragOffset = Vector2.new()

-- Интерфейс
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SA_Force_ESP"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

local menu = Instance.new("Frame", screenGui)
menu.Size = UDim2.new(0, 140, 0, 60)
menu.Position = UDim2.new(0, 50, 0, 50)
menu.BackgroundColor3 = Color3.new(0, 0, 0)
menu.BackgroundTransparency = 0.5
menu.BorderSizePixel = 0
menu.Active = true

local toggleButton = Instance.new("TextButton", menu)
toggleButton.Size = UDim2.new(0.9, 0, 0.7, 0)
toggleButton.Position = UDim2.new(0.05, 0, 0.15, 0)
toggleButton.Text = "FORCE ESP"
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.SourceSansBold

-- Перетаскивание
menu.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMenu = true
        dragOffset = menu.AbsolutePosition - UserInputService:GetMouseLocation()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingMenu = false end
end)

-- Функция "силовой" подсветки
local function applyForceESP(char, p)
    if not char then return end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and not part:FindFirstChild("ForceChams") then
            local chams = Instance.new("BoxHandleAdornment")
            chams.Name = "ForceChams"
            chams.AlwaysOnTop = true
            chams.ZIndex = 5
            chams.Adornee = part
            chams.Size = part.Size
            chams.Transparency = 0.4
            
            -- Цвет: Красный для убийцы, Зеленый для остальных
            if p.TeamColor == BrickColor.new("Bright red") or p.Name == "Murderer" then
                chams.Color3 = Color3.new(1, 0, 0)
            else
                chams.Color3 = Color3.new(0, 1, 0)
            end
            
            chams.Parent = part
        end
    end
end

-- Бесконечный цикл обновления (для новых раундов и обхода защиты)
task.spawn(function()
    while true do
        if espActive then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    applyForceESP(p.Character, p)
                end
            end
        end
        task.wait(0.5) -- Очень быстрая проверка (полсекунды)
    end
end)

-- Кнопка
toggleButton.MouseButton1Click:Connect(function()
    espActive = not espActive
    toggleButton.Text = espActive and "ESP: ON" or "FORCE ESP"
    toggleButton.BackgroundColor3 = espActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
    
    if not espActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                for _, obj in pairs(p.Character:GetDescendants()) do
                    if obj.Name == "ForceChams" then obj:Destroy() end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if draggingMenu then
        local mPos = UserInputService:GetMouseLocation()
        menu.Position = UDim2.new(0, mPos.X + dragOffset.X, 0, mPos.Y + dragOffset.Y)
    end
end)
