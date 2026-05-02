-- UserID Lock
if game.Players.LocalPlayer.UserId ~= 2817715599 then 
    return 
end

local localPlayer = game.Players.LocalPlayer
local playerGUI = localPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

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

-- THEME COLORS (Gold & Black)
local c_bg = Color3.fromRGB(15, 15, 15)
local c_bg2 = Color3.fromRGB(22, 22, 22)
local c_bg3 = Color3.fromRGB(30, 30, 30)
local c_gold = Color3.fromRGB(255, 215, 0)
local c_goldDark = Color3.fromRGB(180, 150, 0)
local c_text = Color3.fromRGB(220, 220, 220)
local c_textDim = Color3.fromRGB(130, 130, 130)

local tracked = {}
local toggles = {
	["BeeESP"] = false, ["MetalESP"] = false, ["StarESP"] = false, ["BoxESP"] = false,
	["ShowName"] = false, ["ShowTeam"] = false, ["ShowKit"] = false, 
	["DevMode"] = false, ["KitRender"] = false, ["FarmESP"] = false, 
	["BeehiveESP"] = false, ["TaliyahESP"] = false, ["BedESP"] = false
}
local hotkeys = {}
local uiUpdaters = {}
local boxTargetMode = "All"
local farmFilter = "Everything"
local expandedTeams = {}
local uiVisible = true
local connections = {}
local currentBindName = nil
local currentBindBtn = nil

-- CONFIG SYSTEM
local function saveConfig()
	local cfg = { t = toggles, h = {}, btm = boxTargetMode, ff = farmFilter }
	for k, v in pairs(hotkeys) do cfg.h[k] = v.Name end
	if type(writefile) == "function" then
		pcall(function() writefile("feenware_cfg.json", HttpService:JSONEncode(cfg)) end)
	end
end

local function loadConfig()
	if type(readfile) == "function" and type(isfile) == "function" and isfile("feenware_cfg.json") then
		local s, res = pcall(function() return HttpService:JSONDecode(readfile("feenware_cfg.json")) end)
		if s and type(res) == "table" then
			if res.t then for k, v in pairs(res.t) do toggles[k] = v end end
			if res.h then for k, v in pairs(res.h) do pcall(function() hotkeys[k] = Enum.KeyCode[v] end) end end
			if res.btm then boxTargetMode = res.btm end
			if res.ff then farmFilter = res.ff end
		end
	end
end

local function addUICorner(val, parent)
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, val); c.Parent = parent
end

local function makeDraggable(frame, handle)
	local dragging, dragStart, startPos
	table.insert(connections, handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = input.Position startPos = frame.Position end
	end))
	table.insert(connections, UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end))
	table.insert(connections, UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end))
end

-- GUI Setup
local zenWareGUI = Instance.new("ScreenGui", playerGUI); zenWareGUI.Name = "FEENWARE_MAIN"; zenWareGUI.ResetOnSpawn = false 

-- NOTIFICATION SYSTEM
local notifContainer = Instance.new("Frame", zenWareGUI); notifContainer.Size = UDim2.new(0, 220, 1, -50); notifContainer.Position = UDim2.new(1, -230, 0, 0); notifContainer.BackgroundTransparency = 1
local notifLayout = Instance.new("UIListLayout", notifContainer); notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom; notifLayout.Padding = UDim.new(0, 8)

