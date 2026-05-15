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
local tracked = {}
local defaultToggles = {
	["BeeESP"] = false, ["MetalESP"] = false, ["StarESP"] = false, ["BoxESP"] = false,
	["ShowName"] = false, ["ShowTeam"] = false, ["ShowKit"] = false, ["ShowHealth"] = false, ["DevMode"] = false, 
	["KitRender"] = false, ["KitRenderOwnTeam"] = true, ["FarmESP"] = false, ["BeehiveESP"] = false, ["TaliyahESP"] = false, ["BedESP"] = false,
	["Trails"] = false, ["TrailRainbow"] = false, ["TrailBall"] = false,
	["AntiAFK"] = false, ["Freecam"] = false, ["FreecamSpeed"] = 2, 
	["SpinBot"] = false, ["SpinSpeed"] = 20, ["VoidJump"] = false, 
	["Fly"] = false, ["FlySpeed"] = 20, ["InfJump"] = false,
	["Speed"] = false, ["SpeedValue"] = 23, ["WallClimb"] = false,
	["KA"] = false, ["KASpeed"] = 0.1, ["KARange"] = 25, ["KAAngle"] = 360,
	["KAWallCheck"] = false, ["KASwingAnim"] = false, ["KASwingSpeed"] = 1.0, ["KASwingRange"] = 25,
	["KATargetPlayer"] = true, ["KATargetNPC"] = false, ["KATargetDummy"] = false, ["KAPriority"] = "Distance",
	["FastBreak"] = false, ["FastBreakTimer"] = 0.05,
	["Nuker"] = false, ["NukerTimer"] = 0.1, ["NukerReqPickaxe"] = true, ["NukerReqAxe"] = false, ["NukerReqShears"] = false, ["NukerBed"] = true, ["NukerOre"] = false, ["NukerPriority"] = "Bed", ["NukerHighlight"] = false,
	["AutoBuyArmor"] = false,
	["FastDrop"] = false, ["FastDropSpeed"] = 5,
	["ExtendedDrop"] = false, ["ExtendedDropRange"] = 20,
	["StaffDetect"] = false, ["StaffLeave"] = false, ["StaffDestruct"] = false
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

-- ==========================================
-- MODERN UI LIBRARY
-- ==========================================
local coreGui = gethui and gethui() or game.CoreGui
if coreGui:FindFirstChild("FEENWARE_ULTIMATE") then coreGui.FEENWARE_ULTIMATE:Destroy() end

local ui = Instance.new("ScreenGui", coreGui)
ui.Name = "FEENWARE_ULTIMATE"
ui.ResetOnSpawn = false

-- Theming
local currentAccent = Color3.fromRGB(139, 92, 246) -- Violet Default
local c_bg = Color3.fromRGB(18, 18, 20)
local c_sidebar = Color3.fromRGB(24, 24, 27)
local c_element = Color3.fromRGB(39, 39, 42)
local c_text = Color3.fromRGB(244, 244, 245)
local c_textMuted = Color3.fromRGB(161, 161, 170)
local accentObjects = {}

local function setAccent(color)
	currentAccent = color
	for obj, prop in pairs(accentObjects) do
		if obj and obj.Parent then
			TweenService:Create(obj, TweenInfo.new(0.3), {[prop] = color}):Play()
		end
	end
end

-- Main Window
local mainFrame = Instance.new("Frame", ui)
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = c_bg
mainFrame.ClipsDescendants = true
local mainCorner = Instance.new("UICorner", mainFrame); mainCorner.CornerRadius = UDim.new(0, 8)
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
sidebar.Size = UDim2.new(0, 140, 1, 0)
sidebar.BackgroundColor3 = c_sidebar
sidebar.BorderSizePixel = 0
local sidebarCorner = Instance.new("UICorner", sidebar); sidebarCorner.CornerRadius = UDim.new(0, 8)
local sidebarCover = Instance.new("Frame", sidebar); sidebarCover.Size = UDim2.new(0, 8, 1, 0); sidebarCover.Position = UDim2.new(1, -8, 0, 0); sidebarCover.BackgroundColor3 = c_sidebar; sidebarCover.BorderSizePixel = 0

local title = Instance.new("TextLabel", sidebar)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "FEENWARE"
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
title.TextColor3 = currentAccent
accentObjects[title] = "TextColor3"

local tabLayout = Instance.new("UIListLayout", sidebar)
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 4)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local tabPadding = Instance.new("UIPadding", sidebar); tabPadding.PaddingTop = UDim.new(0, 50)

