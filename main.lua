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
local tutorialActive = true 
local isDraggingSlider = false
local tracked = {}
local sharedKATarget = nil -- Allows Aim Assist to sync with Kill Aura
local defaultToggles = {
	["BoxESP"] = false, ["Chams"] = false, ["ShowName"] = false, ["ShowTeam"] = false, ["ShowKit"] = false, ["ShowHealth"] = false, 
	["KitRender"] = false, ["KitRenderOwnTeam"] = true, 
	["MetalESP"] = false, ["StarESP"] = false, ["BeeESP"] = false, ["ChestESP"] = false,
	["FarmESP"] = false, ["BeehiveESP"] = false, ["TaliyahESP"] = false, ["BedESP"] = false,
	["Trails"] = false, ["TrailRainbow"] = false, ["TrailBall"] = false,
	["AntiAFK"] = false, ["Freecam"] = false, ["FreecamSpeed"] = 2, 
	["SpinBot"] = false, ["SpinSpeed"] = 20, ["VoidJump"] = false, 
	["Fly"] = false, ["FlySpeed"] = 20, ["InfJump"] = false, ["HighJump"] = false, ["Sprint"] = false,
	["Speed"] = false, ["SpeedValue"] = 23, ["WallClimb"] = false,
	["KA"] = false, ["KASpeed"] = 0.1, ["KARange"] = 28, ["KAAngle"] = 360,
	["KAWallCheck"] = false, ["KASwingAnim"] = false, ["KASwingSpeed"] = 1.0, ["KASwingRange"] = 43,
	["KATargetPlayer"] = true, ["KATargetNPC"] = false, ["KATargetDummy"] = false, ["KAPriority"] = "Distance",
	["AimAssist"] = false, ["AimSpeed"] = 50, ["AimRange"] = 100, ["AimPart"] = "Head",
	["AimTeamCheck"] = true, ["AimWallCheck"] = true, ["AimTargetPlayer"] = true, ["AimTargetNPC"] = false, ["AimTargetDummy"] = false, ["AimReqSword"] = true, ["AimTrackKA"] = false,
	["Velocity"] = false, ["VelocityH"] = 0, ["VelocityV"] = 0,
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
local expandedStates = {} 
local uiVisible = true
local connections = {}
local currentBindName = nil
local flyBodyVel = nil

-- DYNAMIC REMOTE HANDLER
local function fireRemote(remote, ...)
	if remote then
		if remote:IsA("RemoteEvent") then
			remote:FireServer(...)
		elseif remote:IsA("RemoteFunction") then
			pcall(function(...) remote:InvokeServer(...) end, ...)
		end
	end
end

-- ORIGINAL REMOTE LOCATOR
local function getDamageBlockRemote()
	local remote = ReplicatedStorage:FindFirstChild("rbxts_include")
	if remote then remote = remote:FindFirstChild("node_modules") end
	if remote then remote = remote:FindFirstChild("@easy-games") end
	if remote then remote = remote:FindFirstChild("block-engine") end
	if remote then remote = remote:FindFirstChild("node_modules") end
	if remote then remote = remote:FindFirstChild("@rbxts") end
	if remote then remote = remote:FindFirstChild("net") end
	if remote then remote = remote:FindFirstChild("out") end
	if remote then remote = remote:FindFirstChild("_NetManaged") end
	if remote then remote = remote:FindFirstChild("DamageBlock") end
	return remote
end

-- AUTO ARMOR REMOTE LOCATORS
local function getPurchaseRemote()
	local rem = ReplicatedStorage:FindFirstChild("rbxts_include")
	if rem then rem = rem.node_modules:FindFirstChild("@rbxts") end
	if rem then rem = rem.net.out._NetManaged:FindFirstChild("BedwarsPurchaseItem") end
	return rem
end

local function getEquipRemote()
	local rem = ReplicatedStorage:FindFirstChild("rbxts_include")
	if rem then rem = rem.node_modules:FindFirstChild("@rbxts") end
	if rem then rem = rem.net.out._NetManaged:FindFirstChild("SetArmorInvItem") end
	return rem
end

-- VELOCITY (ANTI-KB) ROBUST HOOK
local function applyVelocityMod(v)
	if toggles.Velocity and (v:IsA("BodyVelocity") or v:IsA("LinearVelocity") or v:IsA("VectorForce") or v:IsA("BodyModifier")) and v.Name ~= "FlyVelocity" then
		local h = (tonumber(toggles.VelocityH) or 0) / 100
		local y = (tonumber(toggles.VelocityV) or 0) / 100
		if h == 0 and y == 0 then
			task.defer(function() pcall(function() v:Destroy() end) end)
		else
			task.spawn(function()
				task.wait(0.01)
				if v and v.Parent then
					if v:IsA("BodyVelocity") then
						v.Velocity = Vector3.new(v.Velocity.X * h, v.Velocity.Y * y, v.Velocity.Z * h)
					elseif v:IsA("LinearVelocity") then
						v.VectorVelocity = Vector3.new(v.VectorVelocity.X * h, v.VectorVelocity.Y * y, v.VectorVelocity.Z * h)
					elseif v:IsA("VectorForce") then
						v.Force = Vector3.new(v.Force.X * h, v.Force.Y * y, v.Force.Z * h)
					end
				end
			end)
		end
	end
end

local function hookVelocity(characterRoot)
	if not characterRoot then return end
	characterRoot.ChildAdded:Connect(applyVelocityMod)
end

-- RE-SETUP CHARACTER REFS
localPlayer.CharacterAdded:Connect(function(char)
	character = char
	hrp = char:WaitForChild("HumanoidRootPart")
	hookVelocity(hrp)
end)
if character and character:FindFirstChild("HumanoidRootPart") then hookVelocity(character.HumanoidRootPart) end

-- CONFIG SAVING
local currentAccent = Color3.fromRGB(139, 92, 246)
local function saveConfig()
	local cfg = { 
		t = toggles, 
		h = {}, 
		btm = boxTargetMode, 
		ff = farmFilter,
		acc = {currentAccent.R, currentAccent.G, currentAccent.B},
		exp = expandedStates
	}
	for k, v in pairs(hotkeys) do cfg.h[k] = v.Name end
	if type(writefile) == "function" then pcall(function() writefile("feenware_cfg.json", HttpService:JSONEncode(cfg)) end) end
end

local function loadConfig()
	if type(readfile) == "function" and type(isfile) == "function" and isfile("feenware_cfg.json") then
		local s, res = pcall(function() return HttpService:JSONDecode(readfile("feenware_cfg.json")) end)
		if s and type(res) == "table" then
			if res.t then for k, v in pairs(res.t) do toggles[k] = v end end
			if res.h then for k, v in pairs(res.h) do pcall(function() hotkeys[k] = Enum.KeyCode[v] end) end end
			if res.btm then boxTargetMode = res.btm end
			if res.ff then farmFilter = res.ff end
			if res.exp then expandedStates = res.exp end
			if res.acc then 
				pcall(function() 
					local c = Color3.new(res.acc[1], res.acc[2], res.acc[3])
					currentAccent = c
				end)
			end
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
		local remote = rs:WaitForChild("events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"):WaitForChild("leaveParty")
		fireRemote(remote)
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
ui.IgnoreGuiInset = true 

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
	table.insert(connections, h.InputBegan:Connect(function(i) 
		if tutorialActive then return end 
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = true; ds = i.Position; sp = f.Position end 
	end))
	table.insert(connections, UIS.InputChanged:Connect(function(i) if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local del = i.Position - ds; f.Position = UDim2.new(sp.X.Scale, sp.X.Offset + del.X, sp.Y.Scale, sp.Y.Offset + del.Y) end end))
	table.insert(connections, UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end end))
end

-- TOOLTIP SYSTEM 
local tooltipFrame = Instance.new("Frame", ui)
tooltipFrame.BackgroundColor3 = c_sidebar
tooltipFrame.Visible = false
tooltipFrame.ZIndex = 100
addCorner(6, tooltipFrame)
local ttStroke = Instance.new("UIStroke", tooltipFrame); ttStroke.Color = currentAccent; accentObjects[ttStroke] = "Color"
local ttLabel = Instance.new("TextLabel", tooltipFrame)
ttLabel.BackgroundTransparency = 1; ttLabel.TextColor3 = c_text
ttLabel.Font = Enum.Font.Gotham; ttLabel.TextSize = 12; ttLabel.ZIndex = 101
ttLabel.TextXAlignment = Enum.TextXAlignment.Left; ttLabel.TextYAlignment = Enum.TextYAlignment.Top

