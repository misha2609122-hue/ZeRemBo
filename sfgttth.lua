local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local targetPlayer = nil
local isAttached = false
local draggingMenu = false
local dragOffset = Vector2.new()

-- ИНТЕРФЕЙС
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HeadAttacher_Fixed"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 160, 0, 120)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.5
mainFrame.BorderSizePixel = 0
mainFrame.Active = true

local selectBtn = Instance.new("TextButton", mainFrame)
selectBtn.Size = UDim2.new(0.9, 0, 0.3, 0)
selectBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
selectBtn.Text = "Выбрать игрока"
selectBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
selectBtn.TextColor3 = Color3.new(1, 1, 1)
selectBtn.Font = Enum.Font.SourceSansBold
selectBtn.ClipsDescendants = true

local listFrame = Instance.new("ScrollingFrame", screenGui)
listFrame.Size = UDim2.new(0, 160, 0, 200)
listFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
listFrame.BackgroundTransparency = 0.2
listFrame.Visible = false
listFrame.ScrollBarThickness = 4

local uiListLayout = Instance.new("UIListLayout", listFrame)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local refreshBtn = Instance.new("TextButton", mainFrame)
refreshBtn.Size = UDim2.new(0.9, 0, 0.2, 0)
refreshBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
refreshBtn.Text = "Обновить список"
refreshBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
refreshBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
refreshBtn.TextSize = 12

local attachBtn = Instance.new("TextButton", mainFrame)
attachBtn.Size = UDim2.new(0.9, 0, 0.25, 0)
attachBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
attachBtn.Text = "ПРИКЛЕИТЬСЯ"
attachBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
attachBtn.TextColor3 = Color3.new(1, 1, 1)

-- ПЕРЕТАСКИВАНИЕ
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingMenu = true
		dragOffset = mainFrame.AbsolutePosition - UserInputService:GetMouseLocation()
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingMenu = false end
end)

-- ОБНОВЛЕНИЕ СПИСКА
local function updatePlayerList()
	for _, child in pairs(listFrame:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			local pBtn = Instance.new("TextButton", listFrame)
			pBtn.Size = UDim2.new(1, 0, 0, 30)
			pBtn.Text = p.DisplayName or p.Name
			pBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			pBtn.TextColor3 = Color3.new(1, 1, 1)
			pBtn.MouseButton1Click:Connect(function()
				targetPlayer = p
				selectBtn.Text = p.DisplayName
				listFrame.Visible = false
			end)
		end
	end
	listFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
end

selectBtn.MouseButton1Click:Connect(function()
	if listFrame.Visible or targetPlayer ~= nil then
		listFrame.Visible = false
		targetPlayer = nil
		isAttached = false
		selectBtn.Text = "Выбрать игрока"
		attachBtn.Text = "ПРИКЛЕИТЬСЯ"
		attachBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
	else
		listFrame.Position = UDim2.new(0, mainFrame.AbsolutePosition.X, 0, mainFrame.AbsolutePosition.Y + mainFrame.AbsoluteSize.Y + 5)
		updatePlayerList()
		listFrame.Visible = true
	end
end)

refreshBtn.MouseButton1Click:Connect(updatePlayerList)

attachBtn.MouseButton1Click:Connect(function()
	if not targetPlayer then return end
	isAttached = not isAttached
	attachBtn.Text = isAttached and "ОТКЛЕИТЬСЯ" or "ПРИКЛЕИТЬСЯ"
	attachBtn.BackgroundColor3 = isAttached and Color3.fromRGB(100, 30, 30) or Color3.fromRGB(30, 100, 30)
end)

-- ЦИКЛ ПРИКЛЕИВАНИЯ
RunService.RenderStepped:Connect(function()
	if draggingMenu then
		local mPos = UserInputService:GetMouseLocation()
		mainFrame.Position = UDim2.new(0, mPos.X + dragOffset.X, 0, mPos.Y + dragOffset.Y)
		listFrame.Position = UDim2.new(0, mainFrame.AbsolutePosition.X, 0, mainFrame.AbsolutePosition.Y + mainFrame.AbsoluteSize.Y + 5)
	end
	
	if isAttached and targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
		local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if myRoot then
			-- ИЗМЕНЕНО: Смещение 3.2 блока вверх, чтобы ноги были над головой
			myRoot.CFrame = targetPlayer.Character.Head.CFrame * CFrame.new(0, 3.2, 0)
		end
	end
end)
