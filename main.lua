print("Feenware Ultimate Loaded!")

local localPlayer = game.Players.LocalPlayer
local playerGUI = localPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local cam = workspace.CurrentCamera
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local kitTranslations = {
	["SPIRIT_GARDENER"] = "Grove", ["BLOOD_ASSASSIN"] = "Caitlyn", ["SHIELDER"] = "Infernal Shielder",
	["PINATA"] = "Lucia", ["CACTUS"] = "Martin", ["DRAGON_SLAYER"] = "Kaliyah", ["FROST_HAMMER_KIT"] = "Adetunde",
	["NECROMANCER"] = "Crypt", ["BIGMAN"] = "Eldertree", ["SPIRIT_ASSASSIN"] = "Evelynn", ["ICE_QUEEN"] = "Freiya",
	["SWORD_SHIELD"] = "Isabel", ["SUMMONER"] = "Kaida", ["COWGIRL"] = "Lassy", ["FLOWER_BEE"] = "Lyla",
	["DEFENDER"] = "Marcel", ["JELLYFISH"] = "Marina", ["OASIS"] = "Nahla", ["BERSERKER"] = "Ragnar",
	["REBELLION_LEADER"] = "Silas", ["VOID_HUNTER"] = "Skoll", ["ANGEL"] = "Trinity", ["TRIPLE_SHOT"] = "Vanessa",
	["OWL"] = "Whisper", ["BLACK_MARKET_TRADER"] = "Wren", ["DASHER"] = "Yuzi", ["DISRUPTOR"] = "Zenith",
	["WIZARD"] = "Zeno", ["FALCONER"] = "Bekzat", ["BATTERY"] = "Cobalt", ["VESTA"] = "Conqueror",
	["BEAST"] = "Crocowolf", ["QUEEN_BEE"] = "Flora", ["GHOST_CATCHER"] = "Gompy", ["TINKER"] = "Hepaestus",
	["PALADIN"] = "Lani", ["MIDNIGHT"] = "Nyx", ["HATTER"] = "Umbra", ["JAILOR"] = "Warden", ["MAGE"] = "Whim",
	["VOID_DRAGON"] = "Xur'ot", ["SCARAB"] = "Abaddon", ["SPIDER_QUEEN"] = "Arachne", ["SORCERER"] = "Death Adder",
	["WARLOCK"] = "Eldric", ["GLACIAL_SKATER"] = "Krystal", ["DRAGON_SWORD"] = "Lian", ["SKELETON"] = "Marrow",
	["MIMIC"] = "Milo", ["AIRBENDER"] = "Ramil", ["SEAHORSE"] = "Sheila", ["ELK_MASTER"] = "Sigrid",
	["WINTER_LADY"] = "Sophia", ["HARPOON"] = "Triton", ["VOID_WALKER"] = "Trixie", ["SPIRIT_SUMMONER"] = "Uma",
	["REGENT"] = "Void Regent", ["GUN_BLADE"] = "Zarrah", ["SOUL_BROKER"] = "Zola", ["SPEARMAN"] = "Ares",
	["STEAM_ENGINEER"] = "Cogsworth", ["CARD"] = "Fortuna", ["OIL_MAN"] = "Jack", ["SLIME_TAMER"] = "Noelle",
	["BLOCK_KICKER"] = "Terra", ["NINJA"] = "Umeko", ["CAT"] = "Yamini", ["WIND_WALKER"] = "Zephyr"
}

-- STATE TRACKING
local isRunning = true
local tracked = {}
local defaultToggles = {
	["BoxESP"] = false, ["Chams"] = false, ["ShowName"] = false, ["ShowTeam"] = false, ["ShowKit"] = false, ["ShowHealth"] = false, 
	["KitRender"] = false, ["KitRenderOwnTeam"] = true, 
	["MetalESP"] = false, ["StarESP"] = false, ["BeeESP"] = false, ["ChestESP"] = false,
	["FarmESP"] = false, ["BeehiveESP"] = false, ["TaliyahESP"] = false, ["BedESP"] = false,
	["Trails"] = false, ["TrailRainbow"] = false, ["TrailBall"] = false,
	["AntiAFK"] = false, ["Freecam"] = false, ["FreecamSpeed"] = 2, 
	["SpinBot"] = false, ["SpinSpeed"] = 20, ["VoidJump"] = false, 
	["Fly"] = false, ["FlySpeed"] = 20, ["InfJump"] = false, ["HighJump"] = false,
	["Speed"] = false, ["SpeedValue"] = 23, ["WallClimb"] = false,
	["KA"] = false, ["KASpeed"] = 0.1, ["KARange"] = 25, ["KAAngle"] = 360,
	["KAWallCheck"] = false, ["KASwingAnim"] = false, ["KASwingSpeed"] = 1.0, ["KASwingRange"] = 25,
	["KATargetPlayer"] = true, ["KATargetNPC"] = false, ["KATargetDummy"] = false, ["KAPriority"] = "Distance",
	["FastBreak"] = false, ["FastBreakTimer"] = 0.05,
	["Nuker"] = false, ["NukerTimer"] = 0.1, ["NukerReqPickaxe"] = true, ["NukerReqAxe"] = false, ["NukerReqShears"] = false, ["NukerBed"] = true, ["NukerOre"] = false, ["NukerPriority"] = "Bed", ["NukerHighlight"] = false,
	["AutoArmor"] = false,
	["ExtendedDrop"] = false, ["ExtendedDropRange"] = 20,
	["StaffDetect"] = false, ["StaffLeave"] = false, ["StaffDestruct"] = false,
	["FOVChanger"] = false, ["FOVValue"] = 90, ["Fullbright"] = false,
	["MenuKey"] = "RightShift"
}
local toggles = {}
for k,v in pairs(defaultToggles) do toggles[k] = v end

local hotkeys = {}
local uiVisuals = {} 
local boxTargetMode = "All"
local farmFilter = "Everything"
local expandedTeams = {}
local uiVisible = true
local connections = {}
local currentBindName = nil
local flyBodyVel = nil

-- RE-SETUP CHARACTER REFS
localPlayer.CharacterAdded:Connect(function(char)
	character = char
	hrp = char:WaitForChild("HumanoidRootPart")
end)

-- CONFIG SAVING
local function saveConfig()
	local cfg = { t = toggles, h = {}, btm = boxTargetMode, ff = farmFilter }
	for k, v in pairs(hotkeys) do cfg.h[k] = v.Name end
	if type(writefile) == "function" then pcall(function() writefile("feenware_cfg.json", HttpService:JSONEncode(cfg)) end) end
end

local function loadConfig()
	if type(readfile) == "function" and type(isfile) == "function" and isfile("feenware_cfg.json") then
		local s, res = pcall(function() return HttpService:JSONDecode(readfile("feenware_cfg.json")) end)
		if s and type(res) == "table" then
			if res.t then for k, v in pairs(res.t) do toggles[k] = v end end
			if res.h then for k, v in pairs(res.h) do pcall(function() hotkeys[k] = Enum.KeyCode[v] end) end end
			boxTargetMode = res.btm or "All"
			farmFilter = res.ff or "Everything"
		end
	end
end

table.insert(connections, Players.PlayerRemoving:Connect(function(plr)
	if plr == localPlayer then saveConfig() end
end))

-- ==========================================
-- FUNCTION DECLARATIONS
-- ==========================================
local ui 
local kitFrame 

local function leaveParty()
	pcall(function()
		local rs = game:GetService("ReplicatedStorage")
		rs:WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("leaveParty"):FireServer()
	end)
end

local function uninject() 
	isRunning = false
	saveConfig()
	for k, v in pairs(toggles) do if type(v) == "boolean" then toggles[k] = false end end
	for _, c in pairs(connections) do c:Disconnect() end
	for o, _ in pairs(tracked) do 
		if tracked[o] and tracked[o].gui then tracked[o].gui:Destroy() end
		if tracked[o] and tracked[o].info then tracked[o].info:Destroy() end
		if tracked[o] and tracked[o].highlight then tracked[o].highlight:Destroy() end 
		if tracked[o] and tracked[o].chams then tracked[o].chams:Destroy() end
	end
	if flyBodyVel then flyBodyVel:Destroy() end
	if cam.CameraType == Enum.CameraType.Scriptable then cam.CameraType = Enum.CameraType.Custom end
	local char = localPlayer.Character
	local hum = char and char:FindFirstChild("Humanoid")
	if hum then hum.WalkSpeed = 16; hum.AutoRotate = true end
	if ui then ui:Destroy() end
end

local staffRoles = { ["Anticheat Mod"] = true, ["Anticheat Manager"] = true, ["Owner"] = true }
local function checkStaff(plr)
	if not toggles.StaffDetect then return end
	task.spawn(function()
		local s, role = pcall(function() return plr:GetRoleInGroup(5774246) end)
		if s and staffRoles[role] then
			if toggles.StaffLeave then leaveParty() end
			if toggles.StaffDestruct then uninject() end
		end
	end)
end

Players.PlayerAdded:Connect(checkStaff)
local function handleStaffScan()
	if toggles.StaffDetect then for _, p in pairs(Players:GetPlayers()) do checkStaff(p) end end
end

-- ==========================================
-- MODERN UI LIBRARY
-- ==========================================
local coreGui = gethui and gethui() or game.CoreGui
if coreGui:FindFirstChild("FEENWARE_ULTIMATE") then coreGui.FEENWARE_ULTIMATE:Destroy() end

ui = Instance.new("ScreenGui", coreGui)
ui.Name = "FEENWARE_ULTIMATE"
ui.ResetOnSpawn = false

-- Theming Palette
local currentAccent = Color3.fromRGB(139, 92, 246)
local c_bg = Color3.fromRGB(15, 15, 18)
local c_sidebar = Color3.fromRGB(22, 22, 26)
local c_element = Color3.fromRGB(32, 32, 38)
local c_hover = Color3.fromRGB(42, 42, 48)
local c_text = Color3.fromRGB(240, 240, 245)
local c_textMuted = Color3.fromRGB(150, 150, 160)
local accentObjects = {}
local searchableItems = {}

local function setAccent(color)
	currentAccent = color
	for obj, prop in pairs(accentObjects) do
		if obj and obj.Parent then TweenService:Create(obj, TweenInfo.new(0.3), {[prop] = color}):Play() end
	end
end

local function addCorner(val, p) local c = Instance.new("UICorner", p); c.CornerRadius = UDim.new(0, val) end

local function makeDraggable(f, h)
	local d, ds, sp
	table.insert(connections, h.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; ds = i.Position; sp = f.Position end end))
	table.insert(connections, UIS.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local del = i.Position - ds; f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + del.X, sp.Y.Scale, sp.Y.Offset + del.Y) end end))
	table.insert(connections, UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end end))
end

-- Notification System
local notifHolder = Instance.new("Frame", ui)
notifHolder.Size = UDim2.new(0, 250, 1, -50); notifHolder.Position = UDim2.new(1, -260, 0, 0); notifHolder.BackgroundTransparency = 1
local notifLayout = Instance.new("UIListLayout", notifHolder); notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom; notifLayout.Padding = UDim.new(0, 10)