local function notify(title, state)
	local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 45); f.BackgroundColor3 = c_bg2; f.BackgroundTransparency = 1; addUICorner(6, f)
	local s = Instance.new("UIStroke", f); s.Color = state and c_gold or Color3.fromRGB(80, 80, 80); s.Transparency = 1
	local line = Instance.new("Frame", f); line.Size = UDim2.new(0, 4, 1, 0); line.BackgroundColor3 = state and c_gold or Color3.fromRGB(80, 80, 80); line.BorderSizePixel = 0; line.BackgroundTransparency = 1; addUICorner(6, line)
	local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1, -15, 1, 0); t.Position = UDim2.new(0, 10, 0, 0); t.BackgroundTransparency = 1; t.TextXAlignment = Enum.TextXAlignment.Left; t.Font = Enum.Font.GothamBold; t.TextSize = 14
	t.Text = title .. (state and " Enabled" or " Disabled"); t.TextColor3 = c_text; t.TextTransparency = 1
	f.Parent = notifContainer
	
	TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
	TweenService:Create(s, TweenInfo.new(0.3), {Transparency = 0}):Play()
	TweenService:Create(line, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
	TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
	
	task.delay(2.5, function()
		TweenService:Create(f, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
		TweenService:Create(s, TweenInfo.new(0.3), {Transparency = 1}):Play()
		TweenService:Create(line, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
		TweenService:Create(t, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		task.wait(0.3); f:Destroy()
	end)
end

-- MAIN UI
local mainUI = Instance.new("Frame", zenWareGUI); mainUI.Size = UDim2.new(0, 300, 0, 620); mainUI.Position = UDim2.new(0.05, 0, 0.15, 0); mainUI.BackgroundColor3 = c_bg; addUICorner(8, mainUI)
local titleFrame = Instance.new("Frame", mainUI); titleFrame.Size = UDim2.new(1, 0, 0, 50); titleFrame.BackgroundColor3 = c_bg2; addUICorner(8, titleFrame); makeDraggable(mainUI, titleFrame)
local titleText = Instance.new("TextLabel", titleFrame); titleText.Size = UDim2.new(1, 0, 1, 0); titleText.Text = "FEENWARE"; titleText.TextColor3 = c_gold; titleText.Font = Enum.Font.GothamBlack; titleText.TextSize = 22; titleText.BackgroundTransparency = 1
local titleLine = Instance.new("Frame", titleFrame); titleLine.Size = UDim2.new(1, 0, 0, 2); titleLine.Position = UDim2.new(0, 0, 1, -2); titleLine.BackgroundColor3 = c_gold; titleLine.BorderSizePixel = 0

local scroll = Instance.new("ScrollingFrame", mainUI); scroll.Size = UDim2.new(1, 0, 1, -60); scroll.Position = UDim2.new(0, 0, 0, 55); scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = c_gold; scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local listLayout = Instance.new("UIListLayout", scroll); listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; listLayout.Padding = UDim.new(0, 6); listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- UI Helper Functions
local function createSection(title)
	local f = Instance.new("Frame", scroll); f.Size = UDim2.new(0.9, 0, 0, 25); f.BackgroundTransparency = 1
	local t = Instance.new("TextLabel", f); t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1; t.Text = " " .. title; t.TextColor3 = c_goldDark; t.Font = Enum.Font.GothamBold; t.TextSize = 12; t.TextXAlignment = Enum.TextXAlignment.Left
	return f
end

local function applyGoldTheme(btn, state, textPrefix, mainBtn)
	local target = mainBtn or btn
	target.Text = textPrefix .. (state and " [ON]" or " [OFF]")
	target.TextColor3 = state and c_bg or c_text
	target.BackgroundColor3 = state and c_gold or c_bg3
	local stroke = target:FindFirstChildOfClass("UIStroke")
	if stroke then stroke.Color = state and c_gold or Color3.fromRGB(50, 50, 50) end
end

local function attachKeybind(parentFrame, toggleName)
	local kb = Instance.new("TextButton", parentFrame); kb.Size = UDim2.new(0, 35, 1, -12); kb.Position = UDim2.new(1, -40, 0, 6); kb.BackgroundColor3 = c_bg; kb.TextColor3 = c_textDim; kb.Font = Enum.Font.Gotham; kb.TextSize = 11; addUICorner(4, kb)
	local s = Instance.new("UIStroke", kb); s.Color = Color3.fromRGB(50,50,50)
	
	local function updateKbText() kb.Text = hotkeys[toggleName] and hotkeys[toggleName].Name or "[+]" end
	uiUpdaters[toggleName.."_kb"] = updateKbText
	
	kb.Activated:Connect(function()
		currentBindName = toggleName; currentBindBtn = kb; kb.Text = "..."
	end)
end

local function createToggleBtn(id, title, p)
	local container = Instance.new("Frame", p); container.Size = UDim2.new(0.9, 0, 0, 38); container.BackgroundTransparency = 1
	local b = Instance.new("TextButton", container); b.Size = UDim2.new(1, 0, 1, 0); b.BackgroundColor3 = c_bg3; b.TextColor3 = c_text; b.Text = title; b.Font = Enum.Font.GothamSemibold; b.TextSize = 14; addUICorner(6, b)
	local stroke = Instance.new("UIStroke", b); stroke.Color = Color3.fromRGB(50, 50, 50); stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	attachKeybind(b, id)
	
	local function update() applyGoldTheme(b, toggles[id], title) end
	uiUpdaters[id] = update
	
	b.Activated:Connect(function() 
		toggles[id] = not toggles[id]; update(); notify(title, toggles[id]); saveConfig()
	end)
	return b
end

local function createExpandableBtn(id, title, p)
	local container = Instance.new("Frame", p); container.Size = UDim2.new(0.9, 0, 0, 38); container.BackgroundTransparency = 1
	local row = Instance.new("Frame", container); row.Size = UDim2.new(1, 0, 0, 38); row.BackgroundTransparency = 1
	local mainBtn = Instance.new("TextButton", row); mainBtn.Size = UDim2.new(0.82, -5, 1, 0); mainBtn.BackgroundColor3 = c_bg3; mainBtn.TextColor3 = c_text; mainBtn.Font = Enum.Font.GothamSemibold; mainBtn.TextSize = 14; mainBtn.Text = title; addUICorner(6, mainBtn)
	local s1 = Instance.new("UIStroke", mainBtn); s1.Color = Color3.fromRGB(50, 50, 50)
	attachKeybind(mainBtn, id)
	
	local gearBtn = Instance.new("TextButton", row); gearBtn.Size = UDim2.new(0.18, 0, 1, 0); gearBtn.Position = UDim2.new(0.82, 5, 0, 0); gearBtn.BackgroundColor3 = c_bg2; gearBtn.Text = "▼"; gearBtn.TextColor3 = c_gold; gearBtn.Font = Enum.Font.GothamBold; gearBtn.TextSize = 14; addUICorner(6, gearBtn)
	local s2 = Instance.new("UIStroke", gearBtn); s2.Color = Color3.fromRGB(60, 60, 60)
	
	local subCont = Instance.new("Frame", container); subCont.Size = UDim2.new(1, 0, 0, 0); subCont.Position = UDim2.new(0, 0, 0, 44); subCont.Visible = false; subCont.BackgroundTransparency = 1; local subList = Instance.new("UIListLayout", subCont); subList.Padding = UDim.new(0, 4)
	gearBtn.Activated:Connect(function() 
		subCont.Visible = not subCont.Visible; gearBtn.Text = subCont.Visible and "▲" or "▼"
		container.Size = subCont.Visible and UDim2.new(0.9, 0, 0, 44 + subList.AbsoluteContentSize.Y) or UDim2.new(0.9, 0, 0, 38) 
	end)
	
	local function update() applyGoldTheme(nil, toggles[id], title, mainBtn) end
	uiUpdaters[id] = update
	mainBtn.Activated:Connect(function() toggles[id] = not toggles[id]; update(); notify(title, toggles[id]); saveConfig() end)
	
	return mainBtn, subCont
end

local function createSubBtn(id, title, p, isToggle)
	local b = Instance.new("TextButton", p); b.Size = UDim2.new(1, 0, 0, 30); b.BackgroundColor3 = c_bg2; b.TextColor3 = c_textDim; b.Text = title; b.Font = Enum.Font.Gotham; b.TextSize = 13; addUICorner(4, b)
	if isToggle then
		local function update() b.Text = title .. (toggles[id] and " [ON]" or " [OFF]"); b.TextColor3 = toggles[id] and c_gold or c_textDim end
		uiUpdaters[id] = update
		b.Activated:Connect(function() toggles[id] = not toggles[id]; update(); saveConfig() end)
	end
	return b
end

-- ESP Logic
local function getESPConfig(obj)
	if not obj or not obj.Name then return nil end
	local name = obj.Name:lower()
	if name:find("melon") then return Color3.fromRGB(0, 255, 0), "Melon", "Farm" end
	if name:find("carrot") then return Color3.fromRGB(255, 255, 0), "Carrot", "Farm" end
	if name:find("pumpkin") then return Color3.fromRGB(255, 128, 0), "Pumpkin", "Farm" end
	if name:find("beehive") then return Color3.fromRGB(255, 200, 0), "Beehive", "Farm" end
	if name:find("chicken_egg_block") then return Color3.fromRGB(255, 170, 255), "Taliyah", "Farm" end
	if name:find("bed") and not name:find("bedrock") then return Color3.fromRGB(255, 50, 50), "Bed", "Farm" end
	if name:find("bee") and not name:find("beehive") then return Color3.new(1, 1, 0), "Bee", "Billboard" end
	if name:find("metal") or obj:FindFirstChild("hidden-metal-prompt") then return Color3.new(0, 1, 1), "Metal", "Billboard" end
	if name:find("star") then
		if name:find("health") or name:find("vitality") then return Color3.new(0, 1, 0), "Health Star", "Billboard"
		else return Color3.new(1, 0.5, 0), "Crit Star", "Billboard" end
	end
	return nil
end

local function removeESP(obj)
	if tracked[obj] then
		if tracked[obj].gui then tracked[obj].gui:Destroy() end
		if tracked[obj].info then tracked[obj].info:Destroy() end
		if tracked[obj].highlight then tracked[obj].highlight:Destroy() end
		tracked[obj] = nil
	end
end

local function createESP(obj, isPlayer)
	if tracked[obj] then return end
	local targetPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
	if not targetPart and not isPlayer then return end
	local hrp = obj:FindFirstChild("HumanoidRootPart") or targetPart
	local col, typeStr, method = getESPConfig(obj)
	if isPlayer then method = "Billboard" end
	if not method then return end

	if method == "Farm" then
		local hl = Instance.new("Highlight", targetPart); hl.Name = "ZenHL"; hl.FillColor = col; hl.FillTransparency = 0.5; hl.OutlineColor = col; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Enabled = false
		local marker = Instance.new("BillboardGui", targetPart); marker.Name = "ZenMarker"; marker.AlwaysOnTop = true; marker.Size = UDim2.fromOffset(180, 35); marker.StudsOffset = Vector3.new(0, 5, 0); marker.Enabled = false
		local markerTxt = Instance.new("TextLabel", marker); markerTxt.Size = UDim2.fromScale(1, 1); markerTxt.BackgroundTransparency = 1; markerTxt.TextColor3 = col; markerTxt.TextStrokeTransparency = 0.5; markerTxt.Font = Enum.Font.GothamBold; markerTxt.TextSize = 16
		tracked[obj] = { isFarm = true, highlight = hl, info = marker, textLabel = markerTxt, espType = typeStr, part = targetPart }
	elseif method == "Billboard" then
		local info = Instance.new("BillboardGui", hrp); info.Name = "ZenMarker"; info.AlwaysOnTop = true; info.Size = UDim2.fromOffset(250, 100); info.StudsOffset = Vector3.new(0, 7.5, 0); info.Enabled = false
		local tl = Instance.new("TextLabel", info); tl.Size = UDim2.fromScale(1, 1); tl.BackgroundTransparency = 1; tl.Font = Enum.Font.GothamBold; tl.TextSize = 16; tl.TextStrokeTransparency = 0.5; tl.TextYAlignment = Enum.TextYAlignment.Bottom
        if isPlayer then
			local b = Instance.new("BillboardGui", hrp); b.Name = "ZenBox"; b.AlwaysOnTop = true; b.Size = UDim2.fromScale(4.5, 6.5); b.Enabled = false
			local f = Instance.new("Frame", b); f.Size = UDim2.fromScale(1,1); f.BackgroundTransparency = 1; local s = Instance.new("UIStroke", f); s.Thickness = 2
			tracked[obj] = { isPlayer = true, gui = b, info = info, textLabel = tl, stroke = s, player = Players:GetPlayerFromCharacter(obj), part = hrp }
		else
			tl.TextColor3 = col; tracked[obj] = { isPlayer = false, info = info, textLabel = tl, espType = typeStr, part = targetPart }
		end
	end
end

-- Event Based Tracking
table.insert(connections, workspace.DescendantAdded:Connect(function(v)
	task.wait(0.1); if getESPConfig(v) then createESP(v, false) end
end))
table.insert(connections, workspace.DescendantRemoving:Connect(function(v) removeESP(v) end))

local function onPlayerAdded(p)
	table.insert(connections, p.CharacterAdded:Connect(function(char) task.wait(0.5); createESP(char, true) end))
	if p.Character then createESP(p.Character, true) end
end
table.insert(connections, Players.PlayerAdded:Connect(onPlayerAdded))
for _, p in pairs(Players:GetPlayers()) do onPlayerAdded(p) end
for _, v in pairs(workspace:GetDescendants()) do if getESPConfig(v) then createESP(v, false) end end

-- KIT RENDER PANEL 2.0 (Polished Gold Theme)
local kitFrame = Instance.new("Frame", zenWareGUI); kitFrame.Size = UDim2.new(0, 380, 0, 520); kitFrame.Position = UDim2.new(0.35, 0, 0.2, 0); kitFrame.BackgroundColor3 = c_bg; kitFrame.Visible = false; addUICorner(10, kitFrame); makeDraggable(kitFrame, kitFrame)
local kitStroke = Instance.new("UIStroke", kitFrame); kitStroke.Color = c_goldDark; kitStroke.Thickness = 1
local kitTitle = Instance.new("TextLabel", kitFrame); kitTitle.Size = UDim2.new(1, 0, 0, 45); kitTitle.BackgroundTransparency = 1; kitTitle.Text = "KIT RENDER"; kitTitle.TextColor3 = c_gold; kitTitle.Font = Enum.Font.GothamBlack; kitTitle.TextSize = 20
local kitLine = Instance.new("Frame", kitFrame); kitLine.Size = UDim2.new(1, -30, 0, 1); kitLine.Position = UDim2.new(0, 15, 0, 45); kitLine.BackgroundColor3 = Color3.fromRGB(50,50,50); kitLine.BorderSizePixel = 0
local kitScroll = Instance.new("ScrollingFrame", kitFrame); kitScroll.Size = UDim2.new(0.95, 0, 1, -60); kitScroll.Position = UDim2.new(0.025, 0, 0, 55); kitScroll.BackgroundTransparency = 1; kitScroll.ScrollBarThickness = 2; kitScroll.ScrollBarImageColor3 = c_gold; kitScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local function updateRender()
	kitScroll:ClearAllChildren(); local layout = Instance.new("UIListLayout", kitScroll); layout.Padding = UDim.new(0, 6)
	for _, team in pairs(Teams:GetTeams()) do
		local pList = team:GetPlayers()
		if #pList > 0 then
			local tCol = team.TeamColor.Color
			local header = Instance.new("TextButton", kitScroll); header.Size = UDim2.new(1, 0, 0, 30); header.BackgroundColor3 = c_bg2; header.Text = ""; addUICorner(6, header)
			local hTxt = Instance.new("TextLabel", header); hTxt.Size = UDim2.new(1, -35, 1, 0); hTxt.Position = UDim2.new(0, 35, 0, 0); hTxt.BackgroundTransparency = 1; hTxt.Text = team.Name:upper(); hTxt.TextColor3 = tCol; hTxt.Font = Enum.Font.GothamBold; hTxt.TextSize = 13; hTxt.TextXAlignment = Enum.TextXAlignment.Left
			local arrow = Instance.new("TextLabel", header); arrow.Size = UDim2.new(0, 30, 1, 0); arrow.BackgroundTransparency = 1; arrow.Text = expandedTeams[team.Name] and "▼" or "▶"; arrow.TextColor3 = tCol; arrow.Font = Enum.Font.GothamBold; arrow.TextSize = 14
			
			header.Activated:Connect(function() expandedTeams[team.Name] = not expandedTeams[team.Name]; updateRender() end)
			
			if expandedTeams[team.Name] then
				for _, p in pairs(pList) do
					local r = Instance.new("Frame", kitScroll); r.Size = UDim2.new(1, 0, 0, 50); r.BackgroundColor3 = Color3.fromRGB(20, 20, 20); addUICorner(6, r)
					local img = Instance.new("ImageLabel", r); img.Size = UDim2.new(0, 40, 0, 40); img.Position = UDim2.new(0, 5, 0.5, -20); img.BackgroundColor3 = c_bg3; img.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48); addUICorner(20, img)
					local t = Instance.new("TextLabel", r); t.Size = UDim2.new(0.8, 0, 1, 0); t.Position = UDim2.new(0, 55, 0, 0); t.BackgroundTransparency = 1; t.TextColor3 = Color3.new(1,1,1); t.Font = Enum.Font.GothamSemibold; t.TextSize = 14; t.TextXAlignment = Enum.TextXAlignment.Left
					local rK = tostring(p:GetAttribute("PlayingAsKits") or "None"):upper(); t.Text = p.DisplayName .. "\nKit: " .. (kitTranslations[rK] or rK)
				end
			end
		end
	end
end

-- Main Loop
table.insert(connections, RunService.Heartbeat:Connect(function()
	local camPos = workspace.CurrentCamera.CFrame.Position
	for obj, data in pairs(tracked) do
		if obj and obj.Parent then
			if data.isFarm then
				local act = false
				if data.espType == "Beehive" and toggles["BeehiveESP"] then 
					act = true; data.textLabel.Text = tostring(obj:GetAttribute("Level") or 0) .. " Bees"
				elseif data.espType == "Taliyah" and toggles["TaliyahESP"] then
					act = true; data.textLabel.Text = "EGG"
				elseif data.espType == "Bed" and toggles["BedESP"] then
					act = true; data.textLabel.Text = "[BED]"
				elseif toggles["FarmESP"] and data.espType ~= "Beehive" and data.espType ~= "Taliyah" and data.espType ~= "Bed" then 
					if farmFilter == "Everything" or farmFilter:find(data.espType) then 
						act = true; data.textLabel.Text = "[" .. data.espType:upper() .. "]"
					end 
				end
				data.highlight.Enabled = act; data.info.Enabled = act
			elseif data.isPlayer then
				local act = toggles["BoxESP"]
				if data.player == localPlayer and not toggles["DevMode"] then act = false 
				else
					local isTeammate = (data.player.Team == localPlayer.Team)
					if boxTargetMode == "Enemy" and isTeammate then act = false end
					if boxTargetMode == "Teams" and not isTeammate then act = false end
				end
				data.gui.Enabled = act; data.info.Enabled = act
				if act then
					data.stroke.Color = data.player.TeamColor.Color; data.textLabel.TextColor3 = data.player.TeamColor.Color
					local l = {}
					if toggles["ShowName"] then table.insert(l, data.player.DisplayName) end
					if toggles["ShowTeam"] then table.insert(l, data.player.Team and data.player.Team.Name or "Neutral") end
					if toggles["ShowKit"] then local rK = tostring(data.player:GetAttribute("PlayingAsKits") or "None"):upper(); table.insert(l, "["..(kitTranslations[rK] or rK).."]") end
					data.textLabel.Text = table.concat(l, "\n")
				end
			else
				local act = toggles[data.espType.."ESP"] or (data.espType:find("Star") and toggles["StarESP"])
				data.info.Enabled = act
				if act then data.textLabel.Text = data.espType .. " [" .. math.floor((data.part.Position - camPos).Magnitude) .. "]" end
			end
		else removeESP(obj) end
	end
end))

-- UI Construction
createSection("VISUALS")
local boxMain, boxSub = createExpandableBtn("BoxESP", "BOX ESP", scroll)
local tM = createSubBtn("TargetMode", "TARGET: ALL", boxSub, false)
uiUpdaters["TargetMode"] = function() tM.Text = "TARGET: " .. boxTargetMode:upper() end
tM.Activated:Connect(function() 
    if boxTargetMode == "All" then boxTargetMode = "Teams" elseif boxTargetMode == "Teams" then boxTargetMode = "Enemy" else boxTargetMode = "All" end
    uiUpdaters["TargetMode"](); saveConfig()
end)
for _, o in pairs({"ShowName", "ShowTeam", "ShowKit", "DevMode"}) do createSubBtn(o, o:upper(), boxSub, true) end

createSection("WORLD")
createToggleBtn("MetalESP", "METAL ESP", scroll)
createToggleBtn("StarESP", "STAR ESP", scroll)
createToggleBtn("BeeESP", "BEE ESP", scroll)

createSection("FARMING / OBJECTIVES")
createToggleBtn("BeehiveESP", "BEEHIVE ESP", scroll)
createToggleBtn("TaliyahESP", "TALIYAH ESP", scroll)
createToggleBtn("BedESP", "BED ESP", scroll)

local farmMain, farmSub = createExpandableBtn("FarmESP", "CROP ESP", scroll)
local fF = createSubBtn("FarmFilter", "FILTER: EVERYTHING", farmSub, false)
uiUpdaters["FarmFilter"] = function() fF.Text = "FILTER: " .. farmFilter:upper() end
fF.Activated:Connect(function() 
	if farmFilter == "Everything" then farmFilter = "Melon Only" elseif farmFilter == "Melon Only" then farmFilter = "Carrot Only" elseif farmFilter == "Carrot Only" then farmFilter = "Pumpkin Only" else farmFilter = "Everything" end
	uiUpdaters["FarmFilter"](); saveConfig()
end)

createSection("MISC")
local kr = createToggleBtn("KitRender", "KIT RENDER", scroll)

-- Function to sync the frame visibility with the toggle and UI state
local function syncKitVisibility()
	kitFrame.Visible = toggles["KitRender"] and uiVisible
end

-- Hook the button click to trigger the visibility update
kr.Activated:Connect(syncKitVisibility)

-- Store the update function so keybinds and config loads also trigger it
uiUpdaters["KitRender_Frame"] = syncKitVisibility

local un = Instance.new("TextButton", scroll); un.Size = UDim2.new(0.9, 0, 0, 38); un.BackgroundColor3 = Color3.fromRGB(40, 10, 10); un.TextColor3 = Color3.new(1,0.5,0.5); un.Text = "UNINJECT"; un.Font = Enum.Font.GothamBold; un.TextSize = 14; addUICorner(6, un)
local unS = Instance.new("UIStroke", un); unS.Color = Color3.fromRGB(80, 20, 20)
un.Activated:Connect(function() 
    for _, c in pairs(connections) do c:Disconnect() end 
    for o, _ in pairs(tracked) do removeESP(o) end 
    zenWareGUI:Destroy() 
end)

-- Keybind Input Handler
UIS.InputBegan:Connect(function(input, gpe)
	if not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
		if currentBindName then
			hotkeys[currentBindName] = input.KeyCode
			currentBindName = nil; currentBindBtn = nil
			for _, fn in pairs(uiUpdaters) do fn() end
			saveConfig()
			return
		end
		
		if input.KeyCode == Enum.KeyCode.RightShift then 
			uiVisible = not uiVisible; mainUI.Visible = uiVisible; kitFrame.Visible = uiVisible and toggles["KitRender"]
		end
		
		for tName, key in pairs(hotkeys) do
			if input.KeyCode == key then
				toggles[tName] = not toggles[tName]
				if uiUpdaters[tName] then uiUpdaters[tName]() end
				if tName == "KitRender" then uiUpdaters["KitRender_Frame"]() end
				local titleStr = tName:gsub("ESP", " ESP")
				notify(titleStr:upper(), toggles[tName])
				saveConfig()
			end
		end
	end
end)

-- Initialize Data & UI
loadConfig()
for _, updateFn in pairs(uiUpdaters) do updateFn() end
task.spawn(function() while task.wait(0.5) do if toggles["KitRender"] then updateRender() end end end)
