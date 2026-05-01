local localPlayer = game.Players.LocalPlayer
local playerGUI = localPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Configuration
local tracked = {}
local toggles = {
	["Bee"] = false,
	["Metal"] = false,
	["Star"] = false,
	["Box"] = false,
	["ShowTeam"] = false,
	["ShowName"] = false,
	["NameMode"] = "Display"
}
local connections = {}
local guiVisible = true

-- UI Setup
local fallenWareScreenUI = Instance.new("ScreenGui")
fallenWareScreenUI.Parent = playerGUI
fallenWareScreenUI.Name = "FallenWare"
fallenWareScreenUI.IgnoreGuiInset = true
fallenWareScreenUI.ResetOnSpawn = false 

local function addUICorner(quantity, parent)
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, quantity)
	UICorner.Parent = parent
end

-- Main Frame
local mainUI = Instance.new("Frame")
mainUI.Parent = fallenWareScreenUI
mainUI.Size = UDim2.new(0.13, 0, 0.6, 0)
mainUI.Position = UDim2.new(0.15, 0, 0.15, 0)
mainUI.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainUI.BorderSizePixel = 0
mainUI.Active = true
mainUI.ClipsDescendants = true
addUICorner(10, mainUI)

-- TITLE BAR
local titleFrame = Instance.new("Frame")
titleFrame.Parent = mainUI
titleFrame.Size = UDim2.new(1, 0, 0.1, 0)
titleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleFrame.ZIndex = 10
addUICorner(10, titleFrame)

local titleText = Instance.new("TextLabel")
titleText.Parent = titleFrame
titleText.Size = UDim2.new(1, 0, 1, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "UZIWARE + ZENWARE"
titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
titleText.TextScaled = true
titleText.Font = Enum.Font.Code
titleText.ZIndex = 11

-- SCROLLING CONTENT
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Parent = mainUI
scrollingFrame.Size = UDim2.new(1, 0, 0.78, 0)
scrollingFrame.Position = UDim2.new(0, 0, 0.11, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 4
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollingFrame.ZIndex = 5

local uiList = Instance.new("UIListLayout", scrollingFrame)
uiList.Padding = UDim.new(0, 8)
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local uiPadding = Instance.new("UIPadding", scrollingFrame)
uiPadding.PaddingTop = UDim.new(0, 5)

-- BOTTOM BAR
local bottomBar = Instance.new("Frame")
bottomBar.Parent = mainUI
bottomBar.Size = UDim2.new(1, 0, 0.08, 0)
bottomBar.Position = UDim2.new(0, 0, 0.92, 0)
bottomBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
bottomBar.ZIndex = 10
addUICorner(10, bottomBar)

--- KEYBIND TOGGLE ---
table.insert(connections, UIS.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
		guiVisible = not guiVisible
		mainUI.Visible = guiVisible
	end
end))

--- DRAGGING ---
local dragging, dragStart, startPos
titleFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true dragStart = input.Position startPos = mainUI.Position
	end
end)
table.insert(connections, UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		mainUI.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end))
table.insert(connections, UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end))

--- ESP LOGIC ---
local function getESPConfig(obj)
	if obj.Name == "Bee" then return Color3.new(1, 1, 0), "Bee" end
	if obj:FindFirstChild("hidden-metal-prompt") then return Color3.new(0, 1, 1), "Metal" end
	if obj.Name == "CritStar" then return Color3.fromRGB(255, 165, 0), "Crit Star" end
	if obj.Name == "VitalityStar" then return Color3.fromRGB(50, 255, 50), "Vitality Star" end
	return nil
end

local function removeESP(obj)
	if tracked[obj] then
		if tracked[obj].gui then tracked[obj].gui:Destroy() end
		tracked[obj] = nil
	end
end