local function notify(title, state)
	local f = Instance.new("Frame", notifHolder)
	f.Size = UDim2.new(1, 0, 0, 45); f.BackgroundColor3 = c_sidebar; f.BackgroundTransparency = 1; addCorner(6, f)
	local s = Instance.new("UIStroke", f); s.Color = state and currentAccent or c_element; s.Transparency = 1
	local t = Instance.new("TextLabel", f)
	t.Size = UDim2.new(1, -15, 1, 0); t.Position = UDim2.new(0, 15, 0, 0); t.BackgroundTransparency = 1
	t.Text = title; t.TextColor3 = c_text; t.Font = Enum.Font.GothamBold; t.TextSize = 13; t.TextXAlignment = Enum.TextXAlignment.Left; t.TextTransparency = 1
	
	TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
	TweenService:Create(s, TweenInfo.new(0.3), {Transparency = 0}):Play()
	TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
	task.delay(2.5, function()
		if f.Parent then
			TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
			TweenService:Create(s, TweenInfo.new(0.3), {Transparency = 1}):Play()
			TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
			task.wait(0.3); f:Destroy()
		end
	end)
end

-- Main Window
local mainFrame = Instance.new("Frame", ui)
mainFrame.Size = UDim2.new(0, 700, 0, 460)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -230)
mainFrame.BackgroundColor3 = c_bg
mainFrame.ClipsDescendants = true
addCorner(8, mainFrame)
local mainStroke = Instance.new("UIStroke", mainFrame); mainStroke.Color = Color3.fromRGB(40, 40, 45); mainStroke.Thickness = 1

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true; dragStart = input.Position; startPos = mainFrame.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)
mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Sidebar
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 170, 1, 0)
sidebar.BackgroundColor3 = c_sidebar
sidebar.BorderSizePixel = 0
local sidebarCorner = Instance.new("UICorner", sidebar); sidebarCorner.CornerRadius = UDim.new(0, 8)
local sidebarCover = Instance.new("Frame", sidebar); sidebarCover.Size = UDim2.new(0, 8, 1, 0); sidebarCover.Position = UDim2.new(1, -8, 0, 0); sidebarCover.BackgroundColor3 = c_sidebar; sidebarCover.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", sidebar)
titleLabel.Size = UDim2.new(1, 0, 0, 70)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "FEENWARE"
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 22
titleLabel.TextColor3 = currentAccent
accentObjects[titleLabel] = "TextColor3"

local tabContainer = Instance.new("Frame", sidebar)
tabContainer.Size = UDim2.new(1, 0, 1, -70)
tabContainer.Position = UDim2.new(0, 0, 0, 70)
tabContainer.BackgroundTransparency = 1
local tabLayout = Instance.new("UIListLayout", tabContainer)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 6)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Main Content Area
local contentWrapper = Instance.new("Frame", mainFrame)
contentWrapper.Size = UDim2.new(1, -170, 1, 0)
contentWrapper.Position = UDim2.new(0, 170, 0, 0)
contentWrapper.BackgroundTransparency = 1

-- Topbar with Search
local topbar = Instance.new("Frame", contentWrapper)
topbar.Size = UDim2.new(1, 0, 0, 60)
topbar.BackgroundTransparency = 1

local searchBox = Instance.new("TextBox", topbar)
searchBox.Size = UDim2.new(0.9, 0, 0, 36)
searchBox.Position = UDim2.new(0.05, 0, 0.5, -18)
searchBox.BackgroundColor3 = c_element
searchBox.PlaceholderText = "Search..."
searchBox.Text = ""
searchBox.TextColor3 = c_text
searchBox.PlaceholderColor3 = c_textMuted
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
searchBox.TextXAlignment = Enum.TextXAlignment.Left
local sPad = Instance.new("UIPadding", searchBox); sPad.PaddingLeft = UDim.new(0, 15)
addCorner(6, searchBox)

local contentContainer = Instance.new("Frame", contentWrapper)
contentContainer.Size = UDim2.new(1, 0, 1, -60)
contentContainer.Position = UDim2.new(0, 0, 0, 60)
contentContainer.BackgroundTransparency = 1

local activeTab = nil
local tabs = {}

-- Search Logic
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local q = searchBox.Text:lower()
	for _, item in ipairs(searchableItems) do
		if q == "" then
			item.element.Visible = true
		else
			if item.name:find(q) then
				item.element.Visible = true
				if item.parentCategory then item.parentCategory(true) end
			else
				item.element.Visible = false
			end
		end
	end
end)

local function createTab(name)
	local tabBtn = Instance.new("TextButton", tabContainer)
	tabBtn.Size = UDim2.new(0.85, 0, 0, 38)
	tabBtn.BackgroundColor3 = c_element
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = name
	tabBtn.TextColor3 = c_textMuted
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.TextSize = 14
	addCorner(6, tabBtn)
	
	local tabContent = Instance.new("ScrollingFrame", contentContainer)
	tabContent.Size = UDim2.new(1, 0, 1, 0)
	tabContent.BackgroundTransparency = 1
	tabContent.ScrollBarThickness = 3
	tabContent.ScrollBarImageColor3 = currentAccent
	tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabContent.Visible = false
	accentObjects[tabContent] = "ScrollBarImageColor3"
	
	local contentLayout = Instance.new("UIListLayout", tabContent)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, 8)
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local cPad = Instance.new("UIPadding", tabContent)
	cPad.PaddingTop = UDim.new(0, 5); cPad.PaddingBottom = UDim.new(0, 20)
	
	contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 40)
	end)
	
	tabBtn.MouseButton1Down:Connect(function()
		for _, t in pairs(tabs) do
			TweenService:Create(t.btn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = c_textMuted}):Play()
			t.content.Visible = false
		end
		TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, TextColor3 = currentAccent}):Play()
		tabContent.Visible = true
		activeTab = name
		searchBox.Text = ""
	end)
	
	table.insert(tabs, {btn = tabBtn, content = tabContent})
	if not activeTab then 
		tabBtn.BackgroundTransparency = 0.2; tabBtn.TextColor3 = currentAccent; tabContent.Visible = true; activeTab = name 
	end
	
	return tabContent
end

local function MakeExpandableCategory(parent, titleText)
	local container = Instance.new("Frame", parent)
	container.Size = UDim2.new(0.92, 0, 0, 40)
	container.BackgroundColor3 = c_sidebar
	container.ClipsDescendants = true
	addCorner(6, container)
	
	local header = Instance.new("TextButton", container)
	header.Size = UDim2.new(1, 0, 0, 40)
	header.BackgroundTransparency = 1; header.Text = ""
	
	local lbl = Instance.new("TextLabel", header)
	lbl.Size = UDim2.new(1, -40, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1; lbl.Text = titleText:upper(); lbl.TextColor3 = c_textMuted
	lbl.Font = Enum.Font.GothamBlack; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local arrow = Instance.new("TextLabel", header)
	arrow.Size = UDim2.new(0, 30, 1, 0); arrow.Position = UDim2.new(1, -35, 0, 0)
	arrow.BackgroundTransparency = 1; arrow.Text = "▶"; arrow.TextColor3 = c_textMuted
	arrow.Font = Enum.Font.GothamBlack; arrow.TextSize = 12
	
	local content = Instance.new("Frame", container)
	content.Size = UDim2.new(1, 0, 1, -40); content.Position = UDim2.new(0, 0, 0, 40)
	content.BackgroundTransparency = 1
	
	local layout = Instance.new("UIListLayout", content)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local pad = Instance.new("UIPadding", content); pad.PaddingTop = UDim.new(0, 6); pad.PaddingBottom = UDim.new(0, 6)
	
	local expanded = false
	
	local function setExpanded(state)
		expanded = state
		arrow.Text = expanded and "▼" or "▶"
		arrow.TextColor3 = expanded and currentAccent or c_textMuted
		lbl.TextColor3 = expanded and c_text or c_textMuted
		
		local targetHeight = expanded and (40 + layout.AbsoluteContentSize.Y + 12) or 40
		TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0.92, 0, 0, targetHeight)}):Play()
	end
	
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if expanded then container.Size = UDim2.new(0.92, 0, 0, 40 + layout.AbsoluteContentSize.Y + 12) end
	end)
	
	header.MouseButton1Down:Connect(function() setExpanded(not expanded) end)
	
	return content, function(forceOpen) if forceOpen and not expanded then setExpanded(true) end end
end

local function MakeToggle(parent, id, titleText, callback, parentExpanderFn)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(0.96, 0, 0, 38)
	frame.BackgroundColor3 = c_element
	addCorner(6, frame)
	
	-- Robust trigger that spans the whole row so clicks never miss
	local triggerBtn = Instance.new("TextButton", frame)
	triggerBtn.Size = UDim2.new(1, -60, 1, 0); triggerBtn.BackgroundTransparency = 1; triggerBtn.Text = ""; triggerBtn.ZIndex = 5
	
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(0.6, 0, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1; lbl.Text = titleText; lbl.TextColor3 = c_text
	lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local kbBtn = Instance.new("TextButton", frame)
	kbBtn.Size = UDim2.new(0, 45, 0, 22); kbBtn.Position = UDim2.new(1, -110, 0.5, -11)
	kbBtn.BackgroundColor3 = c_sidebar; kbBtn.TextColor3 = c_textMuted; kbBtn.Text = "[+]"
	kbBtn.Font = Enum.Font.Gotham; kbBtn.TextSize = 10; kbBtn.ZIndex = 6; addCorner(4, kbBtn)
	
	local function updateKB() kbBtn.Text = hotkeys[id] and "["..hotkeys[id].Name.."]" or "[+]" end
	uiVisuals[id.."_key"] = updateKB
	kbBtn.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton2 then hotkeys[id] = nil; updateKB(); saveConfig() end end)
	kbBtn.MouseButton1Down:Connect(function() currentBindName = id; kbBtn.Text = "..." end)
	updateKB()
	
	local switchBg = Instance.new("Frame", frame)
	switchBg.Size = UDim2.new(0, 40, 0, 20); switchBg.Position = UDim2.new(1, -55, 0.5, -10)
	switchBg.BackgroundColor3 = toggles[id] and currentAccent or c_sidebar
	addCorner(10, switchBg)
	accentObjects[switchBg] = toggles[id] and "BackgroundColor3" or nil
	
	local knob = Instance.new("Frame", switchBg)
	knob.Size = UDim2.new(0, 16, 0, 16); knob.Position = UDim2.new(toggles[id] and 1 or 0, toggles[id] and -18 or 2, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); addCorner(10, knob)
	
	local function updateVis()
		local state = toggles[id]
		if state then accentObjects[switchBg] = "BackgroundColor3" else accentObjects[switchBg] = nil end
		TweenService:Create(switchBg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = state and currentAccent or c_sidebar}):Play()
		TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(state and 1 or 0, state and -18 or 2, 0.5, -8)}):Play()
		if id == "KitRender" and kitFrame then kitFrame.Visible = (state and uiVisible) end
		if id == "Fullbright" then 
			if state then Lighting.Ambient = Color3.new(1,1,1); Lighting.Brightness = 1 else Lighting.Ambient = Color3.new(0,0,0); Lighting.Brightness = 0.5 end 
		end
	end
	uiVisuals[id] = updateVis
	
	triggerBtn.MouseButton1Down:Connect(function()
		toggles[id] = not toggles[id]; updateVis(); if callback then callback() end; saveConfig()
	end)
	updateVis()
	
	table.insert(searchableItems, {name = titleText:lower(), element = frame, parentCategory = parentExpanderFn})