-- Content Area
local contentContainer = Instance.new("Frame", mainFrame)
contentContainer.Size = UDim2.new(1, -140, 1, 0)
contentContainer.Position = UDim2.new(0, 140, 0, 0)
contentContainer.BackgroundTransparency = 1

local activeTab = nil
local tabs = {}

local function createTab(name)
	local tabBtn = Instance.new("TextButton", sidebar)
	tabBtn.Size = UDim2.new(0.9, 0, 0, 32)
	tabBtn.BackgroundColor3 = c_element
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = name
	tabBtn.TextColor3 = c_textMuted
	tabBtn.Font = Enum.Font.GothamSemibold
	tabBtn.TextSize = 13
	local btnCorner = Instance.new("UICorner", tabBtn); btnCorner.CornerRadius = UDim.new(0, 6)
	
	local tabContent = Instance.new("ScrollingFrame", contentContainer)
	tabContent.Size = UDim2.new(1, 0, 1, 0)
	tabContent.BackgroundTransparency = 1
	tabContent.ScrollBarThickness = 2
	tabContent.ScrollBarImageColor3 = currentAccent
	tabContent.Visible = false
	accentObjects[tabContent] = "ScrollBarImageColor3"
	
	local contentLayout = Instance.new("UIListLayout", tabContent)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, 8)
	contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	local cPad = Instance.new("UIPadding", tabContent)
	cPad.PaddingTop = UDim.new(0, 15); cPad.PaddingBottom = UDim.new(0, 15)
	
	tabBtn.Activated:Connect(function()
		for _, t in pairs(tabs) do
			t.btn.BackgroundTransparency = 1
			t.btn.TextColor3 = c_textMuted
			t.content.Visible = false
		end
		tabBtn.BackgroundTransparency = 0
		tabBtn.TextColor3 = currentAccent
		tabContent.Visible = true
		activeTab = name
	end)
	
	table.insert(tabs, {btn = tabBtn, content = tabContent})
	if not activeTab then tabBtn.BackgroundTransparency = 0; tabBtn.TextColor3 = currentAccent; tabContent.Visible = true; activeTab = name end
	
	return tabContent
end

-- UI Element Generators
local function MakeToggle(parent, id, titleText, callback)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(0.95, 0, 0, 36)
	frame.BackgroundColor3 = c_element
	local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0, 6)
	
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(0.6, 0, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1; lbl.Text = titleText; lbl.TextColor3 = c_text
	lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	-- Keybind integration
	local kbBtn = Instance.new("TextButton", frame)
	kbBtn.Size = UDim2.new(0, 35, 0, 20); kbBtn.Position = UDim2.new(1, -95, 0.5, -10)
	kbBtn.BackgroundColor3 = c_sidebar; kbBtn.TextColor3 = c_textMuted; kbBtn.Text = "[+]"
	kbBtn.Font = Enum.Font.Gotham; kbBtn.TextSize = 11; local kbCorner = Instance.new("UICorner", kbBtn); kbCorner.CornerRadius = UDim.new(0,4)
	
	local function updateKB() kbBtn.Text = hotkeys[id] and "["..hotkeys[id].Name.."]" or "[+]" end
	uiVisuals[id.."_key"] = updateKB
	kbBtn.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton2 then hotkeys[id] = nil; updateKB(); saveConfig() end end)
	kbBtn.Activated:Connect(function() currentBindName = id; kbBtn.Text = "..." end)
	updateKB()
	
	-- Switch
	local switchBg = Instance.new("TextButton", frame)
	switchBg.Size = UDim2.new(0, 36, 0, 18); switchBg.Position = UDim2.new(1, -46, 0.5, -9)
	switchBg.BackgroundColor3 = toggles[id] and currentAccent or c_sidebar; switchBg.Text = ""
	local swCorner = Instance.new("UICorner", switchBg); swCorner.CornerRadius = UDim.new(1, 0)
	accentObjects[switchBg] = toggles[id] and "BackgroundColor3" or nil
	
	local knob = Instance.new("Frame", switchBg)
	knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = UDim2.new(toggles[id] and 1 or 0, toggles[id] and -16 or 2, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	local kCorner = Instance.new("UICorner", knob); kCorner.CornerRadius = UDim.new(1, 0)
	
	local function updateVis()
		local state = toggles[id]
		if state then accentObjects[switchBg] = "BackgroundColor3" else accentObjects[switchBg] = nil end
		TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = state and currentAccent or c_sidebar}):Play()
		TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(state and 1 or 0, state and -16 or 2, 0.5, -7)}):Play()
		if id == "KitRender" then kitFrame.Visible = (state and uiVisible) end
	end
	uiVisuals[id] = updateVis
	
	switchBg.Activated:Connect(function()
		toggles[id] = not toggles[id]
		updateVis(); if callback then callback() end; saveConfig()
	end)
	updateVis()
