-- ============================================================
-- HXN Hub MM2 — Optimized v8.5.0
-- ============================================================

if _G.HXNHubLoaded then
	if _G.HXN_WINDUI then
		_G.HXN_WINDUI:Notify({ Title = "HXN Hub", Content = "The script is already running.", Icon = "x", Duration = 4 })
	else
		warn("[HXN] Hub is already loaded, aborting second execute.")
	end
	return
end
_G.HXNHubLoaded = true

print("[HXN] Starting script cleanup...")

pcall(function()
	local WindUIGui = game:GetService("CoreGui"):FindFirstChild("WindUI")
	if WindUIGui then WindUIGui:Destroy() end
end)

if _G.HXN_WINDOW then
	pcall(function() if _G.HXN_WINDOW.Window then _G.HXN_WINDOW.Window:Destroy() end end)
	pcall(function() _G.HXN_WINDOW:Close() end)
	_G.HXN_WINDOW = nil
end

if _G.HXN_TASKS then
	for _, taskId in ipairs(_G.HXN_TASKS) do pcall(function() task.cancel(taskId) end) end
end
_G.HXN_TASKS = {}

if _G.HXN_CONNECTIONS then
	for _, connection in ipairs(_G.HXN_CONNECTIONS) do pcall(function() connection:Disconnect() end) end
end
_G.HXN_CONNECTIONS = {}

if _G.HXN_TRACER_LOOP then
	pcall(function() _G.HXN_TRACER_LOOP:Disconnect() end)
	_G.HXN_TRACER_LOOP = nil
end
if _G.HXN_TRACERS then
	for _, line in pairs(_G.HXN_TRACERS) do pcall(function() line:Remove() end) end
end
_G.HXN_TRACERS = {}

-- ── Services ──────────────────────────────────────────────────
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting         = game:GetService("Lighting")
local LocalPlayer      = Players.LocalPlayer

-- ── ESP cleanup on reload ─────────────────────────────────────
local ESP_CLEANUP_NAMES = {
	PlayerHighlight = true, PlayerBox = true, PlayerBoxOutline = true,
	NameTag = true, ChamHL = true, ChamsHL_Single = true,
}
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		for _, obj in ipairs(player.Character:GetDescendants()) do
			if ESP_CLEANUP_NAMES[obj.Name] then pcall(function() obj:Destroy() end) end
		end
	end
end

pcall(function()
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if hrp then hrp.Anchored = false hrp.CanCollide = true end
end)

pcall(function()
	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("BlurEffect") or effect:IsA("BloomEffect") or effect:IsA("ColorCorrectionEffect") then
			effect:Destroy()
		end
	end
	local oldSky = Lighting:FindFirstChild("CustomSky")
	if oldSky then oldSky:Destroy() end
end)

-- ── Connection tracker ────────────────────────────────────────
local connectionSet = {}

local function trackConn(conn)
	connectionSet[conn] = true
	table.insert(_G.HXN_CONNECTIONS, conn)
	return conn
end

-- ── Per-player connection registry (replaces _G key iteration) ─
local playerConnRegistry = {}  -- [userId] = {conns table}

local function registerPlayerConns(userId, conns)
	playerConnRegistry[userId] = conns
end

local function cleanupPlayerConns(userId)
	local conns = playerConnRegistry[userId]
	if conns then
		for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
		playerConnRegistry[userId] = nil
	end
	-- also clean _G keys for backward compat
	local key = "HXN_PCONNS_" .. tostring(userId)
	if _G[key] then _G[key] = nil end
	local rkey = "HXN_REWIRE_" .. tostring(userId)
	if _G[rkey] then _G[rkey] = nil end
end