end

local function MakeSlider(parent, id, titleText, min, max, isFloat, parentExpanderFn)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(0.96, 0, 0, 50)
	frame.BackgroundColor3 = c_element
	addCorner(6, frame)
	
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(1, -24, 0, 20); lbl.Position = UDim2.new(0, 12, 0, 6)
	lbl.BackgroundTransparency = 1; lbl.TextColor3 = c_text; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local sBg = Instance.new("Frame", frame)
	sBg.Size = UDim2.new(1, -24, 0, 6); sBg.Position = UDim2.new(0, 12, 0, 32)
	sBg.BackgroundColor3 = c_sidebar; addCorner(3, sBg)
	
	local fill = Instance.new("Frame", sBg)
	fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = currentAccent; addCorner(3, fill)
	accentObjects[fill] = "BackgroundColor3"
	
	local btn = Instance.new("TextButton", sBg)
	btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 5
	
	local function updateVis()
		local val = toggles[id] or min
		local pct = math.clamp((val - min) / (max - min), 0, 1)
		fill.Size = UDim2.new(pct, 0, 1, 0)
		lbl.Text = titleText .. ": " .. (isFloat and string.format("%.2f", val) or val)
		if id == "FOVValue" and toggles.FOVChanger then cam.FieldOfView = val end
	end
	uiVisuals[id] = updateVis
	
	local drag = false
	btn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = true
			local pct = math.clamp((i.Position.X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
			local raw = min + ((max - min) * pct)
			toggles[id] = isFloat and raw or math.floor(raw)
			updateVis(); saveConfig()
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local pct = math.clamp((i.Position.X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
			local raw = min + ((max - min) * pct)
			toggles[id] = isFloat and raw or math.floor(raw)
			updateVis(); saveConfig()
		end
	end)
	btn.MouseButton1Down:Connect(function(x)
		local pct = math.clamp((x - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
		local raw = min + ((max - min) * pct)
		toggles[id] = isFloat and raw or math.floor(raw)
		updateVis(); saveConfig()
	end)
	
	updateVis()
	table.insert(searchableItems, {name = titleText:lower(), element = frame, parentCategory = parentExpanderFn})
end

local function MakeDropdown(parent, id, titleText, options, parentExpanderFn)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(0.96, 0, 0, 40)
	frame.BackgroundColor3 = c_element
	addCorner(6, frame)
	
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(1, -24, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1; lbl.TextColor3 = c_text; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 5
	
	local function updateVis() 
		local currentVal = toggles[id] or options[1]
		lbl.Text = titleText .. ": " .. tostring(currentVal):upper() 
	end
	uiVisuals[id] = updateVis
	
	btn.MouseButton1Down:Connect(function()
		local current = toggles[id] or options[1]
		local idx = table.find(options, current) or 1
		local nextIdx = idx >= #options and 1 or idx + 1
		toggles[id] = options[nextIdx]
		updateVis(); saveConfig()
	end)
	updateVis()
	table.insert(searchableItems, {name = titleText:lower(), element = frame, parentCategory = parentExpanderFn})
end

local function MakeButton(parent, text, callback, parentExpanderFn)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0.96, 0, 0, 36)
	b.BackgroundColor3 = c_element
	b.TextColor3 = c_text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.Text = text
	b.ZIndex = 5
	addCorner(6, b)
	
	b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = c_hover}):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = c_element}):Play() end)
	b.MouseButton1Down:Connect(callback)
	
	table.insert(searchableItems, {name = text:lower(), element = b, parentCategory = parentExpanderFn})
	return b
end

-- ==========================================
-- POPULATE TABS & EXPANDABLE CATEGORIES
-- ==========================================
local tCombat = createTab("Combat")
local cAura, fAura = MakeExpandableCategory(tCombat, "KA Config")
MakeToggle(cAura, "KA", "KA", nil, fAura)
MakeSlider(cAura, "KASpeed", "Delay", 0.01, 2.0, true, fAura)
MakeSlider(cAura, "KARange", "Range", 5, 100, false, fAura)
MakeSlider(cAura, "KAAngle", "Angle", 10, 360, false, fAura)
MakeToggle(cAura, "KAWallCheck", "Wall Check", nil, fAura)
MakeDropdown(cAura, "KAPriority", "Priority", {"Distance", "Player", "NPC", "Dummy"}, fAura)

local cAuraVis, fAuraVis = MakeExpandableCategory(tCombat, "KA Visuals")
MakeToggle(cAuraVis, "KASwingAnim", "Swing Anim", nil, fAuraVis)
MakeSlider(cAuraVis, "KASwingRange", "Anim Range", 5, 100, false, fAuraVis)
MakeSlider(cAuraVis, "KASwingSpeed", "Anim Speed", 0.1, 3.0, true, fAuraVis)

local cAuraTarg, fAuraTarg = MakeExpandableCategory(tCombat, "KA Targets")
MakeToggle(cAuraTarg, "KATargetPlayer", "Players", nil, fAuraTarg)
MakeToggle(cAuraTarg, "KATargetNPC", "NPCs", nil, fAuraTarg)
MakeToggle(cAuraTarg, "KATargetDummy", "Dummies", nil, fAuraTarg)

local tMovement = createTab("Movement")
local cSpeed, fSpeed = MakeExpandableCategory(tMovement, "Speed")
MakeToggle(cSpeed, "Speed", "Speed", nil, fSpeed)
MakeSlider(cSpeed, "SpeedValue", "Value", 16, 50, false, fSpeed)
MakeToggle(cSpeed, "Fly", "Fly", nil, fSpeed)
MakeSlider(cSpeed, "FlySpeed", "Speed", 10, 100, false, fSpeed)

local cAbil, fAbil = MakeExpandableCategory(tMovement, "Actions")
MakeToggle(cAbil, "InfJump", "Inf Jump", nil, fAbil)
MakeToggle(cAbil, "HighJump", "High Jump", nil, fAbil)
MakeToggle(cAbil, "VoidJump", "Void Jump", nil, fAbil)
MakeToggle(cAbil, "WallClimb", "Crawler", nil, fAbil)
MakeToggle(cAbil, "SpinBot", "SpinBot", nil, fAbil)
MakeSlider(cAbil, "SpinSpeed", "Speed", 10, 100, false, fAbil)

local tVisuals = createTab("Visuals")
local cPlrEsp, fPlrEsp = MakeExpandableCategory(tVisuals, "Player ESP")
MakeToggle(cPlrEsp, "BoxESP", "Boxes", nil, fPlrEsp)
MakeToggle(cPlrEsp, "Chams", "Chams", nil, fPlrEsp)
MakeDropdown(cPlrEsp, "TM", "Target", {"All", "Enemy", "Teams"}, fPlrEsp)
MakeToggle(cPlrEsp, "ShowName", "Names", nil, fPlrEsp)
MakeToggle(cPlrEsp, "ShowTeam", "Teams", nil, fPlrEsp)
MakeToggle(cPlrEsp, "ShowKit", "Kits", nil, fPlrEsp)
MakeToggle(cPlrEsp, "ShowHealth", "Health", nil, fPlrEsp)

local cWorldR, fWorldR = MakeExpandableCategory(tVisuals, "World Render")
MakeToggle(cWorldR, "KitRender", "Kit Render", nil, fWorldR)
MakeToggle(cWorldR, "KitRenderOwnTeam", "Own Team", nil, fWorldR)
MakeToggle(cWorldR, "Freecam", "Freecam", nil, fWorldR)
MakeSlider(cWorldR, "FreecamSpeed", "Cam Speed", 1, 10, false, fWorldR)
MakeToggle(cWorldR, "Fullbright", "Fullbright", nil, fWorldR)
MakeToggle(cWorldR, "FOVChanger", "FOV", function() if not toggles.FOVChanger then cam.FieldOfView = 70 end end, fWorldR)
MakeSlider(cWorldR, "FOVValue", "Value", 70, 120, false, fWorldR)

local cCosm, fCosm = MakeExpandableCategory(tVisuals, "Cosmetics")
MakeToggle(cCosm, "Trails", "Trails", nil, fCosm)
MakeToggle(cCosm, "TrailRainbow", "Rainbow", nil, fCosm)
MakeToggle(cCosm, "TrailBall", "Ball", nil, fCosm)

local tWorld = createTab("World")
local cResEsp, fResEsp = MakeExpandableCategory(tWorld, "Ores")
MakeToggle(cResEsp, "MetalESP", "Metal", nil, fResEsp)
MakeToggle(cResEsp, "StarESP", "Stars", nil, fResEsp)
MakeToggle(cResEsp, "BeeESP", "Bees", nil, fResEsp)
MakeToggle(cResEsp, "ChestESP", "Chests", nil, fResEsp)

local cFarmEsp, fFarmEsp = MakeExpandableCategory(tWorld, "Farming")
MakeToggle(cFarmEsp, "FarmESP", "Crops", nil, fFarmEsp)
MakeDropdown(cFarmEsp, "FF", "Filter", {"Everything", "Melon Only", "Carrot Only", "Pumpkin Only"}, fFarmEsp)
MakeToggle(cFarmEsp, "BeehiveESP", "Beehives", nil, fFarmEsp)
MakeToggle(cFarmEsp, "TaliyahESP", "Taliyah", nil, fFarmEsp)
MakeToggle(cFarmEsp, "BedESP", "Beds", nil, fFarmEsp)

local tMisc = createTab("Misc")
local cMine, fMine = MakeExpandableCategory(tMisc, "Mining")
MakeToggle(cMine, "Nuker", "Nuker", nil, fMine)
MakeSlider(cMine, "NukerTimer", "Speed", 0.01, 1.0, true, fMine)
MakeToggle(cMine, "NukerBed", "Beds", nil, fMine)
MakeToggle(cMine, "NukerOre", "Ores", nil, fMine)
MakeDropdown(cMine, "NukerPriority", "Priority", {"Bed", "Ore", "Distance"}, fMine)
MakeToggle(cMine, "NukerHighlight", "Highlight", nil, fMine)
MakeToggle(cMine, "NukerReqPickaxe", "Req Pickaxe", nil, fMine)
MakeToggle(cMine, "NukerReqAxe", "Req Axe", nil, fMine)
MakeToggle(cMine, "NukerReqShears", "Req Shears", nil, fMine)
MakeToggle(cMine, "FastBreak", "Fast Break", nil, fMine)
MakeSlider(cMine, "FastBreakTimer", "Tick", 0.01, 0.5, true, fMine)