table.insert(connections, RunService.RenderStepped:Connect(function()
	if tooltipFrame.Visible then
		if isDraggingSlider then 
			tooltipFrame.Position = UDim2.new(2, 0, 2, 0)
			return 
		end
		
		local mPos = UIS:GetMouseLocation()
		tooltipFrame.Position = UDim2.new(0, mPos.X + 15, 0, mPos.Y - 20)
		
		ttLabel.TextWrapped = false
		ttLabel.Size = UDim2.new(0, 1000, 0, 20)
		local bounds = ttLabel.TextBounds
		
		local targetWidth = bounds.X
		if targetWidth > 250 then
			targetWidth = 250
			ttLabel.TextWrapped = true
		end
		
		ttLabel.Size = UDim2.new(0, targetWidth, 0, 1000)
		local targetHeight = ttLabel.TextBounds.Y
		
		ttLabel.Size = UDim2.new(0, targetWidth, 0, targetHeight)
		ttLabel.Position = UDim2.new(0, 10, 0, 6)
		tooltipFrame.Size = UDim2.new(0, targetWidth + 20, 0, targetHeight + 12)
	end
end))

local function attachTooltip(element, desc)
	if not desc or desc == "" then return end
	element.MouseEnter:Connect(function() 
		if isDraggingSlider then return end
		ttLabel.Text = desc
		tooltipFrame.Visible = true 
	end)
	element.MouseLeave:Connect(function() tooltipFrame.Visible = false end)
end

-- Notification System
local notifHolder = Instance.new("Frame", ui)
notifHolder.Size = UDim2.new(0, 250, 1, -50); notifHolder.Position = UDim2.new(1, -260, 0, 0); notifHolder.BackgroundTransparency = 1; notifHolder.ZIndex = 50
local notifLayout = Instance.new("UIListLayout", notifHolder); notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom; notifLayout.Padding = UDim.new(0, 10)

local function notify(title, state)
	local f = Instance.new("Frame", notifHolder)
	f.Size = UDim2.new(1, 0, 0, 45); f.BackgroundColor3 = c_sidebar; f.BackgroundTransparency = 1; f.ZIndex = 51; addCorner(6, f)
	local s = Instance.new("UIStroke", f); s.Color = state and currentAccent or c_element; s.Transparency = 1
	local t = Instance.new("TextLabel", f)
	t.Size = UDim2.new(1, -15, 1, 0); t.Position = UDim2.new(0, 15, 0, 0); t.BackgroundTransparency = 1
	t.Text = title; t.TextColor3 = c_text; t.Font = Enum.Font.GothamBold; t.TextSize = 13; t.TextXAlignment = Enum.TextXAlignment.Left; t.TextTransparency = 1; t.ZIndex = 52
	
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
makeDraggable(mainFrame, mainFrame)

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
	
	local expanded = expandedStates[titleText] or false
	
	local function setExpanded(state, instant)
		expanded = state
		expandedStates[titleText] = state
		arrow.Text = expanded and "▼" or "▶"
		arrow.TextColor3 = expanded and currentAccent or c_textMuted
		lbl.TextColor3 = expanded and c_text or c_textMuted
		
		local targetHeight = expanded and (40 + layout.AbsoluteContentSize.Y + 12) or 40
		if instant then
			container.Size = UDim2.new(0.92, 0, 0, targetHeight)
		else
			TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0.92, 0, 0, targetHeight)}):Play()
		end
		saveConfig()
	end
	
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		if expanded then container.Size = UDim2.new(0.92, 0, 0, 40 + layout.AbsoluteContentSize.Y + 12) end
	end)
	
	header.MouseButton1Down:Connect(function() setExpanded(not expanded) end)
	
	if expanded then setExpanded(true, true) end
	
	return content, function(forceOpen) if forceOpen and not expanded then setExpanded(true) end end
end

local function MakeToggle(parent, id, titleText, desc, callback, parentExpanderFn)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(0.96, 0, 0, 38)
	frame.BackgroundColor3 = c_element
	addCorner(6, frame)
	
	local triggerBtn = Instance.new("TextButton", frame)
	triggerBtn.Size = UDim2.new(1, -60, 1, 0); triggerBtn.BackgroundTransparency = 1; triggerBtn.Text = ""; triggerBtn.ZIndex = 5
	attachTooltip(triggerBtn, desc)
	
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(0.6, 0, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1; lbl.Text = titleText; lbl.TextColor3 = c_text
	lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local kbBtn = Instance.new("TextButton", frame)
	kbBtn.Size = UDim2.new(0, 45, 0, 22); kbBtn.Position = UDim2.new(1, -110, 0.5, -11)
	kbBtn.BackgroundColor3 = c_sidebar; kbBtn.TextColor3 = c_textMuted; kbBtn.Text = "[+]"
	kbBtn.Font = Enum.Font.Gotham; kbBtn.TextSize = 10; kbBtn.ZIndex = 6; addCorner(4, kbBtn)
	attachTooltip(kbBtn, "Left click to bind key. Right click to unbind.")
	
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

local function MakeSlider(parent, id, titleText, desc, min, max, isFloat, parentExpanderFn)
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
	attachTooltip(btn, desc)
	
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
			isDraggingSlider = true
			tooltipFrame.Visible = false
			local pct = math.clamp((i.Position.X - sBg.AbsolutePosition.X) / sBg.AbsoluteSize.X, 0, 1)
			local raw = min + ((max - min) * pct)
			toggles[id] = isFloat and raw or math.floor(raw)
			updateVis(); saveConfig()
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
			drag = false 
			isDraggingSlider = false
		end
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

local function MakeDropdown(parent, id, titleText, desc, options, parentExpanderFn)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(0.96, 0, 0, 40)
	frame.BackgroundColor3 = c_element
	addCorner(6, frame)
	
	local lbl = Instance.new("TextLabel", frame)
	lbl.Size = UDim2.new(1, -24, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1; lbl.TextColor3 = c_text; lbl.Font = Enum.Font.GothamSemibold; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left
	
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 5
	attachTooltip(btn, desc)
	
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

local function MakeButton(parent, text, desc, callback, parentExpanderFn)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(0.96, 0, 0, 36)
	b.BackgroundColor3 = c_element
	b.TextColor3 = c_text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.Text = text
	b.ZIndex = 5
	addCorner(6, b)
	attachTooltip(b, desc)
	
	b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = c_hover}):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = c_element}):Play() end)
	b.MouseButton1Down:Connect(callback)
	
	table.insert(searchableItems, {name = text:lower(), element = b, parentCategory = parentExpanderFn})
	return b
end

-- ==========================================
-- LOAD CONFIG FIRST SO UI READS CORRECT STATES
-- ==========================================
loadConfig()

-- Initialize tabs
local tCombat = createTab("Combat")
local tMovement = createTab("Movement")
local tVisuals = createTab("Visuals")
local tWorld = createTab("World")
local tMisc = createTab("Misc")
local tSettings = createTab("Settings")

-- ==========================================
-- POPULATE TABS & EXPANDABLE CATEGORIES
-- ==========================================
-- COMBAT
local cAura, fAura = MakeExpandableCategory(tCombat, "KA Config")
MakeToggle(cAura, "KA", "KA", "Automatically attacks enemies within range.", nil, fAura)
MakeSlider(cAura, "KASpeed", "Delay", "How fast KA attacks. Lower = Faster.", 0.01, 2.0, true, fAura)
MakeSlider(cAura, "KARange", "Range", "Distance KA will reach (Max 28).", 5, 28, false, fAura)
MakeSlider(cAura, "KAAngle", "Angle", "Field of View (FOV) angle for attacks.", 10, 360, false, fAura)
MakeToggle(cAura, "KAWallCheck", "Wall Check", "Ensures targets are not behind walls.", nil, fAura)
MakeDropdown(cAura, "KAPriority", "Priority", "Who Kill Aura locks onto first.", {"Distance", "Player", "NPC", "Dummy"}, fAura)

local cAuraVis, fAuraVis = MakeExpandableCategory(tCombat, "KA Visuals")
MakeToggle(cAuraVis, "KASwingAnim", "Swing Anim", "Plays your sword animation when hitting.", nil, fAuraVis)
MakeSlider(cAuraVis, "KASwingRange", "Anim Range", "Max distance to play the animation.", 5, 43, false, fAuraVis)
MakeSlider(cAuraVis, "KASwingSpeed", "Anim Speed", "How fast the visual animation plays.", 0.1, 3.0, true, fAuraVis)

local cAuraTarg, fAuraTarg = MakeExpandableCategory(tCombat, "KA Targets")
MakeToggle(cAuraTarg, "KATargetPlayer", "Players", "Target real players.", nil, fAuraTarg)
MakeToggle(cAuraTarg, "KATargetNPC", "NPCs", "Target map monsters and bosses.", nil, fAuraTarg)
MakeToggle(cAuraTarg, "KATargetDummy", "Dummies", "Target training dummies.", nil, fAuraTarg)

