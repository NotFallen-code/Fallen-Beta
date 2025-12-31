local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

local ESPEnabled = true

local function createESP(player)
	if player == LocalPlayer then return end -- skip yourself
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
	if player.Character:FindFirstChild("ESP") then return end -- don't duplicate

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP"
	billboard.Adornee = player.Character.HumanoidRootPart
	billboard.Size = UDim2.new(3, 0, 5, 0)
	billboard.AlwaysOnTop = true
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Parent = player.Character -- local only

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
	frame.BackgroundTransparency = 0.5
	frame.BorderSizePixel = 0
	frame.Parent = billboard
end

local function removeESP(player)
	if player.Character and player.Character:FindFirstChild("ESP") then
		player.Character.ESP:Destroy()
	end
end

local function updateESPs()
	for _, player in pairs(Players:GetPlayers()) do
		if ESPEnabled then
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