end

local function MakeSlider(parent, id, titleText, min, max, isFloat)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(0.95, 0, 0, 45)
	frame.BackgroundColor3 = c_element
	local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0, 6)
	
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(1, -20, 0, 20); lbl.Position = UDim2.new(0, 10, 0, 5)
	lbl.BackgroundTransparency = 1; lbl.TextColor3 = c_text; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local sBg = Instance.new("Frame", frame)
	sBg.Size = UDim2.new(1, -20, 0, 6); sBg.Position = UDim2.new(0, 10, 0, 28)
	sBg.BackgroundColor3 = c_sidebar; local sc = Instance.new("UICorner", sBg); sc.CornerRadius = UDim.new(1, 0)
	
	local fill = Instance.new("Frame", sBg)
	fill.Size = UDim2.new(0, 0, 1, 0); fill.BackgroundColor3 = currentAccent
	local fc = Instance.new("UICorner", fill); fc.CornerRadius = UDim.new(1, 0)
	accentObjects[fill] = "BackgroundColor3"
	
	local btn = Instance.new("TextButton", sBg)
	btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""
	
	local function updateVis()
		local val = toggles[id] or min
		local pct = math.clamp((val - min) / (max - min), 0, 1)
		fill.Size = UDim2.new(pct, 0, 1, 0)
		lbl.Text = titleText .. ": " .. (isFloat and string.format("%.2f", val) or val)
	end
	uiVisuals[id] = updateVis
	
	local drag = false
	btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true end end)
	UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
	UIS.InputChanged:Connect(function(i)
		if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
			local pct = math.clamp((i.Position.X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
			local raw = min + ((max - min) * pct)
			toggles[id] = isFloat and raw or math.floor(raw)
			updateVis(); saveConfig()
		end
	end)
	updateVis()
end

local function MakeButton(parent, text, callback)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0.95, 0, 0, 36)
	b.BackgroundColor3 = c_element
	b.TextColor3 = c_text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.Text = text
	local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0, 6)
	b.Activated:Connect(callback)
	return b
end

local function MakeDropdown(parent, id, titleText, options)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(0.95, 0, 0, 36)
	frame.BackgroundColor3 = c_element
	local corner = Instance.new("UICorner", frame); corner.CornerRadius = UDim.new(0, 6)
	
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""
	
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(1, -20, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0)
	lbl.BackgroundTransparency = 1; lbl.TextColor3 = c_text; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local function updateVis()
		lbl.Text = titleText .. ": " .. tostring(toggles[id] or options[1]):upper()
	end
	uiVisuals[id] = updateVis
	
	btn.Activated:Connect(function()
		local current = toggles[id] or options[1]
		local idx = table.find(options, current) or 1
		local nextIdx = idx >= #options and 1 or idx + 1
		toggles[id] = options[nextIdx]
		updateVis(); saveConfig()
	end)
	updateVis()
end

-- ==========================================
-- POPULATE TABS & FEATURES
-- ==========================================
local tCombat = createTab("Combat")
MakeToggle(tCombat, "KA", "Kill Aura")
MakeSlider(tCombat, "KASpeed", "Attack Delay", 0.01, 2.0, true)
MakeSlider(tCombat, "KARange", "Attack Range", 5, 100, false)
MakeSlider(tCombat, "KAAngle", "Angle (FOV)", 10, 360, false)
MakeToggle(tCombat, "KAWallCheck", "Wall Check")
MakeToggle(tCombat, "KASwingAnim", "Swing Animation")
MakeSlider(tCombat, "KASwingRange", "Anim Range", 5, 100, false)
MakeSlider(tCombat, "KASwingSpeed", "Anim Speed", 0.1, 3.0, true)
MakeToggle(tCombat, "KATargetPlayer", "Target Player")
MakeToggle(tCombat, "KATargetNPC", "Target NPC")
MakeToggle(tCombat, "KATargetDummy", "Target Dummy")
MakeDropdown(tCombat, "KAPriority", "Priority", {"Distance", "Player", "NPC", "Dummy"})

