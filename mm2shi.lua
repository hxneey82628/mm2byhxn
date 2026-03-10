-- Prevent double-loading: if hub is already loaded, show notification and stop
if _G.HXNHubLoaded then
	if _G.HXN_WINDUI then
		_G.HXN_WINDUI:Notify({
			Title = "HXN Hub",
			Content = "The script is already running.",
			Icon = "x",
			Duration = 4,
		})
	else
		warn("[HXN] Hub is already loaded, aborting second execute.")
	end
	return
end
_G.HXNHubLoaded = true

print("[HXN] Starting script cleanup...")

pcall(function()
	local CoreGui = game:GetService("CoreGui")
	local WindUIGui = CoreGui:FindFirstChild("WindUI")
	if WindUIGui then
		print("[HXN] Removing old Wind UI instance from CoreGui...")
		WindUIGui:Destroy()
	end
end)

if _G.HXN_WINDOW then
	print("[HXN] Closing old window...")
	pcall(function()
		if _G.HXN_WINDOW.Window then
			_G.HXN_WINDOW.Window:Destroy()
		end
	end)
	pcall(function() _G.HXN_WINDOW:Close() end)
	_G.HXN_WINDOW = nil
end

if _G.HXN_TASKS then
	print("[HXN] Cancelling " .. #_G.HXN_TASKS .. " tasks...")
	for _, taskId in ipairs(_G.HXN_TASKS) do
		pcall(function() task.cancel(taskId) end)
	end
	_G.HXN_TASKS = {}
end

if _G.HXN_CONNECTIONS then
	print("[HXN] Disconnecting " .. #_G.HXN_CONNECTIONS .. " connections...")
	for _, connection in ipairs(_G.HXN_CONNECTIONS) do
		pcall(function() connection:Disconnect() end)
	end
	_G.HXN_CONNECTIONS = {}
end

print("[HXN] Cleaning up old adornments...")
local Players = game:GetService("Players")
for _, player in ipairs(Players:GetPlayers()) do
	if player.Character then
		for _, obj in ipairs(player.Character:GetDescendants()) do
			if obj.Name == "PlayerHighlight" or obj.Name == "PlayerBox" or obj.Name == "NameTag" then
				pcall(function() obj:Destroy() end)
			end
		end
	end
end

pcall(function()
	local localPlayer = game.Players.LocalPlayer
	if localPlayer and localPlayer.Character then
		local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.Anchored = false
			hrp.CanCollide = true
		end
	end
end)

print("[HXN] Cleaning up old Visual effects...")
local Lighting = game:GetService("Lighting")
pcall(function()
	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("BlurEffect") then effect:Destroy() end
	end
end)
pcall(function()
	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("BloomEffect") then effect:Destroy() end
	end
end)
pcall(function()
	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("ColorCorrectionEffect") then effect:Destroy() end
	end
end)
pcall(function()
	local oldSky = Lighting:FindFirstChild("CustomSky")
	if oldSky then oldSky:Destroy() end
end)

----------------------------------------------------------------
-- LOAD WIND UI
----------------------------------------------------------------
print("[HXN] Loading Wind UI...")

local success, WindUI = pcall(function()
	return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/1.6.62/main.lua"))()
end)

if not success then
	print("[HXN] ERROR: Failed to load Wind UI library! " .. tostring(WindUI))
	return
end

if not WindUI then
	print("[HXN] ERROR: Loadstring returned nil!")
	return
end

_G.HXN_WINDUI = WindUI

WindUI.TransparencyValue = 0.35

local RedBlackTheme = {
	Name = "RedBlack",
	Accent = Color3.fromRGB(20, 20, 20),
	Dialog = Color3.fromRGB(15, 15, 15),
	Outline = Color3.fromRGB(255, 50, 50),
	Text = Color3.fromRGB(240, 240, 240),
	Placeholder = Color3.fromRGB(120, 40, 40),
	Background = Color3.fromRGB(15, 15, 15),
	Button = Color3.fromRGB(15, 15, 15),
	Icon = Color3.fromRGB(255, 70, 70),
	Toggle = Color3.fromRGB(0, 200, 80),
	Slider = Color3.fromRGB(220, 0, 0),
	Checkbox = Color3.fromRGB(0, 200, 80),
	PanelBackground = Color3.fromRGB(25, 25, 25),
	PanelBackgroundTransparency = 0.35,
	Primary = Color3.fromRGB(255, 0, 0),
	SliderIcon = Color3.fromRGB(180, 45, 45),
	TabBackground = Color3.fromRGB(25, 25, 25),
	TabBackgroundHover = Color3.fromRGB(35, 35, 35),
	TabBackgroundHoverTransparency = 0.4,
	TabBackgroundActive = Color3.fromRGB(50, 20, 20),
	TabBackgroundActiveTransparency = 0.35,
	TabText = Color3.fromRGB(240, 240, 240),
	TabTextTransparency = 0.3,
	TabTextTransparencyActive = 0,
	TabIcon = Color3.fromRGB(255, 70, 70),
	TabIconTransparency = 0.4,
	TabIconTransparencyActive = 0,
	TabBorderTransparency = 0.5,
	TabBorderTransparencyActive = 0.4,
	TabBorder = Color3.fromRGB(255, 50, 50),
	ElementBackground = Color3.fromRGB(15, 15, 15),
	ElementBackgroundTransparency = 0.3,
	ElementTitle = Color3.fromRGB(240, 240, 240),
	ElementDesc = Color3.fromRGB(180, 180, 180),
	ElementIcon = Color3.fromRGB(255, 70, 70),
	WindowBackground = Color3.fromRGB(15, 15, 15),
	WindowTopbarTitle = Color3.fromRGB(240, 240, 240),
	WindowTopbarAuthor = Color3.fromRGB(255, 70, 70),
	WindowTopbarIcon = Color3.fromRGB(255, 70, 70),
	WindowTopbarButtonIcon = Color3.fromRGB(255, 70, 70),
	Hover = Color3.fromRGB(50, 20, 20),
	LabelBackground = Color3.fromRGB(25, 25, 25),
	LabelBackgroundTransparency = 0.5,
	Notification = Color3.fromRGB(25, 25, 25),
	NotificationTitle = Color3.fromRGB(240, 240, 240),
	NotificationContent = Color3.fromRGB(180, 180, 180),
	NotificationDuration = Color3.fromRGB(0, 255, 100),
	NotificationBorder = Color3.fromRGB(0, 255, 100),
	NotificationBorderTransparency = 0.4,
	Tooltip = Color3.fromRGB(15, 15, 15),
	TooltipText = Color3.fromRGB(240, 240, 240),
	TooltipSecondary = Color3.fromRGB(0, 255, 100),
	TooltipSecondaryText = Color3.fromRGB(255, 255, 255),
	WindowSearchBarBackground = Color3.fromRGB(35, 35, 35),
	SearchBarBorder = Color3.fromRGB(255, 50, 50),
	SearchBarBorderTransparency = 0.5,
}

WindUI:AddTheme(RedBlackTheme)

print("[HXN] Creating window...")
local Window = WindUI:CreateWindow({
	Title  = "HXN Hub MM2",
	Icon   = "solar:settings-bold",
	Author = "by hxneey",
	Folder = "HXN_MM2",
	Size   = UDim2.fromOffset(580, 490),
	Theme  = "RedBlack",
	Transparent = true,
	BackgroundImageTransparency = 0.65,
	Acrylic = true,
	User = {
		Enabled = true,
		Anonymous = false,
		Callback = function()
			print("[HXN] User profile clicked!")
		end,
	},
})

Window:SetToggleKey(Enum.KeyCode.K)

_G.HXN_WINDOW = Window
_G.HXN_TASKS = {}
_G.HXN_CONNECTIONS = {}

local function Notify(title, content, icon, duration)
	WindUI:Notify({
		Title = title,
		Content = content,
		Icon = icon or "bell",
		Duration = duration or 3,
	})
end

print("[HXN] Window created successfully!")

Window:Tag({
	Title = "Version 7.1.3",
	Color = Color3.fromRGB(0, 255, 100),
	Border = true,
})
Window:Tag({
	Title = "Premium",
	Color = Color3.fromRGB(255, 80, 80),
})
Window:Tag({
	Title = "Updated",
	Color = Color3.fromRGB(0, 255, 100),
})

spawn(function()
	task.wait(0.3)
	pcall(function()
		local CoreGui = game:GetService("CoreGui")
		local WindUIGui = CoreGui:FindFirstChild("WindUI")
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

			print("[HXN] HXN Hub style UI applied!")
		end
	end)
end)

-- create tabs
local CharacterTab = Window:Tab({Title = "Character", Icon = "user"})
local TeleportTab  = Window:Tab({Title = "Teleport",  Icon = "plane"})
local CombatTab    = Window:Tab({Title = "Combat",    Icon = "sword"})
local TrollingTab  = Window:Tab({Title = "Trolling",  Icon = "zap"})
local ESPTab       = Window:Tab({Title = "ESP",       Icon = "eye"})
local VisualTab    = Window:Tab({Title = "Visual",    Icon = "palette"})
local AutofarmTab  = Window:Tab({Title = "Autofarm",  Icon = "sprout"})
local EmoteTab     = Window:Tab({Title = "Emotes",    Icon = "smile"})
local OtherTab     = Window:Tab({Title = "Other",     Icon = "settings"})

CharacterTab:Select()

local function findMurderer()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= Players.LocalPlayer and player.Character then
			local backpack = player:FindFirstChildOfClass("Backpack")
			if backpack and backpack:FindFirstChild("Knife") then return player end
			if player.Character:FindFirstChild("Knife") then return player end
		end
	end
	return nil
end

local function getGunTool()
	local player = Players.LocalPlayer
	if not player or not player.Character then return nil end
	if player.Character:FindFirstChild("Gun") then return player.Character:FindFirstChild("Gun") end
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack and backpack:FindFirstChild("Gun") then return backpack:FindFirstChild("Gun") end
	return nil
end

--------------------------------------------------
-- GUNBEAM SILENT AIM SYSTEM (Sheriff)
--------------------------------------------------

local GunBeamAutoAimEnabled = false
local TargetMurderer = nil

local function HookGunBeam()
	if _G.HXN_GunBeamHooked then return end
	if not hookmetamethod then
		print("[HXN] hookmetamethod not available, skipping GunBeam hook")
		return
	end
	_G.HXN_GunBeamHooked = true

	local WeaponEvents = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
	if WeaponEvents then
		WeaponEvents = WeaponEvents:FindFirstChild("WeaponEvents")
	end

	local oldIndex
	oldIndex = hookmetamethod(game, "__index", function(t, k)
		if t:IsA("Beam") and GunBeamAutoAimEnabled and TargetMurderer and TargetMurderer.Character then
			local TargetPart = TargetMurderer.Character:FindFirstChild("HumanoidRootPart") or TargetMurderer.Character:FindFirstChild("Head")
			if TargetPart and k == "Transparency" then
				return oldIndex(t, k)
			end
		end
		return oldIndex(t, k)
	end)

	print("[HXN] GunBeam hook installed!")
end

local function shootMurdererWithGunBeam()
	if not GunBeamAutoAimEnabled then return end
	local localPlayer = Players.LocalPlayer
	if not localPlayer or not localPlayer.Character then return end

	TargetMurderer = findMurderer()
	if not TargetMurderer or not TargetMurderer.Character then return end

	local gunTool = getGunTool()
	if not gunTool then return end

	if gunTool.Parent == localPlayer:FindFirstChildOfClass("Backpack") then
		gunTool.Parent = localPlayer.Character
	end

	GunBeamAutoAimEnabled = true
	pcall(function()
		gunTool:Activate()
		print("[HXN] GunBeam auto-aim shot fired at murderer!")
	end)

	TargetMurderer = nil

	pcall(function()
		local murderer = findMurderer()
		if murderer then
			local gunKillRemote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
			if gunKillRemote then
				gunKillRemote = gunKillRemote:FindFirstChild("Gameplay")
				if gunKillRemote then
					gunKillRemote = gunKillRemote:FindFirstChild("GunKill")
					if gunKillRemote then
						gunKillRemote:FireServer(murderer)
						print("[HXN] GunKill remote fired!")
					end
				end
			end
		end
	end)
end

HookGunBeam()

-- SHERIFF SECTION
CombatTab:Section({Title = "Sheriff"})

local shootMurdererEnabled = true

CombatTab:Keybind({
	Title = "Shoot Murderer",
	Value = "Q",
	Callback = function()
		if not shootMurdererEnabled then return end
		local localPlayer = Players.LocalPlayer
		if not localPlayer.Character then return end

		local backpack = localPlayer:FindFirstChildOfClass("Backpack")
		local hasGun = localPlayer.Character:FindFirstChild("Gun")
			or (backpack and backpack:FindFirstChild("Gun"))
		if not hasGun then
			Notify("Combat", "You are not the Sheriff or Hero.", "x", 3)
			return
		end

		local murderer = findMurderer()
		if not murderer or not murderer.Character then
			Notify("Combat", "No murderer detected.", "x", 2)
			return
		end

		if not localPlayer.Character:FindFirstChild("Gun") then
			if backpack and backpack:FindFirstChild("Gun") then
				localPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(backpack:FindFirstChild("Gun"))
			end
		end

		local gunTool = localPlayer.Character:FindFirstChild("Gun")
		local murdererHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
		if gunTool and murdererHRP then
			local predictedPos = murdererHRP.Position + (murdererHRP.Velocity * 0.1)
			local args = {
				CFrame.new(localPlayer.Character.RightHand.Position),
				CFrame.new(predictedPos)
			}
			gunTool:WaitForChild("Shoot"):FireServer(unpack(args))
		end
	end,
})

CombatTab:Toggle({
	Title = "Shoot Murderer Enabled",
	Value = true,
	Callback = function(Value)
		shootMurdererEnabled = Value
	end,
})

-- MURDERER SECTION
CombatTab:Section({Title = "Murderer"})

local function getOrEquipKnife()
	local localPlayer = Players.LocalPlayer
	if not localPlayer or not localPlayer.Character then return nil end

	local knife = localPlayer.Character:FindFirstChild("Knife")
	if knife then return knife end

	local backpack = localPlayer:FindFirstChildOfClass("Backpack")
	if backpack and backpack:FindFirstChild("Knife") then
		local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
		hum:EquipTool(backpack:FindFirstChild("Knife"))
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
				if dist < shortestDist then
					shortestDist = dist
					nearest = player
				end
			end
		end
	end
	return nearest
end

local knifeThrowClosestEnabled = true

CombatTab:Keybind({
	Title = "Knife Throw to Closest",
	Value = "E",
	Callback = function()
		if not knifeThrowClosestEnabled then return end
		local knifeTool = getOrEquipKnife()
		if not knifeTool then return end

		local target = findClosestPlayer()
		if not target then return end

		local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
		if not targetHRP then return end

		local localPlayer = Players.LocalPlayer
		local args = {
			CFrame.new(localPlayer.Character.RightHand.Position),
			CFrame.new(targetHRP.Position + targetHRP.Velocity * 0.1)
		}
		pcall(function()
			knifeTool:WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(unpack(args))
		end)
	end,
})

CombatTab:Toggle({
	Title = "Knife Throw to Closest Enabled",
	Value = true,
	Callback = function(Value)
		knifeThrowClosestEnabled = Value
	end,
})

local autoKnifeThrowEnabled = false
CombatTab:Toggle({
	Title = "Auto Knife Throw",
	Value = false,
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
							local args = {
								CFrame.new(localPlayer.Character.RightHand.Position),
								CFrame.new(nearestHRP.Position + nearestHRP.Velocity * 0.1)
							}
							pcall(function()
								knifeTool:WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(unpack(args))
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
-- ANTI-AFK / ANTI-FLING
--------------------------------------------------

local AntiAfkEnabled = true
local antiAfkConn = nil

local function setupAntiAfk()
	if antiAfkConn then return end
	local vu = game:GetService("VirtualUser")
	local plr = game:GetService("Players").LocalPlayer
	antiAfkConn = plr.Idled:Connect(function()
		vu:CaptureController()
		vu:ClickButton2(Vector2.new())
	end)
end

local function disableAntiAfk()
	if antiAfkConn then
		antiAfkConn:Disconnect()
		antiAfkConn = nil
	end
end

local antiFlingEnabled = false
local antiFlingConnections = {}
local antiFlingHeartbeats = {}

local function AntiFling()
	-- Clear old heartbeat connections first
	for _, conn in ipairs(antiFlingHeartbeats) do
		pcall(function() conn:Disconnect() end)
	end
	antiFlingHeartbeats = {}

	local Client = Players.LocalPlayer
	if not Client or not Client.Character then return end

	for _, v in next, game:GetDescendants() do
		if v and v:IsA("Part")
			and v.Parent ~= Client.Character
			and v.Anchored == false
			and v.Name == "HumanoidRootPart"
		then
			local conn = game:GetService("RunService").Heartbeat:Connect(function()
				if not antiFlingEnabled then return end
				v.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
				v.Velocity = Vector3.new(0,0,0)
				v.RotVelocity = Vector3.new(0,0,0)
				v.CanCollide = false
			end)
			table.insert(antiFlingHeartbeats, conn)
		end
	end

	-- Re-run on new parts
	local descConn = workspace.DescendantAdded:Connect(function(part)
		if not antiFlingEnabled then return end
		if part:IsA("Part") and part.Name == "HumanoidRootPart"
			and part.Parent ~= Players.LocalPlayer.Character
		then
			task.wait(2)
			if antiFlingEnabled then AntiFling() end
		end
	end)
	table.insert(antiFlingConnections, descConn)

	-- Stop if local player dies
	if Client.Character and Client.Character:FindFirstChildOfClass("Humanoid") then
		local diedConn = Client.Character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
			for _, conn in ipairs(antiFlingHeartbeats) do
				pcall(function() conn:Disconnect() end)
			end
			antiFlingHeartbeats = {}
		end)
		table.insert(antiFlingConnections, diedConn)
	end
end

local function startAntiFling()
	if antiFlingEnabled then return end
	antiFlingEnabled = true
	AntiFling()
end

local function stopAntiFling()
	antiFlingEnabled = false
	for _, conn in ipairs(antiFlingHeartbeats) do
		pcall(function() conn:Disconnect() end)
	end
	for _, conn in ipairs(antiFlingConnections) do
		pcall(function() conn:Disconnect() end)
	end
	antiFlingHeartbeats = {}
	antiFlingConnections = {}
end

--------------------------------------------------
-- OTHER TAB UI
--------------------------------------------------

OtherTab:Section({Title = "Anti-Exploit"})

OtherTab:Toggle({
	Title = "Anti-AFK",
	Value = true,
	Callback = function(val)
		AntiAfkEnabled = val
		if val then setupAntiAfk() else disableAntiAfk() end
	end,
})

if AntiAfkEnabled then setupAntiAfk() end

OtherTab:Toggle({
	Title = "Anti-Fling",
	Value = false,
	Callback = function(val)
		if val then startAntiFling() else stopAntiFling() end
	end,
})

-- ROUND TIMER SECTION
OtherTab:Section({Title = "Round Timer"})

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

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = label

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 50, 50)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.3
	stroke.Parent = label

	return screenGui, label
end

OtherTab:Toggle({
	Title = "Round Timer",
	Value = false,
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
						if ok and type(timeLeft) == "number" then
							label.Text = "⏱ " .. secondsToMinutes(math.floor(timeLeft))
						else
							label.Text = "⏱ Waiting..."
						end
					else
						break
					end
				end
			end)

			Notify("Other", "Round Timer enabled.", "check", 2)
		else
			if roundTimerGui then
				roundTimerGui:Destroy()
				roundTimerGui = nil
			end
		end
	end,
})

OtherTab:Section({Title = "Utilities"})

OtherTab:Toggle({
	Title = "Gun Drop Notify",
	Value = false,
	Callback = function(Value)
		GunDropNotifyEnabled = Value
		if Value then
			Notify("Other", "Gun Drop Notify enabled.", "check", 2)
		else
			Notify("Other", "Gun Drop Notify disabled.", "x", 2)
		end
	end,
})

OtherTab:Button({
	Title = "Inf Yield",
	Callback = function()
		local success, result = pcall(function()
			local script = game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
			loadstring(script)()
		end)
		if not success then print("[HXN] Inf Yield Error: " .. tostring(result)) end
	end,
})

EmoteTab:Button({
	Title = "Emotes",
	Callback = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/Joystickplays/AFEM/main/max/afemmax.lua"))()
	end,
})

--------------------------------------------------
-- CHARACTER TAB UI
--------------------------------------------------

CharacterTab:Section({Title = "Performance"})

local fps = 0
local fpsFrameCount = 0
local fpsAccumulator = 0
local currentPing = 0

game:GetService("RunService").Heartbeat:Connect(function(dt)
	fpsFrameCount = fpsFrameCount + 1
	fpsAccumulator = fpsAccumulator + dt
	if fpsAccumulator >= 0.5 then
		fps = math.floor(fpsFrameCount / fpsAccumulator)
		fpsFrameCount = 0
		fpsAccumulator = 0
	end
end)

local function getPing()
	local player = game.Players.LocalPlayer
	if player then
		currentPing = math.floor(player:GetNetworkPing() * 1000)
	end
	return currentPing
end

local PerformanceLabel = CharacterTab:Paragraph({
	Title = "FPS & Ping",
	Desc = "FPS: 0\nNetwork Ping: 0 ms"
})

local performanceTaskId = task.spawn(function()
	while true do
		task.wait(0.5)
		getPing()
		if PerformanceLabel then
			PerformanceLabel:SetDesc("FPS: " .. tostring(fps) .. "\nNetwork Ping: " .. tostring(currentPing) .. " ms")
		end
	end
end)
table.insert(_G.HXN_TASKS, performanceTaskId)

CharacterTab:Section({Title = "Movement"})

local currentWalkSpeed = 16
local walkSpeedEnabled = false

CharacterTab:Toggle({
	Title = "Enable WalkSpeed Changer",
	Value = false,
	Callback = function(Value)
		walkSpeedEnabled = Value
		if Value then
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = currentWalkSpeed
		else
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
		end
	end,
})

local WalkSpeedSlider = CharacterTab:Slider({
	Title = "WalkSpeed Slider",
	Step = 1,
	Value = { Min = 1, Max = 350, Default = 16 },
	Callback = function(Value)
		currentWalkSpeed = Value
		if walkSpeedEnabled then
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
		end
	end,
})

if WalkSpeedSlider and WalkSpeedSlider.Instance then
	WalkSpeedSlider.Instance.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local newValue = math.clamp((currentWalkSpeed or 16) + (input.Position.Z > 0 and 1 or -1), 1, 350)
			WalkSpeedSlider:SetValue(newValue)
		end
	end)
end

CharacterTab:Input({
	Title = "Quick WalkSpeed",
	Value = "",
	Placeholder = "1-500",
	Callback = function(Text)
		local speed = tonumber(Text)
		if speed then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed end
	end,
})

CharacterTab:Section({Title = "Jump"})

local currentJumpPower = 50
local jumpPowerEnabled = false

CharacterTab:Toggle({
	Title = "Enable JumpPower Changer",
	Value = false,
	Callback = function(Value)
		jumpPowerEnabled = Value
		if Value then
			game.Players.LocalPlayer.Character.Humanoid.JumpPower = currentJumpPower
		else
			game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
		end
	end,
})

local JumpPowerSlider = CharacterTab:Slider({
	Title = "JumpPower Slider",
	Step = 1,
	Value = { Min = 1, Max = 350, Default = 50 },
	Callback = function(Value)
		currentJumpPower = Value
		if jumpPowerEnabled then
			game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
		end
	end,
})

if JumpPowerSlider and JumpPowerSlider.Instance then
	JumpPowerSlider.Instance.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local newValue = math.clamp((currentJumpPower or 50) + (input.Position.Z > 0 and 1 or -1), 1, 350)
			JumpPowerSlider:SetValue(newValue)
		end
	end)