-- ============================================================
-- LOAD WIND UI
-- ============================================================
print("[HXN] Loading Wind UI...")
local success, WindUI = pcall(function()
	return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not success or not WindUI then
	print("[HXN] ERROR: Failed to load Wind UI! " .. tostring(WindUI))
	return
end
_G.HXN_WINDUI = WindUI
WindUI.TransparencyValue = 0.35

-- ── Themes ───────────────────────────────────────────────────
WindUI:AddTheme({
	Name = "RedBlack",
	Accent = Color3.fromRGB(20,20,20), Dialog = Color3.fromRGB(15,15,15),
	Outline = Color3.fromRGB(255,50,50), Text = Color3.fromRGB(240,240,240),
	Placeholder = Color3.fromRGB(120,40,40), Background = Color3.fromRGB(15,15,15),
	Button = Color3.fromRGB(15,15,15), Icon = Color3.fromRGB(255,70,70),
	Toggle = Color3.fromRGB(0,200,80), Slider = Color3.fromRGB(220,0,0),
	Checkbox = Color3.fromRGB(0,200,80), PanelBackground = Color3.fromRGB(25,25,25),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(255,0,0),
	SliderIcon = Color3.fromRGB(180,45,45), TabBackground = Color3.fromRGB(25,25,25),
	TabBackgroundHover = Color3.fromRGB(35,35,35), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(50,20,20), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(240,240,240), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(255,70,70),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(255,50,50), ElementBackground = Color3.fromRGB(15,15,15),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(240,240,240),
	ElementDesc = Color3.fromRGB(180,180,180), ElementIcon = Color3.fromRGB(255,70,70),
	WindowBackground = Color3.fromRGB(15,15,15), WindowTopbarTitle = Color3.fromRGB(240,240,240),
	WindowTopbarAuthor = Color3.fromRGB(255,70,70), WindowTopbarIcon = Color3.fromRGB(255,70,70),
	WindowTopbarButtonIcon = Color3.fromRGB(255,70,70), Hover = Color3.fromRGB(50,20,20),
	LabelBackground = Color3.fromRGB(25,25,25), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(25,25,25), NotificationTitle = Color3.fromRGB(240,240,240),
	NotificationContent = Color3.fromRGB(180,180,180), NotificationDuration = Color3.fromRGB(0,255,100),
	NotificationBorder = Color3.fromRGB(0,255,100), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(15,15,15), TooltipText = Color3.fromRGB(240,240,240),
	TooltipSecondary = Color3.fromRGB(0,255,100), TooltipSecondaryText = Color3.fromRGB(255,255,255),
	WindowSearchBarBackground = Color3.fromRGB(35,35,35), SearchBarBorder = Color3.fromRGB(255,50,50),
	SearchBarBorderTransparency = 0.5,
})

WindUI:AddTheme({
	Name = "NeonPurple",
	Accent = Color3.fromRGB(20,0,30), Dialog = Color3.fromRGB(12,0,20),
	Outline = Color3.fromRGB(180,0,255), Text = Color3.fromRGB(240,240,240),
	Placeholder = Color3.fromRGB(90,0,130), Background = Color3.fromRGB(12,0,20),
	Button = Color3.fromRGB(20,0,30), Icon = Color3.fromRGB(200,80,255),
	Toggle = Color3.fromRGB(180,0,255), Slider = Color3.fromRGB(160,0,230),
	Checkbox = Color3.fromRGB(180,0,255), PanelBackground = Color3.fromRGB(25,0,38),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(180,0,255),
	SliderIcon = Color3.fromRGB(130,0,190), TabBackground = Color3.fromRGB(22,0,35),
	TabBackgroundHover = Color3.fromRGB(35,0,55), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(50,0,75), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(240,240,240), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(200,80,255),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(180,0,255), ElementBackground = Color3.fromRGB(15,0,25),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(240,240,240),
	ElementDesc = Color3.fromRGB(200,160,220), ElementIcon = Color3.fromRGB(200,80,255),
	WindowBackground = Color3.fromRGB(12,0,20), WindowTopbarTitle = Color3.fromRGB(240,240,240),
	WindowTopbarAuthor = Color3.fromRGB(200,80,255), WindowTopbarIcon = Color3.fromRGB(200,80,255),
	WindowTopbarButtonIcon = Color3.fromRGB(200,80,255), Hover = Color3.fromRGB(50,0,75),
	LabelBackground = Color3.fromRGB(25,0,38), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(20,0,30), NotificationTitle = Color3.fromRGB(240,240,240),
	NotificationContent = Color3.fromRGB(200,160,220), NotificationDuration = Color3.fromRGB(180,0,255),
	NotificationBorder = Color3.fromRGB(180,0,255), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(12,0,20), TooltipText = Color3.fromRGB(240,240,240),
	TooltipSecondary = Color3.fromRGB(180,0,255), TooltipSecondaryText = Color3.fromRGB(255,255,255),
	WindowSearchBarBackground = Color3.fromRGB(30,0,45), SearchBarBorder = Color3.fromRGB(180,0,255),
	SearchBarBorderTransparency = 0.5,
})

WindUI:AddTheme({
	Name = "NeonBlue",
	Accent = Color3.fromRGB(0,10,30), Dialog = Color3.fromRGB(0,8,22),
	Outline = Color3.fromRGB(0,180,255), Text = Color3.fromRGB(220,240,255),
	Placeholder = Color3.fromRGB(0,70,120), Background = Color3.fromRGB(0,8,22),
	Button = Color3.fromRGB(0,10,30), Icon = Color3.fromRGB(0,200,255),
	Toggle = Color3.fromRGB(0,180,255), Slider = Color3.fromRGB(0,150,230),
	Checkbox = Color3.fromRGB(0,180,255), PanelBackground = Color3.fromRGB(0,15,38),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(0,180,255),
	SliderIcon = Color3.fromRGB(0,120,190), TabBackground = Color3.fromRGB(0,12,30),
	TabBackgroundHover = Color3.fromRGB(0,25,55), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(0,35,70), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(220,240,255), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(0,200,255),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(0,180,255), ElementBackground = Color3.fromRGB(0,10,25),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(220,240,255),
	ElementDesc = Color3.fromRGB(140,200,230), ElementIcon = Color3.fromRGB(0,200,255),
	WindowBackground = Color3.fromRGB(0,8,22), WindowTopbarTitle = Color3.fromRGB(220,240,255),
	WindowTopbarAuthor = Color3.fromRGB(0,200,255), WindowTopbarIcon = Color3.fromRGB(0,200,255),
	WindowTopbarButtonIcon = Color3.fromRGB(0,200,255), Hover = Color3.fromRGB(0,35,70),
	LabelBackground = Color3.fromRGB(0,15,38), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(0,10,30), NotificationTitle = Color3.fromRGB(220,240,255),
	NotificationContent = Color3.fromRGB(140,200,230), NotificationDuration = Color3.fromRGB(0,180,255),
	NotificationBorder = Color3.fromRGB(0,180,255), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(0,8,22), TooltipText = Color3.fromRGB(220,240,255),
	TooltipSecondary = Color3.fromRGB(0,180,255), TooltipSecondaryText = Color3.fromRGB(255,255,255),
	WindowSearchBarBackground = Color3.fromRGB(0,18,40), SearchBarBorder = Color3.fromRGB(0,180,255),
	SearchBarBorderTransparency = 0.5,
})

WindUI:AddTheme({
	Name = "NeonGreen",
	Accent = Color3.fromRGB(0,20,10), Dialog = Color3.fromRGB(0,12,6),
	Outline = Color3.fromRGB(0,255,120), Text = Color3.fromRGB(220,255,235),
	Placeholder = Color3.fromRGB(0,100,50), Background = Color3.fromRGB(0,12,6),
	Button = Color3.fromRGB(0,18,9), Icon = Color3.fromRGB(0,255,120),
	Toggle = Color3.fromRGB(0,255,120), Slider = Color3.fromRGB(0,200,90),
	Checkbox = Color3.fromRGB(0,255,120), PanelBackground = Color3.fromRGB(0,22,12),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(0,255,120),
	SliderIcon = Color3.fromRGB(0,160,80), TabBackground = Color3.fromRGB(0,18,10),
	TabBackgroundHover = Color3.fromRGB(0,35,18), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(0,50,25), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(220,255,235), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(0,255,120),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(0,255,120), ElementBackground = Color3.fromRGB(0,14,7),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(220,255,235),
	ElementDesc = Color3.fromRGB(140,220,170), ElementIcon = Color3.fromRGB(0,255,120),
	WindowBackground = Color3.fromRGB(0,12,6), WindowTopbarTitle = Color3.fromRGB(220,255,235),
	WindowTopbarAuthor = Color3.fromRGB(0,255,120), WindowTopbarIcon = Color3.fromRGB(0,255,120),
	WindowTopbarButtonIcon = Color3.fromRGB(0,255,120), Hover = Color3.fromRGB(0,50,25),
	LabelBackground = Color3.fromRGB(0,22,12), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(0,18,9), NotificationTitle = Color3.fromRGB(220,255,235),
	NotificationContent = Color3.fromRGB(140,220,170), NotificationDuration = Color3.fromRGB(0,255,120),
	NotificationBorder = Color3.fromRGB(0,255,120), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(0,12,6), TooltipText = Color3.fromRGB(220,255,235),
	TooltipSecondary = Color3.fromRGB(0,255,120), TooltipSecondaryText = Color3.fromRGB(255,255,255),
	WindowSearchBarBackground = Color3.fromRGB(0,25,13), SearchBarBorder = Color3.fromRGB(0,255,120),
	SearchBarBorderTransparency = 0.5,
})

WindUI:AddTheme({
	Name = "Sunset",
	Accent = Color3.fromRGB(30,10,5), Dialog = Color3.fromRGB(20,8,5),
	Outline = Color3.fromRGB(255,100,30), Text = Color3.fromRGB(255,235,220),
	Placeholder = Color3.fromRGB(150,60,20), Background = Color3.fromRGB(20,8,5),
	Button = Color3.fromRGB(30,10,5), Icon = Color3.fromRGB(255,130,60),
	Toggle = Color3.fromRGB(255,80,120), Slider = Color3.fromRGB(255,100,30),
	Checkbox = Color3.fromRGB(255,80,120), PanelBackground = Color3.fromRGB(38,15,8),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(255,100,30),
	SliderIcon = Color3.fromRGB(200,70,20), TabBackground = Color3.fromRGB(30,12,6),
	TabBackgroundHover = Color3.fromRGB(50,20,10), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(70,25,10), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(255,235,220), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(255,130,60),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(255,100,30), ElementBackground = Color3.fromRGB(22,9,5),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(255,235,220),
	ElementDesc = Color3.fromRGB(230,180,150), ElementIcon = Color3.fromRGB(255,130,60),
	WindowBackground = Color3.fromRGB(20,8,5), WindowTopbarTitle = Color3.fromRGB(255,235,220),
	WindowTopbarAuthor = Color3.fromRGB(255,130,60), WindowTopbarIcon = Color3.fromRGB(255,130,60),
	WindowTopbarButtonIcon = Color3.fromRGB(255,130,60), Hover = Color3.fromRGB(70,25,10),
	LabelBackground = Color3.fromRGB(38,15,8), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(30,10,5), NotificationTitle = Color3.fromRGB(255,235,220),
	NotificationContent = Color3.fromRGB(230,180,150), NotificationDuration = Color3.fromRGB(255,80,120),
	NotificationBorder = Color3.fromRGB(255,80,120), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(20,8,5), TooltipText = Color3.fromRGB(255,235,220),
	TooltipSecondary = Color3.fromRGB(255,100,30), TooltipSecondaryText = Color3.fromRGB(255,255,255),
	WindowSearchBarBackground = Color3.fromRGB(40,16,8), SearchBarBorder = Color3.fromRGB(255,100,30),
	SearchBarBorderTransparency = 0.5,
})

WindUI:AddTheme({
	Name = "Ice",
	Accent = Color3.fromRGB(210,235,255), Dialog = Color3.fromRGB(225,245,255),
	Outline = Color3.fromRGB(80,180,255), Text = Color3.fromRGB(20,40,70),
	Placeholder = Color3.fromRGB(130,180,220), Background = Color3.fromRGB(225,245,255),
	Button = Color3.fromRGB(210,235,255), Icon = Color3.fromRGB(0,150,230),
	Toggle = Color3.fromRGB(0,180,255), Slider = Color3.fromRGB(80,180,255),
	Checkbox = Color3.fromRGB(0,180,255), PanelBackground = Color3.fromRGB(200,228,250),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(80,180,255),
	SliderIcon = Color3.fromRGB(60,140,210), TabBackground = Color3.fromRGB(205,232,255),
	TabBackgroundHover = Color3.fromRGB(185,218,248), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(170,210,245), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(20,40,70), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(0,150,230),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(80,180,255), ElementBackground = Color3.fromRGB(215,238,255),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(20,40,70),
	ElementDesc = Color3.fromRGB(80,120,170), ElementIcon = Color3.fromRGB(0,150,230),
	WindowBackground = Color3.fromRGB(225,245,255), WindowTopbarTitle = Color3.fromRGB(20,40,70),
	WindowTopbarAuthor = Color3.fromRGB(0,150,230), WindowTopbarIcon = Color3.fromRGB(0,150,230),
	WindowTopbarButtonIcon = Color3.fromRGB(0,150,230), Hover = Color3.fromRGB(170,210,245),
	LabelBackground = Color3.fromRGB(200,228,250), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(210,235,255), NotificationTitle = Color3.fromRGB(20,40,70),
	NotificationContent = Color3.fromRGB(80,120,170), NotificationDuration = Color3.fromRGB(0,180,255),
	NotificationBorder = Color3.fromRGB(80,180,255), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(225,245,255), TooltipText = Color3.fromRGB(20,40,70),
	TooltipSecondary = Color3.fromRGB(80,180,255), TooltipSecondaryText = Color3.fromRGB(20,40,70),
	WindowSearchBarBackground = Color3.fromRGB(195,225,248), SearchBarBorder = Color3.fromRGB(80,180,255),
	SearchBarBorderTransparency = 0.5,
})

WindUI:AddTheme({
	Name = "Gold",
	Accent = Color3.fromRGB(20,15,0), Dialog = Color3.fromRGB(12,10,0),
	Outline = Color3.fromRGB(255,200,0), Text = Color3.fromRGB(255,245,200),
	Placeholder = Color3.fromRGB(120,90,0), Background = Color3.fromRGB(12,10,0),
	Button = Color3.fromRGB(20,15,0), Icon = Color3.fromRGB(255,210,30),
	Toggle = Color3.fromRGB(255,200,0), Slider = Color3.fromRGB(220,170,0),
	Checkbox = Color3.fromRGB(255,200,0), PanelBackground = Color3.fromRGB(28,22,0),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(255,200,0),
	SliderIcon = Color3.fromRGB(180,140,0), TabBackground = Color3.fromRGB(22,17,0),
	TabBackgroundHover = Color3.fromRGB(38,30,0), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(55,42,0), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(255,245,200), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(255,210,30),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(255,200,0), ElementBackground = Color3.fromRGB(16,12,0),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(255,245,200),
	ElementDesc = Color3.fromRGB(210,185,120), ElementIcon = Color3.fromRGB(255,210,30),
	WindowBackground = Color3.fromRGB(12,10,0), WindowTopbarTitle = Color3.fromRGB(255,245,200),
	WindowTopbarAuthor = Color3.fromRGB(255,210,30), WindowTopbarIcon = Color3.fromRGB(255,210,30),
	WindowTopbarButtonIcon = Color3.fromRGB(255,210,30), Hover = Color3.fromRGB(55,42,0),
	LabelBackground = Color3.fromRGB(28,22,0), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(20,15,0), NotificationTitle = Color3.fromRGB(255,245,200),
	NotificationContent = Color3.fromRGB(210,185,120), NotificationDuration = Color3.fromRGB(255,200,0),
	NotificationBorder = Color3.fromRGB(255,200,0), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(12,10,0), TooltipText = Color3.fromRGB(255,245,200),
	TooltipSecondary = Color3.fromRGB(255,200,0), TooltipSecondaryText = Color3.fromRGB(20,15,0),
	WindowSearchBarBackground = Color3.fromRGB(32,25,0), SearchBarBorder = Color3.fromRGB(255,200,0),
	SearchBarBorderTransparency = 0.5,
})

-- ── Window ────────────────────────────────────────────────────
local Window = WindUI:CreateWindow({
	Title = "HXN Hub MM2", Icon = "solar:danger-bold", Author = "by hxneey",
	Folder = "HXN_MM2", Size = UDim2.fromOffset(580, 490), Theme = "RedBlack",
	Transparent = true, BackgroundImageTransparency = 0.65, Acrylic = true,
	User = { Enabled = true, Anonymous = false, Callback = function() end },
})
Window:SetToggleKey(Enum.KeyCode.K)
_G.HXN_WINDOW = Window

local function Notify(title, content, icon, duration)
	WindUI:Notify({ Title = title, Content = content, Icon = icon or "bell", Duration = duration or 3 })
end

Window:Tag({ Title = "Updated", Color = Color3.fromRGB(0, 255, 100) })

-- ── Tabs ──────────────────────────────────────────────────────
local CharacterTab = Window:Tab({ Title = "Character", Icon = "user" })
local TeleportTab  = Window:Tab({ Title = "Teleport",  Icon = "plane" })
local CombatTab    = Window:Tab({ Title = "Combat",    Icon = "sword" })
local TrollingTab  = Window:Tab({ Title = "Trolling",  Icon = "zap" })
local ESPTab       = Window:Tab({ Title = "ESP",       Icon = "eye" })
local VisualTab    = Window:Tab({ Title = "Visual",    Icon = "palette" })
local AutofarmTab  = Window:Tab({ Title = "Autofarm",  Icon = "sprout" })
local EmoteTab     = Window:Tab({ Title = "Emotes",    Icon = "smile" })
local OtherTab     = Window:Tab({ Title = "Other",     Icon = "settings" })
CharacterTab:Select()

-- ============================================================
-- ESP STATE
-- ============================================================
local OTHER_PLAYER_COLOR   = Color3.fromRGB(0, 255, 0)
local MURDERER_COLOR       = Color3.fromRGB(255, 0, 0)
local SHERIFF_COLOR        = Color3.fromRGB(0, 0, 139)
local GUN_COLOR            = Color3.fromRGB(139, 0, 0)
local STUCK_KNIFE_COLOR    = Color3.fromRGB(255, 165, 0)
local COIN_COLOR           = Color3.fromRGB(255, 223, 0)
local FILL_TRANSPARENCY    = 0.5
local OUTLINE_TRANSPARENCY = 0

local ESPEnabled             = false
local NameTagsEnabled        = false
local ESPDroppedGunEnabled   = false
local ShowCoinsEnabled       = false
local ShowThrownKnifeEnabled = false
local InnocentESPEnabled     = true
local SheriffESPEnabled      = true
local MurdererESPEnabled     = true
local TracersEnabled         = false

local ESPStyles = { Highlight = false, Chams = false, Box = false }

local HighlightFillTransp    = 0.5
local HighlightOutlineTransp = 0.0
local ChamsFillTransp        = 0.5
local BoxFillTransp          = 0.8

local GunTPKeybind         = Enum.KeyCode.F
local OriginalPosition     = nil
local IsAtGun              = false
local GunDropNotifyEnabled = false

-- ============================================================
-- ROLE CACHE
-- ============================================================
local roleCache = {}
local updatePlayer

local function computeRole(player)
	if not player.Character then return "Other" end
	for _, item in ipairs(player.Character:GetChildren()) do
		if item:IsA("Tool") then
			if item.Name == "Knife" then return "Murderer" end
			if item.Name == "Gun"   then return "Sheriff"  end
		end
	end
	local bp = player:FindFirstChildOfClass("Backpack")
	if bp then
		for _, item in ipairs(bp:GetChildren()) do
			if item:IsA("Tool") then
				if item.Name == "Knife" then return "Murderer" end
				if item.Name == "Gun"   then return "Sheriff"  end
			end
		end
	end
	return "Other"
end

local function getRole(player)
	if roleCache[player] then return roleCache[player] end
	roleCache[player] = computeRole(player)
	return roleCache[player]
end

local function invalidateRole(player)
	roleCache[player] = nil
end

local function watchPlayerRole(player, playerConns)
	local function onChange()
		if not ESPEnabled then return end
		task.spawn(function()
			task.wait(0.1)
			invalidateRole(player)
			if player.Character and updatePlayer then updatePlayer(player) end
		end)
	end
	local function wireBackpack(bp)
		table.insert(playerConns, bp.ChildAdded:Connect(onChange))
		table.insert(playerConns, bp.ChildRemoved:Connect(onChange))
	end
	local bp = player:FindFirstChildOfClass("Backpack")
	if bp then wireBackpack(bp) end
	table.insert(playerConns, player.ChildAdded:Connect(function(child)
		if child:IsA("Backpack") then wireBackpack(child) onChange() end
	end))
end

-- ── Role detector ─────────────────────────────────────────────
-- FIX: sleeps longer (task.wait(4)) when ESP is off — was 2.5s flat before
local roleDetectorActive = false
local roleDetectorThread = nil

local function startRoleDetector()
	if roleDetectorActive then return end
	roleDetectorActive = true
	roleDetectorThread = task.spawn(function()
		while roleDetectorActive do
			if ESPEnabled then
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= LocalPlayer and p.Character then
						local newRole = computeRole(p)
						if roleCache[p] ~= newRole then
							roleCache[p] = newRole
							updatePlayer(p)
						end
					end
				end
				task.wait(2.5)
			else
				task.wait(4)
			end
		end
	end)
end

local function stopRoleDetector()
	roleDetectorActive = false
	if roleDetectorThread then
		pcall(function() task.cancel(roleDetectorThread) end)
		roleDetectorThread = nil
	end
end

-- ============================================================
-- HELPERS
-- ============================================================
local function findMurderer()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and getRole(p) == "Murderer" then return p end
	end
	return nil
end

local function getOrEquipKnife()
	if not LocalPlayer or not LocalPlayer.Character then return nil end
	local knife = LocalPlayer.Character:FindFirstChild("Knife")
	if knife then return knife end
	local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
	if bp and bp:FindFirstChild("Knife") then
		LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(bp:FindFirstChild("Knife"))
		return LocalPlayer.Character:FindFirstChild("Knife")
	end
	Notify("Combat", "You are not the Murderer.", "x", 3)
	return nil
end

local function findClosestPlayer()
	if not LocalPlayer.Character then return nil end
	local lhrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not lhrp then return nil end
	local nearest, shortestDist = nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local hrp = p.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local d = (lhrp.Position - hrp.Position).Magnitude
				if d < shortestDist then shortestDist = d nearest = p end
			end
		end
	end
	return nearest
end

local function GetPlayerList()
	local names = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then table.insert(names, p.Name) end
	end
	return names
end

-- ============================================================
-- COMBAT TAB
-- ============================================================
CombatTab:Section({ Title = "Sheriff" })

local shootMurdererEnabled = true

CombatTab:Keybind({
	Title = "Shoot Murderer", Value = "Q",
	Callback = function()
		if not shootMurdererEnabled then return end
		if not LocalPlayer.Character then return end
		local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
		local hasGun = LocalPlayer.Character:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun"))
		if not hasGun then Notify("Combat", "You are not the Sheriff or Hero.", "x", 3) return end

		local murderer
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				invalidateRole(p)
				if computeRole(p) == "Murderer" then
					murderer = p
					roleCache[p] = "Murderer"
					break
				end
			end
		end

		if not murderer or not murderer.Character then
			Notify("Combat", "No murderer detected.", "x", 2) return
		end

		if not LocalPlayer.Character:FindFirstChild("Gun") and bp and bp:FindFirstChild("Gun") then
			LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(bp:FindFirstChild("Gun"))
			task.wait(0.05)
		end

		local gunTool     = LocalPlayer.Character:FindFirstChild("Gun")
		local shootRemote = gunTool and gunTool:WaitForChild("Shoot", 2)
		if not gunTool or not shootRemote then return end

		local originPart = LocalPlayer.Character:FindFirstChild("RightHand")
			or LocalPlayer.Character:FindFirstChild("Right Arm")
			or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

		local BULLET_SPEED = 500

		local function fireAtMurderer()
			local mHRP = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
			if not mHRP then return false end

			local snapPos = mHRP.Position
			local snapVel = mHRP.Velocity
			local origin  = originPart.Position
			local dist    = (origin - snapPos).Magnitude
			local ping    = LocalPlayer:GetNetworkPing()

			local predicted
			if dist < 15 then
				-- Close range — aim directly
				predicted = snapPos
			else
				local isAirborne = math.abs(snapVel.Y) > 3
				if isAirborne then
					-- Airborne — aim at snapshot position, no horizontal lead
					-- (trajectory too unpredictable mid-air)
					predicted = snapPos
				else
					local mHum    = murderer.Character:FindFirstChildOfClass("Humanoid")
					local moveDir = mHum and mHum.MoveDirection or Vector3.new()
					local speed   = Vector3.new(snapVel.X, 0, snapVel.Z).Magnitude
					local leadTime = (dist / BULLET_SPEED) + ping
					predicted = Vector3.new(
						snapPos.X + moveDir.X * speed * leadTime,
						snapPos.Y,
						snapPos.Z + moveDir.Z * speed * leadTime
					)
				end
			end

			pcall(function()
				shootRemote:FireServer(CFrame.new(origin), CFrame.new(predicted))
			end)
			return true
		end

		task.spawn(fireAtMurderer)
	end,
})

CombatTab:Toggle({
	Title = "Shoot Murderer Enabled", Value = true,
	Callback = function(v) shootMurdererEnabled = v end,
})

CombatTab:Section({ Title = "Murderer" })

local knifeThrowClosestEnabled = true

CombatTab:Keybind({
	Title = "Knife Throw to Closest", Value = "E",
	Callback = function()
		if not knifeThrowClosestEnabled then return end
		local knifeTool = getOrEquipKnife()
		if not knifeTool then return end
		local target = findClosestPlayer()
		if not target then return end
		local tHRP = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
		if not tHRP then return end
		pcall(function()
			knifeTool:WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(
				CFrame.new(LocalPlayer.Character.RightHand.Position),
				CFrame.new(tHRP.Position + tHRP.Velocity * 0.1)
			)
		end)
	end,
})

CombatTab:Toggle({
	Title = "Knife Throw Enabled", Value = true,
	Callback = function(v) knifeThrowClosestEnabled = v end,
})

local autoKnifeThrowEnabled = false
CombatTab:Toggle({
	Title = "Auto Knife Throw", Value = false,
	Callback = function(v)
		autoKnifeThrowEnabled = v
		if not v then return end
		task.spawn(function()
			while autoKnifeThrowEnabled do
				task.wait(1.5)
				if not autoKnifeThrowEnabled then break end
				local knifeTool = getOrEquipKnife()
				if not knifeTool then autoKnifeThrowEnabled = false break end
				if not autoKnifeThrowEnabled then break end
				local target = findClosestPlayer()
				if target and target.Character then
					local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
					if tHRP then
						pcall(function()
							knifeTool:WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(
								CFrame.new(LocalPlayer.Character.RightHand.Position),
								CFrame.new(tHRP.Position + tHRP.Velocity * 0.1)
							)
						end)
					end
				end
			end
		end)
	end,
})

CombatTab:Button({
	Title = "Kill Closest Player",
	Callback = function()
		local knifeTool = getOrEquipKnife()
		if not knifeTool then return end
		local target = findClosestPlayer()
		if not target or not target.Character then return end
		local lHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local tHRP = target.Character:FindFirstChild("HumanoidRootPart")
		if not tHRP or not lHRP then return end
		tHRP.Anchored = true
		tHRP.CFrame   = lHRP.CFrame + lHRP.CFrame.LookVector * 2
		task.wait(0.1)
		pcall(function() knifeTool:WaitForChild("Stab"):FireServer("Slash") end)
		task.wait(0.05)
		pcall(function() tHRP.Anchored = false end)
	end,
})

CombatTab:Button({
	Title = "Kill Everyone",
	Callback = function()
		local knifeTool = getOrEquipKnife()
		if not knifeTool then return end
		local lHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not lHRP then return end
		local anchored = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character and p ~= LocalPlayer then
				local hrp = p.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.Anchored = true
					hrp.CFrame   = lHRP.CFrame + lHRP.CFrame.LookVector * 1
					table.insert(anchored, hrp)
				end
			end
		end
		pcall(function() knifeTool:WaitForChild("Stab"):FireServer("Slash") end)
		task.wait(0.05)
		for _, hrp in ipairs(anchored) do pcall(function() hrp.Anchored = false end) end
	end,
})

-- ============================================================
-- ANTI-AFK
-- ============================================================
local AntiAfkEnabled = true
local antiAfkConn    = nil

local function setupAntiAfk()
	if antiAfkConn then return end
	local vu = game:GetService("VirtualUser")
	antiAfkConn = LocalPlayer.Idled:Connect(function()
		vu:CaptureController()
		vu:ClickButton2(Vector2.new())
	end)
end

local function disableAntiAfk()
	if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
end

-- ============================================================
-- ANTI-FLING (untouched as requested)
-- ============================================================
local antiFlingEnabled     = false
local antiFlingConnections = {}
local antiFlingHeartbeats  = {}
local antiFlingDiedConn    = nil
local antiFlingDescConn    = nil

local function startAntiFling()
	if antiFlingEnabled then return end
	antiFlingEnabled = true

	local function applyAntiFlingToHRP(v)
		if not (v and v.Parent) then return end
		local hb = RunService.Heartbeat:Connect(function()
			if not antiFlingEnabled then return end
			if not (v and v.Parent) then return end
			pcall(function()
				v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
				v.Velocity    = Vector3.new(0, 0, 0)
				v.RotVelocity = Vector3.new(0, 0, 0)
				v.CanCollide  = false
			end)
		end)
		table.insert(antiFlingHeartbeats, hb)
	end

	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Part") and v.Name == "HumanoidRootPart"
			and v.Parent ~= LocalPlayer.Character and not v.Anchored
		then
			applyAntiFlingToHRP(v)
		end
	end

	antiFlingDescConn = workspace.DescendantAdded:Connect(function(part)
		if not antiFlingEnabled then return end
		if part:IsA("Part") and part.Name == "HumanoidRootPart"
			and part.Parent ~= LocalPlayer.Character
		then
			task.wait(2)
			if antiFlingEnabled then applyAntiFlingToHRP(part) end
		end
	end)
	table.insert(antiFlingConnections, antiFlingDescConn)

	local char = LocalPlayer and LocalPlayer.Character
	local hum  = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		antiFlingDiedConn = hum.Died:Connect(function()
			if antiFlingDiedConn then antiFlingDiedConn:Disconnect() antiFlingDiedConn = nil end
			for _, hb in ipairs(antiFlingHeartbeats) do pcall(function() hb:Disconnect() end) end
			antiFlingHeartbeats = {}
		end)
	end

	Notify("Anti-Fling", "Anti-Fling activated.", "shield", 3)
end

local function stopAntiFling()
	antiFlingEnabled = false
	if antiFlingDiedConn then antiFlingDiedConn:Disconnect() antiFlingDiedConn = nil end
	if antiFlingDescConn then antiFlingDescConn:Disconnect() antiFlingDescConn = nil end
	for _, hb in ipairs(antiFlingHeartbeats) do pcall(function() hb:Disconnect() end) end
	for _, c  in ipairs(antiFlingConnections) do pcall(function() c:Disconnect() end) end
	antiFlingHeartbeats  = {}
	antiFlingConnections = {}
end

-- ============================================================
-- OTHER TAB
-- ============================================================
OtherTab:Section({ Title = "Anti-Exploit" })
OtherTab:Toggle({
	Title = "Anti-AFK", Value = true,
	Callback = function(v)
		AntiAfkEnabled = v
		if v then setupAntiAfk() else disableAntiAfk() end
	end,
})
if AntiAfkEnabled then setupAntiAfk() end

OtherTab:Toggle({
	Title = "Anti-Fling", Value = false,
	Callback = function(v) if v then startAntiFling() else stopAntiFling() end end,
})

OtherTab:Section({ Title = "Round Timer" })
local roundTimerEnabled = false
local roundTimerGui     = nil

local function secondsToMinutes(s)
	if not s or s <= 0 then return "00:00" end
	return string.format("%dm %ds", math.floor(s / 60), s % 60)
end

local function createTimerGui()
	local sg = Instance.new("ScreenGui")
	sg.Name = "HXN_RoundTimer"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.Parent = game:GetService("CoreGui")
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromOffset(220, 50)
	lbl.AnchorPoint = Vector2.new(0.5, 0)
	lbl.Position = UDim2.new(0.5, 0, 0, 10)
	lbl.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	lbl.BackgroundTransparency = 0.4
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.TextScaled = true
	lbl.Font = Enum.Font.GothamBold
	lbl.Text = "Timer: --:--"
	lbl.Parent = sg
	local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 8) corner.Parent = lbl
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 50, 50) stroke.Thickness = 1.5 stroke.Transparency = 0.3 stroke.Parent = lbl
	return sg, lbl