local tMovement = createTab("Movement")
MakeToggle(tMovement, "Speed", "Speed")
MakeSlider(tMovement, "SpeedValue", "Speed Multiplier", 16, 50, false)
MakeToggle(tMovement, "Fly", "Fly")
MakeSlider(tMovement, "FlySpeed", "Fly Speed", 10, 100, false)
MakeToggle(tMovement, "InfJump", "Infinite Jump")
MakeToggle(tMovement, "VoidJump", "Void Jump")
MakeToggle(tMovement, "WallClimb", "Spider/Wall Climb")

local tVisuals = createTab("Visuals")
MakeToggle(tVisuals, "BoxESP", "Box ESP")
MakeDropdown(tVisuals, "TM", "ESP Target", {"All", "Enemy", "Teams"})
MakeToggle(tVisuals, "ShowName", "Show Name")
MakeToggle(tVisuals, "ShowTeam", "Show Team")
MakeToggle(tVisuals, "ShowKit", "Show Kit")
MakeToggle(tVisuals, "ShowHealth", "Show Health")
MakeToggle(tVisuals, "KitRender", "Kit Render Window")
MakeToggle(tVisuals, "KitRenderOwnTeam", "Render Own Team")
MakeToggle(tVisuals, "Trails", "Player Trails")
MakeToggle(tVisuals, "TrailRainbow", "Rainbow Trail")
MakeToggle(tVisuals, "TrailBall", "Ball Trail")
MakeToggle(tVisuals, "Freecam", "Freecam")
MakeSlider(tVisuals, "FreecamSpeed", "Freecam Speed", 1, 10, false)

local tWorld = createTab("World & Farm")
MakeToggle(tWorld, "MetalESP", "Metal ESP")
MakeToggle(tWorld, "StarESP", "Star ESP")
MakeToggle(tWorld, "BeeESP", "Bee ESP")
MakeToggle(tWorld, "BeehiveESP", "Beehive ESP")
MakeToggle(tWorld, "TaliyahESP", "Taliyah ESP")
MakeToggle(tWorld, "BedESP", "Bed ESP")
MakeDropdown(tWorld, "FF", "Farm Filter", {"Everything", "Melon Only", "Carrot Only", "Pumpkin Only"})

local tMisc = createTab("Misc")
MakeToggle(tMisc, "Nuker", "Bed/Ore Nuker")
MakeSlider(tMisc, "NukerTimer", "Nuker Speed", 0.01, 1.0, true)
MakeToggle(tMisc, "NukerReqPickaxe", "Require Pickaxe")
MakeToggle(tMisc, "NukerReqAxe", "Require Axe")
MakeToggle(tMisc, "NukerReqShears", "Require Shears")
MakeToggle(tMisc, "NukerBed", "Destroy Beds")
MakeToggle(tMisc, "NukerOre", "Destroy Ores")
MakeDropdown(tMisc, "NukerPriority", "Nuker Priority", {"Bed", "Ore", "Distance"})
MakeToggle(tMisc, "NukerHighlight", "Highlight Target")
MakeToggle(tMisc, "AutoBuyArmor", "Auto Buy Armor (30 Studs)")
MakeToggle(tMisc, "FastBreak", "Fast Break")
MakeSlider(tMisc, "FastBreakTimer", "Break Tick", 0.01, 0.5, true)
MakeToggle(tMisc, "FastDrop", "Fast Drop")
MakeSlider(tMisc, "FastDropSpeed", "Drop Multiplier", 1, 40, false)
MakeToggle(tMisc, "ExtendedDrop", "Extended Resource Pickup")
MakeSlider(tMisc, "ExtendedDropRange", "Pickup Range", 8, 40, false)
MakeToggle(tMisc, "SpinBot", "SpinBot")
MakeSlider(tMisc, "SpinSpeed", "Spin Speed", 10, 100, false)
MakeToggle(tMisc, "AntiAFK", "Anti-AFK")

local tSettings = createTab("Settings")
local colorGrid = Instance.new("Frame", tSettings)
colorGrid.Size = UDim2.new(0.95, 0, 0, 40); colorGrid.BackgroundTransparency = 1
local cl = Instance.new("UIListLayout", colorGrid); cl.FillDirection = Enum.FillDirection.Horizontal; cl.HorizontalAlignment = Enum.HorizontalAlignment.Center; cl.Padding = UDim.new(0, 10)

