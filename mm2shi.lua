-- Prevent double-loading
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
	_G.HXN_TASKS = {}
end

if _G.HXN_CONNECTIONS then
	for _, connection in ipairs(_G.HXN_CONNECTIONS) do pcall(function() connection:Disconnect() end) end
	_G.HXN_CONNECTIONS = {}
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local ESP_CLEANUP_NAMES = {
	PlayerHighlight = true, PlayerBox = true, PlayerBoxOutline = true,
	NameTag = true, ChamHL = true,
}
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		for _, obj in ipairs(player.Character:GetDescendants()) do
			if ESP_CLEANUP_NAMES[obj.Name] then
				pcall(function() obj:Destroy() end)
			end
		end
	end
end

pcall(function()
	local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
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

----------------------------------------------------------------
-- LOAD WIND UI
----------------------------------------------------------------
print("[HXN] Loading Wind UI...")
local success, WindUI = pcall(function()
	return indloadstring(game:HttpGet("https://github.com/Footagesus/WUI/releases/latest/download/main.lua"))()
end)
if not success or not WindUI then
	print("[HXN] ERROR: Failed to load Wind UI! " .. tostring(WindUI))
	return
end
_G.HXN_WINDUI = WindUI
WindUI.TransparencyValue = 0.35

local RedBlackTheme = {
	Name = "RedBlack",
	Accent = Color3.fromRGB(20, 20, 20), Dialog = Color3.fromRGB(15, 15, 15),
	Outline = Color3.fromRGB(255, 50, 50), Text = Color3.fromRGB(240, 240, 240),
	Placeholder = Color3.fromRGB(120, 40, 40), Background = Color3.fromRGB(15, 15, 15),
	Button = Color3.fromRGB(15, 15, 15), Icon = Color3.fromRGB(255, 70, 70),
	Toggle = Color3.fromRGB(0, 200, 80), Slider = Color3.fromRGB(220, 0, 0),
	Checkbox = Color3.fromRGB(0, 200, 80), PanelBackground = Color3.fromRGB(25, 25, 25),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(255, 0, 0),
	SliderIcon = Color3.fromRGB(180, 45, 45), TabBackground = Color3.fromRGB(25, 25, 25),
	TabBackgroundHover = Color3.fromRGB(35, 35, 35), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(50, 20, 20), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(240, 240, 240), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(255, 70, 70),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(255, 50, 50), ElementBackground = Color3.fromRGB(15, 15, 15),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(240, 240, 240),
	ElementDesc = Color3.fromRGB(180, 180, 180), ElementIcon = Color3.fromRGB(255, 70, 70),
	WindowBackground = Color3.fromRGB(15, 15, 15), WindowTopbarTitle = Color3.fromRGB(240, 240, 240),
	WindowTopbarAuthor = Color3.fromRGB(255, 70, 70), WindowTopbarIcon = Color3.fromRGB(255, 70, 70),
	WindowTopbarButtonIcon = Color3.fromRGB(255, 70, 70), Hover = Color3.fromRGB(50, 20, 20),
	LabelBackground = Color3.fromRGB(25, 25, 25), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(25, 25, 25), NotificationTitle = Color3.fromRGB(240, 240, 240),
	NotificationContent = Color3.fromRGB(180, 180, 180), NotificationDuration = Color3.fromRGB(0, 255, 100),
	NotificationBorder = Color3.fromRGB(0, 255, 100), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(15, 15, 15), TooltipText = Color3.fromRGB(240, 240, 240),
	TooltipSecondary = Color3.fromRGB(0, 255, 100), TooltipSecondaryText = Color3.fromRGB(255, 255, 255),
	WindowSearchBarBackground = Color3.fromRGB(35, 35, 35), SearchBarBorder = Color3.fromRGB(255, 50, 50),
	SearchBarBorderTransparency = 0.5,
}
WindUI:AddTheme(RedBlackTheme)

-- NeonPurple
WindUI:AddTheme({
	Name = "NeonPurple",
	Accent = Color3.fromRGB(20, 0, 30), Dialog = Color3.fromRGB(12, 0, 20),
	Outline = Color3.fromRGB(180, 0, 255), Text = Color3.fromRGB(240, 240, 240),
	Placeholder = Color3.fromRGB(90, 0, 130), Background = Color3.fromRGB(12, 0, 20),
	Button = Color3.fromRGB(20, 0, 30), Icon = Color3.fromRGB(200, 80, 255),
	Toggle = Color3.fromRGB(180, 0, 255), Slider = Color3.fromRGB(160, 0, 230),
	Checkbox = Color3.fromRGB(180, 0, 255), PanelBackground = Color3.fromRGB(25, 0, 38),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(180, 0, 255),
	SliderIcon = Color3.fromRGB(130, 0, 190), TabBackground = Color3.fromRGB(22, 0, 35),
	TabBackgroundHover = Color3.fromRGB(35, 0, 55), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(50, 0, 75), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(240, 240, 240), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(200, 80, 255),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(180, 0, 255), ElementBackground = Color3.fromRGB(15, 0, 25),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(240, 240, 240),
	ElementDesc = Color3.fromRGB(200, 160, 220), ElementIcon = Color3.fromRGB(200, 80, 255),
	WindowBackground = Color3.fromRGB(12, 0, 20), WindowTopbarTitle = Color3.fromRGB(240, 240, 240),
	WindowTopbarAuthor = Color3.fromRGB(200, 80, 255), WindowTopbarIcon = Color3.fromRGB(200, 80, 255),
	WindowTopbarButtonIcon = Color3.fromRGB(200, 80, 255), Hover = Color3.fromRGB(50, 0, 75),
	LabelBackground = Color3.fromRGB(25, 0, 38), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(20, 0, 30), NotificationTitle = Color3.fromRGB(240, 240, 240),
	NotificationContent = Color3.fromRGB(200, 160, 220), NotificationDuration = Color3.fromRGB(180, 0, 255),
	NotificationBorder = Color3.fromRGB(180, 0, 255), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(12, 0, 20), TooltipText = Color3.fromRGB(240, 240, 240),
	TooltipSecondary = Color3.fromRGB(180, 0, 255), TooltipSecondaryText = Color3.fromRGB(255, 255, 255),
	WindowSearchBarBackground = Color3.fromRGB(30, 0, 45), SearchBarBorder = Color3.fromRGB(180, 0, 255),
	SearchBarBorderTransparency = 0.5,
})

-- NeonBlue
WindUI:AddTheme({
	Name = "NeonBlue",
	Accent = Color3.fromRGB(0, 10, 30), Dialog = Color3.fromRGB(0, 8, 22),
	Outline = Color3.fromRGB(0, 180, 255), Text = Color3.fromRGB(220, 240, 255),
	Placeholder = Color3.fromRGB(0, 70, 120), Background = Color3.fromRGB(0, 8, 22),
	Button = Color3.fromRGB(0, 10, 30), Icon = Color3.fromRGB(0, 200, 255),
	Toggle = Color3.fromRGB(0, 180, 255), Slider = Color3.fromRGB(0, 150, 230),
	Checkbox = Color3.fromRGB(0, 180, 255), PanelBackground = Color3.fromRGB(0, 15, 38),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(0, 180, 255),
	SliderIcon = Color3.fromRGB(0, 120, 190), TabBackground = Color3.fromRGB(0, 12, 30),
	TabBackgroundHover = Color3.fromRGB(0, 25, 55), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(0, 35, 70), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(220, 240, 255), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(0, 200, 255),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(0, 180, 255), ElementBackground = Color3.fromRGB(0, 10, 25),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(220, 240, 255),
	ElementDesc = Color3.fromRGB(140, 200, 230), ElementIcon = Color3.fromRGB(0, 200, 255),
	WindowBackground = Color3.fromRGB(0, 8, 22), WindowTopbarTitle = Color3.fromRGB(220, 240, 255),
	WindowTopbarAuthor = Color3.fromRGB(0, 200, 255), WindowTopbarIcon = Color3.fromRGB(0, 200, 255),
	WindowTopbarButtonIcon = Color3.fromRGB(0, 200, 255), Hover = Color3.fromRGB(0, 35, 70),
	LabelBackground = Color3.fromRGB(0, 15, 38), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(0, 10, 30), NotificationTitle = Color3.fromRGB(220, 240, 255),
	NotificationContent = Color3.fromRGB(140, 200, 230), NotificationDuration = Color3.fromRGB(0, 180, 255),
	NotificationBorder = Color3.fromRGB(0, 180, 255), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(0, 8, 22), TooltipText = Color3.fromRGB(220, 240, 255),
	TooltipSecondary = Color3.fromRGB(0, 180, 255), TooltipSecondaryText = Color3.fromRGB(255, 255, 255),
	WindowSearchBarBackground = Color3.fromRGB(0, 18, 40), SearchBarBorder = Color3.fromRGB(0, 180, 255),
	SearchBarBorderTransparency = 0.5,
})

-- NeonGreen
WindUI:AddTheme({
	Name = "NeonGreen",
	Accent = Color3.fromRGB(0, 20, 10), Dialog = Color3.fromRGB(0, 12, 6),
	Outline = Color3.fromRGB(0, 255, 120), Text = Color3.fromRGB(220, 255, 235),
	Placeholder = Color3.fromRGB(0, 100, 50), Background = Color3.fromRGB(0, 12, 6),
	Button = Color3.fromRGB(0, 18, 9), Icon = Color3.fromRGB(0, 255, 120),
	Toggle = Color3.fromRGB(0, 255, 120), Slider = Color3.fromRGB(0, 200, 90),
	Checkbox = Color3.fromRGB(0, 255, 120), PanelBackground = Color3.fromRGB(0, 22, 12),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(0, 255, 120),
	SliderIcon = Color3.fromRGB(0, 160, 80), TabBackground = Color3.fromRGB(0, 18, 10),
	TabBackgroundHover = Color3.fromRGB(0, 35, 18), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(0, 50, 25), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(220, 255, 235), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(0, 255, 120),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(0, 255, 120), ElementBackground = Color3.fromRGB(0, 14, 7),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(220, 255, 235),
	ElementDesc = Color3.fromRGB(140, 220, 170), ElementIcon = Color3.fromRGB(0, 255, 120),
	WindowBackground = Color3.fromRGB(0, 12, 6), WindowTopbarTitle = Color3.fromRGB(220, 255, 235),
	WindowTopbarAuthor = Color3.fromRGB(0, 255, 120), WindowTopbarIcon = Color3.fromRGB(0, 255, 120),
	WindowTopbarButtonIcon = Color3.fromRGB(0, 255, 120), Hover = Color3.fromRGB(0, 50, 25),
	LabelBackground = Color3.fromRGB(0, 22, 12), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(0, 18, 9), NotificationTitle = Color3.fromRGB(220, 255, 235),
	NotificationContent = Color3.fromRGB(140, 220, 170), NotificationDuration = Color3.fromRGB(0, 255, 120),
	NotificationBorder = Color3.fromRGB(0, 255, 120), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(0, 12, 6), TooltipText = Color3.fromRGB(220, 255, 235),
	TooltipSecondary = Color3.fromRGB(0, 255, 120), TooltipSecondaryText = Color3.fromRGB(255, 255, 255),
	WindowSearchBarBackground = Color3.fromRGB(0, 25, 13), SearchBarBorder = Color3.fromRGB(0, 255, 120),
	SearchBarBorderTransparency = 0.5,
})

-- Sunset (orange/pink)
WindUI:AddTheme({
	Name = "Sunset",
	Accent = Color3.fromRGB(30, 10, 5), Dialog = Color3.fromRGB(20, 8, 5),
	Outline = Color3.fromRGB(255, 100, 30), Text = Color3.fromRGB(255, 235, 220),
	Placeholder = Color3.fromRGB(150, 60, 20), Background = Color3.fromRGB(20, 8, 5),
	Button = Color3.fromRGB(30, 10, 5), Icon = Color3.fromRGB(255, 130, 60),
	Toggle = Color3.fromRGB(255, 80, 120), Slider = Color3.fromRGB(255, 100, 30),
	Checkbox = Color3.fromRGB(255, 80, 120), PanelBackground = Color3.fromRGB(38, 15, 8),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(255, 100, 30),
	SliderIcon = Color3.fromRGB(200, 70, 20), TabBackground = Color3.fromRGB(30, 12, 6),
	TabBackgroundHover = Color3.fromRGB(50, 20, 10), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(70, 25, 10), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(255, 235, 220), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(255, 130, 60),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(255, 100, 30), ElementBackground = Color3.fromRGB(22, 9, 5),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(255, 235, 220),
	ElementDesc = Color3.fromRGB(230, 180, 150), ElementIcon = Color3.fromRGB(255, 130, 60),
	WindowBackground = Color3.fromRGB(20, 8, 5), WindowTopbarTitle = Color3.fromRGB(255, 235, 220),
	WindowTopbarAuthor = Color3.fromRGB(255, 130, 60), WindowTopbarIcon = Color3.fromRGB(255, 130, 60),
	WindowTopbarButtonIcon = Color3.fromRGB(255, 130, 60), Hover = Color3.fromRGB(70, 25, 10),
	LabelBackground = Color3.fromRGB(38, 15, 8), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(30, 10, 5), NotificationTitle = Color3.fromRGB(255, 235, 220),
	NotificationContent = Color3.fromRGB(230, 180, 150), NotificationDuration = Color3.fromRGB(255, 80, 120),
	NotificationBorder = Color3.fromRGB(255, 80, 120), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(20, 8, 5), TooltipText = Color3.fromRGB(255, 235, 220),
	TooltipSecondary = Color3.fromRGB(255, 100, 30), TooltipSecondaryText = Color3.fromRGB(255, 255, 255),
	WindowSearchBarBackground = Color3.fromRGB(40, 16, 8), SearchBarBorder = Color3.fromRGB(255, 100, 30),
	SearchBarBorderTransparency = 0.5,
})

-- Ice (white/cyan)
WindUI:AddTheme({
	Name = "Ice",
	Accent = Color3.fromRGB(210, 235, 255), Dialog = Color3.fromRGB(225, 245, 255),
	Outline = Color3.fromRGB(80, 180, 255), Text = Color3.fromRGB(20, 40, 70),
	Placeholder = Color3.fromRGB(130, 180, 220), Background = Color3.fromRGB(225, 245, 255),
	Button = Color3.fromRGB(210, 235, 255), Icon = Color3.fromRGB(0, 150, 230),
	Toggle = Color3.fromRGB(0, 180, 255), Slider = Color3.fromRGB(80, 180, 255),
	Checkbox = Color3.fromRGB(0, 180, 255), PanelBackground = Color3.fromRGB(200, 228, 250),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(80, 180, 255),
	SliderIcon = Color3.fromRGB(60, 140, 210), TabBackground = Color3.fromRGB(205, 232, 255),
	TabBackgroundHover = Color3.fromRGB(185, 218, 248), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(170, 210, 245), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(20, 40, 70), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(0, 150, 230),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(80, 180, 255), ElementBackground = Color3.fromRGB(215, 238, 255),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(20, 40, 70),
	ElementDesc = Color3.fromRGB(80, 120, 170), ElementIcon = Color3.fromRGB(0, 150, 230),
	WindowBackground = Color3.fromRGB(225, 245, 255), WindowTopbarTitle = Color3.fromRGB(20, 40, 70),
	WindowTopbarAuthor = Color3.fromRGB(0, 150, 230), WindowTopbarIcon = Color3.fromRGB(0, 150, 230),
	WindowTopbarButtonIcon = Color3.fromRGB(0, 150, 230), Hover = Color3.fromRGB(170, 210, 245),
	LabelBackground = Color3.fromRGB(200, 228, 250), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(210, 235, 255), NotificationTitle = Color3.fromRGB(20, 40, 70),
	NotificationContent = Color3.fromRGB(80, 120, 170), NotificationDuration = Color3.fromRGB(0, 180, 255),
	NotificationBorder = Color3.fromRGB(80, 180, 255), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(225, 245, 255), TooltipText = Color3.fromRGB(20, 40, 70),
	TooltipSecondary = Color3.fromRGB(80, 180, 255), TooltipSecondaryText = Color3.fromRGB(20, 40, 70),
	WindowSearchBarBackground = Color3.fromRGB(195, 225, 248), SearchBarBorder = Color3.fromRGB(80, 180, 255),
	SearchBarBorderTransparency = 0.5,
})

-- Gold (black/gold)
WindUI:AddTheme({
	Name = "Gold",
	Accent = Color3.fromRGB(20, 15, 0), Dialog = Color3.fromRGB(12, 10, 0),
	Outline = Color3.fromRGB(255, 200, 0), Text = Color3.fromRGB(255, 245, 200),
	Placeholder = Color3.fromRGB(120, 90, 0), Background = Color3.fromRGB(12, 10, 0),
	Button = Color3.fromRGB(20, 15, 0), Icon = Color3.fromRGB(255, 210, 30),
	Toggle = Color3.fromRGB(255, 200, 0), Slider = Color3.fromRGB(220, 170, 0),
	Checkbox = Color3.fromRGB(255, 200, 0), PanelBackground = Color3.fromRGB(28, 22, 0),
	PanelBackgroundTransparency = 0.35, Primary = Color3.fromRGB(255, 200, 0),
	SliderIcon = Color3.fromRGB(180, 140, 0), TabBackground = Color3.fromRGB(22, 17, 0),
	TabBackgroundHover = Color3.fromRGB(38, 30, 0), TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(55, 42, 0), TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(255, 245, 200), TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0, TabIcon = Color3.fromRGB(255, 210, 30),
	TabIconTransparency = 0.4, TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5, TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(255, 200, 0), ElementBackground = Color3.fromRGB(16, 12, 0),
	ElementBackgroundTransparency = 0.3, ElementTitle = Color3.fromRGB(255, 245, 200),
	ElementDesc = Color3.fromRGB(210, 185, 120), ElementIcon = Color3.fromRGB(255, 210, 30),
	WindowBackground = Color3.fromRGB(12, 10, 0), WindowTopbarTitle = Color3.fromRGB(255, 245, 200),
	WindowTopbarAuthor = Color3.fromRGB(255, 210, 30), WindowTopbarIcon = Color3.fromRGB(255, 210, 30),
	WindowTopbarButtonIcon = Color3.fromRGB(255, 210, 30), Hover = Color3.fromRGB(55, 42, 0),
	LabelBackground = Color3.fromRGB(28, 22, 0), LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(20, 15, 0), NotificationTitle = Color3.fromRGB(255, 245, 200),
	NotificationContent = Color3.fromRGB(210, 185, 120), NotificationDuration = Color3.fromRGB(255, 200, 0),
	NotificationBorder = Color3.fromRGB(255, 200, 0), NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(12, 10, 0), TooltipText = Color3.fromRGB(255, 245, 200),
	TooltipSecondary = Color3.fromRGB(255, 200, 0), TooltipSecondaryText = Color3.fromRGB(20, 15, 0),
	WindowSearchBarBackground = Color3.fromRGB(32, 25, 0), SearchBarBorder = Color3.fromRGB(255, 200, 0),
	SearchBarBorderTransparency = 0.5,
})


local Window = WindUI:CreateWindow({
	Title = "HXN Hub MM2", Icon = "solar:danger-bold", Author = "by hxneey",
	Folder = "HXN_MM2", Size = UDim2.fromOffset(580, 490), Theme = "RedBlack",
	Transparent = true, BackgroundImageTransparency = 0.65, Acrylic = true,
	User = { Enabled = true, Anonymous = false, Callback = function() print("[HXN] User profile clicked!") end },
})
Window:SetToggleKey(Enum.KeyCode.K)
_G.HXN_WINDOW = Window
_G.HXN_TASKS = {}
_G.HXN_CONNECTIONS = {}

local function Notify(title, content, icon, duration)
	WindUI:Notify({ Title = title, Content = content, Icon = icon or "bell", Duration = duration or 3 })
end

Window:Tag({ Title = "Premium", Color = Color3.fromRGB(255, 80, 80) })
Window:Tag({ Title = "Updated", Color = Color3.fromRGB(0, 255, 100) })

-- FIX: task.spawn instead of legacy spawn()
task.spawn(function()
	task.wait(0.3)
	pcall(function()
		local WindUIGui = game:GetService("CoreGui"):FindFirstChild("WindUI")
		if WindUIGui then
			for _, element in ipairs(WindUIGui:GetChildren()) do
				if element:IsA("TextButton") or element:IsA("ImageButton") then
					for _, child in ipairs(element:GetChildren()) do
						if child:IsA("UIStroke") then child:Destroy() end
					end
					local glow = Instance.new("UIStroke")
					glow.Color = Color3.fromRGB(255, 0, 0)
					glow.Thickness = 6
					glow.Transparency = 0
					glow.Parent = element
					element.MouseEnter:Connect(function() glow.Thickness = 8 end)
					element.MouseLeave:Connect(function() glow.Thickness = 6 end)
				end
			end
			local mainFrame = WindUIGui:FindFirstChildWhichIsA("Frame")
			if mainFrame and (mainFrame.Name == "MainFrame" or #mainFrame:GetChildren() > 5) then
				mainFrame.BackgroundTransparency = 0.25
				local windowGlow = Instance.new("UIStroke")
				windowGlow.Color = Color3.fromRGB(255, 50, 50)
				windowGlow.Thickness = 2
				windowGlow.Transparency = 0.2
				windowGlow.Parent = mainFrame
				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 12)
				corner.Parent = mainFrame
				local gradient = Instance.new("UIGradient")
				gradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 12)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 22, 22))
				}
				gradient.Rotation = 90
				gradient.Parent = mainFrame
			end
		end
	end)