end

OtherTab:Toggle({
	Title = "Round Timer", Value = false,
	Callback = function(v)
		roundTimerEnabled = v
		if v then
			local old = game:GetService("CoreGui"):FindFirstChild("HXN_RoundTimer")
			if old then old:Destroy() end
			local gui, lbl = createTimerGui()
			roundTimerGui = gui
			-- FIX: token prevents double-loop on rapid toggle
			local myToken = {}
			roundTimerEnabled = myToken
			task.spawn(function()
				while roundTimerEnabled == myToken do
					task.wait(1)
					if roundTimerEnabled ~= myToken then break end
					local ok, timeLeft = pcall(function()
						return game:GetService("ReplicatedStorage").Remotes.Extras.GetTimer:InvokeServer()
					end)
					if lbl and lbl.Parent then
						lbl.Text = (ok and type(timeLeft) == "number")
							and ("⏱ " .. secondsToMinutes(math.floor(timeLeft)))
							or "⏱ Waiting..."
					else break end
				end
			end)
			Notify("Other", "Round Timer enabled.", "check", 2)
		else
			roundTimerEnabled = false
			if roundTimerGui then roundTimerGui:Destroy() roundTimerGui = nil end
		end
	end,
})

OtherTab:Section({ Title = "UI Theme" })
OtherTab:Dropdown({
	Title = "Select Theme",
	Values = { "RedBlack", "NeonPurple", "NeonBlue", "NeonGreen", "Sunset", "Ice", "Gold" },
	Value = "RedBlack", Multi = false, AllowNone = false,
	Callback = function(option)
		if option then
			pcall(function() WindUI:SetTheme(option) end)
			Notify("UI Theme", "Theme changed to " .. option, "palette", 2)
		end
	end,
})