local function createESP(obj, isPlayer)
	if tracked[obj] then return end
	
	local targetPart = obj:FindFirstChild("HumanoidRootPart") or (obj:IsA("BasePart") and obj) or obj.PrimaryPart
	if not targetPart then return end

	local bill = Instance.new("BillboardGui")
	bill.AlwaysOnTop = true
	bill.Adornee = targetPart
	bill.ClipsDescendants = false
	bill.Parent = targetPart
	
	if isPlayer then
		bill.Size = UDim2.fromScale(5, 7) -- Slightly tighter box
		bill.StudsOffset = Vector3.new(0, 1.5, 0) -- Higher center point
		
		local boxFrame = Instance.new("Frame", bill)
		boxFrame.Size = UDim2.fromScale(1, 1)
		boxFrame.BackgroundTransparency = 1
		
		local stroke = Instance.new("UIStroke", boxFrame)
		stroke.Thickness = 2
		
		-- Container for names/teams
		local infoBill = Instance.new("BillboardGui")
		infoBill.Size = UDim2.new(0, 200, 0, 50)
		infoBill.AlwaysOnTop = true
		infoBill.Adornee = targetPart
		infoBill.StudsOffset = Vector3.new(0, 6, 0) -- Fixed distance above box
		infoBill.Parent = targetPart
		
		local layout = Instance.new("UIListLayout", infoBill)
		layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.Padding = UDim.new(0, 0)
		
		local teamLabel = Instance.new("TextLabel", infoBill)
		teamLabel.Size = UDim2.new(1, 0, 0, 18)
		teamLabel.BackgroundTransparency = 1
		teamLabel.Font = Enum.Font.GothamBold
		teamLabel.TextSize = 14
		teamLabel.TextStrokeTransparency = 0
		
		local nameLabel = Instance.new("TextLabel", infoBill)
		nameLabel.Size = UDim2.new(1, 0, 0, 18)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 14
		nameLabel.TextStrokeTransparency = 0

		tracked[obj] = {
			gui = bill, 
			info = infoBill,
			stroke = stroke, 
			teamLbl = teamLabel, 
			nameLbl = nameLabel, 
			part = targetPart, 
			isPlayer = true, 
			player = Players:GetPlayerFromCharacter(obj)
		}
	else
		local color, labelName = getESPConfig(obj)
		bill.Size = UDim2.fromOffset(120, 50)
		bill.StudsOffset = Vector3.new(0, 3, 0)
		
		local label = Instance.new("TextLabel", bill)
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextColor3 = color
		label.TextStrokeTransparency = 0
		label.TextSize = 16
		label.Font = Enum.Font.GothamBold
		
		tracked[obj] = {gui = bill, text = label, part = targetPart, name = labelName, isPlayer = false}
	end
end

-- HEARTBEAT
table.insert(connections, RunService.Heartbeat:Connect(function()
	local rainbow = Color3.fromHSV(tick() % 5 / 5, 1, 1)
	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	for obj, data in pairs(tracked) do
		if obj and obj.Parent and data.part then
			if data.isPlayer then
				data.stroke.Color = rainbow
				local plr = data.player
				
				if plr then
					-- Team Text
					if toggles["ShowTeam"] then
						data.teamLbl.Visible = true
						data.teamLbl.Text = plr.Team and plr.Team.Name or "Neutral"
						data.teamLbl.TextColor3 = plr.TeamColor.Color
					else
						data.teamLbl.Visible = false
					end
					
					-- Name Text
					if toggles["ShowName"] then
						data.nameLbl.Visible = true
						data.nameLbl.TextColor3 = rainbow
						if toggles["NameMode"] == "Display" then
							data.nameLbl.Text = plr.DisplayName
						elseif toggles["NameMode"] == "Username" then
							data.nameLbl.Text = "@" .. plr.Name
						else
							data.nameLbl.Text = plr.DisplayName .. " (@" .. plr.Name .. ")"
						end
					else
						data.nameLbl.Visible = false
					end
				end
			else
				if hrp then
					local dist = math.floor((hrp.Position - data.part.Position).Magnitude)
					data.text.Text = data.name .. "\n[" .. dist .. "m]"
				end
			end
		else
			removeESP(obj)
		end
	end
end))

