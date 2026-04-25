local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local enabled = false
local tracked = {}

local TARGET_NAMES = {
	["CritStar"] = true,
	["VitalityStar"] = true
}

local function getPart(obj)
	if obj:IsA("BasePart") then
		return obj
	end
	return obj:FindFirstChildWhichIsA("BasePart")
end

-- create esp
local function createESP(obj)
	if tracked[obj] then return end
	
	local part = getPart(obj)
	if not part then return end
	
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.new(0,0,0)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 1
	highlight.Adornee = obj
	highlight.Parent = obj
	
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0,100,0,40)
	billboard.StudsOffset = Vector3.new(0,2,0)
	billboard.AlwaysOnTop = true
	billboard.Parent = part
	
	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1,0,1,0)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.new(1,1,1)
	text.TextStrokeTransparency = 0
	text.TextScaled = true
	text.Font = Enum.Font.SourceSansBold
	text.Parent = billboard
	
	tracked[obj] = {
		highlight = highlight,
		gui = billboard,
		text = text,
		part = part
	}
end

local function removeESP(obj)
	if not tracked[obj] then return end
	
	local data = tracked[obj]
	if data.highlight then data.highlight:Destroy() end
	if data.gui then data.gui:Destroy() end
	
	tracked[obj] = nil
end

local function clearAll()
	for obj in pairs(tracked) do
		removeESP(obj)
	end
end

-- update distance
RunService.RenderStepped:Connect(function()
	if not enabled then return end
	
	character = player.Character
	if not character then return end
	
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	for obj, data in pairs(tracked) do
		if obj and obj.Parent and data.part then
			local dist = (root.Position - data.part.Position).Magnitude
			data.text.Text = math.floor(dist).." studs"
		else
			removeESP(obj)
		end
	end
end)

-- scan
local function scan()
	for _, obj in pairs(workspace:GetDescendants()) do
		if TARGET_NAMES[obj.Name] then
			createESP(obj)
		end
	end
end

-- new objects
workspace.DescendantAdded:Connect(function(obj)
	if not enabled then return end
	
	if TARGET_NAMES[obj.Name] then
		task.spawn(function()
			local attempts = 0
			local part = getPart(obj)
			
			while not part and attempts < 20 do
				task.wait(0.1)
				part = getPart(obj)
				attempts += 1
			end
			
			if part then
				createESP(obj)
			end
		end)
	end
end)

workspace.DescendantRemoving:Connect(function(obj)
	if TARGET_NAMES[obj.Name] then
		removeESP(obj)
	end
end)

-- toggle
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	
	if input.KeyCode == Enum.KeyCode.RightShift then
		enabled = not enabled
		print("ESP:", enabled) -- debug
		
		if enabled then
			scan()
		else
			clearAll()
		end
	end
end)