OtherTab:Section({ Title = "Utilities" })

OtherTab:Toggle({
	Title = "Gun Drop Notify", Value = false,
	Callback = function(v)
		GunDropNotifyEnabled = v
		Notify("Other", v and "Gun Drop Notify enabled." or "Gun Drop Notify disabled.", v and "check" or "x", 2)
	end,
})

OtherTab:Button({
	Title = "Inf Yield",
	Callback = function()
		local ok, err = pcall(function()
			loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
		end)
		if not ok then print("[HXN] Inf Yield Error: " .. tostring(err)) end
	end,
})

OtherTab:Button({
	Title = "Rejoin Server",
	Callback = function()
		local TeleportService = game:GetService("TeleportService")
		local placeId = game.PlaceId
		local jobId   = game.JobId
		Notify("Other", "Rejoining server...", "refresh-cw", 3)
		task.wait(1)
		pcall(function()
			TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
		end)
	end,
})

EmoteTab:Button({
	Title = "Emotes",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/hxneey82628/emotes/refs/heads/main/emotes.lua"))()
	end,
})

-- ============================================================
-- CHARACTER TAB
-- ============================================================
CharacterTab:Section({ Title = "Performance" })

local fps         = 0
local currentPing = 0

local PerformanceLabel = CharacterTab:Paragraph({ Title = "FPS & Ping", Desc = "FPS: 0 | Ping: 0 ms" })

-- FIX: single clean loop — no Heartbeat:Wait() blocking, no RenderStepped connection
local frameCount = 0
local frameConn  = RunService.RenderStepped:Connect(function() frameCount = frameCount + 1 end)
trackConn(frameConn)

local perfTask = task.spawn(function()
	local lastTime = tick()
	while true do
		task.wait(1)
		local now     = tick()
		local elapsed = now - lastTime
		fps           = elapsed > 0 and math.floor(frameCount / elapsed) or 0
		frameCount    = 0
		lastTime      = now
		currentPing   = math.floor(LocalPlayer:GetNetworkPing() * 1000)
		if PerformanceLabel then
			PerformanceLabel:SetDesc("FPS: " .. fps .. " | Ping: " .. currentPing .. " ms")
		end
	end
end)
table.insert(_G.HXN_TASKS, perfTask)

CharacterTab:Section({ Title = "Movement" })

local currentWalkSpeed = 16
local walkSpeedEnabled = false

local noclipEnabled  = false
local noclipDescConn = nil
local noclipCharConn = nil

local function applyNoclipToChar(char)
	if not char then return end
	for _, p in ipairs(char:GetDescendants()) do
		if p:IsA("BasePart") then p.CanCollide = false end
	end
	if noclipDescConn then noclipDescConn:Disconnect() noclipDescConn = nil end
	noclipDescConn = char.DescendantAdded:Connect(function(obj)
		if noclipEnabled and obj:IsA("BasePart") then obj.CanCollide = false end
	end)
end

local function startNoclipToggle()
	noclipEnabled = true
	applyNoclipToChar(LocalPlayer and LocalPlayer.Character)
	noclipCharConn = LocalPlayer.CharacterAdded:Connect(function(char)
		if noclipEnabled then applyNoclipToChar(char) end
	end)
	trackConn(noclipCharConn)
end

local function stopNoclipToggle()
	noclipEnabled = false
	if noclipDescConn then noclipDescConn:Disconnect() noclipDescConn = nil end
	if noclipCharConn then noclipCharConn:Disconnect() noclipCharConn = nil end
	if LocalPlayer and LocalPlayer.Character then
		for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = true end
		end
	end
end

CharacterTab:Toggle({
	Title = "Noclip", Value = false,
	Callback = function(v) noclipEnabled = v if v then startNoclipToggle() else stopNoclipToggle() end end,
})

-- ── Fly ───────────────────────────────────────────────────────
local flyEnabled      = false
local flySpeed        = 50
local flyBodyVelocity = nil
local flyBodyGyro     = nil
local flyHeartbeat    = nil
local flyAnimConn     = nil
local currentJumpPower = 50
local jumpPowerEnabled = false