end)

-- Tabs
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

--------------------------------------------------
-- ESP SETTINGS
--------------------------------------------------
local OTHER_PLAYER_COLOR = Color3.fromRGB(0, 255, 0)
local MURDERER_COLOR     = Color3.fromRGB(255, 0, 0)
local SHERIFF_COLOR      = Color3.fromRGB(0, 0, 139)
local GUN_COLOR          = Color3.fromRGB(139, 0, 0)
local STUCK_KNIFE_COLOR  = Color3.fromRGB(255, 165, 0)
local COIN_COLOR         = Color3.fromRGB(255, 223, 0)
local FILL_TRANSPARENCY    = 0.5
local OUTLINE_TRANSPARENCY = 0

local ESPEnabled           = false
local NameTagsEnabled      = false
local ESPDroppedGunEnabled = false
local ShowCoinsEnabled     = false
local ShowThrownKnifeEnabled = false
local InnocentESPEnabled   = true
local SheriffESPEnabled    = true
local MurdererESPEnabled   = true
local TracersEnabled       = false

-- Multi-style ESP: each style is independent
local ESPStyles = { Highlight = false, Chams = false, Box = false }

-- Per-style transparency (0 = solid, 1 = invisible)
local HighlightFillTransp    = 0.5
local HighlightOutlineTransp = 0.0
local ChamsFillTransp        = 0.5
local BoxFillTransp          = 0.8