end

CharacterTab:Section({Title = "Camera"})

local fov_enabled = false
local fov_value = 70

local function updateFOV()
	local cam = workspace.CurrentCamera
	if cam then cam.FieldOfView = fov_enabled and fov_value or 70 end
end

CharacterTab:Toggle({
	Title = "Custom FOV",
	Value = false,
	Callback = function(val) fov_enabled = val updateFOV() end,
})

local FOVSlider = CharacterTab:Slider({
	Title = "FOV Value",
	Step = 1,
	Value = { Min = 1, Max = 120, Default = 70 },
	Callback = function(val) fov_value = val updateFOV() end,
})

if FOVSlider and FOVSlider.Instance then
	FOVSlider.Instance.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local newValue = math.clamp((fov_value or 70) + (input.Position.Z > 0 and 1 or -1), 1, 120)
			FOVSlider:SetValue(newValue)
		end
	end)
end

--------------------------------------------------
-- ESP SETTINGS
--------------------------------------------------

local OTHER_PLAYER_COLOR  = Color3.fromRGB(0, 255, 0)
local LOCAL_PLAYER_COLOR  = Color3.fromRGB(0, 255, 100)
local MURDERER_COLOR      = Color3.fromRGB(255, 0, 0)
local SHERIFF_COLOR       = Color3.fromRGB(0, 0, 139)
local GUN_COLOR           = Color3.fromRGB(255, 255, 0)
local STUCK_KNIFE_COLOR   = Color3.fromRGB(255, 165, 0)
local COIN_COLOR          = Color3.fromRGB(255, 223, 0)