local function startFly()
	local char = LocalPlayer and LocalPlayer.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = 0
		hum.JumpPower = 0
		for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop(0) end
		flyAnimConn = hum.AnimationPlayed:Connect(function(track) track:Stop(0) end)
	end
	flyBodyVelocity = Instance.new("BodyVelocity")
	flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	flyBodyVelocity.Velocity = Vector3.new()
	flyBodyVelocity.Parent   = hrp
	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	flyBodyGyro.P         = 9e9
	flyBodyGyro.CFrame    = hrp.CFrame
	flyBodyGyro.Parent    = hrp
	flyHeartbeat = RunService.Heartbeat:Connect(function()
		if not flyEnabled then
			if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
			if flyBodyGyro     then flyBodyGyro:Destroy()     flyBodyGyro     = nil end
			flyHeartbeat:Disconnect() flyHeartbeat = nil
			return
		end
		local c = LocalPlayer and LocalPlayer.Character
		if not c then return end
		local rp = c:FindFirstChild("HumanoidRootPart")
		if not rp or not flyBodyVelocity or not flyBodyVelocity.Parent then return end
		local cam = workspace.CurrentCamera
		local dir = Vector3.new()
		if UserInputService:IsKeyDown(Enum.KeyCode.W)           then dir = dir + cam.CFrame.LookVector  end
		if UserInputService:IsKeyDown(Enum.KeyCode.S)           then dir = dir - cam.CFrame.LookVector  end
		if UserInputService:IsKeyDown(Enum.KeyCode.A)           then dir = dir - cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D)           then dir = dir + cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir = dir + Vector3.new(0,1,0)     end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0)     end
		if dir.Magnitude > 0 then dir = dir.Unit end
		flyBodyVelocity.Velocity = dir * flySpeed
		flyBodyGyro.CFrame       = cam.CFrame
	end)
end

local function stopFly()
	flyEnabled = false
	if flyAnimConn     then flyAnimConn:Disconnect()     flyAnimConn     = nil end
	if flyBodyVelocity then flyBodyVelocity:Destroy()    flyBodyVelocity = nil end
	if flyBodyGyro     then flyBodyGyro:Destroy()        flyBodyGyro     = nil end
	if flyHeartbeat    then flyHeartbeat:Disconnect()    flyHeartbeat    = nil end
	local char = LocalPlayer and LocalPlayer.Character
	if char then
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hrp then hrp.Velocity = Vector3.new() end
		if hum then
			hum.WalkSpeed = walkSpeedEnabled and currentWalkSpeed or 16
			hum.JumpPower = jumpPowerEnabled  and currentJumpPower or 50
		end
	end
end

CharacterTab:Toggle({
	Title = "Fly", Value = false,
	Callback = function(v) flyEnabled = v if v then startFly() else stopFly() end end,
})

do
	local s = CharacterTab:Slider({ Title = "Fly Speed", Step = 1, Value = { Min = 10, Max = 200, Default = 50 },
		Callback = function(v) flySpeed = v end })
	if s and s.Instance then
		s.Instance.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseWheel then
				s:SetValue(math.clamp(flySpeed + (i.Position.Z > 0 and 1 or -1), 10, 200))
			end
		end)
	end
end

CharacterTab:Toggle({
	Title = "Enable WalkSpeed Changer", Value = false,
	Callback = function(v)
		walkSpeedEnabled = v
		local char = LocalPlayer and LocalPlayer.Character
		if char and char:FindFirstChildOfClass("Humanoid") then
			char:FindFirstChildOfClass("Humanoid").WalkSpeed = v and currentWalkSpeed or 16
		end
	end,
})

do
	local s = CharacterTab:Slider({ Title = "WalkSpeed Slider", Step = 1, Value = { Min = 1, Max = 350, Default = 16 },
		Callback = function(v)
			currentWalkSpeed = v
			if walkSpeedEnabled then
				local char = LocalPlayer and LocalPlayer.Character
				if char and char:FindFirstChildOfClass("Humanoid") then
					char:FindFirstChildOfClass("Humanoid").WalkSpeed = v
				end
			end
		end })
	if s and s.Instance then
		s.Instance.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseWheel then
				s:SetValue(math.clamp(currentWalkSpeed + (i.Position.Z > 0 and 1 or -1), 1, 350))
			end
		end)
	end
end

CharacterTab:Input({
	Title = "Quick WalkSpeed", Value = "", Placeholder = "1-500",
	Callback = function(text)
		local sp = tonumber(text)
		if sp then
			local char = LocalPlayer and LocalPlayer.Character
			if char and char:FindFirstChildOfClass("Humanoid") then
				char:FindFirstChildOfClass("Humanoid").WalkSpeed = sp
			end
		end
	end,
})

CharacterTab:Section({ Title = "Jump" })

CharacterTab:Toggle({
	Title = "Enable JumpPower Changer", Value = false,
	Callback = function(v)
		jumpPowerEnabled = v
		local char = LocalPlayer and LocalPlayer.Character
		if char and char:FindFirstChildOfClass("Humanoid") then
			char:FindFirstChildOfClass("Humanoid").JumpPower = v and currentJumpPower or 50
		end
	end,
})

do
	local s = CharacterTab:Slider({ Title = "JumpPower Slider", Step = 1, Value = { Min = 1, Max = 350, Default = 50 },
		Callback = function(v)
			currentJumpPower = v
			if jumpPowerEnabled then
				local char = LocalPlayer and LocalPlayer.Character
				if char and char:FindFirstChildOfClass("Humanoid") then
					char:FindFirstChildOfClass("Humanoid").JumpPower = v
				end
			end
		end })
	if s and s.Instance then
		s.Instance.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseWheel then
				s:SetValue(math.clamp(currentJumpPower + (i.Position.Z > 0 and 1 or -1), 1, 350))
			end
		end)
	end
end

CharacterTab:Section({ Title = "Camera" })
local fovEnabled = false
local fovValue   = 70

local function updateFOV()
	local cam = workspace.CurrentCamera
	if cam then cam.FieldOfView = fovEnabled and fovValue or 70 end
end

CharacterTab:Toggle({ Title = "Custom FOV", Value = false, Callback = function(v) fovEnabled = v updateFOV() end })

do
	local s = CharacterTab:Slider({ Title = "FOV Value", Step = 1, Value = { Min = 1, Max = 120, Default = 70 },
		Callback = function(v) fovValue = v updateFOV() end })
	if s and s.Instance then
		s.Instance.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseWheel then
				s:SetValue(math.clamp(fovValue + (i.Position.Z > 0 and 1 or -1), 1, 120))
			end
		end)
	end
end

-- ============================================================
-- WORLD OBJECT TRACKER (event-driven)
-- ============================================================
local trackedObjects = {}

-- FIX: whitelist of names — onDescendantAdded exits immediately for irrelevant objects
local TRACKED_NAMES = { GunDrop = true, StuckKnife = true, Coin = true, CoinVisual = true }

local function applyGunHighlight(gun)
	for _, c in ipairs(gun:GetChildren()) do
		if c.Name == "GunHighlight" then c:Destroy() end
	end
	if not ESPDroppedGunEnabled then return end
	local h = Instance.new("Highlight")
	h.Name = "GunHighlight"
	h.FillTransparency    = FILL_TRANSPARENCY
	h.OutlineTransparency = OUTLINE_TRANSPARENCY
	h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	h.FillColor           = GUN_COLOR
	h.Parent              = gun
end

local function applyKnifeHighlight(knife)
	local h = knife:FindFirstChild("StuckKnifeHighlight")
	if not ShowThrownKnifeEnabled then if h then h:Destroy() end return end
	if not h then
		h = Instance.new("Highlight")
		h.Name = "StuckKnifeHighlight"
		h.FillTransparency    = FILL_TRANSPARENCY
		h.OutlineTransparency = OUTLINE_TRANSPARENCY
		h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
		h.FillColor           = STUCK_KNIFE_COLOR
		h.Parent              = knife
	end
	h.Enabled = true
end

local function applyCoinHighlight(obj)
	local target = obj
	if obj.Name == "CoinVisual" then
		local part = obj:FindFirstChild("MainCoin") or obj:FindFirstChildWhichIsA("BasePart")
		if part then target = part end
	end
	for _, c in ipairs(target:GetChildren()) do
		if c.Name == "CoinHighlight" then c:Destroy() end
	end
	if target ~= obj then
		for _, c in ipairs(obj:GetChildren()) do
			if c.Name == "CoinHighlight" then c:Destroy() end
		end
	end
	if not ShowCoinsEnabled then return end
	local h = Instance.new("Highlight")
	h.Name = "CoinHighlight"
	h.FillTransparency    = FILL_TRANSPARENCY
	h.OutlineTransparency = OUTLINE_TRANSPARENCY
	h.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
	h.FillColor           = COIN_COLOR
	h.Parent              = target
	h.Enabled             = true
end

-- FIX: gun drop notify — flag to skip notification on initial scan
local scriptJustLoaded = true
task.defer(function() scriptJustLoaded = false end)

-- FIX: cooldown so rapid DescendantAdded fires don't double-notify
local gunDropNotifyCooldown = false

local function onDescendantAdded(obj)
	local name = obj.Name
	if not TRACKED_NAMES[name] then return end

	if name == "GunDrop" then
		trackedObjects[obj] = "GunDrop"
		applyGunHighlight(obj)
		-- FIX: skip on initial scan, skip if on cooldown
		if GunDropNotifyEnabled and not scriptJustLoaded and not gunDropNotifyCooldown then
			gunDropNotifyCooldown = true
			task.delay(3, function() gunDropNotifyCooldown = false end)
			local ok, pos = pcall(function()
				return obj:IsA("Model") and obj:GetPivot().Position or obj:IsA("BasePart") and obj.Position
			end)
			if ok and pos then
				Notify("🔫 Gun Dropped!",
					"Dropped at (" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")",
					"alert-triangle", 6)
			else
				Notify("🔫 Gun Dropped!", "A gun was dropped on the map!", "alert-triangle", 6)
			end
		end
	elseif name == "StuckKnife" then
		trackedObjects[obj] = "StuckKnife"
		applyKnifeHighlight(obj)
	elseif name == "Coin" or name == "CoinVisual" then
		trackedObjects[obj] = "Coin"
		applyCoinHighlight(obj)
	end
end

local function onDescendantRemoving(obj)
	if trackedObjects[obj] then trackedObjects[obj] = nil end
end

-- FIX: use task.defer so initial scan doesn't block script load
task.defer(function()
	for _, obj in ipairs(workspace:GetDescendants()) do onDescendantAdded(obj) end
end)

trackConn(workspace.DescendantAdded:Connect(onDescendantAdded))
trackConn(workspace.DescendantRemoving:Connect(onDescendantRemoving))

local function refreshAllTrackedHighlights()
	for obj, kind in pairs(trackedObjects) do
		if kind == "GunDrop"        then applyGunHighlight(obj)
		elseif kind == "StuckKnife" then applyKnifeHighlight(obj)
		elseif kind == "Coin"       then applyCoinHighlight(obj) end
	end
end

-- ============================================================
-- ESP — event-driven player tracking
-- ============================================================
local function clearHighlight(char)
	local h = char:FindFirstChild("PlayerHighlight")
	if h then h:Destroy() end
end

local function clearChams(char)
	local h = char:FindFirstChild("ChamsHL_Single")
	if h then h:Destroy() end
end

local function clearBox(char)
	for _, obj in ipairs(char:GetChildren()) do
		if obj.Name == "PlayerBox" or obj.Name == "PlayerBoxOutline" then obj:Destroy() end
	end
end

local function clearAllESPOnCharacter(char)
	if char == LocalPlayer.Character then return end
	clearHighlight(char)
	clearChams(char)
	clearBox(char)
	local tag = char:FindFirstChild("NameTag")
	if tag then tag:Destroy() end