-- Category Logic (Rest is the same)
local function refreshCategory(cat, state)
	if cat == "Box" then
		if state then
			for _, p in pairs(Players:GetPlayers()) do
				if p ~= localPlayer and p.Character then createESP(p.Character, true) end
			end
		else
			for obj, data in pairs(tracked) do
				if data.isPlayer then
					if data.info then data.info:Destroy() end
					removeESP(obj)
				end
			end
		end
	elseif cat ~= "ShowTeam" and cat ~= "ShowName" and cat ~= "NameMode" then
		if state then
			for _, v in pairs(workspace:GetDescendants()) do
				local _, typeName = getESPConfig(v)
				if typeName and typeName:find(cat) then createESP(v, false) end
			end
		else
			for obj, data in pairs(tracked) do
				if not data.isPlayer and data.name:find(cat) then removeESP(obj) end
			end
		end
	end
end

--- BUTTONS ---
local function makeBtn(text, parent)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0.9, 0, 0, 40)
	b.Text = text
	b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.ZIndex = 6
	addUICorner(6, b)
	return b
end

local mainCats = {"Bee", "Metal", "Star", "Box"}
for _, name in pairs(mainCats) do
	local btn = makeBtn(name:upper() .. " ESP [OFF]", scrollingFrame)
	btn.Activated:Connect(function()
		toggles[name] = not toggles[name]
		btn.Text = name:upper() .. " ESP " .. (toggles[name] and "[ON]" or "[OFF]")
		btn.BackgroundColor3 = toggles[name] and Color3.fromRGB(40, 150, 40) or Color3.fromRGB(60, 60, 60)
		refreshCategory(name, toggles[name])
	end)
end

local teamBtn = makeBtn("SHOW TEAM [OFF]", scrollingFrame)
teamBtn.Activated:Connect(function()
	toggles["ShowTeam"] = not toggles["ShowTeam"]
	teamBtn.Text = "SHOW TEAM " .. (toggles["ShowTeam"] and "[ON]" or "[OFF]")
	teamBtn.BackgroundColor3 = toggles["ShowTeam"] and Color3.fromRGB(100, 40, 150) or Color3.fromRGB(60, 60, 60)
end)

local nameBtn = makeBtn("SHOW NAME [OFF]", scrollingFrame)
nameBtn.Activated:Connect(function()
	toggles["ShowName"] = not toggles["ShowName"]
	nameBtn.Text = "SHOW NAME " .. (toggles["ShowName"] and "[ON]" or "[OFF]")
	nameBtn.BackgroundColor3 = toggles["ShowName"] and Color3.fromRGB(100, 40, 150) or Color3.fromRGB(60, 60, 60)
end)

local modeBtn = makeBtn("NAME: DISPLAY", scrollingFrame)
modeBtn.Activated:Connect(function()
	if toggles["NameMode"] == "Display" then
		toggles["NameMode"] = "Username"
	elseif toggles["NameMode"] == "Username" then
		toggles["NameMode"] = "Both"
	else
		toggles["NameMode"] = "Display"
	end
	modeBtn.Text = "NAME: " .. toggles["NameMode"]:upper()
end)

-- UNINJECT
local uninjectBtn = makeBtn("UNINJECT", bottomBar)
uninjectBtn.Size = UDim2.new(0.9, 0, 0.8, 0)
uninjectBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
uninjectBtn.BackgroundColor3 = Color3.fromRGB(130, 40, 40)
uninjectBtn.ZIndex = 11
uninjectBtn.Activated:Connect(function()
	for _, conn in pairs(connections) do conn:Disconnect() end
	for obj in pairs(tracked) do 
		if tracked[obj].info then tracked[obj].info:Destroy() end
		removeESP(obj) 
	end
	fallenWareScreenUI:Destroy()
end)

-- Listeners
table.insert(connections, Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function(c) if toggles["Box"] then task.wait(0.5) createESP(c, true) end end)
end))
for _, p in pairs(Players:GetPlayers()) do
	p.CharacterAdded:Connect(function(c) if toggles["Box"] then task.wait(0.5) createESP(c, true) end end)
end
table.insert(connections, workspace.DescendantAdded:Connect(function(obj)
	task.wait(0.5)
	local _, typeName = getESPConfig(obj)
	if typeName then
		for cat, active in pairs(toggles) do
			if active and typeName:find(cat) then createESP(obj, false) end
		end
	end
end))