local colors = {
	Color3.fromRGB(139, 92, 246), -- Violet
	Color3.fromRGB(239, 68, 68),  -- Red
	Color3.fromRGB(59, 130, 246), -- Blue
	Color3.fromRGB(16, 185, 129), -- Teal/Green
	Color3.fromRGB(245, 158, 11), -- Gold
	Color3.fromRGB(236, 72, 153)  -- Pink
}

for _, col in ipairs(colors) do
	local cb = Instance.new("TextButton", colorGrid)
	cb.Size = UDim2.new(0, 30, 0, 30); cb.BackgroundColor3 = col; cb.Text = ""
	local cc = Instance.new("UICorner", cb); cc.CornerRadius = UDim.new(1, 0)
	cb.Activated:Connect(function() setAccent(col) end)
end

MakeButton(tSettings, "Unbind All Hotkeys", function()
	hotkeys = {}; for id, fn in pairs(uiVisuals) do if id:find("_key") then fn() end end; saveConfig()
end)
MakeButton(tSettings, "Disable All Toggles", function()
	for k, v in pairs(toggles) do if type(v) == "boolean" then toggles[k] = false end end
	for id, fn in pairs(uiVisuals) do if not id:find("_key") then fn() end end; saveConfig()
end)
MakeButton(tSettings, "Uninject", uninject)

-- Fix dropdown integration
uiVisuals.TM = function() boxTargetMode = toggles.TM or "All" end
uiVisuals.FF = function() farmFilter = toggles.FF or "Everything" end

-- KIT RENDER FRAME (Kept original logic, modernized look)
local kitFrame = Instance.new("Frame", zenWareGUI)
kitFrame.Size = UDim2.new(0, 380, 0, 520); kitFrame.Position = UDim2.new(0.35, 0, 0.2, 0); kitFrame.BackgroundColor3 = c_bg; kitFrame.Visible = false; addCorner(10, kitFrame); makeDraggable(kitFrame, kitFrame)
local kitStroke = Instance.new("UIStroke", kitFrame); kitStroke.Color = currentAccent; kitStroke.Thickness = 1; accentObjects[kitStroke] = "Color"
local kitTitleTxt = Instance.new("TextLabel", kitFrame); kitTitleTxt.Size = UDim2.new(1, 0, 0, 45); kitTitleTxt.BackgroundTransparency = 1; kitTitleTxt.Text = "KIT RENDER"; kitTitleTxt.TextColor3 = currentAccent; kitTitleTxt.Font = Enum.Font.GothamBlack; kitTitleTxt.TextSize = 20; accentObjects[kitTitleTxt] = "TextColor3"
local kitLineFrame = Instance.new("Frame", kitFrame); kitLineFrame.Size = UDim2.new(1, -30, 0, 1); kitLineFrame.Position = UDim2.new(0, 15, 0, 45); kitLineFrame.BackgroundColor3 = c_element; kitLineFrame.BorderSizePixel = 0
local kitScroll = Instance.new("ScrollingFrame", kitFrame); kitScroll.Size = UDim2.new(0.95, 0, 0.85, 0); kitScroll.Position = UDim2.new(0.025, 0, 0.12, 0); kitScroll.BackgroundTransparency = 1; kitScroll.ScrollBarThickness = 2; kitScroll.ScrollBarImageColor3 = currentAccent; kitScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; accentObjects[kitScroll] = "ScrollBarImageColor3"

-- ==========================================
-- LOGIC & PHYSICS LOOPS
-- ==========================================
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

-- Inputs for Freecam and InfJump
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
	if g then return end
	if input.KeyCode == Enum.KeyCode.Space and toggles.InfJump then
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then 
			hrp.Velocity = Vector3.new(hrp.Velocity.X, 40, hrp.Velocity.Z) 
		end
	end
end))