end

updatePlayer = function(player)
	if player == LocalPlayer then return end
	local char = player.Character
	if not char then return end

	local role  = getRole(player)
	local color = OTHER_PLAYER_COLOR
	if role == "Murderer"    then color = MURDERER_COLOR
	elseif role == "Sheriff" then color = SHERIFF_COLOR end

	local shouldShow = ESPEnabled and (
		(role == "Murderer" and MurdererESPEnabled)
		or (role == "Sheriff" and SheriffESPEnabled)
		or (role == "Other"   and InnocentESPEnabled)
	)

	-- Highlight
	if ESPStyles.Highlight and shouldShow then
		local hl = char:FindFirstChild("PlayerHighlight")
		if not hl then
			hl = Instance.new("Highlight")
			hl.Name      = "PlayerHighlight"
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent    = char
		end
		hl.FillColor           = color
		hl.OutlineColor        = color
		hl.FillTransparency    = HighlightFillTransp
		hl.OutlineTransparency = HighlightOutlineTransp
		hl.Enabled             = true
	else
		clearHighlight(char)
	end

	-- Chams — single Highlight on char (not per-part)
	if ESPStyles.Chams and shouldShow then
		local chl = char:FindFirstChild("ChamsHL_Single")
		if not chl then
			chl = Instance.new("Highlight")
			chl.Name      = "ChamsHL_Single"
			chl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			chl.Parent    = char
		end
		chl.FillColor           = color
		chl.OutlineColor        = color
		chl.FillTransparency    = ChamsFillTransp
		chl.OutlineTransparency = 0
		chl.Enabled             = true
	else
		clearChams(char)
	end

	-- Box
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if ESPStyles.Box and shouldShow and hrp then
		local box = char:FindFirstChild("PlayerBox")
		if not box then
			box = Instance.new("BoxHandleAdornment")
			box.Name        = "PlayerBox"
			box.Adornee     = hrp
			box.Size        = Vector3.new(4, 6, 2)
			box.AlwaysOnTop = true
			box.ZIndex      = 5
			box.Parent      = char
		end
		box.Color3       = color
		box.Transparency = BoxFillTransp
		if not char:FindFirstChild("PlayerBoxOutline") then
			local outline = Instance.new("BoxHandleAdornment")
			outline.Name         = "PlayerBoxOutline"
			outline.Adornee      = hrp
			outline.Size         = Vector3.new(4.15, 6.15, 2.15)
			outline.Color3       = Color3.new(0, 0, 0)
			outline.AlwaysOnTop  = true
			outline.Transparency = 0.85
			outline.ZIndex       = 4
			outline.Parent       = char
		end
	else
		clearBox(char)
	end

	-- Name tag
	local tag = char:FindFirstChild("NameTag")
	if not NameTagsEnabled or not shouldShow then
		if tag then tag:Destroy() end
	else
		if not tag then
			local head = char:FindFirstChild("Head")
			if head then
				tag = Instance.new("BillboardGui")
				tag.Name        = "NameTag"
				tag.Adornee     = head
				tag.Size        = UDim2.new(0, 100, 0, 20)
				tag.StudsOffset = Vector3.new(0, 2.5, 0)
				tag.AlwaysOnTop = true
				local txt = Instance.new("TextLabel")
				txt.Size = UDim2.new(1, 0, 1, 0)
				txt.BackgroundTransparency = 1
				txt.Text                   = player.Name
				txt.TextColor3             = color
				txt.TextStrokeTransparency = 0
				txt.Font                   = Enum.Font.SourceSansBold
				txt.TextScaled             = true
				txt.Parent = tag
				tag.Parent = char
			end
		else
			local txt = tag:FindFirstChildOfClass("TextLabel")
			if txt then txt.TextColor3 = color end
		end
	end
end

local function startTracking(player)
	local playerConns = {}

	-- FIX: watchPlayerRole gets playerConns so all connections are tracked
	watchPlayerRole(player, playerConns)

	local function onRoleChange()
		if not ESPEnabled then return end
		task.spawn(function()
			task.wait(0.1)
			invalidateRole(player)
			if player.Character then updatePlayer(player) end
		end)
	end

	-- FIX: charConns cleaned on each respawn AND on CharacterRemoving
	local charConns = {}
	local function wireChar(char)
		for _, c in ipairs(charConns) do pcall(function() c:Disconnect() end) end
		table.clear(charConns)
		if not ESPEnabled then return end
		table.insert(charConns, char.ChildAdded:Connect(onRoleChange))
		table.insert(charConns, char.ChildRemoved:Connect(onRoleChange))
	end

	if player.Character then
		wireChar(player.Character)
		if ESPEnabled then updatePlayer(player) end
	end

	table.insert(playerConns, player.CharacterAdded:Connect(function(char)
		invalidateRole(player)
		wireChar(char)
		task.wait(0.2)
		if ESPEnabled then updatePlayer(player) end
	end))

	table.insert(playerConns, player.CharacterRemoving:Connect(function(char)
		clearAllESPOnCharacter(char)
		for _, c in ipairs(charConns) do pcall(function() c:Disconnect() end) end
		table.clear(charConns)
	end))

	-- Store rewire function for when ESP is toggled on
	_G["HXN_REWIRE_" .. player.UserId] = function()
		if player.Character then wireChar(player.Character) end
	end

	registerPlayerConns(player.UserId, playerConns)
	_G["HXN_PCONNS_" .. player.UserId] = playerConns
end

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then startTracking(p) end
end

trackConn(Players.PlayerAdded:Connect(function(p)
	if p ~= LocalPlayer then startTracking(p) end
end))

trackConn(Players.PlayerRemoving:Connect(function(p)
	roleCache[p] = nil
	cleanupPlayerConns(p.UserId)
end))

-- ============================================================
-- TRACERS (untouched as requested)
-- ============================================================
local Camera      = workspace.CurrentCamera
local tracerLines = _G.HXN_TRACERS

-- ============================================================
-- MEMORY CLEANUP — every 60 seconds
-- FIX: no longer iterates _G table — uses playerConnRegistry instead
-- FIX: added to _G.HXN_TASKS so it cancels on reload
-- ============================================================
local cleanupTask = task.spawn(function()
	while true do
		task.wait(60)

		-- Remove dead tracked objects
		for obj in pairs(trackedObjects) do
			if not obj or not obj.Parent then
				trackedObjects[obj] = nil
			end
		end

		-- Clear stale role cache
		for player in pairs(roleCache) do
			if not player or not player.Parent then
				roleCache[player] = nil
			end
		end

		-- Clean dead tracer lines
		for player, line in pairs(tracerLines) do
			if not player.Parent then
				pcall(function() line:Remove() end)
				tracerLines[player] = nil
			end
		end

		-- FIX: clean playerConnRegistry for players who left
		-- Uses our own registry, not _G iteration
		local activePlayers = {}
		for _, p in ipairs(Players:GetPlayers()) do
			activePlayers[p.UserId] = true
		end
		for userId in pairs(playerConnRegistry) do
			if not activePlayers[userId] then
				cleanupPlayerConns(userId)
			end
		end

		-- Clean dead anti-fling heartbeats
		if not antiFlingEnabled and #antiFlingHeartbeats > 0 then
			for _, hb in ipairs(antiFlingHeartbeats) do pcall(function() hb:Disconnect() end) end
			antiFlingHeartbeats = {}
		end
	end
end)
table.insert(_G.HXN_TASKS, cleanupTask)

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then
		local line = Drawing.new("Line")
		line.Visible   = false
		line.Thickness = 1
		tracerLines[p] = line
	end
end

trackConn(Players.PlayerAdded:Connect(function(p)
	if p ~= LocalPlayer then
		local line = Drawing.new("Line")
		line.Visible   = false
		tracerLines[p] = line
	end
end))

trackConn(Players.PlayerRemoving:Connect(function(p)
	if tracerLines[p] then
		tracerLines[p]:Remove()
		tracerLines[p] = nil
	end
end))

local function startTracerLoop()
	if _G.HXN_TRACER_LOOP then return end
	local tracerTick = 0
	_G.HXN_TRACER_LOOP = RunService.Heartbeat:Connect(function()
		tracerTick = tracerTick + 1
		if tracerTick < 5 then return end
		tracerTick = 0
		for player, line in pairs(tracerLines) do
			local char = player.Character
			if not char then line.Visible = false continue end
			local root = char:FindFirstChild("HumanoidRootPart")
			if not root then line.Visible = false continue end
			local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
			if onScreen then
				line.Visible   = true
				line.From      = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				line.To        = Vector2.new(pos.X, pos.Y)
				local role     = getRole(player)
				line.Color     = role == "Murderer" and MURDERER_COLOR
					or role == "Sheriff" and SHERIFF_COLOR or OTHER_PLAYER_COLOR
				line.Thickness = 3
			else
				line.Visible = false
			end
		end
	end)
end

local function stopTracerLoop()
	if _G.HXN_TRACER_LOOP then
		_G.HXN_TRACER_LOOP:Disconnect()
		_G.HXN_TRACER_LOOP = nil
	end
	for _, line in pairs(tracerLines) do line.Visible = false end
end

-- ============================================================
-- VISUAL TAB
-- ============================================================
VisualTab:Section({ Title = "Sky Settings" })
local currentSky

local function applySky(skyName)
	if currentSky then currentSky:Destroy() currentSky = nil end
	if skyName == "Default" then return end
	local sky = Instance.new("Sky") sky.Name = "CustomSky"
	if skyName == "Aesthetic" then
		sky.SkyboxBk="rbxassetid://600830446" sky.SkyboxDn="rbxassetid://600831635"
		sky.SkyboxFt="rbxassetid://600832720" sky.SkyboxLf="rbxassetid://600886090"
		sky.SkyboxRt="rbxassetid://600833862" sky.SkyboxUp="rbxassetid://600835177"
	elseif skyName == "Night" then
		sky.SkyboxBk="rbxassetid://154185004" sky.SkyboxDn="rbxassetid://154184960"
		sky.SkyboxFt="rbxassetid://154185021" sky.SkyboxLf="rbxassetid://154184943"
		sky.SkyboxRt="rbxassetid://154184972" sky.SkyboxUp="rbxassetid://154185031"
	elseif skyName == "MC" then
		sky.SkyboxBk="rbxassetid://1876545003" sky.SkyboxDn="rbxassetid://1876544331"
		sky.SkyboxFt="rbxassetid://1876542941" sky.SkyboxLf="rbxassetid://1876543392"
		sky.SkyboxRt="rbxassetid://1876543764" sky.SkyboxUp="rbxassetid://1876544642"
	elseif skyName == "Pink" then
		sky.SkyboxBk="rbxassetid://271042516" sky.SkyboxDn="rbxassetid://271077243"
		sky.SkyboxFt="rbxassetid://271042556" sky.SkyboxLf="rbxassetid://271042310"
		sky.SkyboxRt="rbxassetid://271042467" sky.SkyboxUp="rbxassetid://271077958"
	end
	sky.Parent = Lighting
	currentSky = sky