local GunTPEnabled     = false
local GunTPKeybind     = Enum.KeyCode.G
local OriginalPosition = nil
local IsAtGun          = false
local GunDropNotifyEnabled = false

--------------------------------------------------
-- FIX 1: ROLE CACHING
--------------------------------------------------
local updatePlayer -- forward declaration
local roleCache = {}

local function computeRole(player)
	if not player.Character then return "Other" end
	for _, item in ipairs(player.Character:GetChildren()) do
		if item:IsA("Tool") then
			if item.Name == "Knife" then return "Murderer" end
			if item.Name == "Gun" then return "Sheriff" end
		end
	end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then
		for _, item in ipairs(backpack:GetChildren()) do
			if item:IsA("Tool") then
				if item.Name == "Knife" then return "Murderer" end
				if item.Name == "Gun" then return "Sheriff" end
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

local function watchPlayerRole(player)
	local function onBackpackChange()
		task.spawn(function()
			task.wait(0.1)
			invalidateRole(player)
			if player.Character and updatePlayer then updatePlayer(player) end
		end)
	end

	local function wireBackpack(backpack)
		backpack.ChildAdded:Connect(onBackpackChange)
		backpack.ChildRemoved:Connect(onBackpackChange)
	end

	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack then wireBackpack(backpack) end

	player.ChildAdded:Connect(function(child)
		if child:IsA("Backpack") then
			wireBackpack(child)
			onBackpackChange()
		end
	end)
end

--------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------
local function findMurderer()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= Players.LocalPlayer and getRole(player) == "Murderer" then
			return player
		end
	end
	return nil
end

local function getOrEquipKnife()
	local localPlayer = Players.LocalPlayer
	if not localPlayer or not localPlayer.Character then return nil end
	local knife = localPlayer.Character:FindFirstChild("Knife")
	if knife then return knife end
	local backpack = localPlayer:FindFirstChildOfClass("Backpack")
	if backpack and backpack:FindFirstChild("Knife") then
		localPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(backpack:FindFirstChild("Knife"))
		return localPlayer.Character:FindFirstChild("Knife")
	end
	Notify("Combat", "You are not the Murderer.", "x", 3)
	return nil
end

local function findClosestPlayer()
	local localPlayer = Players.LocalPlayer
	if not localPlayer.Character then return nil end
	local localHRP = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not localHRP then return nil end
	local nearest, shortestDist = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local dist = (localHRP.Position - hrp.Position).Magnitude
				if dist < shortestDist then shortestDist = dist nearest = player end
			end
		end
	end
	return nearest
end

local function GetPlayerList()
	local names = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer then table.insert(names, p.Name) end
	end
	return names
end

--------------------------------------------------
-- COMBAT TAB
--------------------------------------------------
CombatTab:Section({ Title = "Sheriff" })

local shootMurdererEnabled = true

CombatTab:Keybind({
	Title = "Shoot Murderer", Value = "Q",
	Callback = function()
		if not shootMurdererEnabled then return end
		local localPlayer = Players.LocalPlayer
		if not localPlayer.Character then return end
		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		local hasGun = localPlayer.Character:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun"))
		if not hasGun then Notify("Combat", "You are not the Sheriff or Hero.", "x", 3) return end

		local murderer
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= localPlayer then
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

		if not localPlayer.Character:FindFirstChild("Gun") and backpack and backpack:FindFirstChild("Gun") then
			localPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(backpack:FindFirstChild("Gun"))
			task.wait(0.05)
		end

		local gunTool = localPlayer.Character:FindFirstChild("Gun")
		local shootRemote = gunTool and gunTool:WaitForChild("Shoot", 2)
		if not gunTool or not shootRemote then return end

		-- originPart kept for reference but origin is spoofed in new logic
		local originPart = localPlayer.Character:FindFirstChild("RightHand")
			or localPlayer.Character:FindFirstChild("Right Arm")
			or localPlayer.Character:FindFirstChild("HumanoidRootPart")

		-- Rapid multi-shot: spoof origin on top of murderer so bullet travel = 0, guaranteed hit
		task.spawn(function()
			local murdererHRP = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
			if not murdererHRP then return end

			local SHOTS    = 5    -- number of shots to fire
			local SHOT_GAP = 0.05 -- seconds between each shot

			for i = 1, SHOTS do
				murdererHRP = murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
				if not murdererHRP then break end

				local mHum = murderer.Character:FindFirstChildOfClass("Humanoid")
				if mHum and mHum.Health <= 0 then break end

				local targetPos  = murdererHRP.Position + Vector3.new(0, 1.5, 0)
				local fakeOrigin = targetPos + Vector3.new(0, 0.1, 0) -- origin spoofed to murderer

				pcall(function()
					shootRemote:FireServer(
						CFrame.new(fakeOrigin),
						CFrame.new(targetPos)
					)
				end)

				task.wait(SHOT_GAP)
			end
		end)
	end,
})

CombatTab:Toggle({
	Title = "Shoot Murderer Enabled", Value = true,
	Callback = function(Value) shootMurdererEnabled = Value end,
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
		local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
		if not targetHRP then return end
		local localPlayer = Players.LocalPlayer
		pcall(function()
			knifeTool:WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(
				CFrame.new(localPlayer.Character.RightHand.Position),
				CFrame.new(targetHRP.Position + targetHRP.Velocity * 0.1)
			)
		end)
	end,
})

CombatTab:Toggle({
	Title = "Knife Throw to Closest Enabled", Value = true,
	Callback = function(Value) knifeThrowClosestEnabled = Value end,
})

local autoKnifeThrowEnabled = false
CombatTab:Toggle({
	Title = "Auto Knife Throw", Value = false,
	Callback = function(Value)
		autoKnifeThrowEnabled = Value
		if Value then
			task.spawn(function()
				while autoKnifeThrowEnabled do
					task.wait(1.5)
					if not autoKnifeThrowEnabled then break end
					local knifeTool = getOrEquipKnife()
					if not knifeTool then autoKnifeThrowEnabled = false break end
					local target = findClosestPlayer()
					if target and target.Character then
						local nearestHRP = target.Character:FindFirstChild("HumanoidRootPart")
						if nearestHRP then
							local localPlayer = Players.LocalPlayer
							pcall(function()
								knifeTool:WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(
									CFrame.new(localPlayer.Character.RightHand.Position),
									CFrame.new(nearestHRP.Position + nearestHRP.Velocity * 0.1)
								)
							end)
						end
					end
				end
			end)
		end
	end,
})

CombatTab:Button({
	Title = "Kill Closest Player",
	Callback = function()
		local knifeTool = getOrEquipKnife()
		if not knifeTool then return end
		local target = findClosestPlayer()
		if not target then return end
		local localPlayer = Players.LocalPlayer
		local localHRP = localPlayer.Character:FindFirstChild("HumanoidRootPart")
		local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
		if not targetHRP or not localHRP then return end
		targetHRP.Anchored = true
		targetHRP.CFrame = localHRP.CFrame + localHRP.CFrame.LookVector * 2
		task.wait(0.1)
		knifeTool:WaitForChild("Stab"):FireServer("Slash")
	end,
})

CombatTab:Button({
	Title = "Kill Everyone",
	Callback = function()
		local knifeTool = getOrEquipKnife()
		if not knifeTool then return end
		local localPlayer = Players.LocalPlayer
		local localHRP = localPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not localHRP then return end
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character and player ~= localPlayer then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.Anchored = true
					hrp.CFrame = localHRP.CFrame + localHRP.CFrame.LookVector * 1
				end
			end
		end
		knifeTool:WaitForChild("Stab"):FireServer("Slash")
	end,
})

--------------------------------------------------
-- ANTI-AFK
--------------------------------------------------
local AntiAfkEnabled = true
local antiAfkConn = nil

local function setupAntiAfk()
	if antiAfkConn then return end
	local vu = game:GetService("VirtualUser")
	antiAfkConn = Players.LocalPlayer.Idled:Connect(function()
		vu:CaptureController()
		vu:ClickButton2(Vector2.new())
	end)
end

local function disableAntiAfk()
	if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
end

--------------------------------------------------
-- ANTI-FLING
--------------------------------------------------
local antiFlingEnabled = false
local antiFlingHeartbeatConns = {} -- one Heartbeat connection per HRP
local antiFlingDescConn = nil

local function AntiFling()
	-- For each existing HRP in workspace (not ours), hook a Heartbeat to zero it out
	for _, v in next, game:GetDescendants() do
		if v and v:IsA("Part") and v.Name == "HumanoidRootPart"
			and v.Parent ~= Players.LocalPlayer.Character
			and not v.Anchored
		then
			local conn = RunService.Heartbeat:Connect(function()
				if not antiFlingEnabled then return end
				v.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
				v.Velocity                 = Vector3.new(0,0,0)
				v.RotVelocity              = Vector3.new(0,0,0)
				v.CanCollide               = false
			end)
			table.insert(antiFlingHeartbeatConns, conn)
		end
	end
end

local function startAntiFling()
	if antiFlingEnabled then return end
	antiFlingEnabled = true

	-- Disconnect all connections on respawn
	local hum = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.Died:Connect(function()
			for _, c in ipairs(antiFlingHeartbeatConns) do pcall(function() c:Disconnect() end) end
			antiFlingHeartbeatConns = {}
		end)
	end

	AntiFling()

	-- Watch for new HRPs being added and hook them too
	antiFlingDescConn = workspace.DescendantAdded:Connect(function(part)
		if not antiFlingEnabled then return end
		if part:IsA("Part") and part.Name == "HumanoidRootPart"
			and part.Parent ~= Players.LocalPlayer.Character
		then
			task.wait(2) -- match original script delay before locking new HRPs
			if not antiFlingEnabled then return end
			local conn = RunService.Heartbeat:Connect(function()
				if not antiFlingEnabled then return end
				part.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
				part.Velocity                 = Vector3.new(0,0,0)
				part.RotVelocity              = Vector3.new(0,0,0)
				part.CanCollide               = false
			end)
			table.insert(antiFlingHeartbeatConns, conn)
		end
	end)
