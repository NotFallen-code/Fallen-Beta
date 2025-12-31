local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local ESPEnabled = true

local function createESP(player)
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
	if player:FindFirstChild("PlayerGui") and not player.PlayerGui:FindFirstChild("ESP") then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP"
		billboard.Adornee = player.Character.HumanoidRootPart
		billboard.Size = UDim2.new(3, 0, 5, 0)
		billboard.AlwaysOnTop = true
		billboard.StudsOffset = Vector3.new(0, 0, 0)
		billboard.Parent = player.PlayerGui

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
		frame.BackgroundTransparency = 0.5
		frame.BorderSizePixel = 0
		frame.Parent = billboard
	end
end

local function removeESP(player)
	if player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("ESP") then
		player.PlayerGui.ESP:Destroy()
	end
end

local function updateESPs()
	for _, player in pairs(Players:GetPlayers()) do
		if ESPEnabled == true then
			createESP(player)
		else
			removeESP(player)
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		if ESPEnabled then
			createESP(player)
		end
	end)
end)

for _, player in pairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(function()
		if ESPEnabled then
			createESP(player)
		end
	end)
	if ESPEnabled then
		createESP(player)
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.R then
		ESPEnabled = not ESPEnabled
		updateESPs()
	end
end)