end

VisualTab:Dropdown({
	Title = "Select Sky", Values = {"Default","Aesthetic","Night","MC","Pink"},
	Value = "Default", Multi = false, AllowNone = false,
	Callback = function(opt) if opt then applySky(opt) end end,
})

local BlurEffect, BloomEffect, ColorCorrection

VisualTab:Toggle({ Title = "Enable Blur", Value = false, Callback = function(v)
	if v then
		if not BlurEffect then BlurEffect = Instance.new("BlurEffect") BlurEffect.Size = 8 BlurEffect.Parent = Lighting end
	else
		if BlurEffect then BlurEffect:Destroy() BlurEffect = nil end
	end
end })

VisualTab:Toggle({ Title = "Enable Bloom", Value = false, Callback = function(v)
	if v then
		if not BloomEffect then
			BloomEffect = Instance.new("BloomEffect")
			BloomEffect.Intensity = 1.5 BloomEffect.Threshold = 0.8 BloomEffect.Parent = Lighting
		end
	else
		if BloomEffect then BloomEffect:Destroy() BloomEffect = nil end
	end
end })

VisualTab:Toggle({ Title = "Enable Color Correction", Value = false, Callback = function(v)
	if v then
		if not ColorCorrection then
			ColorCorrection = Instance.new("ColorCorrectionEffect")
			ColorCorrection.Saturation = 0.3 ColorCorrection.Contrast = 0.2 ColorCorrection.Parent = Lighting
		end
	else
		if ColorCorrection then ColorCorrection:Destroy() ColorCorrection = nil end
	end
end })

-- ============================================================
-- AUTOFARM — DISABLED (WIP)
-- ============================================================
AutofarmTab:Section({ Title = "Autofarm — Work In Progress" })
AutofarmTab:Paragraph({
	Title = "Coming Soon",
	Desc  = "Autofarm is temporarily disabled while it\'s being reworked.\nCheck back in a future update.",
})

-- ============================================================
-- TELEPORT
-- ============================================================
local knownMapNames = {
	"Bank2","BioLab","Factory","Hospital3","Hotel2","House2","Mansion2",
	"MilBase","Office3","PoliceStation","ResearchFacility","Workplace"
}

local function teleportToLobby()
	local char = LocalPlayer and LocalPlayer.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local lobby  = workspace:FindFirstChild("Lobby")
	local spawns = lobby and lobby:FindFirstChild("Spawns")
	if not spawns then return end
	local pts = {}
	for _, obj in ipairs(spawns:GetChildren()) do if obj:IsA("SpawnLocation") then table.insert(pts, obj) end end
	if #pts == 0 then return end
	hrp.CFrame = pts[math.random(1, #pts)].CFrame + Vector3.new(0, 3, 0)
end

local function teleportToMap()
	local char = LocalPlayer and LocalPlayer.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local map
	for _, name in ipairs(knownMapNames) do map = workspace:FindFirstChild(name) if map then break end end
	if not map then return end
	local spawns = map:FindFirstChild("Spawns") if not spawns then return end
	local pts = {}
	for _, obj in ipairs(spawns:GetChildren()) do
		if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then table.insert(pts, obj) end
	end
	if #pts == 0 then return end
	hrp.CFrame = pts[math.random(1, #pts)].CFrame + Vector3.new(0, 3, 0)
end

local function teleportToSecretPlace()
	local char = LocalPlayer and LocalPlayer.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then hrp.CFrame = CFrame.new(319, 537, 89) end
end

local function findGun()
	for obj, kind in pairs(trackedObjects) do
		if kind == "GunDrop" and obj.Parent then
			local ok, pos = pcall(function()
				return obj:IsA("Model") and obj:GetPivot().Position
					or obj:IsA("BasePart") and obj.Position
			end)
			if ok and pos then return pos end
		end
	end
	return nil
end

local function teleportToGun()
	local char = LocalPlayer and LocalPlayer.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local gunPos = findGun()
	if not gunPos then Notify("Teleport", "No gun found on the map.", "x", 3) return end
	OriginalPosition = hrp.CFrame
	hrp.CFrame       = CFrame.new(gunPos + Vector3.new(0, 3, 0))
	IsAtGun          = true
	Notify("Teleport", "Teleported to gun successfully!", "check", 3)
	local cancelConn
	cancelConn = LocalPlayer.CharacterRemoving:Connect(function()
		IsAtGun = false
		cancelConn:Disconnect()
	end)
	task.spawn(function()
		while IsAtGun do
			task.wait(0.3)
			local plr = Players.LocalPlayer
			if not plr or not plr.Character then IsAtGun = false break end
			local bp     = plr:FindFirstChildOfClass("Backpack")
			local hasGun = (bp and bp:FindFirstChild("Gun")) or plr.Character:FindFirstChild("Gun")
			if hasGun and OriginalPosition then
				plr.Character.HumanoidRootPart.CFrame = OriginalPosition
				IsAtGun = false
				cancelConn:Disconnect()
				Notify("Teleport", "Gun picked up! Returned to original position.", "check", 3)
				break
			end
		end
	end)
end

local function returnToOriginalPos()
	local char = LocalPlayer and LocalPlayer.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	if not OriginalPosition then Notify("Teleport", "No saved position.", "x", 3) return end
	hrp.CFrame = OriginalPosition
	IsAtGun    = false
	Notify("Teleport", "Returned to original position.", "check", 3)
end

TeleportTab:Section({ Title = "Gun Teleport" })

TeleportTab:Button({
	Title = "Teleport to Gun / Return",
	Callback = function()
		if not IsAtGun then teleportToGun() else returnToOriginalPos() end
	end,
})

local GunTPKeybindEnabled = false

TeleportTab:Toggle({
	Title = "Enable Gun TP Keybind", Value = false,
	Callback = function(v) GunTPKeybindEnabled = v end,
})

TeleportTab:Keybind({
	Title = "Gun TP Keybind", Value = "F",
	Callback = function(keyName)
		local ok, key = pcall(function() return Enum.KeyCode[keyName] end)
		if ok and key then GunTPKeybind = key end
	end,
})

TeleportTab:Section({ Title = "Map Teleports" })
TeleportTab:Button({ Title = "TP To Lobby",       Callback = function() teleportToLobby()      Notify("Teleport","Teleported to Lobby.","check",2) end })
TeleportTab:Button({ Title = "TP To Map",          Callback = function() teleportToMap()         Notify("Teleport","Teleported to Map.","check",2) end })
TeleportTab:Button({ Title = "TP To Secret Place", Callback = function() teleportToSecretPlace() Notify("Teleport","Teleported to Secret Place.","check",2) end })

TeleportTab:Section({ Title = "Player Teleport" })
do
	local selectedTP = nil
	local tpDrop = TeleportTab:Dropdown({
		Title = "Select Player", Values = GetPlayerList(), Value = "None",
		Multi = false, AllowNone = true,
		Callback = function(opt) selectedTP = opt end,
	})
	local function refreshTP()
		if tpDrop then tpDrop:Refresh(GetPlayerList()) end
	end
	trackConn(Players.PlayerAdded:Connect(refreshTP))
	trackConn(Players.PlayerRemoving:Connect(function(p)
		if selectedTP == p.Name then selectedTP = nil end
		refreshTP()
	end))
	TeleportTab:Button({
		Title = "TP to Selected Player",
		Callback = function()
			if not selectedTP or selectedTP == "None" then Notify("Teleport","No player selected.","x",3) return end
			local target
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Name == selectedTP and p ~= LocalPlayer then target = p break end
			end
			if not target or not target.Character then Notify("Teleport","Player not found.","x",3) return end
			local lhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			local thrp = target.Character:FindFirstChild("HumanoidRootPart")
			if lhrp and thrp then
				lhrp.CFrame = thrp.CFrame + Vector3.new(0, 3, 0)
				Notify("Teleport", "Teleported to " .. selectedTP .. ".", "check", 3)
			end
		end,
	})
end

trackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if GunTPKeybindEnabled and input.KeyCode == GunTPKeybind then
		if not IsAtGun then teleportToGun() else returnToOriginalPos() end
	end
end))

-- ============================================================
-- TROLLING TAB
-- ============================================================
getgenv().FPDH   = workspace.FallenPartsDestroyHeight
getgenv().OldPos = nil

local FlingActive         = false
local SelectedFlingTarget = nil

local function SkidFling(TargetPlayer)
	local Player    = Players.LocalPlayer
	local Character = Player.Character
	local Humanoid  = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart  = Humanoid and Humanoid.RootPart
	local TChar     = TargetPlayer.Character
	if not TChar or not Character or not Humanoid or not RootPart then return end

	local THumanoid = TChar:FindFirstChildOfClass("Humanoid")
	local TRootPart = THumanoid and THumanoid.RootPart
	local THead     = TChar:FindFirstChild("Head")
	local Accessory = TChar:FindFirstChildOfClass("Accessory")
	local Handle    = Accessory and Accessory:FindFirstChild("Handle")

	if not TChar:FindFirstChildWhichIsA("BasePart") then return end
	if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
	if THumanoid and THumanoid.Sit then return end

	if THead      then workspace.CurrentCamera.CameraSubject = THead
	elseif Handle then workspace.CurrentCamera.CameraSubject = Handle
	elseif THumanoid and TRootPart then workspace.CurrentCamera.CameraSubject = THumanoid end

	local FPos = function(BasePart, Pos, Ang)
		RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
		Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
		RootPart.Velocity    = Vector3.new(9e7, 9e7 * 10, 9e7)
		RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
	end

	local SFBasePart = function(BasePart)
		local Time  = tick()
		local Angle = 0
		repeat
			if RootPart and THumanoid then
				if BasePart.Velocity.Magnitude < 50 then
					Angle = Angle + 100
					FPos(BasePart, CFrame.new(0,1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,-1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,-1.5,0)+THumanoid.MoveDirection*BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,1.5,0)+THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,-1.5,0)+THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0)) task.wait()
				else
					FPos(BasePart, CFrame.new(0,1.5,THumanoid.WalkSpeed),  CFrame.Angles(math.rad(90),0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,-1.5,-THumanoid.WalkSpeed), CFrame.Angles(0,0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,1.5,THumanoid.WalkSpeed),  CFrame.Angles(math.rad(90),0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(90),0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(90),0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0)) task.wait()
				end
			end
		until Time + 2 < tick() or not FlingActive
	end

	local FPDH_BACKUP = getgenv().FPDH or workspace.FallenPartsDestroyHeight
	local ok, err = pcall(function()
		workspace.FallenPartsDestroyHeight = -1e9
		local BV = Instance.new("BodyVelocity")
		BV.Parent   = RootPart
		BV.Velocity = Vector3.new()
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		if TRootPart then SFBasePart(TRootPart)
		elseif THead  then SFBasePart(THead)
		elseif Handle then SFBasePart(Handle) end
		BV:Destroy()
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		workspace.CurrentCamera.CameraSubject = Humanoid
	end)
	workspace.FallenPartsDestroyHeight = FPDH_BACKUP
	if not ok then warn("[HXN] Fling error: " .. tostring(err)) end

	if getgenv().OldPos then
		local attempts = 0
		repeat
			attempts = attempts + 1
			pcall(function()
				RootPart.CFrame = getgenv().OldPos * CFrame.new(0, 0.5, 0)
				Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, 0.5, 0))
				Humanoid:ChangeState("GettingUp")
				for _, part in pairs(Character:GetChildren()) do
					if part:IsA("BasePart") then
						part.Velocity    = Vector3.new()
						part.RotVelocity = Vector3.new()
					end
				end
			end)
			task.wait()
		until attempts > 60 or (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
	end
end

local function StartFling()
	if FlingActive or not SelectedFlingTarget then return end
	FlingActive = true
	task.spawn(function()
		while FlingActive do
			local target
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Name == SelectedFlingTarget and p ~= LocalPlayer then target = p break end
			end
			if target and target.Parent then
				SkidFling(target) task.wait(0.1)
			else
				FlingActive = false break
			end
		end
	end)
end

local function StopFling() FlingActive = false end

local function FlingAll()
	if FlingActive then return end
	FlingActive = true
	task.spawn(function()
		while FlingActive do
			local targets = {}
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character then table.insert(targets, p) end
			end
			if #targets == 0 then FlingActive = false break end
			for _, p in ipairs(targets) do
				if FlingActive then SkidFling(p) task.wait(0.1) else break end
			end
			task.wait(0.5)
		end
	end)
end

TrollingTab:Section({ Title = "Select Target" })
do
	local flingDrop = TrollingTab:Dropdown({
		Title = "Select Player", Values = GetPlayerList(), Value = "None",
		Callback = function(opt) SelectedFlingTarget = opt end,
	})
	local function refreshFling()
		if flingDrop then flingDrop:Refresh(GetPlayerList()) end
	end
	trackConn(Players.PlayerAdded:Connect(refreshFling))
	trackConn(Players.PlayerRemoving:Connect(function(p)
		if SelectedFlingTarget == p.Name then SelectedFlingTarget = nil end
		refreshFling()
	end))
end

TrollingTab:Section({ Title = "Fling Controls" })
TrollingTab:Button({ Title = "Start Flinging", Callback = StartFling })
TrollingTab:Button({ Title = "Stop Flinging",  Callback = StopFling  })

TrollingTab:Section({ Title = "Fling by Role" })
do
	local function flingRole(role)
		local target
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and getRole(p) == role then target = p break end
		end
		if target then SelectedFlingTarget = target.Name StartFling()
		else Notify("Trolling", "No " .. role .. " found.", "x", 3) end
	end
	TrollingTab:Button({ Title = "Fling Murderer", Callback = function() flingRole("Murderer") end })
	TrollingTab:Button({ Title = "Fling Sheriff",  Callback = function() flingRole("Sheriff")  end })
end

TrollingTab:Section({ Title = "Fling All" })
TrollingTab:Button({ Title = "Fling All Players", Callback = FlingAll })

-- ── Spin ──────────────────────────────────────────────────────
local spinEnabled = false
local spinSpeed   = 10
local spinConn    = nil

local function startSpin()
	if spinConn then spinConn:Disconnect() spinConn = nil end
	local char = LocalPlayer and LocalPlayer.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local spinTick = 0
	spinConn = RunService.Heartbeat:Connect(function()
		spinTick = spinTick + 1
		if spinTick < 2 then return end
		spinTick = 0
		if not spinEnabled then spinConn:Disconnect() spinConn = nil return end
		if not hrp.Parent then
			local newChar = LocalPlayer and LocalPlayer.Character
			hrp = newChar and newChar:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
		end
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
	end)
end

local function stopSpin()
	spinEnabled = false
	if spinConn then spinConn:Disconnect() spinConn = nil end
end

trackConn(LocalPlayer.CharacterAdded:Connect(function()
	if spinEnabled then task.wait(0.5) startSpin() end
end))

TrollingTab:Section({ Title = "Spin" })
TrollingTab:Toggle({
	Title = "Spin", Value = false,
	Callback = function(v)
		spinEnabled = v
		if v then startSpin() Notify("Trolling","Spin enabled!","zap",2)
		else stopSpin() Notify("Trolling","Spin disabled.","x",2) end
	end,
})

do
	local s = TrollingTab:Slider({ Title = "Spin Speed", Step = 1, Value = { Min = 1, Max = 50, Default = 10 },
		Callback = function(v) spinSpeed = v end })
	if s and s.Instance then
		s.Instance.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseWheel then
				s:SetValue(math.clamp(spinSpeed + (i.Position.Z > 0 and 1 or -1), 1, 50))
			end
		end)
	end