end

local function stopAntiFling()
	antiFlingEnabled = false
	for _, c in ipairs(antiFlingHeartbeatConns) do pcall(function() c:Disconnect() end) end
	antiFlingHeartbeatConns = {}
	if antiFlingDescConn then antiFlingDescConn:Disconnect() antiFlingDescConn = nil end
end

--------------------------------------------------
-- OTHER TAB
--------------------------------------------------
OtherTab:Section({ Title = "Anti-Exploit" })
OtherTab:Toggle({
	Title = "Anti-AFK", Value = true,
	Callback = function(val) AntiAfkEnabled = val if val then setupAntiAfk() else disableAntiAfk() end end,
})
if AntiAfkEnabled then setupAntiAfk() end

OtherTab:Toggle({
	Title = "Anti-Fling", Value = false,
	Callback = function(val) if val then startAntiFling() else stopAntiFling() end end,
})

-- Round Timer
OtherTab:Section({ Title = "Round Timer" })
local roundTimerEnabled = false
local roundTimerGui = nil

local function secondsToMinutes(seconds)
	if not seconds or seconds <= 0 then return "00:00" end
	return string.format("%dm %ds", math.floor(seconds / 60), seconds % 60)
end

local function createTimerGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "HXN_RoundTimer"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = game:GetService("CoreGui")
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromOffset(220, 50)
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.Position = UDim2.new(0.5, 0, 0, 10)
	label.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	label.BackgroundTransparency = 0.4
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = "Timer: --:--"
	label.Parent = screenGui
	local corner = Instance.new("UICorner") corner.CornerRadius = UDim.new(0, 8) corner.Parent = label
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 50, 50) stroke.Thickness = 1.5 stroke.Transparency = 0.3 stroke.Parent = label
	return screenGui, label
end

OtherTab:Toggle({
	Title = "Round Timer", Value = false,
	Callback = function(Value)
		roundTimerEnabled = Value
		if Value then
			local old = game:GetService("CoreGui"):FindFirstChild("HXN_RoundTimer")
			if old then old:Destroy() end
			local gui, label = createTimerGui()
			roundTimerGui = gui
			task.spawn(function()
				while roundTimerEnabled do
					task.wait(1)
					local ok, timeLeft = pcall(function()
						return game:GetService("ReplicatedStorage").Remotes.Extras.GetTimer:InvokeServer()
					end)
					if label and label.Parent then
						label.Text = (ok and type(timeLeft) == "number")
							and ("⏱ " .. secondsToMinutes(math.floor(timeLeft)))
							or "⏱ Waiting..."
					else break end
				end
			end)
			Notify("Other", "Round Timer enabled.", "check", 2)
		else
			if roundTimerGui then roundTimerGui:Destroy() roundTimerGui = nil end
		end
	end,
})

OtherTab:Section({ Title = "Utilities" })

OtherTab:Section({ Title = "UI Theme" })
OtherTab:Dropdown({
	Title = "Select Theme",
	Values = { "RedBlack", "NeonPurple", "NeonBlue", "NeonGreen", "Sunset", "Ice", "Gold" },
	Value = "RedBlack",
	Multi = false,
	AllowNone = false,
	Callback = function(option)
		if option then
			pcall(function() WindUI:SetTheme(option) end)
			Notify("UI Theme", "Theme changed to " .. option, "palette", 2)
		end
	end,
})

OtherTab:Toggle({
	Title = "Gun Drop Notify", Value = false,
	Callback = function(Value)
		GunDropNotifyEnabled = Value
		Notify("Other", Value and "Gun Drop Notify enabled." or "Gun Drop Notify disabled.", Value and "check" or "x", 2)
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

EmoteTab:Button({
	Title = "Emotes",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Joystickplays/AFEM/main/max/afemmax.lua"))()
	end,
})

--------------------------------------------------
-- CHARACTER TAB
--------------------------------------------------
CharacterTab:Section({ Title = "Performance" })

local fps = 0
local currentPing = 0

local fpsTaskId = task.spawn(function()
	local lastTime = tick()
	local frameCount = 0
	local frameConn = RunService.RenderStepped:Connect(function()
		frameCount = frameCount + 1
	end)
	table.insert(_G.HXN_CONNECTIONS, frameConn)
	while true do
		task.wait(0.5)
		local now = tick()
		local elapsed = now - lastTime
		fps = elapsed > 0 and math.floor(frameCount / elapsed) or 0
		frameCount = 0
		lastTime = now
	end
end)
table.insert(_G.HXN_TASKS, fpsTaskId)

local PerformanceLabel = CharacterTab:Paragraph({ Title = "FPS & Ping", Desc = "FPS: 0\nNetwork Ping: 0 ms" })

local performanceTaskId = task.spawn(function()
	while true do
		task.wait(1)
		currentPing = math.floor(Players.LocalPlayer:GetNetworkPing() * 1000)
		if PerformanceLabel then
			PerformanceLabel:SetDesc("FPS: " .. fps .. "\nNetwork Ping: " .. currentPing .. " ms")
		end
	end
end)
table.insert(_G.HXN_TASKS, performanceTaskId)

CharacterTab:Section({ Title = "Movement" })
local currentWalkSpeed = 16
local walkSpeedEnabled = false

local noclipEnabled = false
local noclipDescConn = nil
local noclipCharConn = nil

local function applyNoclipToChar(char)
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then part.CanCollide = false end
	end
	if noclipDescConn then noclipDescConn:Disconnect() noclipDescConn = nil end
	noclipDescConn = char.DescendantAdded:Connect(function(obj)
		if noclipEnabled and obj:IsA("BasePart") then obj.CanCollide = false end
	end)
end

local function startNoclipToggle()
	noclipEnabled = true
	local plr = Players.LocalPlayer
	applyNoclipToChar(plr and plr.Character)
	noclipCharConn = plr.CharacterAdded:Connect(function(char)
		if noclipEnabled then applyNoclipToChar(char) end
	end)
end

local function stopNoclipToggle()
	noclipEnabled = false
	if noclipDescConn then noclipDescConn:Disconnect() noclipDescConn = nil end
	if noclipCharConn then noclipCharConn:Disconnect() noclipCharConn = nil end
	local plr = Players.LocalPlayer
	if plr and plr.Character then
		for _, part in ipairs(plr.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	end
end

CharacterTab:Toggle({
	Title = "Noclip", Value = false,
	Callback = function(Value)
		noclipEnabled = Value
		if Value then startNoclipToggle() else stopNoclipToggle() end
	end,
})

-- Fly
local flyEnabled = false
local flySpeed = 50
local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyHeartbeat = nil
local flyAnimConn = nil

local function startFly()
	local plr = Players.LocalPlayer
	if not plr or not plr.Character then return end
	local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local hum = plr.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = 0
		hum.JumpPower = 0
		for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
			track:Stop(0)
		end
		flyAnimConn = hum.AnimationPlayed:Connect(function(track)
			track:Stop(0)
		end)
	end

	flyBodyVelocity = Instance.new("BodyVelocity")
	flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
	flyBodyVelocity.Parent = hrp

	flyBodyGyro = Instance.new("BodyGyro")
	flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	flyBodyGyro.P = 9e9
	flyBodyGyro.CFrame = hrp.CFrame
	flyBodyGyro.Parent = hrp

	flyHeartbeat = RunService.Heartbeat:Connect(function()
		if not flyEnabled then
			if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
			if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
			flyHeartbeat:Disconnect() flyHeartbeat = nil
			return
		end
		local char = plr.Character
		if not char then return end
		local rootPart = char:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		local cam = workspace.CurrentCamera
		local moveDir = Vector3.new(0, 0, 0)
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
		if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
		flyBodyVelocity.Velocity = moveDir * flySpeed
		flyBodyGyro.CFrame = cam.CFrame
	end)
end

local function stopFly()
	flyEnabled = false
	if flyAnimConn then flyAnimConn:Disconnect() flyAnimConn = nil end
	if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
	if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
	if flyHeartbeat then flyHeartbeat:Disconnect() flyHeartbeat = nil end
	local plr = Players.LocalPlayer
	if plr and plr.Character then
		local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
		local hum = plr.Character:FindFirstChildOfClass("Humanoid")
		if hrp then hrp.Velocity = Vector3.new(0, 0, 0) end
		if hum then
			hum.WalkSpeed = walkSpeedEnabled and currentWalkSpeed or 16
			hum.JumpPower = jumpPowerEnabled and currentJumpPower or 50
		end
	end
end

CharacterTab:Toggle({
	Title = "Fly", Value = false,
	Callback = function(Value)
		flyEnabled = Value
		if Value then startFly() else stopFly() end
	end,
})

do
	local FlySpeedSlider = CharacterTab:Slider({
		Title = "Fly Speed", Step = 1,
		Value = { Min = 10, Max = 200, Default = 50 },
		Callback = function(Value) flySpeed = Value end,
	})
	if FlySpeedSlider and FlySpeedSlider.Instance then
		FlySpeedSlider.Instance.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				FlySpeedSlider:SetValue(math.clamp(flySpeed + (input.Position.Z > 0 and 1 or -1), 10, 200))
			end
		end)
	end
end

CharacterTab:Toggle({
	Title = "Enable WalkSpeed Changer", Value = false,
	Callback = function(Value)
		walkSpeedEnabled = Value
		Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value and currentWalkSpeed or 16
	end,
})

do
	local WalkSpeedSlider = CharacterTab:Slider({
		Title = "WalkSpeed Slider", Step = 1,
		Value = { Min = 1, Max = 350, Default = 16 },
		Callback = function(Value)
			currentWalkSpeed = Value
			if walkSpeedEnabled then Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value end
		end,
	})
	if WalkSpeedSlider and WalkSpeedSlider.Instance then
		WalkSpeedSlider.Instance.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				WalkSpeedSlider:SetValue(math.clamp(currentWalkSpeed + (input.Position.Z > 0 and 1 or -1), 1, 350))
			end
		end)
	end
end

CharacterTab:Input({
	Title = "Quick WalkSpeed", Value = "", Placeholder = "1-500",
	Callback = function(Text)
		local speed = tonumber(Text)
		if speed then Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed end
	end,
})

CharacterTab:Section({ Title = "Jump" })
local currentJumpPower = 50
local jumpPowerEnabled = false

CharacterTab:Toggle({
	Title = "Enable JumpPower Changer", Value = false,
	Callback = function(Value)
		jumpPowerEnabled = Value
		Players.LocalPlayer.Character.Humanoid.JumpPower = Value and currentJumpPower or 50
	end,
})

do
	local JumpPowerSlider = CharacterTab:Slider({
		Title = "JumpPower Slider", Step = 1,
		Value = { Min = 1, Max = 350, Default = 50 },
		Callback = function(Value)
			currentJumpPower = Value
			if jumpPowerEnabled then Players.LocalPlayer.Character.Humanoid.JumpPower = Value end
		end,
	})
	if JumpPowerSlider and JumpPowerSlider.Instance then
		JumpPowerSlider.Instance.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				JumpPowerSlider:SetValue(math.clamp(currentJumpPower + (input.Position.Z > 0 and 1 or -1), 1, 350))
			end
		end)
	end