local cAim, fAim = MakeExpandableCategory(tCombat, "Aim Assist")
MakeToggle(cAim, "AimAssist", "Aim Assist", "Smoothly locks your camera onto nearby targets.", nil, fAim)
MakeSlider(cAim, "AimSpeed", "Smoothness", "Lower = Slower/Smoother, Higher = Snappy.", 1, 100, false, fAim)
MakeSlider(cAim, "AimRange", "Range", "Max distance to target enemies.", 10, 500, false, fAim)
MakeDropdown(cAim, "AimPart", "Target Part", "Which body part to aim at.", {"Head", "Torso"}, fAim)
MakeToggle(cAim, "AimTeamCheck", "Team Check", "Ignores players on your own team.", nil, fAim)
MakeToggle(cAim, "AimWallCheck", "Wall Check", "Only aims if the target is visible.", nil, fAim)
MakeToggle(cAim, "AimTargetPlayer", "Target Players", "Aim at real players.", nil, fAim)
MakeToggle(cAim, "AimTargetNPC", "Target NPCs", "Aim at mobs/bosses.", nil, fAim)
MakeToggle(cAim, "AimTargetDummy", "Target Dummies", "Aim at training dummies.", nil, fAim)
MakeToggle(cAim, "AimReqSword", "Require Sword", "Only aim assists when holding a sword.", nil, fAim)
MakeToggle(cAim, "AimTrackKA", "Track KA Target", "Aim Assist perfectly syncs with your Kill Aura.", nil, fAim)

local cVel, fVel = MakeExpandableCategory(tCombat, "Velocity")
MakeToggle(cVel, "Velocity", "Velocity", "Reduces or removes incoming knockback.", nil, fVel)
MakeSlider(cVel, "VelocityH", "Horizontal %", "100% = Normal KB. 0% = You take 0 Horizontal KB.", 0, 100, false, fVel)
MakeSlider(cVel, "VelocityV", "Vertical %", "100% = Normal KB. 0% = You take 0 Vertical KB.", 0, 100, false, fVel)

-- MOVEMENT
local cSpeed, fSpeed = MakeExpandableCategory(tMovement, "Movement Config")
MakeToggle(cSpeed, "Sprint", "Auto Sprint", "Forces your character to always sprint.", nil, fSpeed)
MakeToggle(cSpeed, "Speed", "Custom Speed", "Increases your base walking speed.", nil, fSpeed)
MakeSlider(cSpeed, "SpeedValue", "Speed Value", "The exact walk speed to set.", 16, 50, false, fSpeed)
MakeToggle(cSpeed, "Fly", "Flight", "Allows you to freely fly through the air.", nil, fSpeed)
MakeSlider(cSpeed, "FlySpeed", "Flight Speed", "How fast your fly hack travels.", 10, 100, false, fSpeed)

local cAbil, fAbil = MakeExpandableCategory(tMovement, "Agility")
MakeToggle(cAbil, "InfJump", "Infinite Jump", "Allows you to jump endlessly in mid-air.", nil, fAbil)
MakeToggle(cAbil, "HighJump", "High Jump", "Increases your jump height massively.", nil, fAbil)
MakeToggle(cAbil, "VoidJump", "Void Jump", "Automatically boosts you up if you fall into the void.", nil, fAbil)
MakeToggle(cAbil, "WallClimb", "Spider Climb", "Allows you to scale solid walls effortlessly.", nil, fAbil)
MakeToggle(cAbil, "SpinBot", "Spin Bot", "Spins your character rapidly, breaking enemy aim.", nil, fAbil)
MakeSlider(cAbil, "SpinSpeed", "Spin Speed", "How fast your character rotates.", 10, 100, false, fAbil)

-- VISUALS
local cPlrEsp, fPlrEsp = MakeExpandableCategory(tVisuals, "Player ESP")
MakeToggle(cPlrEsp, "BoxESP", "Boxes", "Draws bounding boxes around players.", nil, fPlrEsp)
MakeToggle(cPlrEsp, "Chams", "Chams", "Highlights players cleanly through walls.", nil, fPlrEsp)
MakeDropdown(cPlrEsp, "TM", "Target Filter", "Filter who ESP renders on.", {"All", "Enemy", "Teams"}, fPlrEsp)
MakeToggle(cPlrEsp, "ShowName", "Show Names", "Displays the player's nametag.", nil, fPlrEsp)
MakeToggle(cPlrEsp, "ShowTeam", "Show Teams", "Displays the player's team.", nil, fPlrEsp)
MakeToggle(cPlrEsp, "ShowKit", "Show Kits", "Displays the player's active kit.", nil, fPlrEsp)
MakeToggle(cPlrEsp, "ShowHealth", "Show Health", "Displays the player's exact HP.", nil, fPlrEsp)

local cWorldR, fWorldR = MakeExpandableCategory(tVisuals, "Environment")
MakeToggle(cWorldR, "KitRender", "Kit Monitor", "Shows a side-menu listing everyone's kit.", nil, fWorldR)
MakeToggle(cWorldR, "KitRenderOwnTeam", "Show Own Team", "Include your own team in the Kit monitor.", nil, fWorldR)
MakeToggle(cWorldR, "Freecam", "Freecam", "Detach your camera and explore invisibly.", nil, fWorldR)
MakeSlider(cWorldR, "FreecamSpeed", "Camera Speed", "How fast the free camera moves.", 1, 10, false, fWorldR)
MakeToggle(cWorldR, "Fullbright", "Fullbright", "Makes the map fully bright, ignoring shadows.", nil, fWorldR)
MakeToggle(cWorldR, "FOVChanger", "Custom FOV", "Modifies your Field of View.", function() if not toggles.FOVChanger then cam.FieldOfView = 70 end end, fWorldR)
MakeSlider(cWorldR, "FOVValue", "FOV Amount", "Widen or narrow your camera lens.", 70, 120, false, fWorldR)

local cCosm, fCosm = MakeExpandableCategory(tVisuals, "Cosmetics")
MakeToggle(cCosm, "Trails", "Movement Trails", "Leaves a colorful trail behind your character.", nil, fCosm)
MakeToggle(cCosm, "TrailRainbow", "Rainbow Trail", "Makes the trail shift colors constantly.", nil, fCosm)
MakeToggle(cCosm, "TrailBall", "Ball Style", "Uses sphere shapes instead of blocks for the trail.", nil, fCosm)

-- WORLD
local cResEsp, fResEsp = MakeExpandableCategory(tWorld, "Valuables")
MakeToggle(cResEsp, "MetalESP", "Metal Drops", "Displays hidden Metal drops on the map.", nil, fResEsp)
MakeToggle(cResEsp, "StarESP", "Fallen Stars", "Highlights spawned game Stars.", nil, fResEsp)
MakeToggle(cResEsp, "BeeESP", "Wild Bees", "Highlights naturally spawned wild bees.", nil, fResEsp)
MakeToggle(cResEsp, "ChestESP", "Hidden Chests", "Highlights dropped or hidden map chests.", nil, fResEsp)

local cFarmEsp, fFarmEsp = MakeExpandableCategory(tWorld, "Farming & Bases")
MakeToggle(cFarmEsp, "FarmESP", "Crop ESP", "Displays fully grown crops.", nil, fFarmEsp)
MakeDropdown(cFarmEsp, "FF", "Crop Filter", "Which specific crops to highlight.", {"Everything", "Melon Only", "Carrot Only", "Pumpkin Only"}, fFarmEsp)
MakeToggle(cFarmEsp, "BeehiveESP", "Beehives", "Highlights placed beehives.", nil, fFarmEsp)
MakeToggle(cFarmEsp, "TaliyahESP", "Taliyah Eggs", "Highlights spawned eggs.", nil, fFarmEsp)
MakeToggle(cFarmEsp, "BedESP", "Enemy Beds", "Highlights all enemy beds globally.", nil, fFarmEsp)

-- MISC (Split Mining)
local cNuker, fNuker = MakeExpandableCategory(tMisc, "Nuker")
MakeToggle(cNuker, "Nuker", "Enable Nuker", "Automatically destroys map blocks around you.", nil, fNuker)
MakeSlider(cNuker, "NukerTimer", "Nuker Speed", "How fast the nuker strikes blocks.", 0.01, 1.0, true, fNuker)
MakeToggle(cNuker, "NukerBed", "Target Beds", "Nuker explicitly locks onto enemy beds.", nil, fNuker)
MakeToggle(cNuker, "NukerOre", "Target Ores", "Nuker explicitly locks onto map ores.", nil, fNuker)
MakeDropdown(cNuker, "NukerPriority", "Priority", "What the Nuker targets first if both are close.", {"Bed", "Ore", "Distance"}, fNuker)
MakeToggle(cNuker, "NukerHighlight", "Visual Highlight", "Shows a red box on the block being destroyed.", nil, fNuker)
MakeToggle(cNuker, "NukerReqPickaxe", "Require Pickaxe", "Nuker only works when you have a Pickaxe.", nil, fNuker)
MakeToggle(cNuker, "NukerReqAxe", "Require Axe", "Nuker only works when you have an Axe.", nil, fNuker)
MakeToggle(cNuker, "NukerReqShears", "Require Shears", "Nuker only works when you have Shears.", nil, fNuker)