-- MAIN BACKGROUND LOOP
table.insert(connections, RunService.RenderStepped:Connect(function(dt)
	local char = localPlayer.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local cp = cam.CFrame.Position
	
	-- FREECAM
	if toggles.Freecam then
		if not freecamActive then
			freecamActive = true; local rx, ry, rz = cam.CFrame:ToEulerAnglesYXZ(); camAngleX = math.deg(ry); camAngleY = math.deg(rx)
			if hrp then hrp.Anchored = true end 
		end
		cam.CameraType = Enum.CameraType.Scriptable; local move = Vector3.new(); local spd = toggles.FreecamSpeed
		if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.E) then move += cam.CFrame.UpVector end
		if UIS:IsKeyDown(Enum.KeyCode.Q) then move -= cam.CFrame.UpVector end
		cam.CFrame = cam.CFrame + (move * (spd * 0.5))
	else
		if freecamActive then
			freecamActive = false; if hrp and hrp.Anchored then hrp.Anchored = false end
			cam.CameraType = Enum.CameraType.Custom; cam.CameraSubject = hum; UIS.MouseBehavior = Enum.MouseBehavior.Default
		end
	end

	-- SPINBOT
	if toggles.SpinBot and hrp and hum and not toggles.Freecam then
		hum.AutoRotate = false
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(toggles.SpinSpeed), 0)
	elseif hum and not toggles.SpinBot then
		hum.AutoRotate = true
	end

	-- FLY
	if toggles.Fly and hrp then
		if not flyBodyVel or not flyBodyVel.Parent then
			flyBodyVel = Instance.new("BodyVelocity")
			flyBodyVel.MaxForce = Vector3.new(100000, 100000, 100000)
			flyBodyVel.Parent = hrp
		end
		local move = Vector3.new()
		if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		local yVel = 0
		if UIS:IsKeyDown(Enum.KeyCode.Space) then yVel = toggles.FlySpeed end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then yVel = -toggles.FlySpeed end
		flyBodyVel.Velocity = Vector3.new(move.X * toggles.FlySpeed, yVel, move.Z * toggles.FlySpeed)
	else
		if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end
	end

	-- SPEED
	if toggles.Speed and hrp and hum and not toggles.Fly then
		if hum.MoveDirection.Magnitude > 0 then
			local bonusSpeed = toggles.SpeedValue - 16
			if bonusSpeed > 0 then
				hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (bonusSpeed * dt))
			end
		end
	end

	-- WALL CLIMB
	if toggles.WallClimb and hrp and UIS:IsKeyDown(Enum.KeyCode.W) then
		local params = RaycastParams.new(); params.FilterDescendantsInstances = {char}; params.FilterType = Enum.RaycastFilterType.Exclude
		local hit = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 3, params)
		if hit then hrp.Velocity = Vector3.new(hrp.Velocity.X, 40, hrp.Velocity.Z) end
	end

	-- VOID JUMP
	if toggles.VoidJump and hrp and hum then
		if tick() - lastVoidJump > 0.6 then
			if hum:GetState() == Enum.HumanoidStateType.Freefall and hrp.Velocity.Y < -15 then
				local params = RaycastParams.new(); params.FilterDescendantsInstances = {char}; params.FilterType = Enum.RaycastFilterType.Exclude
				local groundHit = workspace:Raycast(hrp.Position, Vector3.new(0, -15, 0), params)
				if not groundHit then
					hrp.Velocity = Vector3.new(hrp.Velocity.X, 65, hrp.Velocity.Z)
					lastVoidJump = tick()
				end
			end
		end
	end

	-- TRAILS
	if toggles.Trails and hrp and hum then
		if hum.MoveDirection.Magnitude > 0 and tick() - lastTrail > 0.08 then
			lastTrail = tick()
			local p = Instance.new("Part"); p.Anchored = true; p.CanCollide = false; p.CanTouch = false; p.CanQuery = false; p.Material = Enum.Material.Neon
			p.Size = toggles.TrailBall and Vector3.new(1.2,1.2,1.2) or Vector3.new(1,1,1); p.Shape = toggles.TrailBall and Enum.PartType.Ball or Enum.PartType.Block
			p.CFrame = hrp.CFrame * CFrame.new(0, -1, 0); p.Color = toggles.TrailRainbow and Color3.fromHSV(tick() % 5 / 5, 1, 1) or currentAccent; p.Parent = workspace
			TweenService:Create(p, TweenInfo.new(1), {Transparency = 1, Size = Vector3.new(0,0,0)}):Play(); game.Debris:AddItem(p, 1.1)
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
				local act = toggles[data.espType:gsub(" ","") .. "ESP"] or (data.espType:find("Star") and toggles.StarESP)
				data.info.Enabled = act; if act then data.textLabel.Text = data.espType .. " [" .. math.floor((data.part.Position - cp).Magnitude) .. "m]" end
			elseif data.mode == "Player" then
				local act = toggles.BoxESP
				if data.player == localPlayer and not toggles.DevMode then act = false 
				else
					local team = (data.player.Team == localPlayer.Team)
					if boxTargetMode == "Enemy" and team then act = false end
					if boxTargetMode == "Teams" and not team then act = false end
				end
				data.gui.Enabled = act; data.info.Enabled = act
				if act then
					data.stroke.Color = data.player.TeamColor.Color; data.textLabel.TextColor3 = data.player.TeamColor.Color
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
				h.Activated:Connect(function() 
					expandedTeams[team.Name] = not expandedTeams[team.Name]
					updateRender() 
				end)
			end
			
			h.Text = "  " .. team.Name:upper()
			h.TextColor3 = team.TeamColor.Color
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
					
					card.Border.Color = team.TeamColor.Color
					card.PName.Text = p.DisplayName
					card.PKit.Text = kitName
					card.PKit.TextColor3 = team.TeamColor.Color
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
task.spawn(function() while zenWareGUI.Parent and task.wait(0.5) do if toggles.KitRender and kitFrame.Visible then updateRender() end end end)