local FILL_TRANSPARENCY    = 0.5
local OUTLINE_TRANSPARENCY = 0
local CHECK_INTERVAL       = 1.0

local ESPEnabled             = false
local NameTagsEnabled        = false
local ESPNamesEnabled        = false
local ESPDroppedGunEnabled   = false
local ShowCoinsEnabled       = false
local ShowThrownKnifeEnabled = false
local InnocentESPEnabled     = true
local SheriffESPEnabled      = true
local MurdererESPEnabled     = true
local ESPModeType            = "Highlight"
local GunDropType            = "Highlight"
local GunTPEnabled           = false
local GunTPKeybind           = Enum.KeyCode.G
local OriginalPosition       = nil
local IsAtGun                = false
local GunDropNotifyEnabled   = false  -- FIX: declared here before use
local GunDropDetected        = false
local TracersEnabled         = false

--------------------------------------------------
-- GUN DROP NOTIFY SYSTEM (NEW)
--------------------------------------------------

local gunDropNotifyTask = task.spawn(function()
	local lastKnownGuns = {}

	while true do
		task.wait(2)

		if not GunDropNotifyEnabled then
			-- Clear table so when re-enabled we don't get false positives
			lastKnownGuns = {}
			continue
		end

		-- Build current gun set by scanning workspace
		local currentGuns = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj.Name == "GunDrop" then
				currentGuns[obj] = true
			end
		end

		-- Check for newly appeared guns
		for obj in pairs(currentGuns) do
			if not lastKnownGuns[obj] then
				-- Get position safely whether it's a Model or BasePart
				local pos
				pcall(function()
					if obj:IsA("Model") then
						pos = obj:GetPivot().Position
					elseif obj:IsA("BasePart") then
						pos = obj.Position
					elseif obj.Parent and obj.Parent:IsA("Model") then
						pos = obj.Parent:GetPivot().Position
					end
				end)

				if pos then
					Notify(
						"🔫 Gun Dropped!",
						"A gun was dropped at (" ..
						math.floor(pos.X) .. ", " ..
						math.floor(pos.Y) .. ", " ..
						math.floor(pos.Z) .. ")",
						"alert-triangle",
						6
					)
				else
					Notify("🔫 Gun Dropped!", "A gun was dropped on the map!", "alert-triangle", 6)
				end
			end
		end

		lastKnownGuns = currentGuns
	end
end)
table.insert(_G.HXN_TASKS, gunDropNotifyTask)