local cFastBreak, fFastBreak = MakeExpandableCategory(tMisc, "Fast Break")
MakeToggle(cFastBreak, "FastBreak", "Fast Break", "Instantly breaks blocks you click on.", nil, fFastBreak)
MakeSlider(cFastBreak, "FastBreakTimer", "Break Speed", "Delay between fast break swings.", 0.01, 0.5, true, fFastBreak)

local cAuto, fAuto = MakeExpandableCategory(tMisc, "Automation")
MakeToggle(cAuto, "AutoArmor", "Auto Armor", "Automatically buys and equips armor near shops.", nil, fAuto)
MakeToggle(cAuto, "ExtendedDrop", "Item Magnet", "Magnetically pulls items into your inventory.", nil, fAuto)
MakeSlider(cAuto, "ExtendedDropRange", "Magnet Range", "How far the item magnet reaches.", 10, 50, false, fAuto)

local cUtil, fUtil = MakeExpandableCategory(tMisc, "Utility")
MakeToggle(cUtil, "AntiAFK", "Anti-AFK", "Prevents Roblox from kicking you for idle time.", nil, fUtil)
MakeToggle(cUtil, "StaffDetect", "Staff Radar", "Alerts you instantly if a developer joins.", nil, fUtil)
MakeToggle(cUtil, "StaffLeave", "Auto-Leave", "Instantly leaves the game if a staff member is found.", nil, fUtil)
MakeToggle(cUtil, "StaffDestruct", "Auto-Destruct", "Removes the exploit menu entirely if staff is found.", nil, fUtil)

-- SETTINGS
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
	cb.MouseButton1Down:Connect(function() setAccent(col); saveConfig() end)
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
attachTooltip(mKbBtn, "Click to rebind the menu toggle key.")

MakeButton(cCfg, "Unbind Hotkeys", "Instantly resets every bound hotkey.", function()
	hotkeys = {}; for id, fn in pairs(uiVisuals) do if id:find("_key") then fn() end end; saveConfig(); notify("Hotkeys Unbound", false)
end, fCfg)
MakeButton(cCfg, "Disable Toggles", "Turns off every hack in the menu.", function()
	for k, v in pairs(toggles) do if type(v) == "boolean" and k ~= "KitRenderOwnTeam" then toggles[k] = false end end
	for id, fn in pairs(uiVisuals) do if not id:find("_key") then fn() end end; saveConfig(); notify("Toggles Disabled", false)
end, fCfg)
MakeButton(cCfg, "Leave Party", "Forces your client to leave your current lobby party.", function() notify("Leaving Party...", true); leaveParty() end, fCfg)
MakeButton(cCfg, "Uninject", "Completely removes the menu and safely stops all hacks.", function() notify("Uninjecting Feenware...", false); uninject() end, fCfg)

-- Finalize initial states
uiVisuals.TM = function() boxTargetMode = toggles.TM or "All" end
uiVisuals.FF = function() farmFilter = toggles.FF or "Everything" end
setAccent(currentAccent)

if #tabs > 0 then
	TweenService:Create(tabs[1].btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2, TextColor3 = currentAccent}):Play()
	tabs[1].content.Visible = true
	activeTab = tabs[1].btn.Text
end

-- ==========================================
-- INTERACTIVE TUTORIAL OVERLAY SCREEN
-- ==========================================
local tutOverlay = Instance.new("Frame", ui)
tutOverlay.Size = UDim2.new(1, 0, 1, 0)
tutOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
tutOverlay.BackgroundTransparency = 0.5
tutOverlay.ZIndex = 1000

local tutFrame = Instance.new("Frame", tutOverlay)
tutFrame.Size = UDim2.new(0, 480, 0, 320)
tutFrame.Position = UDim2.new(0.5, -240, 0.5, -160)
tutFrame.BackgroundColor3 = c_bg
tutFrame.ClipsDescendants = true
tutFrame.ZIndex = 1001
addCorner(8, tutFrame)

local tutStroke = Instance.new("UIStroke", tutFrame)
tutStroke.Color = currentAccent
tutStroke.Thickness = 2
accentObjects[tutStroke] = "Color"

local tutTitle = Instance.new("TextLabel", tutFrame)
tutTitle.Size = UDim2.new(1, 0, 0, 60)
tutTitle.BackgroundTransparency = 1
tutTitle.Text = "Welcome to Feenware Ultimate"
tutTitle.Font = Enum.Font.GothamBlack
tutTitle.TextSize = 22
tutTitle.TextColor3 = currentAccent
tutTitle.ZIndex = 1002
accentObjects[tutTitle] = "TextColor3"

local tutText = Instance.new("TextLabel", tutFrame)
tutText.Size = UDim2.new(1, -60, 1, -140)
tutText.Position = UDim2.new(0, 30, 0, 60)
tutText.BackgroundTransparency = 1
tutText.TextColor3 = c_text
tutText.TextWrapped = true
tutText.Font = Enum.Font.GothamSemibold
tutText.TextSize = 14
tutText.TextXAlignment = Enum.TextXAlignment.Left
tutText.TextYAlignment = Enum.TextYAlignment.Top
tutText.ZIndex = 1002

local tutSlides = {
	"QUICK START GUIDE:\n\n• Press [RightShift] (or your custom Menu Key) to open/close this menu.\n\n• The UI is completely draggable! Just click and drag anywhere on the menu background.",
	"HOTKEYS & BINDING:\n\n• To bind a hotkey, Left-Click the [+] button next to a feature, then press any key.\n\n• To unbind a hotkey, Right-Click the same button.",
	"TOOLTIPS & SAVING:\n\n• Hover your mouse over any feature to see a descriptive tooltip of what it does.\n\n• ALL of your settings, hotkeys, and theme colors save automatically and seamlessly!"
}
local currentSlide = 1
tutText.Text = tutSlides[currentSlide]

local nextBtn = Instance.new("TextButton", tutFrame)
nextBtn.Size = UDim2.new(0, 120, 0, 40)
nextBtn.Position = UDim2.new(1, -150, 1, -60)
nextBtn.BackgroundColor3 = currentAccent
nextBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nextBtn.Font = Enum.Font.GothamBold
nextBtn.TextSize = 14
nextBtn.Text = "NEXT >"
nextBtn.ZIndex = 1002
addCorner(6, nextBtn)
accentObjects[nextBtn] = "BackgroundColor3"

local skipBtn = Instance.new("TextButton", tutFrame)
skipBtn.Size = UDim2.new(0, 120, 0, 40)
skipBtn.Position = UDim2.new(0, 30, 1, -60)
skipBtn.BackgroundColor3 = c_element
skipBtn.TextColor3 = c_textMuted
skipBtn.Font = Enum.Font.GothamBold
skipBtn.TextSize = 14
skipBtn.Text = "SKIP"
skipBtn.ZIndex = 1002
addCorner(6, skipBtn)

local function closeTutorial()
	tutOverlay:Destroy()
	tutorialActive = false
end

nextBtn.MouseButton1Click:Connect(function()
	if currentSlide < #tutSlides then
		currentSlide = currentSlide + 1
		tutText.Text = tutSlides[currentSlide]
		if currentSlide == #tutSlides then nextBtn.Text = "FINISH" end
	else
		closeTutorial()
	end
end)
skipBtn.MouseButton1Click:Connect(closeTutorial)

-- ==========================================
-- KEYBINDS INPUT HANDLER
-- ==========================================
table.insert(connections, UIS.InputBegan:Connect(function(input, g)
	-- Processing hotkey assignments
	if currentBindName then
		local keyName = input.KeyCode.Name
		if keyName ~= "Unknown" then
			if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Delete then
				hotkeys[currentBindName] = nil
				notify("Unbound Hotkey", false)
			else
				hotkeys[currentBindName] = input.KeyCode
				notify("Bound to [" .. keyName .. "]", true)
			end
			local temp = currentBindName
			currentBindName = nil
			if uiVisuals[temp.."_key"] then uiVisuals[temp.."_key"]() end
			saveConfig()
		end
		return
	end

	-- Menu Toggle Key Assignment
	if bindingMenu then
		local keyName = input.KeyCode.Name
		if keyName ~= "Unknown" then
			toggles.MenuKey = keyName
			mKbBtn.Text = "[" .. keyName .. "]"
			bindingMenu = false
			saveConfig()
			notify("Menu Key Bound to " .. keyName, true)
		end
		return
	end

	-- Ignore hotkeys if user is actively typing in a chatbox or search bar
	if UIS:GetFocusedTextBox() then return end
	
	-- Menu Toggle
	local targetKey = toggles.MenuKey or "RightShift"
	if input.KeyCode.Name == targetKey then
		uiVisible = not uiVisible; mainFrame.Visible = uiVisible
		if toggles.KitRender and kitFrame then kitFrame.Visible = uiVisible end
	end
	
	-- Toggle triggers
	for id, k in pairs(hotkeys) do
		if input.KeyCode == k then
			toggles[id] = not toggles[id]
			if uiVisuals[id] then uiVisuals[id]() end
			local cleanName = string.gsub(id, "ESP", " ESP")
			notify(string.upper(cleanName) .. (toggles[id] and " Enabled" or " Disabled"), toggles[id])
			saveConfig()
		end
	end

	-- Jump Abilities
	if input.KeyCode == Enum.KeyCode.Space then
		local char = localPlayer.Character
		local locHrp = char and char:FindFirstChild("HumanoidRootPart")
		if locHrp then
			if toggles.InfJump then locHrp.Velocity = Vector3.new(locHrp.Velocity.X, 40, locHrp.Velocity.Z) end
			if toggles.HighJump then locHrp.Velocity = Vector3.new(locHrp.Velocity.X, 100, locHrp.Velocity.Z) end
		end
	end
end))