end

CharacterTab:Section({ Title = "Camera" })
local fov_enabled = false
local fov_value = 70

local function updateFOV()
	local cam = workspace.CurrentCamera
	if cam then cam.FieldOfView = fov_enabled and fov_value or 70 end
end

CharacterTab:Toggle({ Title = "Custom FOV", Value = false, Callback = function(val) fov_enabled = val updateFOV() end })

do
	local FOVSlider = CharacterTab:Slider({
		Title = "FOV Value", Step = 1, Value = { Min = 1, Max = 120, Default = 70 },
		Callback = function(val) fov_value = val updateFOV() end,
	})
	if FOVSlider and FOVSlider.Instance then
		FOVSlider.Instance.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				FOVSlider:SetValue(math.clamp(fov_value + (input.Position.Z > 0 and 1 or -1), 1, 120))
			end
		end)
	end
end

--------------------------------------------------
-- EVENT-DRIVEN WORLD OBJECT TRACKER
--------------------------------------------------
local trackedObjects = {}

local function applyGunHighlight(gun)
	for _, c in ipairs(gun:GetChildren()) do
		if c.Name == "GunHighlight" then c:Destroy() end
	end
	if not ESPDroppedGunEnabled then return end
	local h = Instance.new("Highlight")
	h.Name = "GunHighlight"
	h.FillTransparency = FILL_TRANSPARENCY
	h.OutlineTransparency = OUTLINE_TRANSPARENCY
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.FillColor = GUN_COLOR
	h.Parent = gun
end

local function applyKnifeHighlight(knife)
	local h = knife:FindFirstChild("StuckKnifeHighlight")
	if not ShowThrownKnifeEnabled then
		if h then h:Destroy() end return
	end
	if not h then
		h = Instance.new("Highlight")
		h.Name = "StuckKnifeHighlight"
		h.FillTransparency = FILL_TRANSPARENCY
		h.OutlineTransparency = OUTLINE_TRANSPARENCY
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.FillColor = STUCK_KNIFE_COLOR
		h.Parent = knife
	end
	h.Enabled = true
end

local function applyCoinHighlight(obj)
	local target = obj
	if obj.Name == "CoinVisual" then
		local part = obj:FindFirstChild("MainCoin") or obj:FindFirstChildWhichIsA("BasePart")
		if part then target = part end
	end
	for _, child in ipairs(target:GetChildren()) do
		if child.Name == "CoinHighlight" then child:Destroy() end
	end
	if target ~= obj then
		for _, child in ipairs(obj:GetChildren()) do
			if child.Name == "CoinHighlight" then child:Destroy() end
		end
	end
	if not ShowCoinsEnabled then return end
	local h = Instance.new("Highlight")
	h.Name = "CoinHighlight"
	h.FillTransparency = FILL_TRANSPARENCY
	h.OutlineTransparency = OUTLINE_TRANSPARENCY
	h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	h.FillColor = COIN_COLOR
	h.Parent = target
	h.Enabled = true
end

local function onDescendantAdded(obj)
	local name = obj.Name
	if name == "GunDrop" then
		trackedObjects[obj] = "GunDrop"
		applyGunHighlight(obj)
		if GunDropNotifyEnabled then
			local pos
			pcall(function()
				if obj:IsA("Model") then pos = obj:GetPivot().Position
				elseif obj:IsA("BasePart") then pos = obj.Position end
			end)
			if pos then
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
	trackedObjects[obj] = nil
end

for _, obj in ipairs(workspace:GetDescendants()) do
	onDescendantAdded(obj)
end

local descAddedConn = workspace.DescendantAdded:Connect(onDescendantAdded)
local descRemConn = workspace.DescendantRemoving:Connect(onDescendantRemoving)
table.insert(_G.HXN_CONNECTIONS, descAddedConn)
table.insert(_G.HXN_CONNECTIONS, descRemConn)

local function refreshAllTrackedHighlights()
	for obj, kind in pairs(trackedObjects) do
		if kind == "GunDrop" then applyGunHighlight(obj)
		elseif kind == "StuckKnife" then applyKnifeHighlight(obj)
		elseif kind == "Coin" then applyCoinHighlight(obj) end
	end
end

--------------------------------------------------
-- EVENT-DRIVEN PLAYER ESP
--------------------------------------------------
local function clearHighlight(character)
	for _, obj in ipairs(character:GetChildren()) do
		if obj:IsA("Highlight") then obj:Destroy() end
	end
end

local function clearChams(character)
	for _, obj in ipairs(character:GetDescendants()) do
		if obj.Name == "ChamHL" then obj:Destroy() end
	end
end

local function clearBox(character)
	for _, obj in ipairs(character:GetChildren()) do
		if obj.Name == "PlayerBox" or obj.Name == "PlayerBoxOutline" then obj:Destroy() end
	end
end

local function clearAllESPOnCharacter(character)
	if character == Players.LocalPlayer.Character then return end
	clearHighlight(character)
	clearChams(character)
	clearBox(character)
	local tag = character:FindFirstChild("NameTag")
	if tag then tag:Destroy() end
end

local characterPartsCache = {}

local function buildPartsCache(character)
	local parts = {}
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			table.insert(parts, part)
		end
	end
	characterPartsCache[character] = parts
end

updatePlayer = function(player)
	if player == LocalPlayer then return end
	local character = player.Character
	if not character then return end

	local role = getRole(player)
	local color = OTHER_PLAYER_COLOR
	if role == "Murderer" then color = MURDERER_COLOR
	elseif role == "Sheriff" then color = SHERIFF_COLOR
	end

	local shouldShowESP = ESPEnabled and (
		(role == "Murderer" and MurdererESPEnabled)
		or (role == "Sheriff" and SheriffESPEnabled)
		or (role == "Other" and InnocentESPEnabled)
	)

	if ESPStyles.Highlight and shouldShowESP then
		local highlight = character:FindFirstChild("PlayerHighlight")
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Name = "PlayerHighlight"
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = character
		end
		highlight.FillColor           = color
		highlight.OutlineColor        = color
		highlight.FillTransparency    = HighlightFillTransp
		highlight.OutlineTransparency = HighlightOutlineTransp
		highlight.Enabled = true
	else
		clearHighlight(character)
	end

	if ESPStyles.Chams and shouldShowESP then
		local parts = characterPartsCache[character]
		if not parts then
			buildPartsCache(character)
			parts = characterPartsCache[character]
		end
		for _, part in ipairs(parts) do
			if part.Parent then
				local chl = part:FindFirstChild("ChamHL")
				if not chl then
					chl = Instance.new("Highlight")
					chl.Name = "ChamHL"
					chl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					chl.Parent = part
				end
				chl.FillColor           = color
				chl.OutlineColor        = color
				chl.FillTransparency    = ChamsFillTransp
				chl.OutlineTransparency = 0
				chl.Enabled = true
			end
		end
	else
		clearChams(character)
	end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if ESPStyles.Box and shouldShowESP and hrp then
		local box = character:FindFirstChild("PlayerBox")
		if not box then
			box = Instance.new("BoxHandleAdornment")
			box.Name = "PlayerBox"
			box.Adornee = hrp
			box.Size = Vector3.new(4, 6, 2)
			box.AlwaysOnTop = true
			box.ZIndex = 5
			box.Parent = character
		end
		box.Color3       = color
		box.Transparency = BoxFillTransp
		local outline = character:FindFirstChild("PlayerBoxOutline")
		if not outline then
			outline = Instance.new("BoxHandleAdornment")
			outline.Name = "PlayerBoxOutline"
			outline.Adornee = hrp
			outline.Size = Vector3.new(4.15, 6.15, 2.15)
			outline.Color3 = Color3.new(0, 0, 0)
			outline.AlwaysOnTop = true
			outline.Transparency = 0.85
			outline.ZIndex = 4
			outline.Parent = character
		end
	else
		clearBox(character)
	end

	local tag = character:FindFirstChild("NameTag")
	if not NameTagsEnabled or not shouldShowESP then
		if tag then tag:Destroy() end
	else
		if not tag then
			local head = character:FindFirstChild("Head")
			if head then
				tag = Instance.new("BillboardGui")
				tag.Name = "NameTag"
				tag.Adornee = head
				tag.Size = UDim2.new(0, 100, 0, 20)
				tag.StudsOffset = Vector3.new(0, 2.5, 0)
				tag.AlwaysOnTop = true
				local text = Instance.new("TextLabel")
				text.Size = UDim2.new(1, 0, 1, 0)
				text.BackgroundTransparency = 1
				text.Text = player.Name
				text.TextColor3 = color
				text.TextStrokeTransparency = 0
				text.Font = Enum.Font.SourceSansBold
				text.TextScaled = true
				text.Parent = tag
				tag.Parent = character
			end
		else
			local text = tag:FindFirstChildOfClass("TextLabel")
			if text then text.TextColor3 = color end
		end
	end
end

local function startTracking(player)
	watchPlayerRole(player)

	local function onRoleChange()
		task.spawn(function()
			task.wait(0.1)
			invalidateRole(player)
			if player.Character then updatePlayer(player) end
		end)
	end

	local function wireCharacter(char)
		char.ChildAdded:Connect(onRoleChange)
		char.ChildRemoved:Connect(onRoleChange)
	end

	if player.Character then
		buildPartsCache(player.Character)
		wireCharacter(player.Character)
		updatePlayer(player)
	end

	local charAddedConn = player.CharacterAdded:Connect(function(char)
		invalidateRole(player)
		characterPartsCache[char] = nil
		buildPartsCache(char)
		wireCharacter(char)
		task.wait(0.2)
		updatePlayer(player)
	end)
	table.insert(_G.HXN_CONNECTIONS, charAddedConn)

	local charRemovingConn = player.CharacterRemoving:Connect(function(char)
		characterPartsCache[char] = nil
		clearAllESPOnCharacter(char)
	end)
	table.insert(_G.HXN_CONNECTIONS, charRemovingConn)
end

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then startTracking(player) end
end

local playerAddedConn = Players.PlayerAdded:Connect(function(player)
	if player ~= LocalPlayer then startTracking(player) end
end)
table.insert(_G.HXN_CONNECTIONS, playerAddedConn)

local roleCacheRemovingConn = Players.PlayerRemoving:Connect(function(player)
	roleCache[player] = nil
	characterPartsCache[player.Character or false] = nil
end)
table.insert(_G.HXN_CONNECTIONS, roleCacheRemovingConn)