local cAuto, fAuto = MakeExpandableCategory(tMisc, "Automation")
MakeToggle(cAuto, "AutoArmor", "Auto Armor", nil, fAuto)
MakeToggle(cAuto, "ExtendedDrop", "Auto Pickup", nil, fAuto)
MakeSlider(cAuto, "ExtendedDropRange", "Range", 8, 40, false, fAuto)

local cUtil, fUtil = MakeExpandableCategory(tMisc, "Utility")
MakeToggle(cUtil, "AntiAFK", "Anti-AFK", nil, fUtil)
MakeToggle(cUtil, "StaffDetect", "Staff Detect", nil, fUtil)
MakeToggle(cUtil, "StaffLeave", "Staff Leave", nil, fUtil)
MakeToggle(cUtil, "StaffDestruct", "Staff Destruct", nil, fUtil)

local tSettings = createTab("Settings")
local cTheme, fTheme = MakeExpandableCategory(tSettings, "UI Theme")
local colorGrid = Instance.new("Frame", cTheme)
colorGrid.Size = UDim2.new(0.92, 0, 0, 45); colorGrid.BackgroundTransparency = 1
local cl = Instance.new("UIListLayout", colorGrid); cl.FillDirection = Enum.FillDirection.Horizontal; cl.HorizontalAlignment = Enum.HorizontalAlignment.Center; cl.VerticalAlignment = Enum.VerticalAlignment.Center; cl.Padding = UDim.new(0, 12)

local colors = {
	Color3.fromRGB(139, 92, 246), -- Violet
	Color3.fromRGB(239, 68, 68),  -- Red
	Color3.fromRGB(59, 130, 246), -- Blue
	Color3.fromRGB(16, 185, 129), -- Teal
	Color3.fromRGB(245, 158, 11), -- Gold
	Color3.fromRGB(236, 72, 153)  -- Pink
}

for _, col in ipairs(colors) do
	local cb = Instance.new("TextButton", colorGrid)
	cb.Size = UDim2.new(0, 32, 0, 32); cb.BackgroundColor3 = col; cb.Text = ""; cb.ZIndex = 5
	addCorner(16, cb)
	local cs = Instance.new("UIStroke", cb); cs.Color = Color3.new(1,1,1); cs.Transparency = 0.8; cs.Thickness = 2
	cb.MouseButton1Down:Connect(function() setAccent(col) end)
end

local cCfg, fCfg = MakeExpandableCategory(tSettings, "Configuration")
local menuKbFrame = Instance.new("Frame", cCfg)
menuKbFrame.Size = UDim2.new(0.96, 0, 0, 40); menuKbFrame.BackgroundColor3 = c_element; addCorner(6, menuKbFrame)
local mKbLbl = Instance.new("TextLabel", menuKbFrame)
mKbLbl.Size = UDim2.new(0.6, 0, 1, 0); mKbLbl.Position = UDim2.new(0, 12, 0, 0); mKbLbl.BackgroundTransparency = 1; mKbLbl.Text = "Menu Key"; mKbLbl.TextColor3 = c_text; mKbLbl.Font = Enum.Font.GothamSemibold; mKbLbl.TextSize = 13; mKbLbl.TextXAlignment = Enum.TextXAlignment.Left
local mKbBtn = Instance.new("TextButton", menuKbFrame)
mKbBtn.Size = UDim2.new(0, 80, 0, 22); mKbBtn.Position = UDim2.new(1, -90, 0.5, -11); mKbBtn.BackgroundColor3 = c_sidebar; mKbBtn.TextColor3 = currentAccent; mKbBtn.Font = Enum.Font.GothamBold; mKbBtn.TextSize = 12; mKbBtn.ZIndex = 5; addCorner(4, mKbBtn)
accentObjects[mKbBtn] = "TextColor3"
local bindingMenu = false
mKbBtn.Text = "[" .. (toggles.MenuKey or "RightShift") .. "]"
mKbBtn.MouseButton1Down:Connect(function() bindingMenu = true; mKbBtn.Text = "..." end)

MakeButton(cCfg, "Unbind Hotkeys", function()
	hotkeys = {}; for id, fn in pairs(uiVisuals) do if id:find("_key") then fn() end end; saveConfig(); notify("Hotkeys Unbound", false)
end, fCfg)
MakeButton(cCfg, "Disable Toggles", function()
	for k, v in pairs(toggles) do if type(v) == "boolean" and k ~= "KitRenderOwnTeam" then toggles[k] = false end end
	for id, fn in pairs(uiVisuals) do if not id:find("_key") then fn() end end; saveConfig(); notify("Toggles Disabled", false)
end, fCfg)
MakeButton(cCfg, "Leave Party", function() notify("Leaving Party...", true); leaveParty() end, fCfg)
MakeButton(cCfg, "Uninject", function() notify("Uninjecting Feenware...", false); uninject() end, fCfg)

uiVisuals.TM = function() boxTargetMode = toggles.TM or "All" end
uiVisuals.FF = function() farmFilter = toggles.FF or "Everything" end

-- ==========================================
-- KIT RENDER FRAME
-- ==========================================
kitFrame = Instance.new("Frame", ui)
kitFrame.Size = UDim2.new(0, 380, 0, 520); kitFrame.Position = UDim2.new(0.7, 0, 0.2, 0); kitFrame.BackgroundColor3 = c_bg; kitFrame.Visible = false; addCorner(10, kitFrame); makeDraggable(kitFrame, kitFrame)
local kitStroke = Instance.new("UIStroke", kitFrame); kitStroke.Color = currentAccent; kitStroke.Thickness = 1; accentObjects[kitStroke] = "Color"
local kitTitleTxt = Instance.new("TextLabel", kitFrame); kitTitleTxt.Size = UDim2.new(1, 0, 0, 45); kitTitleTxt.BackgroundTransparency = 1; kitTitleTxt.Text = "KIT RENDER"; kitTitleTxt.TextColor3 = currentAccent; kitTitleTxt.Font = Enum.Font.GothamBlack; kitTitleTxt.TextSize = 18; accentObjects[kitTitleTxt] = "TextColor3"
local kitLineFrame = Instance.new("Frame", kitFrame); kitLineFrame.Size = UDim2.new(1, -30, 0, 1); kitLineFrame.Position = UDim2.new(0, 15, 0, 45); kitLineFrame.BackgroundColor3 = c_element; kitLineFrame.BorderSizePixel = 0
local kitScroll = Instance.new("ScrollingFrame", kitFrame); kitScroll.Size = UDim2.new(0.95, 0, 0.85, 0); kitScroll.Position = UDim2.new(0.025, 0, 0.12, 0); kitScroll.BackgroundTransparency = 1; kitScroll.ScrollBarThickness = 2; kitScroll.ScrollBarImageColor3 = currentAccent; kitScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; accentObjects[kitScroll] = "ScrollBarImageColor3"

-- ==========================================
-- LOGIC & PHYSICS LOOPS
-- ==========================================
local function getESPConfig(obj)
	if not obj or not obj.Name then return nil end
	local n = obj.Name:lower()
	if n:find("melon") then return Color3.fromRGB(0, 255, 0), "Melon", "Farm" end
	if n:find("carrot") then return Color3.fromRGB(255, 255, 0), "Carrot", "Farm" end
	if n:find("pumpkin") then return Color3.fromRGB(255, 128, 0), "Pumpkin", "Farm" end
	if n:find("beehive") then return Color3.fromRGB(255, 200, 0), "Beehive", "Farm" end
	if n:find("chicken_egg_block") then return Color3.fromRGB(255, 170, 255), "Taliyah", "Farm" end
	if n:find("bed") and not n:find("bedrock") then return Color3.fromRGB(255, 50, 50), "Bed", "Farm" end
	if n:find("star") then
		if n:find("vitality") or n:find("health") then return Color3.new(0, 1, 0), "Health Star", "World"
		else return Color3.new(1, 0.5, 0), "Crit Star", "World" end
	end
	if n:find("metal") or obj:FindFirstChild("hidden-metal-prompt") then return Color3.new(0, 1, 1), "Metal", "World" end
	if n:find("bee") and not n:find("beehive") then return Color3.new(1, 1, 0), "Bee", "World" end
	if n:find("chest") and not obj:IsA("Accessory") then return Color3.fromRGB(150, 100, 50), "Chest", "World" end
	return nil
end

local function createESP(obj, isPlayer)
	if tracked[obj] then return end
	local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
	if not targetPart and not isPlayer then return end
	local root = obj:FindFirstChild("HumanoidRootPart") or targetPart
	local col, typeStr, method = getESPConfig(obj)
	if isPlayer then method = "Player" end
	if not method then return end

	if method == "Farm" then
		local hl = Instance.new("Highlight", targetPart); hl.Name = "ZenHL"; hl.FillColor = col; hl.FillTransparency = 0.5; hl.OutlineColor = col; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Enabled = false
		local marker = Instance.new("BillboardGui", targetPart); marker.Name = "ZenMarker"; marker.AlwaysOnTop = true; marker.Size = UDim2.fromOffset(180, 35); marker.StudsOffset = Vector3.new(0, 5, 0); marker.Enabled = false
		local markerTxt = Instance.new("TextLabel", marker); markerTxt.Size = UDim2.fromScale(1, 1); markerTxt.BackgroundTransparency = 1; markerTxt.TextColor3 = col; markerTxt.TextStrokeTransparency = 0.5; markerTxt.Font = Enum.Font.GothamBold; markerTxt.TextSize = 16
		tracked[obj] = { mode = "Farm", highlight = hl, info = marker, textLabel = markerTxt, espType = typeStr, part = targetPart }
	elseif method == "World" then
		local m = Instance.new("BillboardGui", root); m.AlwaysOnTop = true; m.Size = UDim2.fromOffset(100, 30); m.StudsOffset = Vector3.new(0,3,0); m.Enabled = false
		local t = Instance.new("TextLabel", m); t.Size = UDim2.fromScale(1,1); t.BackgroundTransparency = 1; t.TextColor3 = col; t.Font = Enum.Font.GothamBold; t.TextSize = 14
		tracked[obj] = { mode = "World", info = m, textLabel = t, espType = typeStr, part = root }
	elseif method == "Player" then
		local info = Instance.new("BillboardGui", root); info.Name = "ZenMarker"; info.AlwaysOnTop = true; info.Size = UDim2.fromOffset(250, 100); info.StudsOffset = Vector3.new(0, 7.5, 0); info.Enabled = false
		local tl = Instance.new("TextLabel", info); tl.Size = UDim2.fromScale(1, 1); tl.BackgroundTransparency = 1; tl.Font = Enum.Font.GothamBold; tl.TextSize = 16; tl.TextStrokeTransparency = 0.5; tl.TextYAlignment = Enum.TextYAlignment.Bottom
		local b = Instance.new("BillboardGui", root); b.Name = "ZenBox"; b.AlwaysOnTop = true; b.Size = UDim2.fromScale(4.5, 6.5); b.Enabled = false
		local f = Instance.new("Frame", b); f.Size = UDim2.fromScale(1,1); f.BackgroundTransparency = 1; local s = Instance.new("UIStroke", f); s.Thickness = 2
		tracked[obj] = { mode = "Player", gui = b, info = info, textLabel = tl, stroke = s, player = Players:GetPlayerFromCharacter(obj), part = root, chams = nil }
	end