-- KEYBINDS INPUT
UIS.InputBegan:Connect(function(i, g)
	if currentBindName then
		local keyName = i.KeyCode.Name
		if i.KeyCode == Enum.KeyCode.Backspace or i.KeyCode == Enum.KeyCode.Escape or i.KeyCode == Enum.KeyCode.Delete then
			hotkeys[currentBindName] = nil
			notify("Unbound " .. currentBindName:gsub("ESP", " ESP"), false)
			currentBindName = nil
			saveConfig()
			return
		end
		if g then return end 
		local conflict = nil
		for id, k in pairs(hotkeys) do if k == i.KeyCode and id ~= currentBindName then conflict = id break end end
		if conflict then
			notify("WARNING: ["..keyName.."] is already used by "..conflict:gsub("ESP", " ESP").."!", false)
			return 
		else
			hotkeys[currentBindName] = i.KeyCode
			notify("Bound " .. currentBindName:gsub("ESP", " ESP") .. " to [" .. keyName .. "]", true)
			local temp = currentBindName
			currentBindName = nil
			if uiVisuals[temp.."_key"] then uiVisuals[temp.."_key"]() end
			saveConfig()
		end
		return
	end
	
	if g then return end 
	
	if i.KeyCode == Enum.KeyCode.RightShift then
		uiVisible = not uiVisible; mainFrame.Visible = uiVisible
		if toggles.KitRender then kitFrame.Visible = uiVisible end
	end
	
	for id, k in pairs(hotkeys) do
		if i.KeyCode == k then
			toggles[id] = not toggles[id]; 
			if uiVisuals[id] then uiVisuals[id]() end
			local cleanName = string.gsub(id, "ESP", " ESP")
			notify(string.upper(cleanName) .. (toggles[id] and " Enabled" or " Disabled"), toggles[id])
			saveConfig()
		end
	end
end)

-- ANTI-AFK
localPlayer.Idled:Connect(function()
	if toggles.AntiAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end
end)