-- ==========================================
-- LOGIC & PHYSICS LOOPS
-- ==========================================
local modifiedVelocities = {}
table.insert(connections, RunService.Heartbeat:Connect(function()
	if not isRunning then return end
	if toggles.Velocity then
		local char = localPlayer.Character
		local locHrp = char and char:FindFirstChild("HumanoidRootPart")
		if locHrp then
			local h = (tonumber(toggles.VelocityH) or 0) / 100
			local y = (tonumber(toggles.VelocityV) or 0) / 100
			
			-- Modern BedWars direct AssemblyLinearVelocity knockback modifier
			local currentVel = locHrp.AssemblyLinearVelocity
			local horizontalVel = Vector3.new(currentVel.X, 0, currentVel.Z)
			
			if horizontalVel.Magnitude > 30 then 
				locHrp.AssemblyLinearVelocity = Vector3.new(currentVel.X * h, currentVel.Y, currentVel.Z * h)
			end
			if math.abs(currentVel.Y) > 55 then
				locHrp.AssemblyLinearVelocity = Vector3.new(locHrp.AssemblyLinearVelocity.X, currentVel.Y * y, locHrp.AssemblyLinearVelocity.Z)
			end
			
			for _, v in ipairs(locHrp:GetChildren()) do
				if (v:IsA("BodyVelocity") or v:IsA("LinearVelocity") or v:IsA("VectorForce") or v:IsA("BodyModifier")) and v.Name ~= "FlyVelocity" then
					if h == 0 and y == 0 then
						v:Destroy()
					elseif not modifiedVelocities[v] then
						modifiedVelocities[v] = true
						if v:IsA("BodyVelocity") then
							v.Velocity = Vector3.new(v.Velocity.X * h, v.Velocity.Y * y, v.Velocity.Z * h)
						elseif v:IsA("LinearVelocity") then
							v.VectorVelocity = Vector3.new(v.VectorVelocity.X * h, v.VectorVelocity.Y * y, v.VectorVelocity.Z * h)
						elseif v:IsA("VectorForce") then
							v.Force = Vector3.new(v.Force.X * h, v.Force.Y * y, v.Force.Z * h)
						end
					end
				end
			end
		end
	end
end))

local cachedDamageBlock = nil
local function getDamageBlockRemote()
	if cachedDamageBlock and cachedDamageBlock.Parent then return cachedDamageBlock end
	local netManaged = ReplicatedStorage:FindFirstChild("rbxts_include")
	if netManaged then netManaged = netManaged:FindFirstChild("node_modules") end
	if netManaged then netManaged = netManaged:FindFirstChild("@easy-games") end
	if netManaged then netManaged = netManaged:FindFirstChild("block-engine") end
	if netManaged then netManaged = netManaged:FindFirstChild("node_modules") end
	if netManaged then netManaged = netManaged:FindFirstChild("@rbxts") end
	if netManaged then netManaged = netManaged:FindFirstChild("net") end
	if netManaged then netManaged = netManaged:FindFirstChild("out") end
	if netManaged then netManaged = netManaged:FindFirstChild("_NetManaged") end
	
	if netManaged then 
		cachedDamageBlock = netManaged:FindFirstChild("DamageBlock") or netManaged:FindFirstChild("DestroyBlock")
		if cachedDamageBlock then return cachedDamageBlock end
	end
	
	for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
		if (v.Name == "DamageBlock" or v.Name == "DestroyBlock") and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
			cachedDamageBlock = v
			return v
		end
	end
	return nil
end

-- AUTO ARMOR REMOTE LOCATORS
local function getPurchaseRemote()
	local rem = ReplicatedStorage:FindFirstChild("rbxts_include")
	if rem then rem = rem.node_modules:FindFirstChild("@rbxts") end
	if rem then rem = rem.net.out._NetManaged:FindFirstChild("BedwarsPurchaseItem") end
	return rem
end

local function getEquipRemote()
	local rem = ReplicatedStorage:FindFirstChild("rbxts_include")
	if rem then rem = rem.node_modules:FindFirstChild("@rbxts") end
	if rem then rem = rem.net.out._NetManaged:FindFirstChild("SetArmorInvItem") end
	return rem
end

