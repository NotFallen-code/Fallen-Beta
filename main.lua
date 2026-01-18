-- WHITELIST
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- SERVICES
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- SETTINGS
local ENABLED = true
local ESP_NAME = "MetalESP"

-- CLEANUP
local function removeESP()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BillboardGui") and v.Name == ESP_NAME then
			v:Destroy()
		end
	end
end

-- CREATE ESP
local function createESP(model)
	if not ENABLED then return end
	if not model:IsA("Model") then return end
	if model:FindFirstChild(ESP_NAME) then return end
	if not model:FindFirstChild("hidden-metal-prompt") then return end

	local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not part then return end

	local gui = Instance.new("BillboardGui")
	gui.Name = ESP_NAME
	gui.Adornee = part
	gui.Size = UDim2.fromOffset(120, 40)
	gui.AlwaysOnTop = true
	gui.MaxDistance = 100000
	gui.Parent = model

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 2
	frame.Parent = gui

	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.TextScaled = true
	text.Font = Enum.Font.GothamBold
	text.Text = "METAL"
	text.Parent = frame

	RunService.RenderStepped:Connect(function()
		if not part
			or not LocalPlayer.Character
			or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			return
		end

		local dist = (LocalPlayer.Character.HumanoidRootPart.Position - part.Position).Magnitude
		text.Text = "METAL\n" .. math.floor(dist) .. " studs"
	end)
end

-- REFRESH
local function refreshESP()
	if not ENABLED then return end
	for _, v in ipairs(workspace:GetDescendants()) do
		createESP(v)
	end
end

-- AUTO UPDATE
workspace.DescendantAdded:Connect(function(obj)
	task.wait()
	createESP(obj)
end)

-- INITIAL
refreshESP()

-- TOGGLE (RIGHT SHIFT)
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		ENABLED = not ENABLED
		if ENABLED then
			refreshESP()
		else
			removeESP()
		end
	end
end)