-- ==========================================
-- KA LOGIC (PURE, AUTHENTIC HIT NO SPOOFING)
-- ==========================================
local SwordHit = ReplicatedStorage.rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.SwordHit
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
	while zenWareGUI.Parent do
		task.wait(0.5) 
		local newCache = {}
		local function scanFolder(folder)
			if not folder then return end
			for _, obj in ipairs(folder:GetChildren()) do
				if obj:IsA("Model") and obj ~= character and not Players:GetPlayerFromCharacter(obj) then
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

	while zenWareGUI.Parent do
		task.wait(toggles.KASpeed or 0.1)
		
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")
		
		if not toggles.KA or not char or not hrp or not hum or hum.Health <= 0 then continue end
		
		local weaponList = ReplicatedStorage:FindFirstChild("Inventories") and ReplicatedStorage.Inventories:FindFirstChild(localPlayer.Name)
		local equippedItemModel = nil
		
		if char and weaponList then
			for _, item in ipairs(char:GetChildren()) do
				if item:IsA("Model") or item:IsA("Accessory") or item:IsA("Tool") then
					local eqModelFound = weaponList:FindFirstChild(item.Name)
					if eqModelFound then
						equippedItemModel = eqModelFound
						break
					end
				end
			end
		end

		if not equippedItemModel then continue end
		
		local wName = equippedItemModel.Name:lower()
		if not (wName:find("sword") or wName:find("blade") or wName:find("dao") or wName:find("scythe") or wName:find("dagger") or wName:find("rageblade")) then
			continue 
		end

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
					local dirVec = targetHRP.Position - hrp.Position
					local dist = dirVec.Magnitude
					if dist <= range then
						local dotProduct = hrp.CFrame.LookVector:Dot(dirVec.Unit)
						local angleToTarget = math.deg(math.acos(math.clamp(dotProduct, -1, 1)))
						if angleToTarget <= maxAngle then
							local isBlocked = false
							if toggles.KAWallCheck then isBlocked = not isTargetVisible(hrp.Position, model, {char, model}) end
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
				local direction = (targetHRP.Position - hrp.Position).Unit
				local reachOffset = math.clamp(finalEnemyDist - 14, 0, 14.4)
				local fakePos = hrp.Position + (direction * reachOffset)
				
				local args = {
					[1] = {
						["entityInstance"] = targetEnemy,
						["chargedAttack"] = { ["chargeRatio"] = 0 },
						["validate"] = {
							["targetPosition"] = { ["value"] = targetHRP.Position },
							["raycast"] = { ["cursorDirection"] = { ["value"] = direction }, ["cameraPosition"] = { ["value"] = fakePos } },
							["selfPosition"] = { ["value"] = fakePos }
						},
						["weapon"] = equippedItemModel
					}
				}
				
				task.spawn(function() 
					pcall(function() SwordHit:FireServer(unpack(args)) end)
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
	while zenWareGUI.Parent do
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

	while zenWareGUI.Parent do
		task.wait(0.5)
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if not toggles.AutoBuyArmor or not hrp or not hum or hum.Health <= 0 then continue end
		
		local nearShop = false
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("Model") and (v.Name:lower():find("itemshop") or v.Name:lower():find("merchant") or v:GetAttribute("ShopId") == "1_item_shop") then
				local p = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
				if p and (p.Position - hrp.Position).Magnitude < 30 then nearShop = true; break end
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
nukerHighlight.Name = "NukerHighlight"; nukerHighlight.FillColor = Color3.fromRGB(255, 50, 50); nukerHighlight.OutlineColor = Color3.fromRGB(255, 200, 0); nukerHighlight.FillTransparency = 0.5; nukerHighlight.OutlineTransparency = 0.1; nukerHighlight.Parent = zenWareGUI; nukerHighlight.Enabled = false

task.spawn(function()
	while zenWareGUI.Parent do
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

	while zenWareGUI.Parent do
		task.wait(toggles.NukerTimer or 0.1)
		
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if not toggles.Nuker or not char or not hrp or not hum or hum.Health <= 0 then 
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
			if not lockedNukerBlock:IsDescendantOf(workspace) or not lockedNukerBlock.CanCollide or lockedNukerBlock.Transparency >= 1 or not hrp or (lockedNukerBlock.Position - hrp.Position).Magnitude > 32 then
				lockedNukerBlock = nil; lockedRawTarget = nil
			end
		end
		
		if not lockedNukerBlock then
			local closestBed, closestBedDist = nil, 30
			local closestOre, closestOreDist = nil, 30
			
			for _, obj in ipairs(cachedNukerBlocks) do
				if obj and obj.Parent then
					local n = obj.Name:lower()
					local dist = (obj.Position - hrp.Position).Magnitude
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
					cam.CFrame.Position, hrp.Position, hrp.Position + Vector3.new(0, 1.5, 0),
					hrp.Position + Vector3.new(1.2, 0, 0), hrp.Position + Vector3.new(-1.2, 0, 0)
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
	while zenWareGUI.Parent do
		task.wait(0.1)
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if toggles.ExtendedDrop and hrp and hum and hum.Health > 0 then
			local itemDrops = workspace:FindFirstChild("ItemDrops")
			if itemDrops then
				local pickupRemote = ReplicatedStorage.rbxts_include.node_modules:FindFirstChild("@rbxts")
				if pickupRemote then pickupRemote = pickupRemote.net.out._NetManaged:FindFirstChild("PickupItemDrop") end
				if pickupRemote then
					local myPos = hrp.Position
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

-- ==========================================
-- FAST DROP HOOK
-- ==========================================
pcall(function()
	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		local method = getnamecallmethod()
		if getgenv()._fastDropping then return oldNamecall(self, ...) end

		if toggles.FastDrop and method == "InvokeServer" and tostring(self) == "DropItem" then
			local args = {...}
			task.spawn(function()
				getgenv()._fastDropping = true
				local dropMult = math.floor(toggles.FastDropSpeed or 5)
				for i = 1, dropMult - 1 do
					pcall(function() self:InvokeServer(unpack(args)) end)
					task.wait(0.01)
				end
				getgenv()._fastDropping = false
			end)
		end
		return oldNamecall(self, ...)
	end)
end)

loadConfig()
for id, fn in pairs(uiVisuals) do if not id:find("_key") then fn() end end
handleStaffScan()
