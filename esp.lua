local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ESPEnabled = true

local function createESP(player)
	local char = player.Character
	if char and char:WaitForChild("HumanoidRootPart") and not player:WaitForChild("PlayerGui"):FindFirstChild("ESP") then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESP"
		billboard.Adornee = char.HumanoidRootPart
		billboard.Size = UDim2.new(3, 0, 5, 0)
		billboard.AlwaysOnTop = true
		billboard.StudsOffset = Vector3.new(0, 0, 0)
		billboard.Parent = player:WaitForChild("PlayerGui") 

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
		frame.BackgroundTransparency = 0.5
		frame.BorderSizePixel = 0
		frame.Parent = billboard

	end
end


local function removeESP(player)
	if player:WaitForChild("PlayerGui"):FindFirstChild("ESP") then
		player:WaitForChild("PlayerGui"):FindFirstChild("ESP"):Destroy()
	end
end

local function updateESPs()
	for i, player in pairs(Players:GetPlayers()) do
			if ESPEnabled == true then
				createESP(player)
			else
				removeESP(player)
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(Character)
		if ESPEnabled then
			createESP(Character, player)
		end
	end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.R then
		ESPEnabled = not ESPEnabled
		updateESPs()
	end
end)

RunService.RenderStepped:Connect(function()
	updateESPs()
end)