--------------------------------------------------
-- FLING VARIABLES
--------------------------------------------------

local FlingActive = false
local SelectedFlingTarget = nil
local FlingConnection = nil
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

local function FllingMessage(Title, Text, Time)
	print("[Fling] " .. Title .. ": " .. Text)
end

local function SkidFling(TargetPlayer)
	local Player = Players.LocalPlayer
	local Character = Player.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart = Humanoid and Humanoid.RootPart
	local TCharacter = TargetPlayer.Character
	if not TCharacter then return end

	local THumanoid, TRootPart, THead, Accessory, Handle
	THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
	if THumanoid and THumanoid.RootPart then TRootPart = THumanoid.RootPart end
	THead = TCharacter:FindFirstChild("Head")
	Accessory = TCharacter:FindFirstChildOfClass("Accessory")
	if Accessory then Handle = Accessory:FindFirstChild("Handle") end

	if Character and Humanoid and RootPart then
		if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end

		if THumanoid and THumanoid.Sit then
			return FllingMessage("Error", TargetPlayer.Name .. " is sitting", 2)
		end

		if THead then workspace.CurrentCamera.CameraSubject = THead
		elseif Handle then workspace.CurrentCamera.CameraSubject = Handle
		elseif THumanoid and TRootPart then workspace.CurrentCamera.CameraSubject = THumanoid
		end

		if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end

		local FPos = function(BasePart, Pos, Ang)
			RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
			Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
			RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
			RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
		end

		local SFBasePart = function(BasePart)
			local TimeToWait = 2
			local Time = tick()
			local Angle = 0
			repeat
				if RootPart and THumanoid then
					if BasePart.Velocity.Magnitude < 50 then
						Angle = Angle + 100
						FPos(BasePart, CFrame.new(0,1.5,0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)) task.wait()
						FPos(BasePart, CFrame.new(0,-1.5,0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)) task.wait()
						FPos(BasePart, CFrame.new(0,1.5,0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)) task.wait()
						FPos(BasePart, CFrame.new(0,-1.5,0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude/1.25, CFrame.Angles(math.rad(Angle),0,0)) task.wait()
						FPos(BasePart, CFrame.new(0,1.5,0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0)) task.wait()
						FPos(BasePart, CFrame.new(0,-1.5,0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0,0)) task.wait()
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
			until Time + TimeToWait < tick() or not FlingActive
		end

		workspace.FallenPartsDestroyHeight = 0/0

		local BV = Instance.new("BodyVelocity")
		BV.Parent = RootPart
		BV.Velocity = Vector3.new(0,0,0)
		BV.MaxForce = Vector3.new(9e9,9e9,9e9)

		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

		if TRootPart then SFBasePart(TRootPart)
		elseif THead then SFBasePart(THead)
		elseif Handle then SFBasePart(Handle)
		else return FllingMessage("Error", TargetPlayer.Name .. " has no valid parts", 2)
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
					if part:IsA("BasePart") then
						part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
					end
				end
				task.wait()
			until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
			workspace.FallenPartsDestroyHeight = getgenv().FPDH
		end
	else
		return FllingMessage("Error", "Your character is not ready", 2)
	end
end

local function GetPlayerList()
	local playerNames = {}
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= Players.LocalPlayer then
			table.insert(playerNames, player.Name)
		end
	end
	return playerNames
end

local function StartFling()
	if FlingActive then return end
	if not SelectedFlingTarget then FllingMessage("Error","No target selected!",2) return end
	FlingActive = true
	FllingMessage("Started","Flinging " .. SelectedFlingTarget .. "!",2)
	task.spawn(function()
		while FlingActive do
			local targetPlayer = nil
			for _, player in ipairs(Players:GetPlayers()) do
				if player.Name == SelectedFlingTarget and player ~= Players.LocalPlayer then
					targetPlayer = player break
				end
			end
			if targetPlayer and targetPlayer.Parent then
				SkidFling(targetPlayer) task.wait(0.1)
			else
				FlingActive = false break
			end
		end
	end)
end

local function StopFling()
	if not FlingActive then return end
	FlingActive = false
	FllingMessage("Stopped","Fling has been stopped",2)
end

local function FlingAll()
	if FlingActive then return end
	FlingActive = true
	FllingMessage("Started","Flinging all players!",2)
	task.spawn(function()
		while FlingActive do
			local validTargets = {}
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= Players.LocalPlayer and player.Character then
					table.insert(validTargets, player)
				end
			end
			if #validTargets == 0 then FlingActive = false break end
			for _, targetPlayer in ipairs(validTargets) do
				if FlingActive then SkidFling(targetPlayer) task.wait(0.1) else break end
			end
			task.wait(0.5)
		end
	end)
end

--------------------------------------------------
-- TELEPORT FUNCTIONS
--------------------------------------------------

local knownMapNames = {
	"Bank2","BioLab","Factory","Hospital3","Hotel2","House2","Mansion2","MilBase","Office3","PoliceStation","ResearchFacility","Workplace"
}

local function getCurrentMapName()
	for _, knownName in ipairs(knownMapNames) do
		local found = workspace:FindFirstChild(knownName)
		if found and found:IsA("Model") then return knownName end
	end
	return "Unknown"
end

local function teleportToLobby()
	local player = Players.LocalPlayer
	if not player or not player.Character then return end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local lobby = workspace:FindFirstChild("Lobby")
	if not lobby or not lobby:IsA("Model") then return end
	local spawnsFolder = lobby:FindFirstChild("Spawns")
	if not spawnsFolder then return end

	local spawnPoints = {}
	for _, obj in ipairs(spawnsFolder:GetChildren()) do
		if obj:IsA("SpawnLocation") then table.insert(spawnPoints, obj) end
	end
	if #spawnPoints == 0 then return end

	local chosenSpawn = spawnPoints[math.random(1, #spawnPoints)]
	hrp.CFrame = chosenSpawn.CFrame + Vector3.new(0, 3, 0)
end

local function teleportToMap()
	local player = Players.LocalPlayer
	if not player or not player.Character then return end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local map
	for _, name in ipairs(knownMapNames) do
		map = workspace:FindFirstChild(name)
		if map then break end
	end
	if not map then return end

	local spawnsFolder = map:FindFirstChild("Spawns")
	if not spawnsFolder then return end

	local spawnPoints = {}
	for _, obj in ipairs(spawnsFolder:GetChildren()) do
		if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then table.insert(spawnPoints, obj) end
	end
	if #spawnPoints == 0 then return end

	local chosenSpawn = spawnPoints[math.random(1, #spawnPoints)]
	hrp.CFrame = chosenSpawn.CFrame + Vector3.new(0, 3, 0)
end

local function teleportToSecretPlace()
	local player = Players.LocalPlayer
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = CFrame.new(319, 537, 89)
	end
end

--------------------------------------------------
-- WORLD OBJECT TRACKER (Gun / StuckKnife / Coins)
--------------------------------------------------

local function updateGunDisplay(gun)
	if not gun or gun.Name ~= "GunDrop" then return end
	for _, child in ipairs(gun:GetChildren()) do
		if child.Name == "GunHighlight" or child.Name == "GunBillboard" then child:Destroy() end
	end
	if not ESPDroppedGunEnabled then return end
	local highlight = Instance.new("Highlight")
	highlight.Name = "GunHighlight"
	highlight.FillTransparency = FILL_TRANSPARENCY
	highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = GUN_COLOR
	highlight.Parent = gun
end

local function updateStuckKnifeHighlight(knife)
	if not knife or knife.Name ~= "StuckKnife" then return end
	local highlight = knife:FindFirstChild("StuckKnifeHighlight")
	if not ShowThrownKnifeEnabled then
		if highlight then highlight:Destroy() end
		return
	end
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "StuckKnifeHighlight"
		highlight.FillTransparency = FILL_TRANSPARENCY
		highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = STUCK_KNIFE_COLOR
		highlight.Parent = knife
	end
	highlight.Enabled = ShowThrownKnifeEnabled
end

local function updateCoinHighlight(obj)
	if not obj then return end
	if obj.Name ~= "Coin" and obj.Name ~= "CoinVisual" then return end
	local target = obj
	if obj.Name == "CoinVisual" then
		local part = obj:FindFirstChild("MainCoin") or obj:FindFirstChildWhichIsA("BasePart")
		if part then target = part end
	end
	local highlight = target:FindFirstChild("CoinHighlight")
	if not ShowCoinsEnabled then
		if highlight then highlight:Destroy() end
		return
	end
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "CoinHighlight"
		highlight.FillTransparency = FILL_TRANSPARENCY
		highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = COIN_COLOR
		highlight.Parent = target
	end
	highlight.Enabled = ShowCoinsEnabled
end

local mergedTrackerTaskId = task.spawn(function()
	while true do
		task.wait(CHECK_INTERVAL)
		for _, obj in ipairs(workspace:GetDescendants()) do
			local name = obj.Name
			if name == "GunDrop" then
				updateGunDisplay(obj)
			elseif name == "StuckKnife" then
				updateStuckKnifeHighlight(obj)
			elseif name == "Coin" or name == "CoinVisual" then
				updateCoinHighlight(obj)
			end
		end
	end
end)
table.insert(_G.HXN_TASKS, mergedTrackerTaskId)

--------------------------------------------------
-- ROLE DETECTION
--------------------------------------------------

local function getRole(player)
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

--------------------------------------------------
-- VISUAL UPDATE
--------------------------------------------------

local function updatePlayer(player)
	local character = player.Character
	if not character then return end

	local role = getRole(player)
	local color = OTHER_PLAYER_COLOR
	if role == "Murderer" then color = MURDERER_COLOR
	elseif role == "Sheriff" then color = SHERIFF_COLOR
	end

	local shouldShowESP = (role == "Murderer" and MurdererESPEnabled)
		or (role == "Sheriff" and SheriffESPEnabled)
		or (role == "Other" and InnocentESPEnabled)

	local highlight = character:FindFirstChild("PlayerHighlight")
	if ESPModeType == "Highlight" then
		if not highlight then
			highlight = Instance.new("Highlight")
			highlight.Name = "PlayerHighlight"
			highlight.FillTransparency = FILL_TRANSPARENCY
			highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = character
		end
		highlight.FillColor = color
		highlight.Enabled = ESPEnabled and shouldShowESP
	else
		if highlight then highlight:Destroy() end
	end

	if ESPModeType == "Chams" and ESPEnabled and shouldShowESP then
		for _, part in ipairs(character:GetChildren()) do
			if part:IsA("BasePart") then
				local cham = part:FindFirstChild("Cham")
				if not cham then
					cham = Instance.new("BoxHandleAdornment")
					cham.Name = "Cham"
					cham.Adornee = part
					cham.AlwaysOnTop = true
					cham.Size = part.Size + Vector3.new(0.1,0.1,0.1)
					cham.Transparency = 0.5
					cham.Color3 = color
					cham.Parent = part
				end
				cham.Color3 = color
				cham.Visible = true
			end
		end
	else
		for _, obj in ipairs(character:GetDescendants()) do
			if obj.Name == "Cham" then obj:Destroy() end
		end
	end

	if ESPModeType == "Box" and ESPEnabled and shouldShowESP then
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local box = character:FindFirstChild("PlayerBox")
			local outline = character:FindFirstChild("PlayerBoxOutline")
			if not box then
				box = Instance.new("BoxHandleAdornment")
				box.Name = "PlayerBox"
				box.Adornee = hrp
				box.Size = Vector3.new(6,6,6)
				box.AlwaysOnTop = true
				box.Transparency = 0.8
				box.ZIndex = 5
				box.Parent = character
			end
			if not outline then
				outline = Instance.new("BoxHandleAdornment")
				outline.Name = "PlayerBoxOutline"
				outline.Adornee = hrp
				outline.Size = Vector3.new(6.2,6.2,6.2)
				outline.Color3 = Color3.new(0,0,0)
				outline.AlwaysOnTop = true
				outline.Transparency = 0.9
				outline.ZIndex = 4
				outline.Parent = character
			end
			box.Color3 = color
		end
	else
		for _, obj in ipairs(character:GetChildren()) do
			if obj.Name == "PlayerBox" or obj.Name == "PlayerBoxOutline" then obj:Destroy() end
		end
	end

	local tag = character:FindFirstChild("NameTag")
	if not NameTagsEnabled then
		if tag then tag:Destroy() end
	else
		if not tag then
			local head = character:FindFirstChild("Head")
			if head then
				tag = Instance.new("BillboardGui")
				tag.Name = "NameTag"
				tag.Adornee = head
				tag.Size = UDim2.new(0,100,0,20)
				tag.StudsOffset = Vector3.new(0,2.5,0)
				tag.AlwaysOnTop = true

				local text = Instance.new("TextLabel")
				text.Size = UDim2.new(1,0,1,0)
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

--------------------------------------------------
-- PLAYER TRACKING LOOP
--------------------------------------------------

local function startTracking(player)
	local charAddedConn = player.CharacterAdded:Connect(function()
		task.wait(0.2)
		updatePlayer(player)
	end)
	table.insert(_G.HXN_CONNECTIONS, charAddedConn)

	local trackTaskId = task.spawn(function()
		while true do
			updatePlayer(player)
			task.wait(CHECK_INTERVAL)
		end
	end)
	table.insert(_G.HXN_TASKS, trackTaskId)
end

for _, player in ipairs(Players:GetPlayers()) do
	startTracking(player)
end

local playerAddedConn = Players.PlayerAdded:Connect(startTracking)
table.insert(_G.HXN_CONNECTIONS, playerAddedConn)

--------------------------------------------------
-- TRACERS
--------------------------------------------------

if _G.HXN_TRACER_LOOP then pcall(function() _G.HXN_TRACER_LOOP:Disconnect() end) end
if _G.HXN_TRACERS then
	for _, line in pairs(_G.HXN_TRACERS) do pcall(function() line:Remove() end) end
end

_G.HXN_TRACERS = {}

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local tracerLines = _G.HXN_TRACERS

_G.HXN_TRACER_LOOP = game:GetService("RunService").RenderStepped:Connect(function()
	if not TracersEnabled then
		for _, line in pairs(tracerLines) do line.Visible = false end
		return
	end

	for player, line in pairs(tracerLines) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local root = player.Character.HumanoidRootPart
			local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
			if onScreen then
				line.Visible = true
				line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
				line.To = Vector2.new(pos.X, pos.Y)
				local role = getRole(player)
				if role == "Murderer" then line.Color = MURDERER_COLOR
				elseif role == "Sheriff" then line.Color = SHERIFF_COLOR
				else line.Color = OTHER_PLAYER_COLOR
				end
				line.Thickness = 3
			else
				line.Visible = false
			end
		else
			line.Visible = false
		end
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		local line = Drawing.new("Line")
		line.Visible = false
		line.Thickness = 1
		tracerLines[player] = line
	end
end

Players.PlayerAdded:Connect(function(player)
	if player ~= LocalPlayer then
		local line = Drawing.new("Line")
		line.Visible = false
		tracerLines[player] = line
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if tracerLines[player] then
		tracerLines[player]:Remove()
		tracerLines[player] = nil
	end
end)

--------------------------------------------------
-- VISUAL TAB
--------------------------------------------------

VisualTab:Section({Title = "Sky Settings"})

local currentSky

local function applySky(skyName)
	if currentSky then currentSky:Destroy() currentSky = nil end
	if skyName == "Default" then return end

	local sky = Instance.new("Sky")
	sky.Name = "CustomSky"

	if skyName == "Aesthetic" then
		sky.SkyboxBk = "rbxassetid://600830446" sky.SkyboxDn = "rbxassetid://600831635"
		sky.SkyboxFt = "rbxassetid://600832720" sky.SkyboxLf = "rbxassetid://600886090"
		sky.SkyboxRt = "rbxassetid://600833862" sky.SkyboxUp = "rbxassetid://600835177"
	elseif skyName == "Night" then
		sky.SkyboxBk = "rbxassetid://154185004" sky.SkyboxDn = "rbxassetid://154184960"
		sky.SkyboxFt = "rbxassetid://154185021" sky.SkyboxLf = "rbxassetid://154184943"
		sky.SkyboxRt = "rbxassetid://154184972" sky.SkyboxUp = "rbxassetid://154185031"
	elseif skyName == "MC" then
		sky.SkyboxBk = "rbxassetid://1876545003" sky.SkyboxDn = "rbxassetid://1876544331"
		sky.SkyboxFt = "rbxassetid://1876542941" sky.SkyboxLf = "rbxassetid://1876543392"
		sky.SkyboxRt = "rbxassetid://1876543764" sky.SkyboxUp = "rbxassetid://1876544642"
	elseif skyName == "Pink" then
		sky.SkyboxBk = "rbxassetid://271042516" sky.SkyboxDn = "rbxassetid://271077243"
		sky.SkyboxFt = "rbxassetid://271042556" sky.SkyboxLf = "rbxassetid://271042310"
		sky.SkyboxRt = "rbxassetid://271042467" sky.SkyboxUp = "rbxassetid://271077958"
	end

	sky.Parent = game:GetService("Lighting")
	currentSky = sky
end

VisualTab:Dropdown({
	Title = "Select Sky",
	Values = {"Default", "Aesthetic", "Night", "MC", "Pink"},
	Value = "Default",
	Multi = false,
	AllowNone = false,
	Callback = function(option) if option then applySky(option) end end
})

local BlurEffect, BloomEffect, ColorCorrection

VisualTab:Toggle({
	Title = "Enable Blur",
	Value = false,
	Callback = function(value)
		if value then
			if not BlurEffect then
				BlurEffect = Instance.new("BlurEffect")
				BlurEffect.Size = 8
				BlurEffect.Parent = game:GetService("Lighting")
			end
		else
			if BlurEffect then BlurEffect:Destroy() BlurEffect = nil end
		end
	end
})

VisualTab:Toggle({
	Title = "Enable Bloom",
	Value = false,
	Callback = function(value)
		if value then
			if not BloomEffect then
				BloomEffect = Instance.new("BloomEffect")
				BloomEffect.Intensity = 1.5
				BloomEffect.Threshold = 0.8
				BloomEffect.Parent = game:GetService("Lighting")
			end
		else
			if BloomEffect then BloomEffect:Destroy() BloomEffect = nil end
		end
	end
})

VisualTab:Toggle({
	Title = "Enable Color Correction",
	Value = false,
	Callback = function(value)
		if value then
			if not ColorCorrection then
				ColorCorrection = Instance.new("ColorCorrectionEffect")
				ColorCorrection.Saturation = 0.3
				ColorCorrection.Contrast = 0.2
				ColorCorrection.Parent = game:GetService("Lighting")
			end
		else
			if ColorCorrection then ColorCorrection:Destroy() ColorCorrection = nil end
		end
	end
})

applySky("Default")

--------------------------------------------------
-- AUTOFARM LOGIC
--------------------------------------------------

local AutofarmEnabled   = false
local autofarmActive    = false
local autofarmStartTime = 0
local coinsCollected    = 0
local farmStatus        = "Idle"
local TeleportOnComplete = false
local AutofarmSpeed     = 24
local AutofarmStatusLabel = nil

local flyConn = nil

local function disableFly()
	if flyConn then flyConn:Disconnect() flyConn = nil end
end

local function restorePlayer()
	local plr = Players.LocalPlayer
	if plr and plr.Character then
		for _, part in ipairs(plr.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	end
end

local function applyNoclip()
	local plr = Players.LocalPlayer
	if not plr or not plr.Character then return end
	for _, part in ipairs(plr.Character:GetDescendants()) do
		if part:IsA("BasePart") then part.CanCollide = false end
	end
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
			if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
				table.insert(coins, obj)
			end
		end
		if #coins > 0 then return coins end
	end
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Name == "Coin_Server" and obj:FindFirstChildWhichIsA("TouchTransmitter") then
			table.insert(coins, obj)
		end
	end
	return coins
end

local function waitForRoundStart()
	farmStatus = "Waiting for round..."
	updateAutofarmLabel()
	while AutofarmEnabled do
		local coins = getCoins()
		if #coins > 0 then
			farmStatus = "Round started!"
			updateAutofarmLabel()
			Notify("Autofarm", "Round started — farming coins!", "check", 3)
			return true
		end
		task.wait(1)
	end
	return false
end

local function floatTo(hrp, targetPos)
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bv.Parent = hrp

	local bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bg.CFrame = hrp.CFrame
	bg.Parent = hrp

	local lastVel = Vector3.new()
	while AutofarmEnabled do
		local dir = targetPos - hrp.Position
		if dir.Magnitude < 1.5 then break end
		local targetVel = dir.Unit * AutofarmSpeed
		lastVel = lastVel:Lerp(targetVel, 0.25)
		bv.Velocity = lastVel
		hrp.RotVelocity = Vector3.new()
		task.wait(0.05)
	end

	bv:Destroy()
	bg:Destroy()
end

local function startAutofarm()
	autofarmStartTime = tick()
	coinsCollected = 0

	while AutofarmEnabled do
		restorePlayer()
		local started = waitForRoundStart()
		if not started then break end

		local plr = Players.LocalPlayer
		if not plr then break end

		local noclipTask = task.spawn(function()
			while AutofarmEnabled do
				applyNoclip()
				task.wait(0.1)
			end
		end)
		table.insert(_G.HXN_TASKS, noclipTask)

		while AutofarmEnabled do
			local char = plr.Character
			if not char then task.wait(0.5) continue end

			local hrp = char:FindFirstChild("HumanoidRootPart")
			if not hrp then task.wait(0.5) continue end

			local coins = getCoins()

			if #coins == 0 then
				task.cancel(noclipTask)
				restorePlayer()
				farmStatus = "Round over, waiting..."
				updateAutofarmLabel()
				Notify("Autofarm", "All coins collected! Waiting for next round.", "check", 3)

				if TeleportOnComplete then
					teleportToLobby()
					Notify("Autofarm", "Teleported to Lobby.", "check", 2)
				end
				break
			end

			local closest, closestDist = nil, math.huge
			for _, coin in ipairs(coins) do
				if coin.Parent then
					local dist = (hrp.Position - coin.Position).Magnitude
					if dist < closestDist then
						closestDist = dist
						closest = coin
					end
				end
			end

			if not closest then break end

			farmStatus = "Collecting (" .. #coins .. " left)"
			updateAutofarmLabel()

			workspace.FallenPartsDestroyHeight = -math.huge
			floatTo(hrp, closest.Position)
			workspace.FallenPartsDestroyHeight = getgenv().FPDH or -500

			coinsCollected = coinsCollected + 1
			task.wait(0.05)
		end
	end

	restorePlayer()
	farmStatus = "Idle"
	updateAutofarmLabel()
end

Players.LocalPlayer.CharacterAdded:Connect(function()
	if AutofarmEnabled and not autofarmActive then
		task.wait(1.5)
		farmStatus = "Respawned, restarting..."
		updateAutofarmLabel()
		autofarmActive = true
		task.spawn(function()
			startAutofarm()
			autofarmActive = false
		end)
	end
end)

--------------------------------------------------
-- AUTOFARM TAB UI
--------------------------------------------------

AutofarmTab:Section({Title = "Farm Status"})

AutofarmStatusLabel = AutofarmTab:Paragraph({
	Title = "Live Status",
	Desc = "Autofarm OFF — toggle to start."
})

task.spawn(function()
	while true do
		task.wait(1)
		if AutofarmEnabled then updateAutofarmLabel() end
	end
end)

AutofarmTab:Section({Title = "Settings"})

AutofarmTab:Toggle({
	Title = "Autofarm",
	Value = false,
	Callback = function(Value)
		AutofarmEnabled = Value
		if Value then
			if autofarmActive then
				Notify("Autofarm", "Autofarm is already running.", "bell", 2)
				return
			end
			autofarmStartTime = tick()
			coinsCollected = 0
			farmStatus = "Starting..."
			updateAutofarmLabel()
			Notify("Autofarm", "Autofarm started!", "check", 3)
			autofarmActive = true
			task.spawn(function()
				startAutofarm()
				autofarmActive = false
			end)
		else
			restorePlayer()
			farmStatus = "Idle"
			updateAutofarmLabel()
			Notify("Autofarm", "Autofarm stopped.", "x", 3)
		end
	end,
})

AutofarmTab:Toggle({
	Title = "Teleport to Lobby when done",
	Value = false,
	Callback = function(v)
		TeleportOnComplete = v
	end,
})

local AutofarmSpeedSlider = AutofarmTab:Slider({
	Title = "Float Speed",
	Step = 1,
	Value = { Min = 5, Max = 60, Default = 24 },
	Callback = function(v)
		AutofarmSpeed = v
	end,
})

if AutofarmSpeedSlider and AutofarmSpeedSlider.Instance then
	AutofarmSpeedSlider.Instance.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local newValue = math.clamp(AutofarmSpeed + (input.Position.Z > 0 and 1 or -1), 5, 60)
			AutofarmSpeedSlider:SetValue(newValue)
		end
	end)
end

--------------------------------------------------
-- GUN TELEPORT
--------------------------------------------------

local function findGun()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj.Name == "GunDrop" then return obj.Position end
	end
	return nil
end

local function teleportToGun()
	local localPlayer = Players.LocalPlayer
	if not localPlayer or not localPlayer.Character then return end
	local gunPos = findGun()
	if not gunPos then
		Notify("Teleport", "No gun found on the map.", "x", 3)
		return
	end

	OriginalPosition = localPlayer.Character.HumanoidRootPart.CFrame
	localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(gunPos + Vector3.new(0, 3, 0))
	IsAtGun = true
	Notify("Teleport", "Teleported to Gun. Press " .. GunTPKeybind.Name .. " again to return.", "check", 3)

	task.spawn(function()
		while IsAtGun do
			task.wait(0.05)
			local player = Players.LocalPlayer
			if player and player.Character then
				local backpack = player:FindFirstChildOfClass("Backpack")
				local hasGun = (backpack and backpack:FindFirstChild("Gun")) or player.Character:FindFirstChild("Gun")
				if hasGun and OriginalPosition then
					player.Character.HumanoidRootPart.CFrame = OriginalPosition
					IsAtGun = false
					Notify("Teleport", "Gun picked up! Returned to original position.", "check", 3)
					break
				end
			end
		end
	end)
end

local function returnToOriginalPos()
	local localPlayer = Players.LocalPlayer
	if not localPlayer or not localPlayer.Character then return end
	if not OriginalPosition then
		Notify("Teleport", "No saved position to return to.", "x", 3)
		return
	end
	localPlayer.Character.HumanoidRootPart.CFrame = OriginalPosition
	IsAtGun = false
	Notify("Teleport", "Returned to original position.", "check", 3)
end

local UserInputService = game:GetService("UserInputService")

--------------------------------------------------
-- TELEPORT TAB UI
--------------------------------------------------

TeleportTab:Section({Title = "Gun Teleport"})

TeleportTab:Toggle({
	Title = "Gun Teleport",
	Value = false,
	Callback = function(Value) GunTPEnabled = Value end,
})

TeleportTab:Section({Title = "Map Teleports"})

TeleportTab:Button({Title = "TP To Lobby",       Callback = function() teleportToLobby()      Notify("Teleport", "Teleported to Lobby.",       "check", 2) end})
TeleportTab:Button({Title = "TP To Map",          Callback = function() teleportToMap()         Notify("Teleport", "Teleported to Map.",          "check", 2) end})
TeleportTab:Button({Title = "TP To Secret Place", Callback = function() teleportToSecretPlace() Notify("Teleport", "Teleported to Secret Place.", "check", 2) end})

-- FIX: Player Teleport now has a dropdown with auto-refresh
TeleportTab:Section({Title = "Player Teleport"})

local SelectedTPPlayer = nil

local TPPlayerDropdown = TeleportTab:Dropdown({
	Title = "Select Player",
	Values = GetPlayerList(),
	Value = "None",
	Multi = false,
	AllowNone = true,
	Callback = function(option)
		SelectedTPPlayer = option
	end,
})

local function RefreshTPDropdown()
	if TPPlayerDropdown then
		TPPlayerDropdown:Refresh(GetPlayerList())
	end
end

local tpPlayerAddedConn = Players.PlayerAdded:Connect(function()
	RefreshTPDropdown()
end)
table.insert(_G.HXN_CONNECTIONS, tpPlayerAddedConn)

local tpPlayerRemovingConn = Players.PlayerRemoving:Connect(function(player)
	if SelectedTPPlayer == player.Name then SelectedTPPlayer = nil end
	RefreshTPDropdown()
end)
table.insert(_G.HXN_CONNECTIONS, tpPlayerRemovingConn)

local function teleportToPlayer(playerName)
	local targetPlayer = nil
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name == playerName and player ~= Players.LocalPlayer then targetPlayer = player break end
	end
	if not targetPlayer or not targetPlayer.Character then
		Notify("Teleport", "Player not found or has no character.", "x", 3)
		return
	end

	local localPlayer = Players.LocalPlayer
	if not localPlayer or not localPlayer.Character then return end

	local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp or not targetHRP then return end

	hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
	Notify("Teleport", "Teleported to " .. playerName .. ".", "check", 3)
end

TeleportTab:Button({
	Title = "TP to Selected Player",
	Callback = function()
		if not SelectedTPPlayer or SelectedTPPlayer == "None" then
			Notify("Teleport", "No player selected.", "x", 3)
			return
		end
		teleportToPlayer(SelectedTPPlayer)
	end,
})

local gunTPInputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == GunTPKeybind and GunTPEnabled then
		if not IsAtGun then teleportToGun() else returnToOriginalPos() end
	end
end)
table.insert(_G.HXN_CONNECTIONS, gunTPInputConn)

--------------------------------------------------
-- TROLLING TAB UI
--------------------------------------------------

TrollingTab:Section({Title = "Select Target"})

local FlingPlayerDropdown = TrollingTab:Dropdown({
	Title = "Select Player",
	Values = GetPlayerList(),
	Value = "None",
	Callback = function(option) SelectedFlingTarget = option end,
})

local function RefreshFlingDropdown()
	if FlingPlayerDropdown then FlingPlayerDropdown:Refresh(GetPlayerList()) end
end

local playerAddedConn2 = Players.PlayerAdded:Connect(function(player) RefreshFlingDropdown() end)
table.insert(_G.HXN_CONNECTIONS, playerAddedConn2)

local playerRemovingConn2 = Players.PlayerRemoving:Connect(function(player)
	if SelectedFlingTarget == player.Name then SelectedFlingTarget = nil end
	RefreshFlingDropdown()
end)
table.insert(_G.HXN_CONNECTIONS, playerRemovingConn2)

TrollingTab:Section({Title = "Fling Controls"})
TrollingTab:Button({Title = "Start Flinging", Callback = function() StartFling() end})
TrollingTab:Button({Title = "Stop Flinging",  Callback = function() StopFling()  end})

TrollingTab:Section({Title = "Fling by Role"})

local function flingRole(role)
	local target = nil
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer and getRole(p) == role then target = p break end
	end
	if target then
		SelectedFlingTarget = target.Name
		StartFling()
	else
		Notify("Trolling", "No " .. role .. " found in the server.", "x", 3)
	end
end

TrollingTab:Button({Title = "Fling Murderer", Callback = function() flingRole("Murderer") end})
TrollingTab:Button({Title = "Fling Sheriff",  Callback = function() flingRole("Sheriff")  end})

TrollingTab:Section({Title = "Fling All"})
TrollingTab:Button({Title = "Fling All Players", Callback = function() FlingAll() end})

--------------------------------------------------
-- ESP TAB UI
--------------------------------------------------

ESPTab:Section({Title = "Main Control"})

ESPTab:Toggle({
	Title = "ESP",
	Default = false,
	Callback = function(Value) ESPEnabled = Value end,
})

ESPTab:Section({Title = "ESP Options"})

ESPTab:Toggle({
	Title = "ESP Names",
	Default = false,
	Callback = function(Value) ESPNamesEnabled = Value NameTagsEnabled = Value end,
})

ESPTab:Section({Title = "Dropped Items"})

ESPTab:Toggle({
	Title = "ESP Dropped GunDrop",
	Default = false,
	Callback = function(Value)
		ESPDroppedGunEnabled = Value
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj.Name == "GunDrop" then updateGunDisplay(obj) end
		end
	end,
})

ESPTab:Toggle({
	Title = "Show coins",
	Default = false,
	Callback = function(Value) ShowCoinsEnabled = Value end,
})

ESPTab:Toggle({
	Title = "Show thrown knife (StuckKnife)",
	Default = false,
	Callback = function(Value) ShowThrownKnifeEnabled = Value end,
})

ESPTab:Section({Title = "Role ESP"})

ESPTab:Toggle({Title = "Innocent ESP", Value = true,  Callback = function(Value) InnocentESPEnabled = Value end})
ESPTab:Toggle({Title = "Sheriff ESP",  Value = true,  Callback = function(Value) SheriffESPEnabled  = Value end})
ESPTab:Toggle({Title = "Murderer ESP", Value = true,  Callback = function(Value) MurdererESPEnabled = Value end})

ESPTab:Toggle({
	Title = "Player Tracers",
	Default = false,
	Callback = function(Value) TracersEnabled = Value end,
})

print("[HXN] Script fully loaded and ready to use! v7.1.3")