end

local function removeESP(obj)
	if tracked[obj] then
		if tracked[obj].gui then tracked[obj].gui:Destroy() end
		if tracked[obj].info then tracked[obj].info:Destroy() end
		if tracked[obj].highlight then tracked[obj].highlight:Destroy() end
		if tracked[obj].chams then tracked[obj].chams:Destroy() end
		tracked[obj] = nil
	end
end

table.insert(connections, workspace.DescendantAdded:Connect(function(v) 
	task.wait(0.1)
	if getESPConfig(v) then createESP(v, false) end
end))
table.insert(connections, workspace.DescendantRemoving:Connect(function(v) removeESP(v) end))
for _, v in pairs(workspace:GetDescendants()) do if getESPConfig(v) then createESP(v, false) end end

local function onPlayerAdded(p) table.insert(connections, p.CharacterAdded:Connect(function(char) task.wait(0.5); createESP(char, true) end)); if p.Character then createESP(p.Character, true) end end
table.insert(connections, Players.PlayerAdded:Connect(onPlayerAdded))
for _, p in pairs(Players:GetPlayers()) do onPlayerAdded(p) end

local camAngleX, camAngleY, lastTrail, lastVoidJump = 0, 0, tick(), 0
local freecamActive = false

table.insert(connections, UIS.InputChanged:Connect(function(input)
	if toggles.Freecam and input.UserInputType == Enum.UserInputType.MouseMovement then
		if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
			camAngleX = camAngleX - (input.Delta.X * 0.4)
			camAngleY = math.clamp(camAngleY - (input.Delta.Y * 0.4), -89, 89)
			cam.CFrame = CFrame.new(cam.CFrame.Position) * CFrame.Angles(0, math.rad(camAngleX), 0) * CFrame.Angles(math.rad(camAngleY), 0, 0)
		else UIS.MouseBehavior = Enum.MouseBehavior.Default end
	end
end))

table.insert(connections, UIS.InputBegan:Connect(function(input, g)
	if bindingMenu then
		local keyName = input.KeyCode.Name
		if keyName ~= "Unknown" then
			toggles.MenuKey = keyName
			uiVisuals.MenuKey = function() end 
			bindingMenu = false
			saveConfig()
			notify("Menu Key Bound to " .. keyName, true)
		end
		return
	end

	if g then return end
	
	local targetKey = toggles.MenuKey or "RightShift"
	if input.KeyCode.Name == targetKey then
		uiVisible = not uiVisible; mainFrame.Visible = uiVisible
		if toggles.KitRender and kitFrame then kitFrame.Visible = uiVisible end
	end
	
	for id, k in pairs(hotkeys) do
		if input.KeyCode == k then
			toggles[id] = not toggles[id]
			if uiVisuals[id] then uiVisuals[id]() end
			local cleanName = string.gsub(id, "ESP", " ESP")
			notify(string.upper(cleanName) .. (toggles[id] and " Enabled" or " Disabled"), toggles[id])
			saveConfig()
		end
	end

	if input.KeyCode == Enum.KeyCode.Space then
		local char = localPlayer.Character
		local locHrp = char and char:FindFirstChild("HumanoidRootPart")
		if locHrp then
			if toggles.InfJump then locHrp.Velocity = Vector3.new(locHrp.Velocity.X, 40, locHrp.Velocity.Z) end
			if toggles.HighJump then locHrp.Velocity = Vector3.new(locHrp.Velocity.X, 100, locHrp.Velocity.Z) end
		end
	end
end))

-- MAIN BACKGROUND LOOP (Uses isRunning so it never dies on respawn)
table.insert(connections, RunService.RenderStepped:Connect(function(dt)
	if not isRunning then return end
	local char = localPlayer.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local locHrp = char and char:FindFirstChild("HumanoidRootPart")
	local cp = cam.CFrame.Position
	
	-- FREECAM
	if toggles.Freecam then
		if not freecamActive then
			freecamActive = true
			local rx, ry, rz = cam.CFrame:ToEulerAnglesYXZ()
			camAngleX = math.deg(ry)
			camAngleY = math.deg(rx)
			if locHrp then locHrp.Anchored = true end 
		end
		cam.CameraType = Enum.CameraType.Scriptable; local move = Vector3.new(); local spd = toggles.FreecamSpeed
		if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.E) then move = move + cam.CFrame.UpVector end
		if UIS:IsKeyDown(Enum.KeyCode.Q) then move = move - cam.CFrame.UpVector end
		cam.CFrame = cam.CFrame + (move * (spd * 0.5))
	else
		if freecamActive then
			freecamActive = false; if locHrp and locHrp.Anchored then locHrp.Anchored = false end
			cam.CameraType = Enum.CameraType.Custom; cam.CameraSubject = hum; UIS.MouseBehavior = Enum.MouseBehavior.Default
		end
	end

	-- SPINBOT
	if toggles.SpinBot and locHrp and hum and not toggles.Freecam then
		hum.AutoRotate = false
		locHrp.CFrame = locHrp.CFrame * CFrame.Angles(0, math.rad(toggles.SpinSpeed), 0)
	elseif hum and not toggles.SpinBot then
		hum.AutoRotate = true
	end

	-- FLY
	if toggles.Fly and locHrp then
		if not flyBodyVel or not flyBodyVel.Parent then
			flyBodyVel = Instance.new("BodyVelocity")
			flyBodyVel.MaxForce = Vector3.new(100000, 100000, 100000)
			flyBodyVel.Parent = locHrp
		end
		local move = Vector3.new()
		if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
		local yVel = 0
		if UIS:IsKeyDown(Enum.KeyCode.Space) then yVel = toggles.FlySpeed end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then yVel = -toggles.FlySpeed end
		flyBodyVel.Velocity = Vector3.new(move.X * toggles.FlySpeed, yVel, move.Z * toggles.FlySpeed)
	else
		if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
	end

	-- SPEED
	if toggles.Speed and locHrp and hum and not toggles.Fly then
		if hum.MoveDirection.Magnitude > 0 then
			local bonusSpeed = toggles.SpeedValue - 16
			if bonusSpeed > 0 then
				locHrp.CFrame = locHrp.CFrame + (hum.MoveDirection * (bonusSpeed * dt))
			end
		end
	end

	-- WALL CLIMB
	if toggles.WallClimb and locHrp and UIS:IsKeyDown(Enum.KeyCode.W) then
		local params = RaycastParams.new(); params.FilterDescendantsInstances = {char}; params.FilterType = Enum.RaycastFilterType.Exclude
		local hit = workspace:Raycast(locHrp.Position, locHrp.CFrame.LookVector * 3, params)
		if hit then locHrp.Velocity = Vector3.new(locHrp.Velocity.X, 40, locHrp.Velocity.Z) end
	end

	-- VOID JUMP
	if toggles.VoidJump and locHrp and hum then
		if tick() - lastVoidJump > 0.6 then
			if hum:GetState() == Enum.HumanoidStateType.Freefall and locHrp.Velocity.Y < -15 then
				local params = RaycastParams.new(); params.FilterDescendantsInstances = {char}; params.FilterType = Enum.RaycastFilterType.Exclude
				local groundHit = workspace:Raycast(locHrp.Position, Vector3.new(0, -15, 0), params)
				if not groundHit then
					locHrp.Velocity = Vector3.new(locHrp.Velocity.X, 65, locHrp.Velocity.Z)
					lastVoidJump = tick()
				end
			end
		end
	end

	-- TRAILS
	if toggles.Trails and locHrp and hum then
		if hum.MoveDirection.Magnitude > 0 and tick() - lastTrail > 0.08 then
			lastTrail = tick()
			local p = Instance.new("Part"); p.Anchored = true; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false; p.Material = Enum.Material.Neon
			p.Size = toggles.TrailBall and Vector3.new(1.2,1.2,1.2) or Vector3.new(1,1,1); p.Shape = toggles.TrailBall and Enum.PartType.Ball or Enum.PartType.Block
			p.CFrame = locHrp.CFrame * CFrame.new(0, -1, 0); p.Color = toggles.TrailRainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or currentAccent; p.Parent = workspace
			TweenService:Create(p, TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(0,0,0)}):Play(); game:GetService("Debris"):AddItem(p, 1.1)
		end
	end

	-- ESP UPDATES
	for obj, data in pairs(tracked) do
		if obj and obj.Parent then
			if data.mode == "Farm" then
				local act = false
				if data.espType == "Beehive" and toggles.BeehiveESP then act = true; data.textLabel.Text = (obj:GetAttribute("Level") or 0) .. " BEES"
				elseif data.espType == "Taliyah" and toggles.TaliyahESP then act = true; data.textLabel.Text = "EGG"
				elseif data.espType == "Bed" and toggles.BedESP then act = true; data.textLabel.Text = "[BED]"
				elseif toggles.FarmESP and data.espType ~= "Beehive" and data.espType ~= "Taliyah" and data.espType ~= "Bed" then
					if farmFilter == "Everything" or farmFilter:find(data.espType) then act = true; data.textLabel.Text = "[" .. data.espType:upper() .. "]" end 
				end
				data.highlight.Enabled = act; data.info.Enabled = act
			elseif data.mode == "World" then
				local act = false
				local eType = tostring(data.espType)
				if eType:find("Star") and toggles.StarESP then act = true
				elseif toggles[eType:gsub(" ","") .. "ESP"] then act = true end
				
				data.info.Enabled = act
				if act then data.textLabel.Text = eType .. " [" .. math.floor((data.part.Position - cp).Magnitude) .. "m]" end
			elseif data.mode == "Player" then
				local act = toggles.BoxESP
				local chamsAct = toggles.Chams
				
				if data.player == localPlayer and not toggles.DevMode then act = false; chamsAct = false
				else
					local team = (data.player.Team == localPlayer.Team)
					if boxTargetMode == "Enemy" and team then act = false; chamsAct = false end
					if boxTargetMode == "Teams" and not team then act = false; chamsAct = false end
				end
				
				data.gui.Enabled = act; data.info.Enabled = act
				
				-- Chams Logic
				if chamsAct then
					if not data.chams then
						data.chams = Instance.new("Highlight", data.part)
						data.chams.FillTransparency = 0.5
						data.chams.OutlineTransparency = 0.1
					end
					local tc = data.player.TeamColor and data.player.TeamColor.Color or Color3.new(1,1,1)
					data.chams.FillColor = tc
					data.chams.OutlineColor = tc
					data.chams.Enabled = true
				else
					if data.chams then data.chams.Enabled = false end
				end
				
				if act then
					local tc = data.player.TeamColor and data.player.TeamColor.Color or Color3.new(1,1,1)
					data.stroke.Color = tc; data.textLabel.TextColor3 = tc
					local l = {}
					if toggles.ShowName then table.insert(l, data.player.DisplayName) end
					if toggles.ShowTeam then table.insert(l, data.player.Team and data.player.Team.Name or "Neutral") end
					if toggles.ShowKit then local rK = tostring(data.player:GetAttribute("PlayingAsKits") or "None"):upper(); table.insert(l, "[" .. (kitTranslations[rK] or rK) .. "]") end
					if toggles.ShowHealth then
						local phum = data.player.Character and data.player.Character:FindFirstChild("Humanoid")
						local hp = phum and math.floor(phum.Health) or 0
						table.insert(l, "[" .. hp .. " HP]")
					end
					data.textLabel.Text = table.concat(l, "\n")
				end
			end
		else removeESP(obj) end
	end