local roleDetectorActive = false
local roleDetectorThread = nil

local function startRoleDetector()
	if roleDetectorActive then return end
	roleDetectorActive = true
	roleDetectorThread = task.spawn(function()
		while roleDetectorActive do
			task.wait(0.5)
			if not ESPEnabled then continue end
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character then
					local newRole = computeRole(p)
					if roleCache[p] ~= newRole then
						roleCache[p] = newRole
						updatePlayer(p)
					end
				end
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

local roleDetectorRemoveConn = Players.PlayerRemoving:Connect(function(p)
	roleCache[p] = nil
end)
table.insert(_G.HXN_CONNECTIONS, roleDetectorRemoveConn)

startRoleDetector()

--------------------------------------------------
-- TRACERS
--------------------------------------------------
if _G.HXN_TRACER_LOOP then pcall(function() _G.HXN_TRACER_LOOP:Disconnect() end) end
if _G.HXN_TRACERS then
	for _, line in pairs(_G.HXN_TRACERS) do pcall(function() line:Remove() end) end
end
_G.HXN_TRACERS = {}

local Camera = workspace.CurrentCamera
local tracerLines = _G.HXN_TRACERS
_G.HXN_TRACER_LOOP = nil

local function startTracerLoop()
	if _G.HXN_TRACER_LOOP then return end
	_G.HXN_TRACER_LOOP = RunService.RenderStepped:Connect(function()
		for player, line in pairs(tracerLines) do
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local root = player.Character.HumanoidRootPart
				local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
				if onScreen then
					line.Visible = true
					line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
					line.To = Vector2.new(pos.X, pos.Y)
					local role = getRole(player)
					line.Color = (role == "Murderer") and MURDERER_COLOR
						or (role == "Sheriff") and SHERIFF_COLOR
						or OTHER_PLAYER_COLOR
					line.Thickness = 3
				else
					line.Visible = false
				end
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
	for player, line in pairs(tracerLines) do
		line.Visible = false
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		local line = Drawing.new("Line")
		line.Visible = false line.Thickness = 1
		tracerLines[player] = line
	end
end

local tracerPlayerAddedConn = Players.PlayerAdded:Connect(function(player)
	if player ~= LocalPlayer then
		local line = Drawing.new("Line")
		line.Visible = false
		tracerLines[player] = line
	end
end)
table.insert(_G.HXN_CONNECTIONS, tracerPlayerAddedConn)

local tracerPlayerRemovingConn = Players.PlayerRemoving:Connect(function(player)
	if tracerLines[player] then
		tracerLines[player]:Remove()
		tracerLines[player] = nil
	end
end)
table.insert(_G.HXN_CONNECTIONS, tracerPlayerRemovingConn)

--------------------------------------------------
-- VISUAL TAB
--------------------------------------------------
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
	Callback = function(option) if option then applySky(option) end end,
})

local BlurEffect, BloomEffect, ColorCorrection

VisualTab:Toggle({
	Title = "Enable Blur", Value = false,
	Callback = function(value)
		if value then
			if not BlurEffect then BlurEffect = Instance.new("BlurEffect") BlurEffect.Size = 8 BlurEffect.Parent = Lighting end
		else
			if BlurEffect then BlurEffect:Destroy() BlurEffect = nil end
		end
	end,
})

VisualTab:Toggle({
	Title = "Enable Bloom", Value = false,
	Callback = function(value)
		if value then
			if not BloomEffect then
				BloomEffect = Instance.new("BloomEffect")
				BloomEffect.Intensity = 1.5 BloomEffect.Threshold = 0.8 BloomEffect.Parent = Lighting
			end
		else
			if BloomEffect then BloomEffect:Destroy() BloomEffect = nil end
		end
	end,
})

VisualTab:Toggle({
	Title = "Enable Color Correction", Value = false,
	Callback = function(value)
		if value then
			if not ColorCorrection then
				ColorCorrection = Instance.new("ColorCorrectionEffect")
				ColorCorrection.Saturation = 0.3 ColorCorrection.Contrast = 0.2 ColorCorrection.Parent = Lighting
			end
		else
			if ColorCorrection then ColorCorrection:Destroy() ColorCorrection = nil end
		end
	end,
})

--------------------------------------------------
-- AUTOFARM
--------------------------------------------------
local knownMapNames = {
	"Bank2","BioLab","Factory","Hospital3","Hotel2","House2","Mansion2",
	"MilBase","Office3","PoliceStation","ResearchFacility","Workplace"
}

local AutofarmEnabled    = false
local autofarmActive     = false
local autofarmStartTime  = 0
local coinsCollected     = 0
local farmStatus         = "Idle"
local TeleportOnComplete = false
local AutofarmSpeed      = 24
local AutofarmStatusLabel = nil

local function restorePlayer()
	local plr = Players.LocalPlayer
	if plr and plr.Character then
		for _, part in ipairs(plr.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	end
end

local farmNoclipConn = nil

local function startNoclip(plr)
	if not plr or not plr.Character then return end
	for _, part in ipairs(plr.Character:GetDescendants()) do
		if part:IsA("BasePart") then part.CanCollide = false end
	end
	if farmNoclipConn then farmNoclipConn:Disconnect() end
	farmNoclipConn = plr.Character.DescendantAdded:Connect(function(obj)
		if obj:IsA("BasePart") then obj.CanCollide = false end
	end)
end

local function stopNoclip()
	if farmNoclipConn then farmNoclipConn:Disconnect() farmNoclipConn = nil end
end

local function formatTime(s)
	s = math.floor(s)
	return string.format("%02d:%02d", math.floor(s/60), s%60)
end

local function updateAutofarmLabel()
	if not AutofarmStatusLabel then return end
	if AutofarmEnabled then
		local elapsed = tick() - autofarmStartTime
		local cph = elapsed > 0 and (coinsCollected / elapsed) * 3600 or 0
		AutofarmStatusLabel:SetDesc(
			"Status: " .. farmStatus ..
			"\nCoins collected: " .. coinsCollected ..
			"\nCoins/hr: " .. math.floor(cph) ..
			"\nTime: " .. formatTime(elapsed)
		)
	else
		AutofarmStatusLabel:SetDesc("Autofarm OFF — toggle to start.")
	end
end

local function getCoinContainer()
	for _, mapName in ipairs(knownMapNames) do
		local map = workspace:FindFirstChild(mapName)
		if map then
			local container = map:FindFirstChild("CoinContainer")
			if container then return container end
		end
	end
	return nil
end

local function getCoins()
	local coins = {}
	local container = getCoinContainer()
	if container then
		for _, obj in ipairs(container:GetChildren()) do
			if obj.Name == "Coin_Server" and obj:IsA("BasePart") then table.insert(coins, obj) end
		end
		if #coins > 0 then return coins end
	end
	for obj, kind in pairs(trackedObjects) do
		if kind == "Coin" and obj.Parent then
			if obj:IsA("BasePart") and obj.Name == "Coin_Server" then
				table.insert(coins, obj)
			elseif obj:IsA("Model") then
				local part = obj:FindFirstChild("Coin_Server") or obj:FindFirstChildWhichIsA("BasePart")
				if part then table.insert(coins, part) end
			end
		end
	end
	return coins
end

local function waitForRoundStart()
	farmStatus = "Waiting for round..."
	updateAutofarmLabel()
	while AutofarmEnabled do
		if #getCoins() > 0 then
			farmStatus = "Round started!"
			updateAutofarmLabel()
			Notify("Autofarm", "Round started — farming coins!", "check", 3)
			return true
		end
		task.wait(1)
	end
	return false
end

local farmBV = nil
local farmBG = nil

local function ensureFarmPhysics(hrp)
	if not farmBV or not farmBV.Parent then
		farmBV = Instance.new("BodyVelocity")
		farmBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		farmBV.Velocity = Vector3.new(0, 0, 0)
		farmBV.Parent = hrp
	end
	if not farmBG or not farmBG.Parent then
		farmBG = Instance.new("BodyGyro")
		farmBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		farmBG.CFrame = hrp.CFrame
		farmBG.Parent = hrp
	end
end

local function destroyFarmPhysics()
	if farmBV then farmBV:Destroy() farmBV = nil end
	if farmBG then farmBG:Destroy() farmBG = nil end
end

local ZERO_VEC3_FARM = Vector3.new(0, 0, 0)

local function floatTo(hrp, targetPos)
	ensureFarmPhysics(hrp)
	local lastVel = Vector3.new()
	while AutofarmEnabled do
		local dir = targetPos - hrp.Position
		if dir.X*dir.X + dir.Y*dir.Y + dir.Z*dir.Z < 2.25 then break end
		lastVel = lastVel:Lerp(dir.Unit * AutofarmSpeed, 0.25)
		farmBV.Velocity = lastVel
		task.wait(0.05)
	end
	if farmBV then farmBV.Velocity = ZERO_VEC3_FARM end
end

local function startAutofarm()
	autofarmStartTime = tick()
	coinsCollected = 0
	local FPDH_BACKUP = getgenv().FPDH or workspace.FallenPartsDestroyHeight
	local ok, err = pcall(function()
		while AutofarmEnabled do
			restorePlayer()
			if not waitForRoundStart() then break end
			local plr = Players.LocalPlayer
			if not plr then break end

			startNoclip(plr)

			while AutofarmEnabled do
				local char = plr.Character
				if not char then task.wait(0.5) continue end
				local hrp = char:FindFirstChild("HumanoidRootPart")
				if not hrp then task.wait(0.5) continue end
				local coins = getCoins()
				if #coins == 0 then
					stopNoclip()
					destroyFarmPhysics()
					restorePlayer()
					farmStatus = "Round over, waiting..."
					updateAutofarmLabel()
					Notify("Autofarm", "All coins collected! Waiting for next round.", "check", 3)
					if TeleportOnComplete then
						local lobby = workspace:FindFirstChild("Lobby")
						local spawns = lobby and lobby:FindFirstChild("Spawns")
						if spawns then
							local pts = spawns:GetChildren()
							if #pts > 0 then hrp.CFrame = pts[math.random(1,#pts)].CFrame + Vector3.new(0,3,0) end
						end
						Notify("Autofarm", "Teleported to Lobby.", "check", 2)
					end
					break
				end
				local closest, closestDist = nil, math.huge
				for _, coin in ipairs(coins) do
					if coin.Parent then
						local dist = (hrp.Position - coin.Position).Magnitude
						if dist < closestDist then closestDist = dist closest = coin end
					end
				end
				if not closest then break end
				farmStatus = "Collecting (" .. #coins .. " left)"
				updateAutofarmLabel()
				workspace.FallenPartsDestroyHeight = -math.huge
				floatTo(hrp, closest.Position)
				workspace.FallenPartsDestroyHeight = FPDH_BACKUP
				coinsCollected = coinsCollected + 1
				task.wait(0.05)
			end
		end
	end)
	workspace.FallenPartsDestroyHeight = FPDH_BACKUP
	stopNoclip()
	destroyFarmPhysics()
	restorePlayer()
	farmStatus = "Idle"
	updateAutofarmLabel()
	if not ok then warn("[HXN] Autofarm error: " .. tostring(err)) end
end

Players.LocalPlayer.CharacterAdded:Connect(function()
	if AutofarmEnabled and not autofarmActive then
		task.wait(1.5)
		farmStatus = "Respawned, restarting..."
		updateAutofarmLabel()
		autofarmActive = true
		task.spawn(function() startAutofarm() autofarmActive = false end)
	end
end)

AutofarmTab:Section({ Title = "Farm Status" })
AutofarmStatusLabel = AutofarmTab:Paragraph({ Title = "Live Status", Desc = "Autofarm OFF — toggle to start." })

local autofarmLabelTask = nil

local function startLabelUpdater()
	if autofarmLabelTask then return end
	autofarmLabelTask = task.spawn(function()
		while AutofarmEnabled do
			task.wait(1)
			if AutofarmEnabled then updateAutofarmLabel() end
		end
		autofarmLabelTask = nil
	end)
	table.insert(_G.HXN_TASKS, autofarmLabelTask)
end

local function stopLabelUpdater()
	if autofarmLabelTask then
		pcall(function() task.cancel(autofarmLabelTask) end)
		autofarmLabelTask = nil
	end
end

AutofarmTab:Section({ Title = "Settings" })

AutofarmTab:Toggle({
	Title = "Autofarm", Value = false,
	Callback = function(Value)
		AutofarmEnabled = Value
		if Value then
			if autofarmActive then Notify("Autofarm", "Already running.", "bell", 2) return end
			autofarmStartTime = tick() coinsCollected = 0 farmStatus = "Starting..."
			updateAutofarmLabel()
			startLabelUpdater()
			Notify("Autofarm", "Autofarm started!", "check", 3)
			autofarmActive = true
			task.spawn(function() startAutofarm() autofarmActive = false end)
		else
			stopLabelUpdater()
			stopNoclip() destroyFarmPhysics() restorePlayer() farmStatus = "Idle" updateAutofarmLabel()
			Notify("Autofarm", "Autofarm stopped.", "x", 3)
		end
	end,
})

AutofarmTab:Toggle({
	Title = "Teleport to Lobby when done", Value = false,
	Callback = function(v) TeleportOnComplete = v end,
})

do
	local AutofarmSpeedSlider = AutofarmTab:Slider({
		Title = "Float Speed", Step = 1, Value = { Min = 5, Max = 60, Default = 24 },
		Callback = function(v) AutofarmSpeed = v end,
	})
	if AutofarmSpeedSlider and AutofarmSpeedSlider.Instance then
		AutofarmSpeedSlider.Instance.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				AutofarmSpeedSlider:SetValue(math.clamp(AutofarmSpeed + (input.Position.Z > 0 and 1 or -1), 5, 60))
			end
		end)
	end