table.insert(connections, RunService.RenderStepped:Connect(function(dt)
	if not isRunning then return end
	local char = localPlayer.Character
	local hum = char and char:FindFirstChild("Humanoid")
	local locHrp = char and char:FindFirstChild("HumanoidRootPart")
	local cp = cam.CFrame.Position
	
	-- AUTO SPRINT LOGIC
	if toggles.Sprint and hum and hum.Health > 0 and hum.MoveDirection.Magnitude > 0 then
		if hum.WalkSpeed < 20 then hum.WalkSpeed = 20 end
	end
	
	-- AIM ASSIST LOGIC
	if toggles.AimAssist and locHrp then
		local isHoldingSword = false
		if char then
			for _, item in ipairs(char:GetDescendants()) do
				if item:IsA("Model") or item:IsA("Accessory") or item:IsA("Tool") then
					local n = item.Name:lower()
					if n:find("sword") or n:find("blade") or n:find("dao") or n:find("scythe") or n:find("dagger") or n:find("rageblade") or n:find("hammer") then
						isHoldingSword = true; break
					end
				end
			end
		end

		if not toggles.AimReqSword or isHoldingSword then
			local range = tonumber(toggles.AimRange) or 100
			local bestTarget = nil
			local bestDist = math.huge
			
			local mouse = localPlayer:GetMouse()
			local mousePos = Vector2.new(mouse.X, mouse.Y)
			
			if toggles.AimTrackKA and sharedKATarget then
				local thum = sharedKATarget:FindFirstChild("Humanoid")
				if thum and thum.Health > 0 then
					local tHRP = sharedKATarget:FindFirstChild("HumanoidRootPart")
					local tHead = sharedKATarget:FindFirstChild("Head")
					bestTarget = toggles.AimPart == "Head" and tHead or tHRP
				end
			end
			
			if not bestTarget then
				local function checkAimTarget(model, isPlayerTarget)
					if not model then return end
					local targetHRP = model:FindFirstChild("HumanoidRootPart")
					local targetHead = model:FindFirstChild("Head")
					local aimPart = toggles.AimPart == "Head" and targetHead or targetHRP
					local thum = model:FindFirstChild("Humanoid")
					
					if aimPart and aimPart:IsA("BasePart") and thum and thum.Health > 0 then
						if isPlayerTarget and toggles.AimTeamCheck then
							local p = Players:GetPlayerFromCharacter(model)
							if p and p.Team == localPlayer.Team then return end
						end
						
						local dist3D = (aimPart.Position - locHrp.Position).Magnitude
						if dist3D <= range then
							local screenPos, onScreen = cam:WorldToViewportPoint(aimPart.Position)
							if onScreen then
								local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
								if dist2D < bestDist then
									local isBlocked = false
									if toggles.AimWallCheck then
										local params = RaycastParams.new()
										params.FilterDescendantsInstances = {char, model}
										params.FilterType = Enum.RaycastFilterType.Exclude
										local hit = workspace:Raycast(cam.CFrame.Position, aimPart.Position - cam.CFrame.Position, params)
										if hit then isBlocked = true end
									end
									if not isBlocked then
										bestDist = dist2D
										bestTarget = aimPart
									end
								end
							end
						end
					end
				end
				
				if toggles.AimTargetPlayer then
					for _, p in ipairs(Players:GetPlayers()) do
						if p ~= localPlayer and p.Character then checkAimTarget(p.Character, true) end
					end
				end
				
				if toggles.AimTargetNPC or toggles.AimTargetDummy then
					local npcs = workspace:FindFirstChild("Live") or workspace
					for _, npc in ipairs(npcs:GetChildren()) do
						if npc:IsA("Model") and npc ~= char and not Players:GetPlayerFromCharacter(npc) then
							local nhum = npc:FindFirstChildOfClass("Humanoid")
							if nhum and nhum.Health > 0 then
								local nName = npc.Name:lower()
								if toggles.AimTargetDummy and nName:find("dummy") then checkAimTarget(npc, false)
								elseif toggles.AimTargetNPC and not nName:find("dummy") then checkAimTarget(npc, false) end
							end
						end
					end
				end
			end
			
			if bestTarget then
				local targetCFrame = CFrame.new(cam.CFrame.Position, bestTarget.Position)
				local speed = (tonumber(toggles.AimSpeed) or 50) / 100
				cam.CFrame = cam.CFrame:Lerp(targetCFrame, speed)
			end
		end
	end
	
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
			flyBodyVel.Name = "FlyVelocity"
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
		if hum.MoveDirection.Magnitude > 0 and tick() - (tonumber(lastTrail) or 0) > 0.08 then
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

-- KIT RENDER FRAME
kitFrame = Instance.new("Frame", ui)
kitFrame.Size = UDim2.new(0, 380, 0, 520); kitFrame.Position = UDim2.new(0.7, 0, 0.2, 0); kitFrame.BackgroundColor3 = c_bg; kitFrame.Visible = false; addCorner(10, kitFrame); makeDraggable(kitFrame, kitFrame)
local kitStroke = Instance.new("UIStroke", kitFrame); kitStroke.Color = currentAccent; kitStroke.Thickness = 1; accentObjects[kitStroke] = "Color"
local kitTitleTxt = Instance.new("TextLabel", kitFrame); kitTitleTxt.Size = UDim2.new(1, 0, 0, 45); kitTitleTxt.BackgroundTransparency = 1; kitTitleTxt.Text = "KIT RENDER"; kitTitleTxt.TextColor3 = currentAccent; kitTitleTxt.Font = Enum.Font.GothamBlack; kitTitleTxt.TextSize = 18; accentObjects[kitTitleTxt] = "TextColor3"
local kitLineFrame = Instance.new("Frame", kitFrame); kitLineFrame.Size = UDim2.new(1, -30, 0, 1); kitLineFrame.Position = UDim2.new(0, 15, 0, 45); kitLineFrame.BackgroundColor3 = c_element; kitLineFrame.BorderSizePixel = 0
local kitScroll = Instance.new("ScrollingFrame", kitFrame); kitScroll.Size = UDim2.new(0.95, 0, 0.85, 0); kitScroll.Position = UDim2.new(0.025, 0, 0.12, 0); kitScroll.BackgroundTransparency = 1; kitScroll.ScrollBarThickness = 2; kitScroll.ScrollBarImageColor3 = currentAccent; kitScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; accentObjects[kitScroll] = "ScrollBarImageColor3"

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

-- ESP LOGIC
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
	if isPlayer then
		local root = obj:WaitForChild("HumanoidRootPart", 5)
		if not root then return end
	end
	local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
	if not targetPart and not isPlayer then return end
	local root = obj:FindFirstChild("HumanoidRootPart") or targetPart
	local col, typeStr, method = getESPConfig(obj)
	if isPlayer then method = "Player" end
	if not method or not root then return end

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

table.insert(connections, workspace.DescendantAdded:Connect(function(v) task.wait(0.1); if getESPConfig(v) then createESP(v, false) end end))
table.insert(connections, workspace.DescendantRemoving:Connect(function(v) removeESP(v) end))
for _, v in pairs(workspace:GetDescendants()) do if getESPConfig(v) then createESP(v, false) end end

local function onPlayerAdded(p) table.insert(connections, p.CharacterAdded:Connect(function(char) task.wait(0.5); createESP(char, true) end)); if p.Character then createESP(p.Character, true) end end
table.insert(connections, Players.PlayerAdded:Connect(onPlayerAdded))
for _, p in pairs(Players:GetPlayers()) do onPlayerAdded(p) end

-- ==========================================
-- KA LOGIC (PURE, AUTHENTIC HIT NO SPOOFING)
-- ==========================================
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
		task.wait(tonumber(toggles.KASpeed) or 0.1)
		
		local SwordHit = ReplicatedStorage:FindFirstChild("rbxts_include")
		if SwordHit then SwordHit = SwordHit.node_modules:FindFirstChild("@rbxts") end
		if SwordHit then SwordHit = SwordHit.net.out._NetManaged:FindFirstChild("SwordHit") end
		
		local char = localPlayer.Character
		local locHrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")
		
		if not toggles.KA or not char or not locHrp or not hum or hum.Health <= 0 then continue end
		
		local weaponList = ReplicatedStorage:FindFirstChild("Inventories") and ReplicatedStorage.Inventories:FindFirstChild(localPlayer.Name)
		local bestSword = nil
		
		if weaponList then
			local priorityWeapons = {"emerald_sword", "diamond_sword", "iron_sword", "stone_sword", "wood_sword", "rageblade", "emerald_dao", "diamond_dao", "iron_dao", "stone_dao", "wood_dao", "emerald_scythe", "diamond_scythe", "iron_scythe", "stone_scythe", "wood_scythe", "emerald_dagger", "diamond_dagger", "iron_dagger", "stone_dagger", "wood_dagger", "frosty_hammer"}
			for _, sName in ipairs(priorityWeapons) do
				local w = weaponList:FindFirstChild(sName)
				if w then bestSword = w; break end
			end
			if not bestSword then
				for _, w in ipairs(weaponList:GetChildren()) do
					local n = w.Name:lower()
					if n:find("sword") or n:find("blade") or n:find("dao") or n:find("scythe") or n:find("dagger") or n:find("hammer") then 
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
					if n:find("sword") or n:find("blade") or n:find("dao") or n:find("scythe") or n:find("dagger") or n:find("rageblade") or n:find("hammer") then
						isHoldingSword = true; break
					end
				end
			end
		end

		if not isHoldingSword then continue end
		if not bestSword then continue end

		local range = tonumber(toggles.KARange) or 28
		local maxAngle = (tonumber(toggles.KAAngle) or 360) / 2 
		
		local closestPlayer, pDist = nil, math.huge
		local closestNPC, nDist = nil, math.huge
		local closestDummy, dDist = nil, math.huge

		local function checkTargetGroup(groupList)
			local cTarget, cDist = nil, math.huge
			for _, model in ipairs(groupList) do
				if not model then continue end
				local targetHRP = model:FindFirstChild("HumanoidRootPart")
				if not targetHRP then targetHRP = model.PrimaryPart end
				if not targetHRP then targetHRP = model:FindFirstChildWhichIsA("BasePart") end
				
				if targetHRP and targetHRP:IsA("BasePart") then
					local dirVec = targetHRP.Position - locHrp.Position
					local dist = dirVec.Magnitude
					if dist <= range then
						local dotProduct = locHrp.CFrame.LookVector:Dot(dirVec.Unit)
						local angleToTarget = math.deg(math.acos(math.clamp(dotProduct, -1, 1)))
						if angleToTarget <= maxAngle then
							local isBlocked = false
							if toggles.KAWallCheck then
								local params = RaycastParams.new()
								params.FilterDescendantsInstances = {char, model}
								params.FilterType = Enum.RaycastFilterType.Exclude
								local hit = workspace:Raycast(locHrp.Position, dirVec, params)
								if hit then isBlocked = true end
							end
							if not isBlocked and dist < cDist then 
								cDist = dist
								cTarget = model 
							end
						end
					end
				end
			end
			return cTarget, cDist
		end
		
		local pList = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= localPlayer and p.Character then
				if p.Team and localPlayer.Team and p.Team == localPlayer.Team then continue end
				local phum = p.Character:FindFirstChildOfClass("Humanoid")
				if phum and phum.Health > 0 then table.insert(pList, p.Character) end
			end
		end
		
		local npcList, dummyList = {}, {}
		for _, npc in ipairs(cachedTargets) do
			if npc and npc.Parent then
				local nhum = npc:FindFirstChildOfClass("Humanoid")
				if nhum and nhum.Health > 0 then 
					if npc.Name:lower():find("dummy") then table.insert(dummyList, npc)
					else table.insert(npcList, npc) end
				end
			end
		end

		if toggles.KATargetPlayer then closestPlayer, pDist = checkTargetGroup(pList) end
		if toggles.KATargetNPC then closestNPC, nDist = checkTargetGroup(npcList) end
		if toggles.KATargetDummy then closestDummy, dDist = checkTargetGroup(dummyList) end
		
		local targetEnemy = nil
		local actualTargetDist = 0
		
		local allValid = {}
		if closestPlayer then table.insert(allValid, {m=closestPlayer, d=pDist, type="Player"}) end
		if closestNPC then table.insert(allValid, {m=closestNPC, d=nDist, type="NPC"}) end
		if closestDummy then table.insert(allValid, {m=closestDummy, d=dDist, type="Dummy"}) end
		
		if #allValid > 0 then
			table.sort(allValid, function(a,b) return (tonumber(a.d) or math.huge) < (tonumber(b.d) or math.huge) end)
			
			if toggles.KAPriority == "Distance" then
				targetEnemy = allValid[1].m
				actualTargetDist = tonumber(allValid[1].d) or 0
			else
				for _, v in ipairs(allValid) do
					if v.type == toggles.KAPriority then
						targetEnemy = v.m
						actualTargetDist = tonumber(v.d) or 0
						break
					end
				end
				if not targetEnemy then
					targetEnemy = allValid[1].m
					actualTargetDist = tonumber(allValid[1].d) or 0
				end
			end
		end

		sharedKATarget = targetEnemy

		if targetEnemy then
			local targetHRP = targetEnemy:FindFirstChild("HumanoidRootPart") or targetEnemy.PrimaryPart or targetEnemy:FindFirstChildWhichIsA("BasePart")
			if targetHRP and targetHRP:IsA("BasePart") then
				local p1 = locHrp.Position
				local p2 = targetHRP.Position
				local direction = (p2 - p1).Unit
				local safeDist = tonumber(actualTargetDist) or 0
				
				local reachOffset = safeDist - 14
				if type(reachOffset) ~= "number" then reachOffset = 0 end
				if reachOffset < 0 then reachOffset = 0 end
				if reachOffset > 14.4 then reachOffset = 14.4 end
				
				local fakePos = p1 + (direction * reachOffset)
				
				local args = {
					[1] = {
						["entityInstance"] = targetEnemy,
						["chargedAttack"] = { ["chargeRatio"] = 0 },
						["validate"] = {
							["targetPosition"] = { ["value"] = p2 },
							["raycast"] = { ["cursorDirection"] = { ["value"] = direction }, ["cameraPosition"] = { ["value"] = fakePos } },
							["selfPosition"] = { ["value"] = fakePos }
						},
						["weapon"] = bestSword
					}
				}
				
				task.spawn(function() 
					if SwordHit then pcall(function() fireRemote(SwordHit, unpack(args)) end) end
					if toggles.KASwingAnim then
						local sRange = tonumber(toggles.KASwingRange) or 43
						if safeDist <= sRange then
							local now = tick()
							local sSpeed = tonumber(toggles.KASwingSpeed) or 1.0
							if type(sSpeed) ~= "number" or sSpeed <= 0 then sSpeed = 1.0 end
							
							local animCooldown = 0.45 / sSpeed
							local lst = tonumber(lastSwingTime) or 0
							
							if (now - lst) >= animCooldown then
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
												loadedSwingAnim:AdjustSpeed(sSpeed)
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
-- NUKER LOGIC (SMART RAYCAST TARGETING)
-- ==========================================
local cachedNukerBlocks = {}
local nukerHighlight = Instance.new("Highlight")
nukerHighlight.Name = "NukerHighlight"; nukerHighlight.FillColor = Color3.fromRGB(255, 50, 50); nukerHighlight.OutlineColor = Color3.fromRGB(255, 200, 0); nukerHighlight.FillTransparency = 0.5; nukerHighlight.OutlineTransparency = 0.1; nukerHighlight.Parent = ui; nukerHighlight.Enabled = false

local nukerOreUI = Instance.new("BillboardGui")
nukerOreUI.Name = "NukerOreHP"; nukerOreUI.Size = UDim2.new(0, 100, 0, 12); nukerOreUI.StudsOffset = Vector3.new(0, 1.5, 0); nukerOreUI.AlwaysOnTop = true; nukerOreUI.Enabled = false; nukerOreUI.Parent = ui
local hpBg = Instance.new("Frame", nukerOreUI); hpBg.Size = UDim2.new(1, 0, 1, 0); hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25); hpBg.BorderSizePixel = 0; local hpC = Instance.new("UICorner", hpBg); hpC.CornerRadius = UDim.new(0, 4)
local hpFill = Instance.new("Frame", hpBg); hpFill.Size = UDim2.new(1, 0, 1, 0); hpFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129); hpFill.BorderSizePixel = 0; local hpFC = Instance.new("UICorner", hpFill); hpFC.CornerRadius = UDim.new(0, 4)
local hpTxt = Instance.new("TextLabel", hpBg); hpTxt.Size = UDim2.new(1, 0, 1, 0); hpTxt.BackgroundTransparency = 1; hpTxt.Font = Enum.Font.GothamBold; hpTxt.TextSize = 10; hpTxt.TextColor3 = Color3.fromRGB(255, 255, 255); hpTxt.TextStrokeTransparency = 0.5

task.spawn(function()
	while isRunning do
		task.wait(0.25) 
		local blocks = {}
		local searchArea = workspace:FindFirstChild("Map") or workspace
		for _, obj in ipairs(searchArea:GetDescendants()) do
			if obj:IsA("BasePart") then
				local n = obj.Name:lower()
				local pN = obj.Parent and obj.Parent.Name:lower() or ""
				
				if (n:find("bed") or pN:find("bed")) and not n:find("bedrock") and not pN:find("bedrock") then 
					table.insert(blocks, obj)
				elseif n:find("iron_ore") then 
					table.insert(blocks, obj) 
				end
			end
		end
		cachedNukerBlocks = blocks
	end
end)

local function getBlockHp(block)
	if not block then return nil, nil end
	local hp = block:GetAttribute("Health") or block:GetAttribute("blockHealth") or block:GetAttribute("health") or block:GetAttribute("block.Health")
	local maxHp = block:GetAttribute("MaxHealth") or block:GetAttribute("blockMaxHealth") or block:GetAttribute("maxHealth") or block:GetAttribute("block.MaxHealth")
	
	if not hp and block.Parent then
		hp = block.Parent:GetAttribute("Health") or block.Parent:GetAttribute("blockHealth") or block.Parent:GetAttribute("health") or block.Parent:GetAttribute("block.Health")
		maxHp = block.Parent:GetAttribute("MaxHealth") or block.Parent:GetAttribute("blockMaxHealth") or block.Parent:GetAttribute("maxHealth") or block.Parent:GetAttribute("block.MaxHealth")
	end
	return hp, maxHp
end

task.spawn(function()
	while isRunning do
		task.wait(tonumber(toggles.NukerTimer) or 0.1)
		
		local char = localPlayer.Character
		local locHrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if not toggles.Nuker or not char or not locHrp or not hum or hum.Health <= 0 then 
			nukerHighlight.Enabled = false; nukerOreUI.Enabled = false
			continue 
		end

		local myInv = ReplicatedStorage:FindFirstChild("Inventories") and ReplicatedStorage.Inventories:FindFirstChild(localPlayer.Name)
		if not myInv then continue end

		local currentEquipped = nil
		for _, item in ipairs(char:GetChildren()) do
			if item:IsA("Model") or item:IsA("Tool") or item:IsA("Accessory") then
				if myInv:FindFirstChild(item.Name) then
					currentEquipped = myInv:FindFirstChild(item.Name)
					break
				end
			end
		end

		if toggles.NukerReqPickaxe or toggles.NukerReqAxe or toggles.NukerReqShears then
			local hasRequired = false
			if toggles.NukerReqPickaxe and (myInv:FindFirstChild("wood_pickaxe") or myInv:FindFirstChild("stone_pickaxe") or myInv:FindFirstChild("iron_pickaxe") or myInv:FindFirstChild("diamond_pickaxe")) then hasRequired = true end
			if toggles.NukerReqAxe and (myInv:FindFirstChild("wood_axe") or myInv:FindFirstChild("stone_axe") or myInv:FindFirstChild("iron_axe") or myInv:FindFirstChild("diamond_axe")) then hasRequired = true end
			if toggles.NukerReqShears and myInv:FindFirstChild("shears") then hasRequired = true end
			
			if not hasRequired then 
				nukerHighlight.Enabled = false; nukerOreUI.Enabled = false; continue 
			end
		end

		local closestBed, closestBedDist = nil, 25
		local closestOre, closestOreDist = nil, 25
		local myTeamColor = localPlayer.Team and localPlayer.Team.TeamColor
		
		for _, obj in ipairs(cachedNukerBlocks) do
			if obj and obj.Parent then
				local n = obj.Name:lower()
				local pN = obj.Parent.Name:lower()
				local dist = (obj.Position - locHrp.Position).Magnitude
				
				if toggles.NukerBed and (n:find("bed") or pN:find("bed")) and not n:find("bedrock") and not pN:find("bedrock") then
					local isMyBed = false
					if myTeamColor then
						local blanket = obj:FindFirstChild("Blanket") or obj:FindFirstChild("blanket")
						if not blanket and obj.Parent then
							blanket = obj.Parent:FindFirstChild("Blanket") or obj.Parent:FindFirstChild("blanket")
						end
						if blanket and blanket:IsA("BasePart") and blanket.BrickColor == myTeamColor then
							isMyBed = true
						end
					end
					
					if not isMyBed and dist < closestBedDist then 
						closestBedDist = dist; closestBed = obj 
					end
				elseif toggles.NukerOre and n:find("iron_ore") then
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
		
		local lockedNukerBlock = nil
		
		if rawTarget then
			local exposed = false
			local protector = nil
			
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			local excludeList = {char, cam}
			for _, p in ipairs(Players:GetPlayers()) do if p.Character then table.insert(excludeList, p.Character) end end
			if workspace:FindFirstChild("ItemDrops") then table.insert(excludeList, workspace.ItemDrops) end
			
			local startPos = cam.CFrame.Position
			local dir = rawTarget.Position - startPos
			local maxDist = dir.Magnitude + 2
			local curPos = startPos
			local rayDir = dir.Unit
			
			for i = 1, 10 do
				params.FilterDescendantsInstances = excludeList
				local hit = workspace:Raycast(curPos, rayDir * maxDist, params)
				
				if hit and hit.Instance then
					local hitN = hit.Instance.Name:lower()
					local pN = hit.Instance.Parent and hit.Instance.Parent.Name:lower() or ""
					
					if hit.Instance == rawTarget or hit.Instance.Parent == rawTarget.Parent or hitN:find("bed") or pN:find("bed") or hitN:find("iron_ore") then
						exposed = true
						break
					elseif hit.Instance.CanCollide and hit.Instance.Transparency < 1 then
						protector = hit.Instance
						break
					else
						table.insert(excludeList, hit.Instance)
						curPos = hit.Position + (rayDir * 0.01)
						maxDist = maxDist - (hit.Position - curPos).Magnitude
					end
				else
					exposed = true
					break
				end
			end
			
			lockedNukerBlock = protector or rawTarget
		end
		
		if lockedNukerBlock then
			if toggles.NukerHighlight then nukerHighlight.Adornee = lockedNukerBlock; nukerHighlight.Enabled = true else nukerHighlight.Enabled = false end
			
			local hp, maxHp = getBlockHp(lockedNukerBlock)
			if type(hp) == "number" and type(maxHp) == "number" and maxHp > 0 then
				nukerOreUI.Adornee = lockedNukerBlock
				nukerOreUI.Enabled = true
				local pct = math.clamp(hp / maxHp, 0, 1)
				hpFill.Size = UDim2.new(pct, 0, 1, 0)
				hpTxt.Text = math.floor(hp) .. " / " .. math.floor(maxHp)
				if pct > 0.5 then hpFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
				elseif pct > 0.25 then hpFill.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
				else hpFill.BackgroundColor3 = Color3.fromRGB(239, 68, 68) end
			else
				nukerOreUI.Adornee = lockedNukerBlock
				nukerOreUI.Enabled = true
				hpFill.Size = UDim2.new(1, 0, 1, 0)
				hpFill.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
				hpTxt.Text = "MINING"
			end
			
			local DamageBlock = getDamageBlockRemote()
			if DamageBlock then
				local function smash(targetPart)
					if not targetPart then return end
					
					local toolType = "pickaxe"
					local n = targetPart.Name:lower()
					local pN = targetPart.Parent and targetPart.Parent.Name:lower() or ""
					
					if n:find("wood") or n:find("plank") or n:find("bed") or pN:find("bed") then toolType = "axe" end
					if n:find("wool") then toolType = "shears" end
					
					local bestTool = nil
					if toolType == "pickaxe" then bestTool = myInv:FindFirstChild("diamond_pickaxe") or myInv:FindFirstChild("iron_pickaxe") or myInv:FindFirstChild("stone_pickaxe") or myInv:FindFirstChild("wood_pickaxe")
					elseif toolType == "axe" then bestTool = myInv:FindFirstChild("diamond_axe") or myInv:FindFirstChild("iron_axe") or myInv:FindFirstChild("stone_axe") or myInv:FindFirstChild("wood_axe")
					elseif toolType == "shears" then bestTool = myInv:FindFirstChild("shears") end
					
					if toggles.NukerReqPickaxe and not myInv:FindFirstChild("wood_pickaxe") and not myInv:FindFirstChild("stone_pickaxe") and not myInv:FindFirstChild("iron_pickaxe") and not myInv:FindFirstChild("diamond_pickaxe") then return end
					if toggles.NukerReqAxe and not myInv:FindFirstChild("wood_axe") and not myInv:FindFirstChild("stone_axe") and not myInv:FindFirstChild("iron_axe") and not myInv:FindFirstChild("diamond_axe") then return end
					if toggles.NukerReqShears and not myInv:FindFirstChild("shears") then return end

					local net = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged
					local equipRemote = net and net:FindFirstChild("SetInvItem")
					
					if bestTool and equipRemote then 
						pcall(function() equipRemote:FireServer({["item"] = bestTool}) end) 
					end

					local gridX = math.round(targetPart.Position.X / 3)
					local gridY = math.round(targetPart.Position.Y / 3)
					local gridZ = math.round(targetPart.Position.Z / 3)
					local blockData = { ["blockRef"] = { ["blockPosition"] = Vector3.new(gridX, gridY, gridZ) }, ["hitPosition"] = targetPart.Position, ["hitNormal"] = Vector3.new(0, 1, 0) }
					
					task.spawn(function() 
						pcall(function() DamageBlock:FireServer(blockData) end)
					end)
					
					if currentEquipped and bestTool and currentEquipped ~= bestTool and equipRemote then
						pcall(function() equipRemote:FireServer({["item"] = currentEquipped}) end) 
					end
				end
				smash(lockedNukerBlock)
			end
		else
			nukerHighlight.Enabled = false
			nukerOreUI.Enabled = false
		end
	end
end)

-- ==========================================
-- FAST BREAK LOGIC
-- ==========================================
task.spawn(function()
	local mouse = localPlayer:GetMouse()
	while isRunning do
		task.wait(tonumber(toggles.FastBreakTimer) or 0.05)
		local char = localPlayer.Character
		local hum = char and char:FindFirstChild("Humanoid")
		if toggles.FastBreak and char and hum and hum.Health > 0 and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
			local target = mouse.Target
			if target and target:IsA("BasePart") and not target.Parent:FindFirstChild("Humanoid") then
				pcall(function()
					local DamageBlock = getDamageBlockRemote()
					if DamageBlock then
						local myInv = ReplicatedStorage:FindFirstChild("Inventories") and ReplicatedStorage.Inventories:FindFirstChild(localPlayer.Name)
						local currentEquipped = nil
						for _, item in ipairs(char:GetChildren()) do
							if (item:IsA("Model") or item:IsA("Tool") or item:IsA("Accessory")) and myInv and myInv:FindFirstChild(item.Name) then
								currentEquipped = myInv[item.Name]
								break
							end
						end

						local toolType = "pickaxe"
						local n = target.Name:lower()
						if n:find("wood") or n:find("plank") or n:find("bed") then toolType = "axe" end
						if n:find("wool") then toolType = "shears" end
						
						local bestTool = nil
						if myInv then
							if toolType == "pickaxe" then bestTool = myInv:FindFirstChild("diamond_pickaxe") or myInv:FindFirstChild("iron_pickaxe") or myInv:FindFirstChild("stone_pickaxe") or myInv:FindFirstChild("wood_pickaxe")
							elseif toolType == "axe" then bestTool = myInv:FindFirstChild("diamond_axe") or myInv:FindFirstChild("iron_axe") or myInv:FindFirstChild("stone_axe") or myInv:FindFirstChild("wood_axe")
							elseif toolType == "shears" then bestTool = myInv:FindFirstChild("shears") end
						end
						
						local net = ReplicatedStorage.rbxts_include.node_modules["@rbxts"].net.out._NetManaged
						local equipRemote = net and net:FindFirstChild("SetInvItem")
						
						if bestTool and equipRemote then 
							pcall(function() equipRemote:FireServer({["item"] = bestTool}) end) 
						end

						local gridX = math.round(target.Position.X / 3)
						local gridY = math.round(target.Position.Y / 3)
						local gridZ = math.round(target.Position.Z / 3)
						local blockData = { ["blockRef"] = { ["blockPosition"] = Vector3.new(gridX, gridY, gridZ) }, ["hitPosition"] = mouse.Hit.Position, ["hitNormal"] = Vector3.new(0, 1, 0) }
						
						task.spawn(function()
							pcall(function() DamageBlock:FireServer(blockData) end)
						end)
						
						if currentEquipped and bestTool and currentEquipped ~= bestTool and equipRemote then
							pcall(function() equipRemote:FireServer({["item"] = currentEquipped}) end) 
						end
					end
				end)
			end
		end
	end
end)

-- ==========================================
-- AUTO BUY ARMOR FEATURE
-- ==========================================
task.spawn(function()
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

			local purchaseRemote = getPurchaseRemote()
			local equipRemote = getEquipRemote()

			if buyArgs and purchaseRemote then
				local s = pcall(function() fireRemote(purchaseRemote, unpack(buyArgs)) end)
				if s and equipRemote then
					task.wait(0.2)
					local h = inv:FindFirstChild(prefix .. "_helmet")
					local c = inv:FindFirstChild(prefix .. "_chestplate")
					local b = inv:FindFirstChild(prefix .. "_boots")
					if h then pcall(function() fireRemote(equipRemote, { item = h, armorSlot = 0 }) end) end
					if c then pcall(function() fireRemote(equipRemote, { item = c, armorSlot = 1 }) end) end
					if b then pcall(function() fireRemote(equipRemote, { item = b, armorSlot = 2 }) end) end
				end
			end
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
									task.spawn(function() pcall(function() fireRemote(pickupRemote, { ["itemDrop"] = drop }) end) end)
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