end))

-- KIT RENDER LOOP
local function updateRender()
	if not kitScroll:FindFirstChild("UIListLayout") then
		local layout = Instance.new("UIListLayout", kitScroll)
		layout.Padding = UDim.new(0, 8)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		layout.SortOrder = Enum.SortOrder.LayoutOrder
	end
	
	for _, child in ipairs(kitScroll:GetChildren()) do
		if child:IsA("GuiObject") then child.Visible = false end
	end
	
	local layoutIndex = 0
	for _, team in pairs(Teams:GetTeams()) do
		local pList = team:GetPlayers()
		if not toggles.KitRenderOwnTeam and localPlayer.Team == team then continue end
		
		if #pList > 0 then
			layoutIndex = layoutIndex + 1
			local headerId = "TeamHeader_" .. team.Name
			local h = kitScroll:FindFirstChild(headerId)
			if not h then
				h = Instance.new("TextButton", kitScroll)
				h.Name = headerId
				h.Size = UDim2.new(1, 0, 0, 28)
				h.BackgroundColor3 = c_element
				h.Font = Enum.Font.GothamBold
				h.TextSize = 13
				h.TextXAlignment = Enum.TextXAlignment.Left
				addCorner(6, h)
				local arrow = Instance.new("TextLabel", h)
				arrow.Name = "Arrow"
				arrow.Size = UDim2.new(0, 30, 1, 0)
				arrow.Position = UDim2.new(1, -30, 0, 0)
				arrow.BackgroundTransparency = 1
				arrow.Font = Enum.Font.GothamBold
				arrow.TextSize = 14
				h.MouseButton1Down:Connect(function() 
					expandedTeams[team.Name] = not expandedTeams[team.Name]
					updateRender() 
				end)
			end
			
			h.Text = "  " .. team.Name:upper()
			local tc = team.TeamColor and team.TeamColor.Color or Color3.new(1,1,1)
			h.TextColor3 = tc
			h.Arrow.Text = expandedTeams[team.Name] and "▼" or "▶"
			h.Arrow.TextColor3 = currentAccent
			accentObjects[h.Arrow] = "TextColor3"
			h.LayoutOrder = layoutIndex
			h.Visible = true
			
			if expandedTeams[team.Name] then
				for _, p in pairs(pList) do
					layoutIndex = layoutIndex + 1
					local cardId = "PlayerCard_" .. p.UserId
					local card = kitScroll:FindFirstChild(cardId)
					if not card then
						card = Instance.new("Frame", kitScroll)
						card.Name = cardId
						card.Size = UDim2.new(0.95, 0, 0, 65)
						card.BackgroundColor3 = c_sidebar
						addCorner(8, card)
						local stroke = Instance.new("UIStroke", card)
						stroke.Name = "Border"
						stroke.Thickness = 1.5
						stroke.Transparency = 0.3
						local img = Instance.new("ImageLabel", card)
						img.Name = "Avatar"
						img.Size = UDim2.new(0, 46, 0, 46)
						img.Position = UDim2.new(0, 8, 0.5, -23)
						img.BackgroundColor3 = c_element
						addCorner(24, img)
						local tName = Instance.new("TextLabel", card)
						tName.Name = "PName"
						tName.Size = UDim2.new(1, -70, 0.33, 0)
						tName.Position = UDim2.new(0, 62, 0, 5)
						tName.BackgroundTransparency = 1
						tName.TextColor3 = Color3.new(1, 1, 1)
						tName.Font = Enum.Font.GothamBold
						tName.TextSize = 14
						tName.TextXAlignment = Enum.TextXAlignment.Left
						local tKit = Instance.new("TextLabel", card)
						tKit.Name = "PKit"
						tKit.Size = UDim2.new(1, -70, 0.33, 0)
						tKit.Position = UDim2.new(0, 62, 0.33, 1)
						tKit.BackgroundTransparency = 1
						tKit.Font = Enum.Font.GothamSemibold
						tKit.TextSize = 12
						tKit.TextXAlignment = Enum.TextXAlignment.Left
						local tClan = Instance.new("TextLabel", card)
						tClan.Name = "PClan"
						tClan.Size = UDim2.new(1, -70, 0.33, 0)
						tClan.Position = UDim2.new(0, 62, 0.66, -1)
						tClan.BackgroundTransparency = 1
						tClan.Font = Enum.Font.Gotham
						tClan.TextSize = 11
						tClan.TextXAlignment = Enum.TextXAlignment.Left
						tClan.RichText = true
					end
					
					local rK = tostring(p:GetAttribute("PlayingAsKits") or "None"):upper()
					local kitName = kitTranslations[rK] or rK
					local clanText = ""
					pcall(function()
						local tags = p:FindFirstChild("Tags")
						if tags then
							local zero = tags:FindFirstChild("0") or tags:FindFirstChild(0)
							if zero then clanText = tostring(zero.Value) end
						end
					end)
					
					card.Border.Color = tc
					card.PName.Text = p.DisplayName
					card.PKit.Text = kitName
					card.PKit.TextColor3 = tc
					if clanText and clanText ~= "" then
						card.PClan.Text = "CLAN: " .. clanText
						card.PClan.TextColor3 = Color3.new(1, 1, 1)
					else
						card.PClan.Text = "CLAN: NONE"
						card.PClan.TextColor3 = Color3.fromRGB(130, 130, 130)
					end
					
					if card.Avatar.Image == "" then
						pcall(function() card.Avatar.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
					end
					
					card.LayoutOrder = layoutIndex
					card.Visible = true
				end
			end
		end
	end
end
task.spawn(function() while isRunning do task.wait(0.5) if toggles.KitRender and kitFrame and kitFrame.Visible then updateRender() end end end)

-- ANTI-AFK
localPlayer.Idled:Connect(function()
	if toggles.AntiAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end
end)

-- ==========================================
-- KA LOGIC (PURE, AUTHENTIC HIT NO SPOOFING)
-- ==========================================
local SwordHit = ReplicatedStorage:FindFirstChild("rbxts_include")
if SwordHit then SwordHit = SwordHit.node_modules:FindFirstChild("@rbxts") end
if SwordHit then SwordHit = SwordHit.net.out._NetManaged:FindFirstChild("SwordHit") end
local cachedTargets = {}

local function isTargetVisible(startPos, targetModel, ignoreList)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = ignoreList
	params.FilterType = Enum.RaycastFilterType.Exclude
	
	for _, part in ipairs(targetModel:GetChildren()) do
		if part:IsA("BasePart") then
			local dir = part.Position - startPos
			local hit = workspace:Raycast(startPos, dir, params)
			if not hit then return true end
		end
	end
	return false 
end

task.spawn(function()
	while isRunning do
		task.wait(0.5) 
		local newCache = {}
		local function scanFolder(folder)
			if not folder then return end
			for _, obj in ipairs(folder:GetChildren()) do
				if obj:IsA("Model") and obj ~= localPlayer.Character and not Players:GetPlayerFromCharacter(obj) then
					local hum = obj:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then table.insert(newCache, obj) end
				end
			end
		end
		scanFolder(workspace)
		if workspace:FindFirstChild("Live") then scanFolder(workspace.Live) end
		cachedTargets = newCache
	end
end)

task.spawn(function()
	local swingAnimInst = Instance.new("Animation")
	swingAnimInst.AnimationId = "rbxassetid://4947108314"
	local loadedSwingAnim = nil
	local currentAnimHum = nil
	local lastSwingTime = 0

	while isRunning do
		task.wait(toggles.KASpeed or 0.1)
		
		local char = localPlayer.Character
		local locHrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")
		
		if not toggles.KA or not char or not locHrp or not hum or hum.Health <= 0 then continue end
		
		local weaponList = ReplicatedStorage:FindFirstChild("Inventories") and ReplicatedStorage.Inventories:FindFirstChild(localPlayer.Name)
		local bestSword = nil
		
		if weaponList then
			local priorityWeapons = {"emerald_sword", "diamond_sword", "iron_sword", "stone_sword", "wood_sword", "rageblade", "emerald_dao", "diamond_dao", "iron_dao", "stone_dao", "wood_dao", "emerald_scythe", "diamond_scythe", "iron_scythe", "stone_scythe", "wood_scythe", "emerald_dagger", "diamond_dagger", "iron_dagger", "stone_dagger", "wood_dagger"}
			for _, sName in ipairs(priorityWeapons) do
				local w = weaponList:FindFirstChild(sName)
				if w then bestSword = w; break end
			end
			if not bestSword then
				for _, w in ipairs(weaponList:GetChildren()) do
					local n = w.Name:lower()
					if n:find("sword") or n:find("blade") or n:find("dao") or n:find("scythe") or n:find("dagger") then 
						bestSword = w; break 
					end
				end
			end
		end

		local isHoldingSword = false
		if char then
			for _, item in ipairs(char:GetDescendants()) do
				if item:IsA("Model") or item:IsA("Accessory") or item:IsA("Tool") then
					local n = item.Name:lower()
					if n:find("sword") or n:find("blade") or n:find("dao") or n:find("scythe") or n:find("dagger") or n:find("rageblade") then
						isHoldingSword = true; break
					end
				end
			end
		end

		if not isHoldingSword then continue end
		if not bestSword then continue end

		local range = toggles.KARange or 25
		local maxAngle = (toggles.KAAngle or 360) / 2 
		local targetGroups = {Player = {}, NPC = {}, Dummy = {}}
		
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= localPlayer and p.Character then
				local phum = p.Character:FindFirstChildOfClass("Humanoid")
				if phum and phum.Health > 0 then table.insert(targetGroups.Player, p.Character) end
			end
		end
		for _, npc in ipairs(cachedTargets) do
			if npc and npc.Parent then
				local nhum = npc:FindFirstChildOfClass("Humanoid")
				if nhum and nhum.Health > 0 then 
					if npc.Name:lower():find("dummy") then table.insert(targetGroups.Dummy, npc)
					else table.insert(targetGroups.NPC, npc) end
				end
			end
		end
		
		local closestPlayer, pDist = nil, math.huge
		local closestNPC, nDist = nil, math.huge
		local closestDummy, dDist = nil, math.huge

		local function checkTargetGroup(groupList)
			local cTarget, cDist = nil, math.huge
			for _, model in ipairs(groupList) do
				local targetHRP = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
				if targetHRP then
					local dirVec = targetHRP.Position - locHrp.Position
					local dist = dirVec.Magnitude
					if dist <= range then
						local dotProduct = locHrp.CFrame.LookVector:Dot(dirVec.Unit)
						local angleToTarget = math.deg(math.acos(math.clamp(dotProduct, -1, 1)))
						if angleToTarget <= maxAngle then
							local isBlocked = false
							if toggles.KAWallCheck then isBlocked = not isTargetVisible(locHrp.Position, model, {char, model}) end
							if not isBlocked and dist < cDist then cDist = dist; cTarget = model end
						end
					end
				end
			end
			return cTarget, cDist
		end

		if toggles.KATargetPlayer then closestPlayer, pDist = checkTargetGroup(targetGroups.Player) end
		if toggles.KATargetNPC then closestNPC, nDist = checkTargetGroup(targetGroups.NPC) end
		if toggles.KATargetDummy then closestDummy, dDist = checkTargetGroup(targetGroups.Dummy) end
		
		local targetEnemy = nil
		local finalEnemyDist = math.huge
		
		if toggles.KAPriority == "Player" then
			targetEnemy = closestPlayer or closestNPC or closestDummy
			finalEnemyDist = closestPlayer and pDist or (closestNPC and nDist or dDist)
		elseif toggles.KAPriority == "NPC" then
			targetEnemy = closestNPC or closestPlayer or closestDummy
			finalEnemyDist = closestNPC and nDist or (closestPlayer and pDist or dDist)
		elseif toggles.KAPriority == "Dummy" then
			targetEnemy = closestDummy or closestPlayer or closestNPC
			finalEnemyDist = closestDummy and dDist or (closestPlayer and pDist or nDist)
		else 
			local allValid = {}
			if closestPlayer then table.insert(allValid, {m=closestPlayer, d=pDist}) end
			if closestNPC then table.insert(allValid, {m=closestNPC, d=nDist}) end
			if closestDummy then table.insert(allValid, {m=closestDummy, d=dDist}) end
			table.sort(allValid, function(a,b) return a.d < b.d end)
			if #allValid > 0 then targetEnemy = allValid[1].m; finalEnemyDist = allValid[1].d end
		end

		if targetEnemy then
			local targetHRP = targetEnemy:FindFirstChild("HumanoidRootPart") or targetEnemy.PrimaryPart or targetEnemy:FindFirstChildWhichIsA("BasePart")
			if targetHRP then
				local direction = (targetHRP.Position - locHrp.Position).Unit
				local reachOffset = math.clamp(finalEnemyDist - 14, 0, 14.4)
				local fakePos = locHrp.Position + (direction * reachOffset)
				
				local args = {
					[1] = {
						["entityInstance"] = targetEnemy,
						["chargedAttack"] = { ["chargeRatio"] = 0 },
						["validate"] = {
							["targetPosition"] = { ["value"] = targetHRP.Position },
							["raycast"] = { ["cursorDirection"] = { ["value"] = direction }, ["cameraPosition"] = { ["value"] = fakePos } },
							["selfPosition"] = { ["value"] = fakePos }
						},
						["weapon"] = bestSword
					}
				}
				
				task.spawn(function() 
					if SwordHit then pcall(function() SwordHit:FireServer(unpack(args)) end) end
					if toggles.KASwingAnim then
						if finalEnemyDist <= (toggles.KASwingRange or 25) then
							local now = tick()
							local animCooldown = 0.45 / (toggles.KASwingSpeed or 1.0)
							if now - lastSwingTime >= animCooldown then
								lastSwingTime = now
								pcall(function()
									local animHum = char:FindFirstChild("Humanoid")
									if animHum then
										local animator = animHum:FindFirstChild("Animator")
										if animator then
											if currentAnimHum ~= animHum then
												loadedSwingAnim = animator:LoadAnimation(swingAnimInst)
												currentAnimHum = animHum
											end
											if loadedSwingAnim then
												loadedSwingAnim:Play(0.1)
												loadedSwingAnim:AdjustSpeed(toggles.KASwingSpeed or 1.0)
											end
										end
									end
								end)
							end
						end
					end
				end)
			end
		end
	end
end)

-- ==========================================
-- FAST BREAK LOGIC
-- ==========================================
task.spawn(function()
	local mouse = localPlayer:GetMouse()
	while isRunning do
		task.wait(toggles.FastBreakTimer or 0.05)
		local char = localPlayer.Character
		local hum = char and char:FindFirstChild("Humanoid")
		if toggles.FastBreak and char and hum and hum.Health > 0 and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			local target = mouse.Target
			if target and target:IsA("BasePart") and not target.Parent:FindFirstChild("Humanoid") then
				local holdingMiningTool = false
				if char then
					for _, item in ipairs(char:GetChildren()) do
						if item:IsA("Model") or item:IsA("Accessory") or item:IsA("Tool") then
							local name = item.Name:lower()
							if name:find("pickaxe") or name:find("axe") or name:find("shears") then
								holdingMiningTool = true; break
							end
						end
					end
				end

				if holdingMiningTool then
					pcall(function()
						local DamageBlock = ReplicatedStorage:FindFirstChild("rbxts_include")
						if DamageBlock then DamageBlock = DamageBlock.node_modules["@easy-games"]["block-engine"].node_modules["@rbxts"].net.out._NetManaged:FindFirstChild("DamageBlock") end
						
						if DamageBlock then
							local gridX = math.round(target.Position.X / 3)
							local gridY = math.round(target.Position.Y / 3)
							local gridZ = math.round(target.Position.Z / 3)
							local args = { [1] = { ["blockRef"] = { ["blockPosition"] = Vector3.new(gridX, gridY, gridZ) }, ["hitPosition"] = mouse.Hit.Position, ["hitNormal"] = Vector3.new(0, 1, 0) } }
							task.spawn(function() pcall(function() DamageBlock:InvokeServer(unpack(args)) end) end)
						end
					end)
				end
			end
		end
	end
end)

-- ==========================================
-- AUTO BUY ARMOR FEATURE
-- ==========================================
task.spawn(function()
	local purchaseRemote = ReplicatedStorage:FindFirstChild("rbxts_include")
	if purchaseRemote then purchaseRemote = purchaseRemote.node_modules:FindFirstChild("@rbxts") end
	if purchaseRemote then purchaseRemote = purchaseRemote.net.out._NetManaged:FindFirstChild("BedwarsPurchaseItem") end
	
	local equipRemote = ReplicatedStorage:FindFirstChild("rbxts_include")
	if equipRemote then equipRemote = equipRemote.node_modules:FindFirstChild("@rbxts") end
	if equipRemote then equipRemote = equipRemote.net.out._NetManaged:FindFirstChild("SetArmorInvItem") end

	while isRunning do
		task.wait(0.5)
		local char = localPlayer.Character
		local locHrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if not toggles.AutoArmor or not locHrp or not hum or hum.Health <= 0 then continue end
		
		local nearShop = false
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Model") and (v.Name:lower():find("itemshop") or v.Name:lower():find("merchant") or v:GetAttribute("ShopId") == "1_item_shop") then
				local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
				if p and (p.Position - locHrp.Position).Magnitude < 30 then nearShop = true; break end
			end
		end
		
		if nearShop then
			local inv = ReplicatedStorage:FindFirstChild("Inventories") and ReplicatedStorage.Inventories:FindFirstChild(localPlayer.Name)
			if not inv then continue end
			
			local currentTier = 0
			if inv:FindFirstChild("emerald_chestplate") or (char and char:FindFirstChild("emerald_chestplate")) then currentTier = 4
			elseif inv:FindFirstChild("diamond_chestplate") or (char and char:FindFirstChild("diamond_chestplate")) then currentTier = 3
			elseif inv:FindFirstChild("iron_chestplate") or (char and char:FindFirstChild("iron_chestplate")) then currentTier = 2
			elseif inv:FindFirstChild("leather_chestplate") or (char and char:FindFirstChild("leather_chestplate")) then currentTier = 1
			end

			local buyArgs = nil
			local prefix = ""

			if currentTier == 0 then
				prefix = "leather"
				buyArgs = { { ["shopItem"] = { ["lockAfterPurchase"] = true, ["itemType"] = "leather_chestplate", ["price"] = 50, ["customDisplayName"] = "Leather Armor", ["superiorItems"] = { "iron_chestplate" }, ["currency"] = "iron", ["amount"] = 1, ["nextTier"] = "iron_chestplate", ["ignoredByKit"] = { "bigman", "tinker", "void_knight" }, ["spawnWithItems"] = { "leather_helmet", "leather_chestplate", "leather_boots" }, ["category"] = "Combat" }, ["shopId"] = "1_item_shop" } }
			elseif currentTier == 1 then
				prefix = "iron"
				buyArgs = { { ["shopItem"] = { ["lockAfterPurchase"] = true, ["itemType"] = "iron_chestplate", ["price"] = 120, ["prevTier"] = "leather_chestplate", ["customDisplayName"] = "Iron Armor", ["currency"] = "iron", ["category"] = "Combat", ["amount"] = 1, ["tiered"] = true, ["nextTier"] = "diamond_chestplate", ["spawnWithItems"] = { "iron_helmet", "iron_chestplate", "iron_boots" }, ["ignoredByKit"] = { "bigman", "tinker", "void_knight" } }, ["shopId"] = "1_item_shop" } }
			elseif currentTier == 2 then
				prefix = "diamond"
				buyArgs = { { ["shopItem"] = { ["lockAfterPurchase"] = true, ["itemType"] = "diamond_chestplate", ["price"] = 8, ["prevTier"] = "iron_chestplate", ["customDisplayName"] = "Diamond Armor", ["currency"] = "emerald", ["category"] = "Combat", ["amount"] = 1, ["tiered"] = true, ["nextTier"] = "emerald_chestplate", ["spawnWithItems"] = { "diamond_helmet", "diamond_chestplate", "diamond_boots" }, ["ignoredByKit"] = { "bigman", "tinker", "void_knight" } }, ["shopId"] = "1_item_shop" } }
			elseif currentTier == 3 then
				prefix = "emerald"
				buyArgs = { { ["shopItem"] = { ["lockAfterPurchase"] = true, ["itemType"] = "emerald_chestplate", ["price"] = 40, ["prevTier"] = "diamond_chestplate", ["customDisplayName"] = "Emerald Armor", ["currency"] = "emerald", ["amount"] = 1, ["tiered"] = true, ["ignoredByKit"] = { "bigman", "tinker", "void_knight" }, ["spawnWithItems"] = { "emerald_helmet", "emerald_chestplate", "emerald_boots" }, ["category"] = "Combat" }, ["shopId"] = "1_item_shop" } }
			end

			if buyArgs and purchaseRemote then
				local s = pcall(function() purchaseRemote:InvokeServer(unpack(buyArgs)) end)
				if s and equipRemote then
					task.wait(0.2)
					local h = inv:FindFirstChild(prefix .. "_helmet")
					local c = inv:FindFirstChild(prefix .. "_chestplate")
					local b = inv:FindFirstChild(prefix .. "_boots")
					if h then pcall(function() equipRemote:InvokeServer({ item = h, armorSlot = 0 }) end) end
					if c then pcall(function() equipRemote:InvokeServer({ item = c, armorSlot = 1 }) end) end
					if b then pcall(function() equipRemote:InvokeServer({ item = b, armorSlot = 2 }) end) end
				end
			end
		end
	end
end)

-- ==========================================
-- NUKER LOGIC (PURE RAYCAST TARGETING)
-- ==========================================
local cachedNukerBlocks = {}
local nukerHighlight = Instance.new("Highlight")
nukerHighlight.Name = "NukerHighlight"; nukerHighlight.FillColor = Color3.fromRGB(255, 50, 50); nukerHighlight.OutlineColor = Color3.fromRGB(255, 200, 0); nukerHighlight.FillTransparency = 0.5; nukerHighlight.OutlineTransparency = 0.1; nukerHighlight.Parent = ui; nukerHighlight.Enabled = false

task.spawn(function()
	while isRunning do
		task.wait(1)
		local blocks = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") then
				local n = obj.Name:lower()
				if n:find("bed") and not n:find("bedrock") then table.insert(blocks, obj)
				elseif n == "iron_ore_mesh_block" then table.insert(blocks, obj) end
			end
		end
		cachedNukerBlocks = blocks
	end
end)

task.spawn(function()
	local lockedNukerBlock = nil
	local lockedRawTarget = nil

	while isRunning do
		task.wait(toggles.NukerTimer or 0.1)
		
		local char = localPlayer.Character
		local locHrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if not toggles.Nuker or not char or not locHrp or not hum or hum.Health <= 0 then 
			nukerHighlight.Enabled = false; lockedNukerBlock = nil; lockedRawTarget = nil
			continue 
		end
		
		local holdingPickaxe, holdingAxe, holdingShears = false, false, false
		if char then
			for _, item in ipairs(char:GetChildren()) do
				if item:IsA("Model") or item:IsA("Accessory") or item:IsA("Tool") then
					local name = item.Name:lower()
					if name:find("pickaxe") then holdingPickaxe = true end
					if name:find("axe") and not name:find("pickaxe") then holdingAxe = true end
					if name:find("shears") then holdingShears = true end
				end
			end
		end

		if toggles.NukerReqPickaxe or toggles.NukerReqAxe or toggles.NukerReqShears then
			local hasRequired = false
			if toggles.NukerReqPickaxe and holdingPickaxe then hasRequired = true end
			if toggles.NukerReqAxe and holdingAxe then hasRequired = true end
			if toggles.NukerReqShears and holdingShears then hasRequired = true end
			if not hasRequired then nukerHighlight.Enabled = false; continue end
		end

		if lockedNukerBlock then
			if not lockedNukerBlock:IsDescendantOf(workspace) or not lockedNukerBlock.CanCollide or lockedNukerBlock.Transparency >= 1 or not locHrp or (lockedNukerBlock.Position - locHrp.Position).Magnitude > 32 then
				lockedNukerBlock = nil; lockedRawTarget = nil
			end
		end
		
		if not lockedNukerBlock then
			local closestBed, closestBedDist = nil, 30
			local closestOre, closestOreDist = nil, 30
			
			for _, obj in ipairs(cachedNukerBlocks) do
				if obj and obj.Parent then
					local n = obj.Name:lower()
					local dist = (obj.Position - locHrp.Position).Magnitude
					if toggles.NukerBed and n:find("bed") and not n:find("bedrock") then
						local isMyBed = false
						local myTeam = localPlayer.Team
						if myTeam then
							local myColor = myTeam.TeamColor.Color
							local myTeamName = myTeam.Name:lower():gsub(" team", "")
							local shortTeam = myTeamName ~= "" and string.split(myTeamName, " ")[1] or ""
							if shortTeam ~= "" and (n:find(shortTeam) or (obj.Parent and obj.Parent.Name:lower():find(shortTeam))) then isMyBed = true end
							if not isMyBed then
								local function checkColor(part)
									if part:IsA("BasePart") then
										local pColor = part.Color
										local diff = math.abs(pColor.R - myColor.R) + math.abs(pColor.G - myColor.G) + math.abs(pColor.B - myColor.B)
										if diff < 0.1 then return true end
									end
									return false
								end
								if checkColor(obj) then isMyBed = true end
								if not isMyBed and obj.Parent and obj.Parent.Name:lower():find("bed") then
									for _, p in ipairs(obj.Parent:GetChildren()) do
										if checkColor(p) then isMyBed = true; break end
									end
								end
							end
							local myTeamId1 = localPlayer:GetAttribute("Team")
							local myTeamId2 = localPlayer:GetAttribute("TeamId")
							local curr = obj
							while curr and curr ~= workspace and not isMyBed do
								local cId1 = curr:GetAttribute("Team")
								local cId2 = curr:GetAttribute("TeamId")
								if (myTeamId1 ~= nil and cId1 ~= nil and tostring(cId1) == tostring(myTeamId1)) or 
								   (myTeamId2 ~= nil and cId2 ~= nil and tostring(cId2) == tostring(myTeamId2)) then
									isMyBed = true; break
								end
								curr = curr.Parent
							end
						end
						if not isMyBed and dist < closestBedDist then closestBedDist = dist; closestBed = obj end
					elseif toggles.NukerOre and n == "iron_ore_mesh_block" then
						if dist < closestOreDist then closestOreDist = dist; closestOre = obj end
					end
				end
			end
			
			local rawTarget = nil
			if toggles.NukerPriority == "Bed" then rawTarget = closestBed or closestOre
			elseif toggles.NukerPriority == "Ore" then rawTarget = closestOre or closestBed
			else
				if closestBed and closestOre then
					if closestBedDist < closestOreDist then rawTarget = closestBed else rawTarget = closestOre end
				else rawTarget = closestBed or closestOre end
			end
			
			if rawTarget then
				local exposed = false
				local closestProtector = nil
				local params = RaycastParams.new(); params.FilterType = Enum.RaycastFilterType.Exclude
				local excludeList = {char}
				for _, p in ipairs(Players:GetPlayers()) do if p.Character then table.insert(excludeList, p.Character) end end
				if workspace:FindFirstChild("ItemDrops") then table.insert(excludeList, workspace.ItemDrops) end
				params.FilterDescendantsInstances = excludeList
				
				local partsToCheck = {}
				if rawTarget == closestBed and rawTarget.Parent and rawTarget.Parent.Name:lower():find("bed") then
					for _, p in ipairs(rawTarget.Parent:GetChildren()) do if p:IsA("BasePart") then table.insert(partsToCheck, p) end end
				else table.insert(partsToCheck, rawTarget) end
				
				local cPDist = math.huge
				local startPositions = {
					cam.CFrame.Position, locHrp.Position, locHrp.Position + Vector3.new(0, 1.5, 0),
					locHrp.Position + Vector3.new(1.2, 0, 0), locHrp.Position + Vector3.new(-1.2, 0, 0)
				}
				
				for _, part in ipairs(partsToCheck) do
					for _, startPos in ipairs(startPositions) do
						local dir = part.Position - startPos
						local hit = workspace:Raycast(startPos, dir.Unit * (dir.Magnitude + 2), params)
						if hit and hit.Instance then
							local hName = hit.Instance.Name:lower()
							local isTarget = (hit.Instance == part) or (hit.Instance == rawTarget) or (hit.Instance.Parent and hit.Instance.Parent == rawTarget.Parent) or hName:find("bed") or hName == "iron_ore_mesh_block"
							if isTarget then
								exposed = true; break
							else
								if hit.Instance.CanCollide then
									local hitDist = (hit.Position - startPos).Magnitude
									if hitDist < cPDist then cPDist = hitDist; closestProtector = hit.Instance end
								end
							end
						else exposed = true; break end
					end
					if exposed then break end
				end
				lockedRawTarget = rawTarget
				lockedNukerBlock = (not exposed and closestProtector) and closestProtector or rawTarget
			end
		end
		
		if lockedNukerBlock then
			if toggles.NukerHighlight then nukerHighlight.Adornee = lockedNukerBlock; nukerHighlight.Enabled = true else nukerHighlight.Enabled = false end
			local DamageBlock = ReplicatedStorage:FindFirstChild("rbxts_include")
			if DamageBlock then DamageBlock = DamageBlock.node_modules["@easy-games"]["block-engine"].node_modules["@rbxts"].net.out._NetManaged:FindFirstChild("DamageBlock") end
			if DamageBlock then
				local function smash(targetPart)
					if not targetPart then return end
					local gridX = math.round(targetPart.Position.X / 3)
					local gridY = math.round(targetPart.Position.Y / 3)
					local gridZ = math.round(targetPart.Position.Z / 3)
					local args = { [1] = { ["blockRef"] = { ["blockPosition"] = Vector3.new(gridX, gridY, gridZ) }, ["hitPosition"] = targetPart.Position, ["hitNormal"] = Vector3.new(0, 1, 0) } }
					task.spawn(function() pcall(function() DamageBlock:InvokeServer(unpack(args)) end) end)
				end
				smash(lockedNukerBlock)
				if lockedRawTarget and lockedRawTarget ~= lockedNukerBlock then smash(lockedRawTarget) end
			end
		else
			nukerHighlight.Enabled = false
		end
	end
end)

-- ==========================================
-- EXTENDED RESOURCE PICKUP
-- ==========================================
task.spawn(function()
	while isRunning do
		task.wait(0.1)
		local char = localPlayer.Character
		local locHrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if toggles.ExtendedDrop and locHrp and hum and hum.Health > 0 then
			local itemDrops = workspace:FindFirstChild("ItemDrops")
			if itemDrops then
				local pickupRemote = ReplicatedStorage:FindFirstChild("rbxts_include")
				if pickupRemote then pickupRemote = pickupRemote.node_modules:FindFirstChild("@rbxts") end
				if pickupRemote then pickupRemote = pickupRemote.net.out._NetManaged:FindFirstChild("PickupItemDrop") end
				if pickupRemote then
					local myPos = locHrp.Position
					local range = toggles.ExtendedDropRange or 25
					for _, drop in ipairs(itemDrops:GetChildren()) do
						if drop:IsA("BasePart") or drop:IsA("Model") then
							local posPart = drop:IsA("BasePart") and drop or drop.PrimaryPart or drop:FindFirstChildWhichIsA("BasePart")
							if posPart then
								if (posPart.Position - myPos).Magnitude <= range then
									task.spawn(function() pcall(function() pickupRemote:InvokeServer({ ["itemDrop"] = drop }) end) end)
								end
							end
						end
					end
				end
			end
		end
	end
end)

pcall(function() loadConfig() end)
for id, fn in pairs(uiVisuals) do if not id:find("_key") then pcall(fn) end end
pcall(handleStaffScan)