end

--------------------------------------------------
-- TELEPORT
--------------------------------------------------
local function teleportToLobby()
	local plr = Players.LocalPlayer
	if not plr or not plr.Character then return end
	local hrp = plr.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
	local lobby = workspace:FindFirstChild("Lobby")
	if not lobby then return end
	local spawns = lobby:FindFirstChild("Spawns") if not spawns then return end
	local pts = {}
	for _, obj in ipairs(spawns:GetChildren()) do if obj:IsA("SpawnLocation") then table.insert(pts, obj) end end
	if #pts == 0 then return end
	hrp.CFrame = pts[math.random(1, #pts)].CFrame + Vector3.new(0, 3, 0)
end

local function teleportToMap()
	local plr = Players.LocalPlayer
	if not plr or not plr.Character then return end
	local hrp = plr.Character:FindFirstChild("HumanoidRootPart") if not hrp then return end
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
	local plr = Players.LocalPlayer
	if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
		plr.Character.HumanoidRootPart.CFrame = CFrame.new(319, 537, 89)
	end
end

local function findGun()
	for obj, kind in pairs(trackedObjects) do
		if kind == "GunDrop" and obj.Parent then
			local ok, pos = pcall(function()
				if obj:IsA("Model") then return obj:GetPivot().Position
				elseif obj:IsA("BasePart") then return obj.Position end
			end)
			if ok and pos then return pos end
		end
	end
	return nil
end

local function teleportToGun()
	local localPlayer = Players.LocalPlayer
	if not localPlayer or not localPlayer.Character then return end
	local gunPos = findGun()
	if not gunPos then Notify("Teleport", "No gun found on the map.", "x", 3) return end
	OriginalPosition = localPlayer.Character.HumanoidRootPart.CFrame
	localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(gunPos + Vector3.new(0, 3, 0))
	IsAtGun = true
	Notify("Teleport", "Teleported to Gun. Press " .. GunTPKeybind.Name .. " again to return.", "check", 3)

	local cancelConn
	cancelConn = localPlayer.CharacterRemoving:Connect(function()
		IsAtGun = false
		cancelConn:Disconnect()
	end)

	task.spawn(function()
		while IsAtGun do
			task.wait(0.05)
			local player = Players.LocalPlayer
			if not player or not player.Character then
				IsAtGun = false
				break
			end
			local backpack = player:FindFirstChildOfClass("Backpack")
			local hasGun = (backpack and backpack:FindFirstChild("Gun")) or player.Character:FindFirstChild("Gun")
			if hasGun and OriginalPosition then
				player.Character.HumanoidRootPart.CFrame = OriginalPosition
				IsAtGun = false
				cancelConn:Disconnect()
				Notify("Teleport", "Gun picked up! Returned to original position.", "check", 3)
				break
			end
		end
	end)
end

local function returnToOriginalPos()
	local localPlayer = Players.LocalPlayer
	if not localPlayer or not localPlayer.Character then return end
	if not OriginalPosition then Notify("Teleport", "No saved position to return to.", "x", 3) return end
	localPlayer.Character.HumanoidRootPart.CFrame = OriginalPosition
	IsAtGun = false
	Notify("Teleport", "Returned to original position.", "check", 3)
end

TeleportTab:Section({ Title = "Gun Teleport" })
TeleportTab:Toggle({
	Title = "Gun Teleport", Value = false,
	Callback = function(Value) GunTPEnabled = Value end,
})

TeleportTab:Section({ Title = "Map Teleports" })
TeleportTab:Button({ Title = "TP To Lobby",       Callback = function() teleportToLobby()      Notify("Teleport","Teleported to Lobby.","check",2) end })
TeleportTab:Button({ Title = "TP To Map",          Callback = function() teleportToMap()         Notify("Teleport","Teleported to Map.","check",2) end })
TeleportTab:Button({ Title = "TP To Secret Place", Callback = function() teleportToSecretPlace() Notify("Teleport","Teleported to Secret Place.","check",2) end })

TeleportTab:Section({ Title = "Player Teleport" })
do
	local SelectedTPPlayer = nil
	local TPPlayerDropdown = TeleportTab:Dropdown({
		Title = "Select Player", Values = GetPlayerList(), Value = "None",
		Multi = false, AllowNone = true,
		Callback = function(option) SelectedTPPlayer = option end,
	})
	local function RefreshTPDropdown()
		if TPPlayerDropdown then TPPlayerDropdown:Refresh(GetPlayerList()) end
	end
	table.insert(_G.HXN_CONNECTIONS, Players.PlayerAdded:Connect(RefreshTPDropdown))
	table.insert(_G.HXN_CONNECTIONS, Players.PlayerRemoving:Connect(function(player)
		if SelectedTPPlayer == player.Name then SelectedTPPlayer = nil end
		RefreshTPDropdown()
	end))
	TeleportTab:Button({
		Title = "TP to Selected Player",
		Callback = function()
			if not SelectedTPPlayer or SelectedTPPlayer == "None" then
				Notify("Teleport", "No player selected.", "x", 3) return
			end
			local targetPlayer = nil
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Name == SelectedTPPlayer and p ~= Players.LocalPlayer then targetPlayer = p break end
			end
			if not targetPlayer or not targetPlayer.Character then
				Notify("Teleport", "Player not found or has no character.", "x", 3) return
			end
			local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp and targetHRP then
				hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
				Notify("Teleport", "Teleported to " .. SelectedTPPlayer .. ".", "check", 3)
			end
		end,
	})
end

table.insert(_G.HXN_CONNECTIONS, UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == GunTPKeybind and GunTPEnabled then
		if not IsAtGun then teleportToGun() else returnToOriginalPos() end
	end
end))

--------------------------------------------------
-- TROLLING TAB
--------------------------------------------------
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

local FlingActive = false
local SelectedFlingTarget = nil

local function SkidFling(TargetPlayer)
	local Player = Players.LocalPlayer
	local Character = Player.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart = Humanoid and Humanoid.RootPart
	local TCharacter = TargetPlayer.Character
	if not TCharacter then return end
	local THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
	local TRootPart = THumanoid and THumanoid.RootPart
	local THead = TCharacter:FindFirstChild("Head")
	local Accessory = TCharacter:FindFirstChildOfClass("Accessory")
	local Handle = Accessory and Accessory:FindFirstChild("Handle")

	if not (Character and Humanoid and RootPart) then return end
	if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
	if THumanoid and THumanoid.Sit then return end
	if THead then workspace.CurrentCamera.CameraSubject = THead
	elseif Handle then workspace.CurrentCamera.CameraSubject = Handle
	elseif THumanoid and TRootPart then workspace.CurrentCamera.CameraSubject = THumanoid end
	if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end

	local FPos = function(BasePart, Pos, Ang)
		RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
		Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
		RootPart.Velocity = Vector3.new(9e7, 9e7*10, 9e7)
		RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
	end

	local SFBasePart = function(BasePart)
		local Time = tick()
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
					FPos(BasePart, CFrame.new(0,1.5,THumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,-1.5,-THumanoid.WalkSpeed), CFrame.Angles(0,0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,1.5,THumanoid.WalkSpeed), CFrame.Angles(math.rad(90),0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(90),0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(math.rad(90),0,0)) task.wait()
					FPos(BasePart, CFrame.new(0,-1.5,0), CFrame.Angles(0,0,0)) task.wait()
				end
			end
		until Time + 2 < tick() or not FlingActive
	end

	workspace.FallenPartsDestroyHeight = 0/0
	local BV = Instance.new("BodyVelocity")
	BV.Parent = RootPart BV.Velocity = Vector3.new(0,0,0) BV.MaxForce = Vector3.new(9e9,9e9,9e9)
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

	if TRootPart then SFBasePart(TRootPart)
	elseif THead then SFBasePart(THead)
	elseif Handle then SFBasePart(Handle)
	end

	BV:Destroy()
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
	workspace.CurrentCamera.CameraSubject = Humanoid

	if getgenv().OldPos then
		repeat
			RootPart.CFrame = getgenv().OldPos * CFrame.new(0,.5,0)
			Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0,.5,0))
			Humanoid:ChangeState("GettingUp")
			for _, part in pairs(Character:GetChildren()) do
				if part:IsA("BasePart") then part.Velocity = Vector3.new() part.RotVelocity = Vector3.new() end
			end
			task.wait()
		until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
		workspace.FallenPartsDestroyHeight = getgenv().FPDH
	end