end

-- ============================================================
-- ESP TAB
-- ============================================================
local function refreshAllESP()
	if not ESPEnabled then return end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then updatePlayer(p) end
	end
end

ESPTab:Section({ Title = "Main Control" })
ESPTab:Toggle({
	Title = "ESP", Default = false,
	Callback = function(v)
		ESPEnabled = v
		if not v then
			stopRoleDetector()
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character then clearAllESPOnCharacter(p.Character) end
			end
		else
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then
					local rewire = _G["HXN_REWIRE_" .. p.UserId]
					if rewire then rewire() end
				end
			end
			startRoleDetector()
			refreshAllESP()
		end
	end,
})

ESPTab:Section({ Title = "ESP Style" })
ESPTab:Toggle({ Title = "Highlight", Default = false, Callback = function(v)
	ESPStyles.Highlight = v
	if not v then for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then clearHighlight(p.Character) end
	end end
	refreshAllESP()
end })

ESPTab:Toggle({ Title = "Chams (through walls)", Default = false, Callback = function(v)
	ESPStyles.Chams = v
	if not v then for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then clearChams(p.Character) end
	end end
	refreshAllESP()
end })

ESPTab:Toggle({ Title = "Box", Default = false, Callback = function(v)
	ESPStyles.Box = v
	if not v then for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then clearBox(p.Character) end
	end end
	refreshAllESP()
end })

ESPTab:Section({ Title = "Highlight Settings" })
do
	local s = ESPTab:Slider({ Title = "Highlight Fill Transparency", Step = 0.05,
		Value = { Min = 0, Max = 1, Default = 0.5 },
		Callback = function(v) HighlightFillTransp = v if ESPStyles.Highlight then refreshAllESP() end end })
	if s and s.Instance then
		s.Instance.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseWheel then
				s:SetValue(math.clamp(HighlightFillTransp + (i.Position.Z > 0 and -0.05 or 0.05), 0, 1))
			end
		end)
	end
end
do
	local s = ESPTab:Slider({ Title = "Highlight Outline Transparency", Step = 0.05,
		Value = { Min = 0, Max = 1, Default = 0.0 },
		Callback = function(v) HighlightOutlineTransp = v if ESPStyles.Highlight then refreshAllESP() end end })
	if s and s.Instance then
		s.Instance.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseWheel then
				s:SetValue(math.clamp(HighlightOutlineTransp + (i.Position.Z > 0 and -0.05 or 0.05), 0, 1))
			end
		end)
	end
end

ESPTab:Section({ Title = "Chams Settings" })
do
	local s = ESPTab:Slider({ Title = "Chams Fill Transparency", Step = 0.05,
		Value = { Min = 0, Max = 1, Default = 0.5 },
		Callback = function(v) ChamsFillTransp = v if ESPStyles.Chams then refreshAllESP() end end })
	if s and s.Instance then
		s.Instance.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseWheel then
				s:SetValue(math.clamp(ChamsFillTransp + (i.Position.Z > 0 and -0.05 or 0.05), 0, 1))
			end
		end)
	end
end

ESPTab:Section({ Title = "Box Settings" })
do
	local s = ESPTab:Slider({ Title = "Box Fill Transparency", Step = 0.05,
		Value = { Min = 0, Max = 1, Default = 0.8 },
		Callback = function(v) BoxFillTransp = v if ESPStyles.Box then refreshAllESP() end end })
	if s and s.Instance then
		s.Instance.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseWheel then
				s:SetValue(math.clamp(BoxFillTransp + (i.Position.Z > 0 and -0.05 or 0.05), 0, 1))
			end
		end)
	end
end

ESPTab:Section({ Title = "ESP Options" })
ESPTab:Toggle({ Title = "ESP Names", Default = false, Callback = function(v) NameTagsEnabled = v refreshAllESP() end })

ESPTab:Section({ Title = "Dropped Items" })
ESPTab:Toggle({ Title = "ESP Dropped Gun", Default = false, Callback = function(v)
	ESPDroppedGunEnabled = v
	if v then
		for obj, kind in pairs(trackedObjects) do
			if kind == "GunDrop" then applyGunHighlight(obj) end
		end
	else
		refreshAllTrackedHighlights()
	end
end })

ESPTab:Toggle({ Title = "Show Coins", Default = false, Callback = function(v)
	ShowCoinsEnabled = v
	if v then
		for obj, kind in pairs(trackedObjects) do
			if kind == "Coin" then applyCoinHighlight(obj) end
		end
	else
		-- FIX: use trackedObjects only, no workspace scan
		for obj, kind in pairs(trackedObjects) do
			if kind == "Coin" and obj.Parent then
				for _, child in ipairs(obj:GetChildren()) do
					if child.Name == "CoinHighlight" then pcall(function() child:Destroy() end) end
				end
			end
		end
	end
end })

ESPTab:Toggle({ Title = "Show Thrown Knife (StuckKnife)", Default = false, Callback = function(v)
	ShowThrownKnifeEnabled = v
	if v then
		for obj, kind in pairs(trackedObjects) do
			if kind == "StuckKnife" then applyKnifeHighlight(obj) end
		end
	else
		refreshAllTrackedHighlights()
	end
end })

ESPTab:Section({ Title = "Role ESP" })
local function refreshAfterRoleToggle()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then clearAllESPOnCharacter(p.Character) end
	end
	if ESPEnabled then refreshAllESP() end
end

ESPTab:Toggle({ Title = "Innocent ESP", Value = true, Callback = function(v) InnocentESPEnabled = v refreshAfterRoleToggle() end })
ESPTab:Toggle({ Title = "Sheriff ESP",  Value = true, Callback = function(v) SheriffESPEnabled  = v refreshAfterRoleToggle() end })
ESPTab:Toggle({ Title = "Murderer ESP", Value = true, Callback = function(v) MurdererESPEnabled = v refreshAfterRoleToggle() end })

ESPTab:Section({ Title = "Tracers" })
ESPTab:Toggle({
	Title = "Player Tracers", Default = false,
	Callback = function(v)
		TracersEnabled = v
		if v then startTracerLoop() else stopTracerLoop() end
	end,
})

print("[HXN] Script fully loaded — v8.5.0")