end

local function StartFling()
	if FlingActive or not SelectedFlingTarget then return end
	FlingActive = true
	task.spawn(function()
		while FlingActive do
			local targetPlayer = nil
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Name == SelectedFlingTarget and p ~= Players.LocalPlayer then targetPlayer = p break end
			end
			if targetPlayer and targetPlayer.Parent then SkidFling(targetPlayer) task.wait(0.1)
			else FlingActive = false break end
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
				if p ~= Players.LocalPlayer and p.Character then table.insert(targets, p) end
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
	local FlingPlayerDropdown = TrollingTab:Dropdown({
		Title = "Select Player", Values = GetPlayerList(), Value = "None",
		Callback = function(option) SelectedFlingTarget = option end,
	})
	local function RefreshFlingDropdown()
		if FlingPlayerDropdown then FlingPlayerDropdown:Refresh(GetPlayerList()) end
	end
	table.insert(_G.HXN_CONNECTIONS, Players.PlayerAdded:Connect(RefreshFlingDropdown))
	table.insert(_G.HXN_CONNECTIONS, Players.PlayerRemoving:Connect(function(p)
		if SelectedFlingTarget == p.Name then SelectedFlingTarget = nil end
		RefreshFlingDropdown()
	end))
end

TrollingTab:Section({ Title = "Fling Controls" })
TrollingTab:Button({ Title = "Start Flinging", Callback = StartFling })
TrollingTab:Button({ Title = "Stop Flinging",  Callback = StopFling })

TrollingTab:Section({ Title = "Fling by Role" })
do
	local function flingRole(role)
		local target = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Players.LocalPlayer and getRole(p) == role then target = p break end
		end
		if target then SelectedFlingTarget = target.Name StartFling()
		else Notify("Trolling", "No " .. role .. " found.", "x", 3) end
	end
	TrollingTab:Button({ Title = "Fling Murderer", Callback = function() flingRole("Murderer") end })
	TrollingTab:Button({ Title = "Fling Sheriff",  Callback = function() flingRole("Sheriff") end })
end
TrollingTab:Section({ Title = "Fling All" })
TrollingTab:Button({ Title = "Fling All Players", Callback = FlingAll })

--------------------------------------------------
-- SPIN
--------------------------------------------------
local spinEnabled = false
local spinSpeed   = 10
local spinConn    = nil

local function startSpin()
	if spinConn then spinConn:Disconnect() spinConn = nil end
	local plr = Players.LocalPlayer
	local char = plr and plr.Character
	local hrp  = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	spinConn = RunService.Heartbeat:Connect(function()
		if not spinEnabled then
			spinConn:Disconnect() spinConn = nil return
		end
		if not hrp or not hrp.Parent then
			local newChar = plr and plr.Character
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

TrollingTab:Section({ Title = "Spin" })

TrollingTab:Toggle({
	Title = "Spin", Value = false,
	Callback = function(Value)
		spinEnabled = Value
		if Value then
			startSpin()
			Notify("Trolling", "Spin enabled!", "zap", 2)
		else
			stopSpin()
			Notify("Trolling", "Spin disabled.", "x", 2)
		end
	end,
})

do
	local SpinSpeedSlider = TrollingTab:Slider({
		Title = "Spin Speed", Step = 1,
		Value = { Min = 1, Max = 50, Default = 10 },
		Callback = function(Value) spinSpeed = Value end,
	})
	if SpinSpeedSlider and SpinSpeedSlider.Instance then
		SpinSpeedSlider.Instance.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				SpinSpeedSlider:SetValue(math.clamp(spinSpeed + (input.Position.Z > 0 and 1 or -1), 1, 50))
			end
		end)
	end
end

--------------------------------------------------
-- ESP TAB
--------------------------------------------------
local function refreshAllESP()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer and p.Character then
			updatePlayer(p)
		end
	end
end

ESPTab:Section({ Title = "Main Control" })
ESPTab:Toggle({
	Title = "ESP", Default = false,
	Callback = function(Value)
		ESPEnabled = Value
		if not Value then
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= Players.LocalPlayer and p.Character then
					clearAllESPOnCharacter(p.Character)
				end
			end
		else
			refreshAllESP()
		end
	end,
})

ESPTab:Section({ Title = "ESP Style" })

ESPTab:Toggle({
	Title = "Highlight", Default = false,
	Callback = function(Value)
		ESPStyles.Highlight = Value
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Players.LocalPlayer and p.Character then
				if not Value then clearHighlight(p.Character) end
			end
		end
		refreshAllESP()
	end,
})

ESPTab:Toggle({
	Title = "Chams (through walls)", Default = false,
	Callback = function(Value)
		ESPStyles.Chams = Value
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Players.LocalPlayer and p.Character then
				if not Value then clearChams(p.Character) end
			end
		end
		refreshAllESP()
	end,
})

ESPTab:Toggle({
	Title = "Box", Default = false,
	Callback = function(Value)
		ESPStyles.Box = Value
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= Players.LocalPlayer and p.Character then
				if not Value then clearBox(p.Character) end
			end
		end
		refreshAllESP()
	end,
})

ESPTab:Section({ Title = "Highlight Settings" })

do
	local HighlightFillSlider = ESPTab:Slider({
		Title = "Highlight Fill Transparency",
		Step = 0.05,
		Value = { Min = 0, Max = 1, Default = 0.5 },
		Callback = function(v)
			HighlightFillTransp = v
			if ESPStyles.Highlight then refreshAllESP() end
		end,
	})
	if HighlightFillSlider and HighlightFillSlider.Instance then
		HighlightFillSlider.Instance.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local newVal = math.clamp(HighlightFillTransp + (input.Position.Z > 0 and -0.05 or 0.05), 0, 1)
				HighlightFillSlider:SetValue(newVal)
			end
		end)
	end
end

do
	local HighlightOutlineSlider = ESPTab:Slider({
		Title = "Highlight Outline Transparency",
		Step = 0.05,
		Value = { Min = 0, Max = 1, Default = 0.0 },
		Callback = function(v)
			HighlightOutlineTransp = v
			if ESPStyles.Highlight then refreshAllESP() end
		end,
	})
	if HighlightOutlineSlider and HighlightOutlineSlider.Instance then
		HighlightOutlineSlider.Instance.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local newVal = math.clamp(HighlightOutlineTransp + (input.Position.Z > 0 and -0.05 or 0.05), 0, 1)
				HighlightOutlineSlider:SetValue(newVal)
			end
		end)
	end
end

ESPTab:Section({ Title = "Chams Settings" })

do
	local ChamsTranspSlider = ESPTab:Slider({
		Title = "Chams Fill Transparency",
		Step = 0.05,
		Value = { Min = 0, Max = 1, Default = 0.5 },
		Callback = function(v)
			ChamsFillTransp = v
			if ESPStyles.Chams then refreshAllESP() end
		end,
	})
	if ChamsTranspSlider and ChamsTranspSlider.Instance then
		ChamsTranspSlider.Instance.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local newVal = math.clamp(ChamsFillTransp + (input.Position.Z > 0 and -0.05 or 0.05), 0, 1)
				ChamsTranspSlider:SetValue(newVal)
			end
		end)
	end
end

ESPTab:Section({ Title = "Box Settings" })

do
	local BoxTranspSlider = ESPTab:Slider({
		Title = "Box Fill Transparency",
		Step = 0.05,
		Value = { Min = 0, Max = 1, Default = 0.8 },
		Callback = function(v)
			BoxFillTransp = v
			if ESPStyles.Box then refreshAllESP() end
		end,
	})
	if BoxTranspSlider and BoxTranspSlider.Instance then
		BoxTranspSlider.Instance.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseWheel then
				local newVal = math.clamp(BoxFillTransp + (input.Position.Z > 0 and -0.05 or 0.05), 0, 1)
				BoxTranspSlider:SetValue(newVal)
			end
		end)
	end
end

ESPTab:Section({ Title = "ESP Options" })
ESPTab:Toggle({
	Title = "ESP Names", Default = false,
	Callback = function(Value)
		NameTagsEnabled = Value
		refreshAllESP()
	end,
})

ESPTab:Section({ Title = "Dropped Items" })
ESPTab:Toggle({
	Title = "ESP Dropped GunDrop", Default = false,
	Callback = function(Value)
		ESPDroppedGunEnabled = Value
		if Value then
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj.Name == "GunDrop" then
					trackedObjects[obj] = "GunDrop"
					applyGunHighlight(obj)
				end
			end
		else
			refreshAllTrackedHighlights()
		end
	end,
})
ESPTab:Toggle({
	Title = "Show Coins", Default = false,
	Callback = function(Value)
		ShowCoinsEnabled = Value
		if Value then
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj.Name == "Coin" or obj.Name == "CoinVisual" then
					trackedObjects[obj] = "Coin"
					applyCoinHighlight(obj)
				end
			end
		else
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj.Name == "CoinHighlight" then
					pcall(function() obj:Destroy() end)
				end
			end
		end
	end,
})
ESPTab:Toggle({
	Title = "Show Thrown Knife (StuckKnife)", Default = false,
	Callback = function(Value)
		ShowThrownKnifeEnabled = Value
		if Value then
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj.Name == "StuckKnife" then
					trackedObjects[obj] = "StuckKnife"
					applyKnifeHighlight(obj)
				end
			end
		else
			refreshAllTrackedHighlights()
		end
	end,
})

ESPTab:Section({ Title = "Role ESP" })
ESPTab:Toggle({ Title = "Innocent ESP", Value = true, Callback = function(Value)
	InnocentESPEnabled = Value
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer and p.Character then
			clearAllESPOnCharacter(p.Character)
		end
	end
	if ESPEnabled then refreshAllESP() end
end })
ESPTab:Toggle({ Title = "Sheriff ESP", Value = true, Callback = function(Value)
	SheriffESPEnabled = Value
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer and p.Character then
			clearAllESPOnCharacter(p.Character)
		end
	end
	if ESPEnabled then refreshAllESP() end
end })
ESPTab:Toggle({ Title = "Murderer ESP", Value = true, Callback = function(Value)
	MurdererESPEnabled = Value
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer and p.Character then
			clearAllESPOnCharacter(p.Character)
		end
	end
	if ESPEnabled then refreshAllESP() end
end })

ESPTab:Section({ Title = "Tracers" })
ESPTab:Toggle({
	Title = "Player Tracers", Default = false,
	Callback = function(Value)
		TracersEnabled = Value
		if Value then startTracerLoop() else stopTracerLoop() end
	end,
})

print("[HXN] Script fully loaded and ready to use! v7.2.0 (lag optimized)")
