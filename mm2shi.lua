-- Prevent double-loading: if hub is already loaded, stop here
if _G.HXNHubLoaded then
	warn("[HXN] Hub is already loaded, aborting second execute.")
	return
end
_G.HXNHubLoaded = true

-- Cleanup old script instance if running again
print("[HXN] Starting script cleanup...")

-- Destroy any old Wind UI windows in CoreGui
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

-- Kill old tracking tasks
if _G.HXN_TASKS then
	print("[HXN] Cancelling " .. #_G.HXN_TASKS .. " tasks...")
	for _, taskId in ipairs(_G.HXN_TASKS) do
		pcall(function() task.cancel(taskId) end)
	end
	_G.HXN_TASKS = {}
end

-- Disconnect old event connections
if _G.HXN_CONNECTIONS then
	print("[HXN] Disconnecting " .. #_G.HXN_CONNECTIONS .. " connections...")
	for _, connection in ipairs(_G.HXN_CONNECTIONS) do
		pcall(function() connection:Disconnect() end)
	end
	_G.HXN_CONNECTIONS = {}
end

-- Remove old highlights/adornments from all players
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

-- Unfreeze local player if frozen
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

-- Clean up old Visual effects (Blur, Bloom, Color Correction)
print("[HXN] Cleaning up old Visual effects...")
local Lighting = game:GetService("Lighting")
-- Destroy ALL blur effects
for _, effect in ipairs(Lighting:FindFirstChildOfClass("BlurEffect") and {Lighting:FindFirstChildOfClass("BlurEffect")} or {}) do
	pcall(function() effect:Destroy() end)
end
-- Alternative: destroy all descendants that are BlurEffect
pcall(function()
	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("BlurEffect") then effect:Destroy() end
	end
end)
-- Destroy ALL bloom effects
pcall(function()
	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("BloomEffect") then effect:Destroy() end
	end
end)
-- Destroy ALL color correction effects
pcall(function()
	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("ColorCorrectionEffect") then effect:Destroy() end
	end
end)
-- Destroy custom sky
pcall(function()
	local oldSky = Lighting:FindFirstChild("CustomSky")
	if oldSky then oldSky:Destroy() end
end)

----------------------------------------------------------------
-- LOAD WIND UI INSTEAD OF RAYFIELD
----------------------------------------------------------------
print("[HXN] Loading Wind UI...")

local success, WindUI = pcall(function()
    -- TODO: replace URL below with your actual Wind UI URL
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

-- Darker + more transparent window
WindUI.TransparencyValue = 0.35

-- HXN Hub MM2 style theme (darker + more transparent)
local RedBlackTheme = {
    Name = "RedBlack",
    
    -- Darker backgrounds (#0a0a0a - #1a1a1a)
    Accent = Color3.fromRGB(20, 20, 20),
    Dialog = Color3.fromRGB(15, 15, 15),
    Outline = Color3.fromRGB(255, 50, 50),
    Text = Color3.fromRGB(240, 240, 240), -- slightly dimmed white
    Placeholder = Color3.fromRGB(120, 40, 40),
    Background = Color3.fromRGB(15, 15, 15), -- darker
    Button = Color3.fromRGB(15, 15, 15), -- much darker
    Icon = Color3.fromRGB(255, 70, 70),
    Toggle = Color3.fromRGB(0, 200, 80), -- slightly darker
    Slider = Color3.fromRGB(220, 0, 0), -- slightly darker
    Checkbox = Color3.fromRGB(0, 200, 80), -- slightly darker
    
    -- Panels: darker with transparency
    PanelBackground = Color3.fromRGB(25, 25, 25),
    PanelBackgroundTransparency = 0.35, -- more transparent
    
    Primary = Color3.fromRGB(255, 0, 0),
    SliderIcon = Color3.fromRGB(180, 45, 45),
    
    -- Tab styling - darker
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
    
    -- Element styling - darker
    ElementBackground = Color3.fromRGB(15, 15, 15), -- much darker
    ElementBackgroundTransparency = 0.3, -- more transparent
    ElementTitle = Color3.fromRGB(240, 240, 240),
    ElementDesc = Color3.fromRGB(180, 180, 180),
    ElementIcon = Color3.fromRGB(255, 70, 70),
    
    -- Window styling
    WindowBackground = Color3.fromRGB(15, 15, 15),
    WindowTopbarTitle = Color3.fromRGB(240, 240, 240),
    WindowTopbarAuthor = Color3.fromRGB(255, 70, 70),
    WindowTopbarIcon = Color3.fromRGB(255, 70, 70),
    WindowTopbarButtonIcon = Color3.fromRGB(255, 70, 70),
    
    -- Additional
    Hover = Color3.fromRGB(50, 20, 20),
    LabelBackground = Color3.fromRGB(25, 25, 25),
    LabelBackgroundTransparency = 0.5,
    
    -- Notification
    Notification = Color3.fromRGB(25, 25, 25),
    NotificationTitle = Color3.fromRGB(240, 240, 240),
    NotificationContent = Color3.fromRGB(180, 180, 180),
    NotificationDuration = Color3.fromRGB(0, 255, 100),
    NotificationBorder = Color3.fromRGB(0, 255, 100),
    NotificationBorderTransparency = 0.4,
    
    -- Tooltip
    Tooltip = Color3.fromRGB(15, 15, 15),
    TooltipText = Color3.fromRGB(240, 240, 240),
    TooltipSecondary = Color3.fromRGB(0, 255, 100),
    TooltipSecondaryText = Color3.fromRGB(255, 255, 255),
    
    -- Search bar
    WindowSearchBarBackground = Color3.fromRGB(35, 35, 35),
    SearchBarBorder = Color3.fromRGB(255, 50, 50),
    SearchBarBorderTransparency = 0.5,
}

-- Add the custom theme
WindUI:AddTheme(RedBlackTheme)

print("[HXN] Creating window...")
local Window = WindUI:CreateWindow({
    Title  = "HXN Hub MM2",
    Icon   = "solar:settings-bold",  -- Fallback icon while you fix your image
    Author = "by hxneey",
    Folder = "HXN_MM2",            -- this fixes the makefolder error
    Size   = UDim2.fromOffset(580, 490),
    Theme  = "RedBlack",  -- HXN Hub style theme
    Transparent = true,   -- Blur, background shows through
    BackgroundImageTransparency = 0.65,  -- more transparent
    Acrylic = true,  -- Glass blur effect like HXN Hub
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("[HXN] User profile clicked!")
        end,
    },
})

-- Set a toggle key so you can reopen the UI after closing it
Window:SetToggleKey(Enum.KeyCode.K)


--[[
  HOW TO CHANGE THE LOGO TO YOUR OWN PHOTO:
  
  1. ROBLOX ASSET (easiest):
     - Upload your image to Roblox (Create > Decals or use a decal from the library)
     - Get the asset ID from the URL (e.g. roblox.com/library/123456789)
     - Change the Icon line above to: Icon = "rbxassetid://YOUR_ASSET_ID"
  
  2. IMAGE URL:
     - Host your image online (Imgur, Discord CDN, etc.)
     - Use: Icon = "https://your-image-url.com/photo.png"
  
  3. LUCIDE ICON (built-in):
     - Use icon names like: Icon = "sparkles" or Icon = "user" or Icon = "zap"
]]

-- Store window and initialize task tracking
_G.HXN_WINDOW = Window
_G.HXN_TASKS = {}
_G.HXN_CONNECTIONS = {}

print("[HXN] Window created successfully!")

-- HXN Hub style tags: green version badge, red accents
Window:Tag({
    Title = "Version 7.1.2",
    Color = Color3.fromRGB(0, 255, 100),  -- Green pill badge
    Border = true,
})
Window:Tag({
    Title = "Premium",
    Color = Color3.fromRGB(255, 80, 80),
})
Window:Tag({
    Title = "Updated",
    Color = Color3.fromRGB(0, 255, 100),  -- Green status
})

-- HXN Hub style: subtle blur, dark grey panels, soft red accents
spawn(function()
	task.wait(0.3)
	
	pcall(function()
		local CoreGui = game:GetService("CoreGui")
		local WindUIGui = CoreGui:FindFirstChild("WindUI")
		
		if WindUIGui then
			-- Optimized stroke on elements (only buttons, less intensive)
			local function addStrokeToElements(parent)
				-- Only process immediate children to avoid massive iteration
				local function processElement(element)
					if element:IsA("TextButton") or element:IsA("ImageButton") then
						-- Remove old strokes
						for _, child in ipairs(element:GetChildren()) do
							if child:IsA("UIStroke") then
								child:Destroy()
							end
						end
						
						-- Add bright red accent stroke
						local glow = Instance.new("UIStroke")
						glow.Color = Color3.fromRGB(255, 0, 0)
						glow.Thickness = 6
						glow.Transparency = 0
						glow.Parent = element
						
						-- Add glow shadow effect
						local glowShadow = Instance.new("UIStroke")
						glowShadow.Color = Color3.fromRGB(255, 150, 150)
						glowShadow.Thickness = 2
						glowShadow.Transparency = 0.3
						glowShadow.Parent = element
						
						element.MouseEnter:Connect(function()
							glow.Thickness = 8
							glowShadow.Transparency = 0
						end)
						element.MouseLeave:Connect(function()
							glow.Thickness = 6
							glowShadow.Transparency = 0.3
						end)
					end
				end
				
				-- Process children recursively but limit depth
				for _, child in ipairs(parent:GetChildren()) do
					processElement(child)
					for _, subchild in ipairs(child:GetChildren()) do
						processElement(subchild)
					end
				end
			end
			
			addStrokeToElements(WindUIGui)
			
			-- Main window: dark grey, subtle border
			local mainFrame = WindUIGui:FindFirstChildWhichIsA("Frame")
			if mainFrame and (mainFrame.Name == "MainFrame" or #mainFrame:GetChildren() > 5) then
				mainFrame.BackgroundTransparency = 0.1 -- slight transparency for blur
				
				local windowGlow = Instance.new("UIStroke")
				windowGlow.Color = Color3.fromRGB(255, 50, 50)
				windowGlow.Thickness = 2
				windowGlow.Transparency = 0.2
				windowGlow.Parent = mainFrame
				
				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 12)
				corner.Parent = mainFrame
				
				-- Dark gradient
				local gradient = Instance.new("UIGradient")
				gradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 12, 12)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 22, 22))
				}
				gradient.Rotation = 90
				gradient.Parent = mainFrame
			end
			
			-- Darker main frame with more transparency
			if mainFrame then
				mainFrame.BackgroundTransparency = 0.25
			end
			
			print("[HXN] HXN Hub style UI applied!")
		end
	end)
end)

-- create tabs for each category
local CharacterTab = Window:Tab({Title = "Character", Icon = "user"})
local TeleportTab = Window:Tab({Title = "Teleport", Icon = "plane"})
local CombatTab = Window:Tab({Title = "Combat", Icon = "sword"})
local TrollingTab = Window:Tab({Title = "Trolling", Icon = "zap"})
local ESPTab = Window:Tab({Title = "ESP", Icon = "eye"})
local VisualTab = Window:Tab({Title = "Visual", Icon = "palette"})
local AutofarmTab = Window:Tab({Title = "Autofarm", Icon = "sprout"})
local EmoteTab = Window:Tab({Title = "Emotes", Icon = "smile"})
local OtherTab = Window:Tab({Title = "Other", Icon = "settings"})

-- Select Character tab by default when script loads
CharacterTab:Select()

-- Function to find the murderer (player with Knife)
local function findMurderer()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= Players.LocalPlayer and player.Character then
			-- Check if player has Knife in backpack or equipped
			local backpack = player:FindFirstChildOfClass("Backpack")
			if backpack and backpack:FindFirstChild("Knife") then
				return player
			end
			-- Check if knife is equipped
			if player.Character:FindFirstChild("Knife") then
				return player
			end
		end
	end
	return nil
end

-- Function to get the local player's Gun tool
local function getGunTool()
	local player = Players.LocalPlayer
	if not player or not player.Character then return nil end
	
	-- Check if gun is equipped
	if player.Character:FindFirstChild("Gun") then
		return player.Character:FindFirstChild("Gun")
	end
	
	-- Check backpack
	local backpack = player:FindFirstChildOfClass("Backpack")
	if backpack and backpack:FindFirstChild("Gun") then
		return backpack:FindFirstChild("Gun")
	end
	
	return nil
end


--------------------------------------------------
-- GUNBEAM SILENT AIM SYSTEM (Sheriff)
--------------------------------------------------

local GunBeamAutoAimEnabled = false
local TargetMurderer = nil

-- Function to hook GunBeam creation for silent aim
local function HookGunBeam()
	if _G.HXN_GunBeamHooked then return end
	if not hookmetamethod then 
		print("[HXN] hookmetamethod not available, skipping GunBeam hook")
		return 
	end
	_G.HXN_GunBeamHooked = true

	-- Hook into the WeaponEvents GunBeam firing
	local WeaponEvents = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
	if WeaponEvents then
		WeaponEvents = WeaponEvents:FindFirstChild("WeaponEvents")
	end

	-- Alternative: Hook the actual GunBeam creation in workspace
	local oldIndex
	oldIndex = hookmetamethod(game, "__index", function(t, k)
		-- If it's a GunBeam being created, redirect it to target
		if t:IsA("Beam") and GunBeamAutoAimEnabled and TargetMurderer and TargetMurderer.Character then
			local TargetPart = TargetMurderer.Character:FindFirstChild("HumanoidRootPart") or TargetMurderer.Character:FindFirstChild("Head")
			
			if TargetPart and k == "Transparency" then
				-- Don't interfere with transparency
				return oldIndex(t, k)
			end
		end
		
		return oldIndex(t, k)
	end)

	print("[HXN] GunBeam hook installed!")
end

-- Function to shoot murderer with GunBeam silent aim
local function shootMurdererWithGunBeam()
	if not GunBeamAutoAimEnabled then return end

	local localPlayer = Players.LocalPlayer
	if not localPlayer or not localPlayer.Character then return end

	TargetMurderer = findMurderer()
	if not TargetMurderer or not TargetMurderer.Character then
		return
	end

	-- Get gun tool
	local gunTool = getGunTool()
	if not gunTool then
		return
	end

	-- Equip the gun
	if gunTool.Parent == localPlayer:FindFirstChildOfClass("Backpack") then
		gunTool.Parent = localPlayer.Character
	end

	print("[HXN] Equipping gun and aiming at: " .. TargetMurderer.Name)

	-- Activate silent aim
	GunBeamAutoAimEnabled = true

	-- Fire the gun (activate it)
	pcall(function()
		gunTool:Activate()
		print("[HXN] GunBeam auto-aim shot fired at murderer!")
	end)

	-- clear target (toggle remains on until user disables)
	TargetMurderer = nil

	-- Call GunKill remote for guaranteed hit
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

-- Install GunBeam hook on startup
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
		local murderer = findMurderer()
		if not murderer or not murderer.Character then return end
		
		if not localPlayer.Character:FindFirstChild("Gun") then
			local backpack = localPlayer:FindFirstChildOfClass("Backpack")
			if backpack and backpack:FindFirstChild("Gun") then
				local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
				hum:EquipTool(backpack:FindFirstChild("Gun"))
			end
		end
		
		local gunTool = localPlayer.Character:FindFirstChild("Gun")
		if gunTool and murderer.Character:FindFirstChild("HumanoidRootPart") then
			local args = {
				CFrame.new(localPlayer.Character.RightHand.Position),
				CFrame.new(murderer.Character.HumanoidRootPart.Position)
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

local knifeThrowClosestEnabled = true

CombatTab:Keybind({
	Title = "Knife Throw to Closest",
	Value = "E",
	Callback = function()
		if not knifeThrowClosestEnabled then return end
		local localPlayer = Players.LocalPlayer
		if not localPlayer.Character then return end
		local localHRP = localPlayer.Character:FindFirstChild("HumanoidRootPart")
		
		local NearestPlayer = nil
		local shortestDistance = math.huge
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				local otherHRP = player.Character:FindFirstChild("HumanoidRootPart")
				if otherHRP and localHRP then
					local distance = (localHRP.Position - otherHRP.Position).Magnitude
					if distance < shortestDistance then
						shortestDistance = distance
						NearestPlayer = player
					end
				end
			end
		end
		
		if not NearestPlayer then return end
		
		if not localPlayer.Character:FindFirstChild("Knife") then
			local backpack = localPlayer:FindFirstChildOfClass("Backpack")
			if backpack and backpack:FindFirstChild("Knife") then
				local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
				hum:EquipTool(backpack:FindFirstChild("Knife"))
			end
		end
		
		local knifeTool = localPlayer.Character:FindFirstChild("Knife")
		if knifeTool and NearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local args = {
				CFrame.new(localPlayer.Character.RightHand.Position),
				CFrame.new(NearestPlayer.Character.HumanoidRootPart.Position)
			}
			pcall(function()
				knifeTool:WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(unpack(args))
			end)
		end
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
					if autoKnifeThrowEnabled then
						local localPlayer = Players.LocalPlayer
						if localPlayer.Character then
							local NearestPlayer = nil
							local shortestDistance = math.huge
							local localHRP = localPlayer.Character:FindFirstChild("HumanoidRootPart")
							for _, player in ipairs(Players:GetPlayers()) do
								if player ~= localPlayer and player.Character then
									local otherHRP = player.Character:FindFirstChild("HumanoidRootPart")
									if otherHRP and localHRP then
										local distance = (localHRP.Position - otherHRP.Position).Magnitude
										if distance < shortestDistance then
											shortestDistance = distance
											NearestPlayer = player
										end
									end
								end
							end
							
							if NearestPlayer and NearestPlayer.Character then
								if not localPlayer.Character:FindFirstChild("Knife") then
									local backpack = localPlayer:FindFirstChildOfClass("Backpack")
									if backpack and backpack:FindFirstChild("Knife") then
										local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
										hum:EquipTool(backpack:FindFirstChild("Knife"))
									end
								end
								
								local knifeTool = localPlayer.Character:FindFirstChild("Knife")
								if knifeTool then
									local nearestHRP = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
									if nearestHRP then
										local args = {
											CFrame.new(localPlayer.Character.RightHand.Position),
											CFrame.new(nearestHRP.Position)
										}
										pcall(function()
											knifeTool:WaitForChild("Events"):WaitForChild("KnifeThrown"):FireServer(unpack(args))
										end)
									end
								end
							end
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
		local localPlayer = Players.LocalPlayer
		if not localPlayer.Character then return end
		
		local NearestPlayer = nil
		local shortestDistance = math.huge
		local localHRP = localPlayer.Character:FindFirstChild("HumanoidRootPart")
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= localPlayer and player.Character then
				local otherHRP = player.Character:FindFirstChild("HumanoidRootPart")
				if otherHRP and localHRP then
					local distance = (localHRP.Position - otherHRP.Position).Magnitude
					if distance < shortestDistance then
						shortestDistance = distance
						NearestPlayer = player
					end
				end
			end
		end
		
		if not NearestPlayer then return end
		
		if not localPlayer.Character:FindFirstChild("Knife") then
			local backpack = localPlayer:FindFirstChildOfClass("Backpack")
			if backpack and backpack:FindFirstChild("Knife") then
				local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
				hum:EquipTool(backpack:FindFirstChild("Knife"))
			end
		end
		
		local knifeTool = localPlayer.Character:FindFirstChild("Knife")
		if knifeTool and NearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local nearestHRP = NearestPlayer.Character:FindFirstChild("HumanoidRootPart")
			nearestHRP.Anchored = true
			nearestHRP.CFrame = localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 2
			task.wait(0.1)
			local args = {[1] = "Slash"}
			knifeTool:WaitForChild("Stab"):FireServer(unpack(args))
		end
	end,
})

CombatTab:Button({
	Title = "Kill Everyone",
	Callback = function()
		local localPlayer = Players.LocalPlayer
		if not localPlayer.Character then return end
		
		if not localPlayer.Character:FindFirstChild("Knife") then
			local backpack = localPlayer:FindFirstChildOfClass("Backpack")
			if backpack and backpack:FindFirstChild("Knife") then
				local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
				hum:EquipTool(backpack:FindFirstChild("Knife"))
			end
		end
		
		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character and player ~= localPlayer then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.Anchored = true
					hrp.CFrame = localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 1
				end
			end
		end
		
		local knifeTool = localPlayer.Character:FindFirstChild("Knife")
		if knifeTool then
			local args = {[1] = "Slash"}
			knifeTool:WaitForChild("Stab"):FireServer(unpack(args))
		end
	end,
})

local killAuraEnabled = false
CombatTab:Toggle({
	Title = "Murderer Kill Aura",
	Value = false,
	Callback = function(Value)
		killAuraEnabled = Value
		if Value then
			task.spawn(function()
				while killAuraEnabled do
					task.wait(0.1)
					local localPlayer = Players.LocalPlayer
					if localPlayer.Character then
						for _, player in ipairs(Players:GetPlayers()) do
							if player.Character and player ~= localPlayer then
								local hrp = player.Character:FindFirstChild("HumanoidRootPart")
								local localHRP = localPlayer.Character:FindFirstChild("HumanoidRootPart")
								if hrp and localHRP then
									if (hrp.Position - localHRP.Position).Magnitude < 7 then
										hrp.Anchored = true
										hrp.CFrame = localHRP.CFrame + localHRP.CFrame.LookVector * 2
										task.wait(0.1)
										local knifeTool = localPlayer.Character:FindFirstChild("Knife")
										if knifeTool then
											local args = {[1] = "Slash"}
											knifeTool:WaitForChild("Stab"):FireServer(unpack(args))
										end
										return
									end
								end
							end
						end
					end
				end
			end)
		end
	end,
})


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
local flingConnections = {}

local function applyAntiFlingToPart(v)
    if not v or not v:IsA("Part") then return end
    
    -- NEVER apply to local player's character
    local localPlayer = game.Players.LocalPlayer
    if v.Parent and localPlayer and localPlayer.Character and v.Parent:IsDescendantOf(localPlayer.Character) then
        return
    end
    
    if v.Name ~= "HumanoidRootPart" then return end
    if v.Anchored then return end

    local conn
    conn = game:GetService("RunService").Heartbeat:Connect(function()
        if not v or not v.Parent then
            conn:Disconnect()
            return
        end
        v.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
        v.Velocity = Vector3.new()
        v.RotVelocity = Vector3.new()
        v.CanCollide = false
    end)
    table.insert(flingConnections, conn)
end

local function startAntiFling()
    if antiFlingEnabled then return end
    antiFlingEnabled = true
    for _, obj in ipairs(workspace:GetDescendants()) do
        applyAntiFlingToPart(obj)
    end
    workspace.DescendantAdded:Connect(function(part)
        if antiFlingEnabled and part:IsA("Part") and part.Name == "HumanoidRootPart" then
            task.wait(2)
            applyAntiFlingToPart(part)
        end
    end)
end

local function stopAntiFling()
    antiFlingEnabled = false
    for _,c in ipairs(flingConnections) do
        pcall(function() c:Disconnect() end)
    end
    flingConnections = {}
end

--------------------------------------------------
-- OTHER TAB UI
--------------------------------------------------

-- ANTI-EXPLOIT SECTION
OtherTab:Section({Title = "Anti-Exploit"})

OtherTab:Toggle({
   Title = "Anti-AFK",
   Value = true,
   Callback = function(val)
        AntiAfkEnabled = val
        if val then
            setupAntiAfk()
        else
            disableAntiAfk()
        end
   end,
})

-- ensure anti-afk is active right away
if AntiAfkEnabled then
    setupAntiAfk()
end

OtherTab:Toggle({
   Title = "Anti-Fling",
   Value = false,
   Callback = function(val)
        if val then
            startAntiFling()
        else
            stopAntiFling()
        end
   end,
})

-- ROUND TIMER SECTION
OtherTab:Section({Title = "Round Timer"})

local roundTimerEnabled = false
local roundTimerLabel = nil

local function secondsToMinutes(seconds)
	if seconds == -1 then return "" end
	local minutes = math.floor(seconds / 60)
	local remainingSeconds = seconds % 60
	return string.format("%dm %ds", minutes, remainingSeconds)
end

OtherTab:Toggle({
	Title = "Round Timer",
	Value = false,
	Callback = function(Value)
		roundTimerEnabled = Value
		if Value then
			roundTimerLabel = Instance.new("TextLabel")
			roundTimerLabel.Parent = game:GetService("CoreGui"):FindFirstChild("WindUI")
			roundTimerLabel.BackgroundTransparency = 1
			roundTimerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			roundTimerLabel.TextScaled = true
			roundTimerLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			roundTimerLabel.Position = UDim2.fromScale(0.5, 0.15)
			roundTimerLabel.Size = UDim2.fromOffset(200, 50)
			roundTimerLabel.Font = Enum.Font.GothamBold
			
			task.spawn(function()
				while roundTimerEnabled do
					task.wait(0.5)
					local timeLeft = 0
					pcall(function()
						timeLeft = game:GetService("ReplicatedStorage").Remotes.Extras.GetTimer:InvokeServer()
					end)
					if roundTimerLabel then
						roundTimerLabel.Text = secondsToMinutes(timeLeft)
					end
				end
			end)
		else
			if roundTimerLabel then
				roundTimerLabel:Destroy()
				roundTimerLabel = nil
			end
		end
	end,
})

-- UTILITIES SECTION
OtherTab:Section({Title = "Utilities"})

OtherTab:Button({
   Title = "Inf Yield",
   Callback = function()
        local success, result = pcall(function()
            local script = game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
            loadstring(script)()
        end)
        
        if not success then
            print("[HXN] Inf Yield Error: " .. tostring(result))
        end
   end,
})

-- Ensure GunDropNotifyEnabled is initialized
if GunDropNotifyEnabled == nil then
	GunDropNotifyEnabled = false
end

-- Notification disabled (Wind UI incompatible)

EmoteTab:Button({
   Title = "Emotes",
   Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Joystickplays/AFEM/main/max/afemmax.lua"))()
   end,
})

--------------------------------------------------
-- CHARACTER TAB UI
--------------------------------------------------

-- PERFORMANCE SECTION
CharacterTab:Section({Title = "Performance"})

-- FPS and Ping Tracking Variables
local fps = 0
local lastTime = tick()
local currentPing = 0

-- FPS calculation (moved to Heartbeat for better performance)
game:GetService("RunService").Heartbeat:Connect(function()
    fps = math.floor(1 / (tick() - lastTime))
    lastTime = tick()
end)

-- Ping calculation
local function getPing()
    local player = game.Players.LocalPlayer
    if player then
        currentPing = math.floor(player:GetNetworkPing() * 1000)
    end
    return currentPing
end

-- Performance Monitor Paragraph
local PerformanceLabel = CharacterTab:Paragraph({
    Title = "FPS & Ping",
    Desc = "FPS: 0\nNetwork Ping: 0 ms"
})

-- Update performance label continuously
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

-- MOVEMENT SECTION
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
   Value = {
       Min = 1,
       Max = 350,
       Default = 16,
   },
   Callback = function(Value)
        currentWalkSpeed = Value
        if walkSpeedEnabled then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
   end,
})

-- Add scroll wheel support for WalkSpeed slider
if WalkSpeedSlider and WalkSpeedSlider.Instance then
    WalkSpeedSlider.Instance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local currentValue = currentWalkSpeed or 16
            local newValue = currentValue + (input.Position.Z > 0 and 1 or -1)
            newValue = math.clamp(newValue, 1, 350)
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
        if speed then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
        end
   end,
})

-- JUMP POWER SECTION
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
   Value = {
       Min = 1,
       Max = 350,
       Default = 50,
   },
   Callback = function(Value)
        currentJumpPower = Value
        if jumpPowerEnabled then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
   end,
})

-- Add scroll wheel support for JumpPower slider
if JumpPowerSlider and JumpPowerSlider.Instance then
    JumpPowerSlider.Instance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local currentValue = currentJumpPower or 50
            local newValue = currentValue + (input.Position.Z > 0 and 1 or -1)
            newValue = math.clamp(newValue, 1, 350)
            JumpPowerSlider:SetValue(newValue)
        end
    end)
end

-- CAMERA SECTION
CharacterTab:Section({Title = "Camera"})

local fov_enabled = false
local fov_value = 70

local function updateFOV()
    local cam = workspace.CurrentCamera
    if cam then
        cam.FieldOfView = fov_enabled and fov_value or 70
    end
end

CharacterTab:Toggle({
   Title = "Custom FOV",
   Value = false,
   Callback = function(val)
       fov_enabled = val
       updateFOV()
   end,
})

local FOVSlider = CharacterTab:Slider({
   Title = "FOV Value",
   Step = 1,
   Value = {
       Min = 1,
       Max = 120,
       Default = 70,
   },
   Callback = function(val)
       fov_value = val
       updateFOV()
   end,
})

-- Add scroll wheel support for FOV slider
if FOVSlider and FOVSlider.Instance then
    FOVSlider.Instance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local currentValue = fov_value or 70
            local newValue = currentValue + (input.Position.Z > 0 and 1 or -1)
            newValue = math.clamp(newValue, 1, 120)
            FOVSlider:SetValue(newValue)
        end
    end)
end

--// SETTINGS
local OTHER_PLAYER_COLOR = Color3.fromRGB(0,255,0) -- Green for innocent
local LOCAL_PLAYER_COLOR = Color3.fromRGB(0,255,100)
local MURDERER_COLOR = Color3.fromRGB(255,0,0) -- Red
local SHERIFF_COLOR = Color3.fromRGB(0,0,139) -- Dark blue
local GUN_COLOR = Color3.fromRGB(255,255,0) -- Yellow
local STUCK_KNIFE_COLOR = Color3.fromRGB(255,165,0) -- Orange for stuck knife
local COIN_COLOR = Color3.fromRGB(255,223,0) -- Gold for coins

local FILL_TRANSPARENCY = 0.5
local OUTLINE_TRANSPARENCY = 0
local CHECK_INTERVAL = 1.0

--// STATES
local ESPEnabled = false
local NameTagsEnabled = false
-- local GunHighlightEnabled = false (unused)
local ESPNamesEnabled = false
local ESPDroppedGunEnabled = false
local ShowCoinsEnabled = false
local ShowThrownKnifeEnabled = false
local InnocentESPEnabled = true
local SheriffESPEnabled = true
local MurdererESPEnabled = true
local ESPModeType = "Highlight"
local GunDropType = "Highlight" -- default to first available option
local GunTPEnabled = false
local GunTPKeybind = Enum.KeyCode.G
local OriginalPosition = nil
local IsAtGun = false
local GunDropNotifyEnabled = false
local GunDropDetected = false
local TracersEnabled = false

--// FLING VARIABLES
local FlingActive = false
local SelectedFlingTarget = nil
local FlingConnection = nil
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

--------------------------------------------------
-- FLING FUNCTIONS
--------------------------------------------------

-- Fling notification function
local function FllingMessage(Title, Text, Time)
    print("[Fling] " .. Title .. ": " .. Text)
    -- Notifications disabled (Wind UI doesn't support Notify)
end

-- The fling function (adapted from KILASIK's Multi-Target Fling Exploit)
local function SkidFling(TargetPlayer)
    local Player = Players.LocalPlayer
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle
    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessory and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        
        if THumanoid and THumanoid.Sit then
            return FllingMessage("Error", TargetPlayer.Name .. " is sitting", 2)
        end
        
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end
        
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
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick() or not FlingActive
        end
        
        workspace.FallenPartsDestroyHeight = 0/0
        
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        if TRootPart then
            SFBasePart(TRootPart)
        elseif THead then
            SFBasePart(THead)
        elseif Handle then
            SFBasePart(Handle)
        else
            return FllingMessage("Error", TargetPlayer.Name .. " has no valid parts", 2)
        end
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        
        -- Reset character position
        if getgenv().OldPos then
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
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

-- Start flinging a single target
local function StartFling()
    if FlingActive then return end
    
    if not SelectedFlingTarget then
        FllingMessage("Error", "No target selected!", 2)
        return
    end
    
    FlingActive = true
    FllingMessage("Started", "Flinging " .. SelectedFlingTarget .. "!", 2)
    
    spawn(function()
        while FlingActive do
            local targetPlayer = nil
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Name == SelectedFlingTarget and player ~= Players.LocalPlayer then
                    targetPlayer = player
                    break
                end
            end
            
            if targetPlayer and targetPlayer.Parent then
                SkidFling(targetPlayer)
                task.wait(0.1)
            else
                FlingActive = false
                break
            end
        end
    end)
end

-- Stop flinging
local function StopFling()
    if not FlingActive then return end
    FlingActive = false
    FllingMessage("Stopped", "Fling has been stopped", 2)
end

-- Fling all players
local function FlingAll()
    if FlingActive then return end
    
    FlingActive = true
    FllingMessage("Started", "Flinging all players!", 2)
    
    spawn(function()
        while FlingActive do
            local validTargets = {}
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= Players.LocalPlayer and player.Character then
                    table.insert(validTargets, player)
                end
            end
            
            if #validTargets == 0 then
                FlingActive = false
                break
            end
            
            for _, targetPlayer in ipairs(validTargets) do
                if FlingActive then
                    SkidFling(targetPlayer)
                    task.wait(0.1)
                else
                    break
                end
            end
            
            task.wait(0.5)
        end
    end)
end

-- Get list of all players for dropdown
local function GetPlayerList()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    return playerNames
end

--------------------------------------------------
-- TELEPORT FUNCTIONS
--------------------------------------------------

local knownMapNames = {
	"Bank2", "BioLab", "Factory", "Hospital3", "Hotel2", "House2", "Mansion2", "MilBase", "Office3", "PoliceStation", "ResearchFacility", "Workplace"
}

local function getCurrentMapName()
	-- Search direct workspace children AND descendants for known map names
	for _, knownName in ipairs(knownMapNames) do
		-- First check direct children
		local found = workspace:FindFirstChild(knownName)
		if found and found:IsA("Model") then
			return knownName
		end
	end
	
	-- If not found, search through all descendants
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj.Parent == workspace then
			for _, knownName in ipairs(knownMapNames) do
				if obj.Name == knownName then
					return knownName
				end
			end
		end
	end
	
	-- Debug: show what models are in workspace
	print("DEBUG: Known maps not found. Workspace children:")
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Model") and obj.Name ~= "Camera" and obj.Name ~= "Terrain" and obj.Name ~= "Lobby" then
			print("  - " .. obj.Name)
		end
	end
	
	return "Unknown"
end

local function teleportToLobby()
	local player = Players.LocalPlayer
	if not player or not player.Character then return end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Find the Lobby model in Workspace
	local lobby = workspace:FindFirstChild("Lobby")
	if not lobby or not lobby:IsA("Model") then
		-- Notification disabled (Wind UI incompatible)
		return
	end

	-- Find the Spawns folder inside Lobby
	local spawnsFolder = lobby:FindFirstChild("Spawns")
	if not spawnsFolder then
		-- Notification disabled (Wind UI incompatible)
		return
	end

	-- Collect all SpawnLocation parts
	local spawnPoints = {}
	for _, obj in ipairs(spawnsFolder:GetChildren()) do
		if obj:IsA("SpawnLocation") then
			table.insert(spawnPoints, obj)
		end
	end

	if #spawnPoints == 0 then
		-- Notification disabled (Wind UI incompatible)
		return
	end

	-- Pick random spawn and teleport
	local chosenSpawn = spawnPoints[math.random(1, #spawnPoints)]
	hrp.CFrame = chosenSpawn.CFrame + Vector3.new(0, 3, 0)

	-- Notification disabled (Wind UI incompatible)
end

local function teleportToMap()
	local player = Players.LocalPlayer
	if not player or not player.Character then return end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Find the first map that exists in Workspace
	local map
	for _, name in ipairs(knownMapNames) do
		map = workspace:FindFirstChild(name)
		if map then break end
	end

	if not map then
		return
	end

	-- Find its Spawns folder
	local spawnsFolder = map:FindFirstChild("Spawns")
	if not spawnsFolder then
		return
	end

	-- Collect all spawn points
	local spawnPoints = {}
	for _, obj in ipairs(spawnsFolder:GetChildren()) do
		if obj:IsA("BasePart") or obj:IsA("SpawnLocation") then
			table.insert(spawnPoints, obj)
		end
	end

	if #spawnPoints == 0 then
		return
	end

	-- Pick random spawn and teleport
	local chosenSpawn = spawnPoints[math.random(1, #spawnPoints)]
	hrp.CFrame = chosenSpawn.CFrame + Vector3.new(0, 3, 0)

end

local function teleportToSecretPlace()
	local player = Players.LocalPlayer
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		-- Teleport to secret place
		player.Character.HumanoidRootPart.CFrame = CFrame.new(319, 537, 89)
		-- Notification disabled (Wind UI incompatible)
	end
end

--------------------------------------------------
-- GUN DISPLAY HANDLER
--------------------------------------------------

local function updateGunDisplay(gun)
	if not gun or gun.Name ~= "GunDrop" then return end
	
	-- clear prior adornments
	for _, child in ipairs(gun:GetChildren()) do
		if child.Name == "GunHighlight" or child.Name == "GunBillboard" then
			child:Destroy()
		end
	end
	
	if not ESPDroppedGunEnabled then return end
	
	-- Always use highlight mode
	local highlight = Instance.new("Highlight")
	highlight.Name = "GunHighlight"
	highlight.FillTransparency = FILL_TRANSPARENCY
	highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = GUN_COLOR
	highlight.Parent = gun
end

local function trackGuns()
	while true do
		task.wait(CHECK_INTERVAL)
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj.Name == "GunDrop" then
				updateGunDisplay(obj)
			end
		end
	end
end

local gunTaskId = task.spawn(trackGuns)
table.insert(_G.HXN_TASKS, gunTaskId)

--------------------------------------------------
-- STUCK KNIFE HIGHLIGHTING
--------------------------------------------------

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

local function trackStuckKnives()
	while true do
		task.wait(CHECK_INTERVAL)
		
		-- Check all objects in workspace for StuckKnife
		for _, object in ipairs(workspace:GetChildren()) do
			if object.Name == "StuckKnife" then
				updateStuckKnifeHighlight(object)
			end
		end
	end
end

local knifeTaskId = task.spawn(trackStuckKnives)
table.insert(_G.HXN_TASKS, knifeTaskId)

--------------------------------------------------
-- COIN HIGHLIGHTING
--------------------------------------------------

local function updateCoinHighlight(obj)
	if not obj then return end
	
	-- only highlight relevant parts/models directly
	if obj.Name ~= "Coin" and obj.Name ~= "CoinVisual" then
		return
	end
	
	-- determine which descendant to highlight (prefer BasePart like MainCoin)
	local target = obj
	if obj.Name == "CoinVisual" then
		-- look for a part inside CoinVisual
		local part = obj:FindFirstChild("MainCoin")
		if not part then
			part = obj:FindFirstChildWhichIsA("BasePart")
		end
		if part then
			target = part
		end
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

local function trackCoins()
	while true do
		task.wait(CHECK_INTERVAL)
		
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj.Name == "Coin" or obj.Name == "CoinVisual" then
				updateCoinHighlight(obj)
			end
		end
	end
end

local coinTaskId = task.spawn(trackCoins)
table.insert(_G.HXN_TASKS, coinTaskId)

--------------------------------------------------
-- ROLE DETECTION
--------------------------------------------------

local function getRole(player)
	if not player.Character then return "Other" end
	
	-- Check equipped items in character
	for _, item in ipairs(player.Character:GetChildren()) do
		if item:IsA("Tool") then
			if item.Name == "Knife" then return "Murderer" end
			if item.Name == "Gun" then return "Sheriff" end
		end
	end
	
	-- Check backpack for any Knife or Gun items
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
	if role == "Murderer" then
		color = MURDERER_COLOR
	elseif role == "Sheriff" then
		color = SHERIFF_COLOR
	end

	local shouldShowESP = (role == "Murderer" and MurdererESPEnabled) or (role == "Sheriff" and SheriffESPEnabled) or (role == "Other" and InnocentESPEnabled)

--------------------------------------------------
-- HIGHLIGHT MODE
--------------------------------------------------

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
		if highlight then
			highlight:Destroy()
		end
	end

--------------------------------------------------
-- CHAMS MODE
--------------------------------------------------

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
			if obj.Name == "Cham" then
				obj:Destroy()
			end
		end
	end

--------------------------------------------------
-- BOX MODE (Improved FPS Style)
--------------------------------------------------

if ESPModeType == "Box" and ESPEnabled and shouldShowESP then

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then

		local box = character:FindFirstChild("PlayerBox")
		local outline = character:FindFirstChild("PlayerBoxOutline")

		-- Create boxes if they don't exist
		if not box then
			box = Instance.new("BoxHandleAdornment")
			box.Name = "PlayerBox"
			box.Adornee = hrp
			box.Size = Vector3.new(6, 6, 6)
			box.AlwaysOnTop = true
			box.Transparency = 0.8
			box.ZIndex = 5
			box.Parent = character
		end

		if not outline then
			outline = Instance.new("BoxHandleAdornment")
			outline.Name = "PlayerBoxOutline"
			outline.Adornee = hrp
			outline.Size = Vector3.new(6.2, 6.2, 6.2)
			outline.Color3 = Color3.new(0,0,0)
			outline.AlwaysOnTop = true
			outline.Transparency = 0.9
			outline.ZIndex = 4
			outline.Parent = character
		end

		-- Update color every refresh
		box.Color3 = color

	end

else

	-- Destroy BOTH instantly (prevents outline lingering)
	for _, obj in ipairs(character:GetChildren()) do
		if obj.Name == "PlayerBox" or obj.Name == "PlayerBoxOutline" then
			obj:Destroy()
		end
	end

end
--------------------------------------------------
-- NAME TAG
--------------------------------------------------

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
				text.TextColor3 = Color3.new(1,1,1)
				text.TextStrokeTransparency = 0
				text.Font = Enum.Font.SourceSansBold
				text.TextScaled = true
				text.Parent = tag

				tag.Parent = character
			end
		end
	end
end
--------------------------------------------------
-- LOOP
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

-- clean old tracer loop
if _G.HXN_TRACER_LOOP then
	pcall(function()
		_G.HXN_TRACER_LOOP:Disconnect()
	end)
end

-- clean old tracers
if _G.HXN_TRACERS then
    for _, line in pairs(_G.HXN_TRACERS) do
        pcall(function() line:Remove() end)
    end
end

_G.HXN_TRACERS = {}

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local tracerLines = _G.HXN_TRACERS

_G.HXN_TRACER_LOOP = game:GetService("RunService").RenderStepped:Connect(function()
	if not TracersEnabled then
		for player, line in pairs(tracerLines) do
			line.Visible = false
		end
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
				
				-- Set tracer color based on player role
				local role = getRole(player)
				if role == "Murderer" then
					line.Color = MURDERER_COLOR
				elseif role == "Sheriff" then
					line.Color = SHERIFF_COLOR
				else
					line.Color = OTHER_PLAYER_COLOR
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
--// VISUAL TAB - FULL SKY / EFFECTS SYSTEM
--------------------------------------------------
VisualTab:Section({Title = "Sky Settings"})

-- Stores the current applied sky
local currentSky

-- Function to get available sky options
local function GetSkyOptions()
    return {"Default", "Aesthetic", "Night", "MC", "Pink"}
end

-- Function to apply a sky by name
local function applySky(skyName)
    -- Remove old sky
    if currentSky then
        currentSky:Destroy()
        currentSky = nil
    end

    if skyName == "Default" then
        -- Don't create a new sky, just remove the custom one
        return
    end

    local sky = Instance.new("Sky")
    sky.Name = "CustomSky"

    if skyName == "Aesthetic" then
        sky.SkyboxBk = "rbxassetid://600830446"
        sky.SkyboxDn = "rbxassetid://600831635"
        sky.SkyboxFt = "rbxassetid://600832720"
        sky.SkyboxLf = "rbxassetid://600886090"
        sky.SkyboxRt = "rbxassetid://600833862"
        sky.SkyboxUp = "rbxassetid://600835177"
    elseif skyName == "Night" then
        sky.SkyboxBk = "rbxassetid://154185004"
        sky.SkyboxDn = "rbxassetid://154184960"
        sky.SkyboxFt = "rbxassetid://154185021"
        sky.SkyboxLf = "rbxassetid://154184943"
        sky.SkyboxRt = "rbxassetid://154184972"
        sky.SkyboxUp = "rbxassetid://154185031"
    elseif skyName == "MC" then
        sky.SkyboxBk = "rbxassetid://1876545003"
        sky.SkyboxDn = "rbxassetid://1876544331"
        sky.SkyboxFt = "rbxassetid://1876542941"
        sky.SkyboxLf = "rbxassetid://1876543392"
        sky.SkyboxRt = "rbxassetid://1876543764"
        sky.SkyboxUp = "rbxassetid://1876544642"
    elseif skyName == "Pink" then
        sky.SkyboxBk = "rbxassetid://271042516"
        sky.SkyboxDn = "rbxassetid://271077243"
        sky.SkyboxFt = "rbxassetid://271042556"
        sky.SkyboxLf = "rbxassetid://271042310"
        sky.SkyboxRt = "rbxassetid://271042467"
        sky.SkyboxUp = "rbxassetid://271077958"
    end

    sky.Parent = game:GetService("Lighting")
    currentSky = sky
end

-- Dropdown for sky selection
local SkyDropdown = VisualTab:Dropdown({
    Title = "Select Sky",
    Values = {"Default", "Aesthetic", "Night", "MC", "Pink"},
    Value = "Default",
    Multi = false,
    AllowNone = false,
    Callback = function(option)
        if option then
            applySky(option)
        end
    end
})

-- EFFECTS TOGGLES
local BlurEffect
local BloomEffect
local ColorCorrection

-- Blur toggle
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
            if BlurEffect then
                BlurEffect:Destroy()
                BlurEffect = nil
            end
        end
    end
})

-- Bloom toggle (Neon-like glow)
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
            if BloomEffect then
                BloomEffect:Destroy()
                BloomEffect = nil
            end
        end
    end
})

-- Color correction toggle
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
            if ColorCorrection then
                ColorCorrection:Destroy()
                ColorCorrection = nil
            end
        end
    end
})

-- Apply default sky on script load
applySky("Default")

--------------------------------------------------
-- AUTOFARM LOGIC
--------------------------------------------------

local coinCollectedConn = nil

-- tracking for progress UI
local autofarmStartTime = 0
local coinBag = 0
local farmStatus = "Idle"

-- helper to read player's coin bag GUI and detect fullness
local function getBagCount()
    local plr = Players.LocalPlayer
    if not plr then return 0 end
    local gui = plr:FindFirstChild("PlayerGui")
    if not gui then return 0 end
    local main = gui:FindFirstChild("MainGUI")
    if not main then return 0 end
    local gameFrame = main:FindFirstChild("Game")
    if not gameFrame then return 0 end
    local bags = gameFrame:FindFirstChild("CoinBags")
    if not bags then return 0 end
    local count = 0
    for _,v in ipairs(bags:GetChildren()) do
        if v.Name == "Coin" then
            count = count + 1
        end
    end
    return count
end

local function isBagFull()
    local plr = Players.LocalPlayer
    if plr and plr:FindFirstChild("PlayerGui") then
        local gui = plr.PlayerGui:FindFirstChild("MainGUI")
        if gui then
            local gameFrame = gui:FindFirstChild("Game")
            if gameFrame and gameFrame:FindFirstChild("FullBagNotification") then
                return true
            end
        end
    end
    -- fallback if UI isn't present yet
    return getBagCount() >= 50
end

local function performPostFarmAction()
    local plr = Players.LocalPlayer
    if not plr then return end
    if postFarmAction == "Afk" then
        if plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = 0
                hum.JumpPower = 0
                hum.Sit = true
            end
        end
    elseif postFarmAction == "End All" then
        -- Kill all players to end the round
        local localPlayer = Players.LocalPlayer
        if localPlayer.Character then
            if not localPlayer.Character:FindFirstChild("Knife") then
                local backpack = localPlayer:FindFirstChildOfClass("Backpack")
                if backpack and backpack:FindFirstChild("Knife") then
                    local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                    hum:EquipTool(backpack:FindFirstChild("Knife"))
                end
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player ~= localPlayer then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Anchored = true
                        hrp.CFrame = localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 1
                    end
                end
            end
            local knifeTool = localPlayer.Character:FindFirstChild("Knife")
            if knifeTool then
                local args = {[1] = "Slash"}
                knifeTool:WaitForChild("Stab"):FireServer(unpack(args))
            end
        end
        AutofarmEnabled = false
    elseif postFarmAction == "Reset" then
        plr:LoadCharacter()
    end
end

local function handleBagFull()
    if not AutofarmEnabled then return end
    AutofarmEnabled = false
    farmStatus = "Bag full"
    updateAutofarmLabel()
    print("[HXN] Bag full detected, stopping autofarm...")
    task.wait(0.5)
    if TeleportOnComplete then
        teleportToLobby()
        -- Notification disabled (Wind UI incompatible)
    else
        -- Notification disabled (Wind UI incompatible)
    end
    CoinCount = 0
    coinBag = 0
    farmStatus = "Idle"
    updateAutofarmLabel()
    performPostFarmAction()
end

-- watch the player GUI for the FullBagNotification object, so we can react immediately
local function watchBagGui()
    spawn(function()
        local plr = Players.LocalPlayer
        if not plr then return end

        -- wait for PlayerGui to be ready
        repeat task.wait() until plr:FindFirstChild("PlayerGui")
        local gui = plr.PlayerGui

        local function connectToBags(bagsFrame)
            if not bagsFrame then return end
            local conn
            conn = bagsFrame.DescendantAdded:Connect(function(desc)
                if desc.Name == "FullBagNotification" then
                    handleBagFull()
                end
            end)
            table.insert(_G.HXN_CONNECTIONS, conn)
        end

        -- if the structure already exists, hook it immediately
        if gui:FindFirstChild("MainGUI") and gui.MainGUI:FindFirstChild("Game") then
            connectToBags(gui.MainGUI.Game:FindFirstChild("CoinBags"))
        end

        -- monitor for MainGUI/Game/CoinBags creation
        local mainConn
        mainConn = gui.ChildAdded:Connect(function(child)
            if child.Name == "MainGUI" then
                local gameFrame = child:WaitForChild("Game", 5)
                if gameFrame then
                    local bags = gameFrame:WaitForChild("CoinBags", 5)
                    connectToBags(bags)
                end
            end
        end)
        table.insert(_G.HXN_CONNECTIONS, mainConn)
    end)
end

-- start watching right away
watchBagGui()

local function formatTime(seconds)
    seconds = math.floor(seconds)
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", minutes, secs)
end

local function updateAutofarmLabel()
    if AutofarmStatusLabel then
        if AutofarmEnabled then
            local elapsed = tick() - autofarmStartTime
            local cph = elapsed > 0 and (coinBag / elapsed) * 3600 or 0
            local statusText = "Time elapsed: " .. formatTime(elapsed) ..
                               "\nCoinbag: " .. coinBag ..
                               "\nCoins per hour: " .. math.floor(cph) ..
                               "\nFarm Status: " .. farmStatus
            AutofarmStatusLabel:SetDesc(statusText)
        else
            AutofarmStatusLabel:SetDesc("Autofarm is disabled. Waiting...")
        end
    end
end

-- fly helper used during autofarm
local flyConn = nil
local TeleportOnComplete = false
local postFarmAction = "Reset" -- options: Afk, End Round/Kill All, Reset

-- autofarm state defaults
local AutofarmEnabled = false
local AutofarmType = "Floating"         -- "Floating" or "Teleport"
local CollectHeight = -5                 -- coin collect offset
local AutofarmSpeed = 20                 -- movement speed multiplier
local ContinueOnDeath = false            -- end round toggle behavior
local CoinCount = 0
local LastCoinPosition = nil

local function enableFly()
    if flyConn then return end
    flyConn = game:GetService("RunService").RenderStepped:Connect(function()
        local plr = Players.LocalPlayer
        if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            local hum = plr.Character.Humanoid
            if hum.Jump then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

local function disableFly()
    if flyConn then
        flyConn:Disconnect()
        flyConn = nil
    end
end

local function startAutofarm()
    print("[HXN] Autofarm starting...")
    -- reset tracking variables
    autofarmStartTime = tick()
    coinBag = getBagCount()
    farmStatus = "Waiting for coins"
    updateAutofarmLabel()

    -- Enable persistent noclip for the entire autofarm session
    local function applyNoclip()
        local player = Players.LocalPlayer
        if not player or not player.Character then return end
        
        -- Disable collisions on all parts
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        -- Set humanoid properties for better noclip
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = true  -- Prevents ground detection
            hum.Sit = false  -- Ensure not sitting
        end
    end
    
    -- Only apply noclip if using Floating mode (not Teleport)
    if AutofarmType == "Floating" then
        -- Apply noclip initially
        applyNoclip()
        
        -- Reapply noclip every frame to ensure it sticks and counteract gravity
        local noclipTask = task.spawn(function()
            while AutofarmEnabled and AutofarmType == "Floating" do
                applyNoclip()
                task.wait(0.15)  -- Reapply every 0.15s to avoid conflicts with BodyVelocity
            end
        end)
        table.insert(_G.HXN_TASKS, noclipTask)
    end
    
    -- Monitor and set up coin touch detection
    local coinTouchConnections = {}
    local function setupCoinTouches()
        -- Disconnect old coin connections
        for _, conn in ipairs(coinTouchConnections) do
            pcall(function() conn:Disconnect() end)
        end
        coinTouchConnections = {}
        
        -- Find all coins and listen to their touch events
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "CoinVisual" then
                local mainCoin = obj:FindFirstChild("MainCoin") or obj:FindFirstChildWhichIsA("BasePart")
                if mainCoin then
                    local conn = mainCoin.Touched:Connect(function(hit)
                        local player = Players.LocalPlayer
                        if player and player.Character and hit:IsDescendantOf(player.Character) then
                            CoinCount = CoinCount + 1
                            print("[HXN] Coin collected! Count: " .. CoinCount)
                        end
                    end)
                    table.insert(coinTouchConnections, conn)
                    table.insert(_G.HXN_CONNECTIONS, conn)
                end
            end
        end
    end
    
    -- Setup coin touches initially
    setupCoinTouches()
    
    -- Track coins we've already visited to avoid re-teleporting
    local visitedCoins = {}
    
    -- Re-setup coin touches every 3 seconds in case new coins spawn
    local coinMonitorTask = task.spawn(function()
        while AutofarmEnabled do
            task.wait(3)
            setupCoinTouches()
        end
    end)
    table.insert(_G.HXN_TASKS, coinMonitorTask)
    
    -- Main autofarm loop: wait for coins, farm until none left, reset, repeat
    while AutofarmEnabled do
        -- Wait for coins to spawn
        while AutofarmEnabled do
            local coinsExist = false
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "Coin" or obj.Name == "CoinVisual" then
                    coinsExist = true
                    break
                end
            end
            if coinsExist then
                farmStatus = "Coins spawned"
                updateAutofarmLabel()
                break
            end
            farmStatus = "Waiting for coins"
            updateAutofarmLabel()
            task.wait(1)
        end
        
        if not AutofarmEnabled then break end
        
        -- Clear visited coins for new round
        visitedCoins = {}
        
        -- Farm until no coins left or bag full
        while AutofarmEnabled do
            -- refresh bag count each tick
            coinBag = getBagCount()
            if coinBag >= 50 then
                farmStatus = "Bag full"
                updateAutofarmLabel()
                break
            end
            local player = Players.LocalPlayer
            if not player or not player.Character then
                task.wait(0.5)
                continue
            end
            
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            local head = player.Character:FindFirstChild("Head")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if not hrp or not head or not hum then
                task.wait(0.5)
                continue
            end
            
            -- Find closest coin (skip recently visited ones)
            local closestCoin = nil
            local closestDist = math.huge
            
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "Coin" or obj.Name == "CoinVisual" then
                    local coinPart = obj
                    if obj.Name == "CoinVisual" then
                        coinPart = obj:FindFirstChild("MainCoin") or obj:FindFirstChildWhichIsA("BasePart")
                    end
                    
                    -- Only consider coins that still exist (not collected yet)
                    if coinPart and coinPart.Parent and not visitedCoins[coinPart] then
                        local dist = (hrp.Position - coinPart.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closestCoin = coinPart
                        end
                    end
                end
            end
            
            -- If no coin found, break farming loop to reset and wait
            if not closestCoin then
                break
            end
            
            -- If coin found, move to it using selected method
            local coinPos = closestCoin.Position
            local targetPos = coinPos - Vector3.new(0, 1.5, 0) + Vector3.new(0, CollectHeight, 0)  -- Position so head touches coin

            -- Mark this coin as visited immediately (so we don't teleport to it again)
            visitedCoins[closestCoin] = true

            -- prevent map-fall death while moving
            local oldFPDH = workspace.FallenPartsDestroyHeight
            workspace.FallenPartsDestroyHeight = -math.huge

            -- Disable fly during movement to prevent upward force
            disableFly()

            -- Use teleport or float based on AutofarmType
            if AutofarmType == "Teleport" then
                -- Slow down the teleport with a delay
                task.wait(1)  -- Add 1 second delay before teleporting
                
                -- Instant teleport to coin
                hrp.CFrame = CFrame.new(targetPos)
                
                -- Damp velocity after teleport
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.new(0, 0, 0)
                        part.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end
                
                task.wait(0.1)  -- Small delay to let coin register collection
            else
                -- Float smoothly to coin using BodyVelocity (fly logic)
                local bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bodyVelocity.Parent = hrp
                local bodyGyro = Instance.new("BodyGyro")
                bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                bodyGyro.CFrame = hrp.CFrame
                bodyGyro.Parent = hrp
                
                local reached = false
                local lastVelocity = Vector3.new(0, 0, 0)
                while not reached and AutofarmEnabled do
                    -- Create target position that includes the coin's Y coordinate (for multi-floor support)
                    local adjustedTargetPos = Vector3.new(coinPos.X, coinPos.Y + CollectHeight - 1.5, coinPos.Z)
                    local direction = (adjustedTargetPos - hrp.Position)
                    local dist = direction.Magnitude
                    if dist < 1 then
                        reached = true
                        break
                    end
                    direction = direction.Unit
                    -- Calculate target velocity and smooth it to avoid jitter
                    local targetVelocity = direction * AutofarmSpeed
                    lastVelocity = lastVelocity:Lerp(targetVelocity, 0.2)  -- Smooth transition (20% per frame)
                    bodyVelocity.Velocity = lastVelocity
                    
                    -- Damp rotational velocity
                    for _, part in ipairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.RotVelocity = Vector3.new(0, 0, 0)
                        end
                    end
                    task.wait(0.1)
                end
                
                bodyVelocity:Destroy()
                bodyGyro:Destroy()
            end

            -- Wait a bit for collection to register
            local beforeCount = CoinCount
            local waitTime = 0
            while waitTime < 0.5 and CoinCount == beforeCount do
                task.wait(0.05)
                waitTime = waitTime + 0.05
            end
            
            workspace.FallenPartsDestroyHeight = oldFPDH
            
            -- Reset head back to normal offset if needed
            head.CFrame = hrp.CFrame * CFrame.new(0, 1.5, 0)
            farmStatus = "Collecting"
            updateAutofarmLabel()
            
            task.wait(0.05)
        end
        
        -- After farming loop, handle based on reason
        if AutofarmEnabled then
            if coinBag >= 50 then
                -- Bag full, do post farm action and exit
                if postFarmAction == "Reset" then
                    farmStatus = "Resetting after full bag"
                    updateAutofarmLabel()
                    local plr = Players.LocalPlayer
                    if plr then
                        plr:LoadCharacter()
                    end
                    break
                elseif postFarmAction == "Afk" then
                    farmStatus = "AFK after full bag"
                    updateAutofarmLabel()
                    AutofarmEnabled = false
                    updateAutofarmLabel()
                    break
                elseif postFarmAction == "End All" then
                    farmStatus = "Ending round"
                    updateAutofarmLabel()
                    local localPlayer = Players.LocalPlayer
                    if localPlayer.Character then
                        if not localPlayer.Character:FindFirstChild("Knife") then
                            local backpack = localPlayer:FindFirstChildOfClass("Backpack")
                            if backpack and backpack:FindFirstChild("Knife") then
                                local hum = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                                hum:EquipTool(backpack:FindFirstChild("Knife"))
                            end
                        end
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player.Character and player ~= localPlayer then
                                local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    hrp.Anchored = true
                                    hrp.CFrame = localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame + localPlayer.Character:FindFirstChild("HumanoidRootPart").CFrame.LookVector * 1
                                end
                            end
                        end
                        local knifeTool = localPlayer.Character:FindFirstChild("Knife")
                        if knifeTool then
                            local args = {[1] = "Slash"}
                            knifeTool:WaitForChild("Stab"):FireServer(unpack(args))
                        end
                    end
                    AutofarmEnabled = false
                    updateAutofarmLabel()
                    break
                end
            else
                -- No coins found, wait for new coins (don't break - loop continues)
                farmStatus = "Waiting for new coins"
                updateAutofarmLabel()
            end
        end
        -- Loop continues back to wait for coins to spawn
    end
    
    -- Restore normal collision and humanoid state
    local player = Players.LocalPlayer
    if player and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
        end
    end
    
    disableFly()
end

-- Call startAutofarm directly instead of spawning repeatedly
local autofarmActive = false

-- restart autofarm when character respawns if enabled
Players.LocalPlayer.CharacterAdded:Connect(function(char)
    if AutofarmEnabled then
        task.wait(1)
        -- Wait for new coins to appear on map (indicates new round started)
        local waitedForCoins = false
        local startWaitTime = tick()
        repeat
            task.wait(0.5)
            local coinsExist = false
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name == "Coin" or obj.Name == "CoinVisual" then
                    coinsExist = true
                    break
                end
            end
            if coinsExist then
                waitedForCoins = true
            end
        until waitedForCoins or (tick() - startWaitTime) > 30 -- timeout after 30 secs
        
        -- Now restart autofarm
        if not autofarmActive then
            autofarmActive = true
            autofarmStartTime = tick()
            coinBag = getBagCount()
            farmStatus = "Starting"
            updateAutofarmLabel()
            startAutofarm()
            autofarmActive = false
        end
    end
end)

-- monitor humanoid health to detect death and pause autofarm
local deathWatchTask = task.spawn(function()
    while true do
        task.wait(0.1)
        local plr = Players.LocalPlayer
        if plr and plr.Character and AutofarmEnabled then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 0 then
                print("[HXN] Player died, waiting for respawn...")
                farmStatus = "Died, waiting for respawn"
                updateAutofarmLabel()
                task.wait(1) -- brief pause before checking for respawn
            end
        end
    end
end)
table.insert(_G.HXN_TASKS, deathWatchTask)

-- farm progress section + label
AutofarmTab:Section({Title = "Farm progress"})

local AutofarmStatusLabel = AutofarmTab:Paragraph({
    Title = "Status",
    Desc = "Autofarm is disabled. Waiting ..."
})

-- settings
AutofarmTab:Section({Title = "Settings"})

--[[AutofarmTab:Dropdown({
    Title = "Type of autofarm",
    Values = {"Floating","Teleport"},
    Value = {AutofarmType},
    Callback = function(opt)
        AutofarmType = opt[1]
    end,
})--]]

AutofarmTab:Toggle({
   Title = "Autofarm",
   Value = false,
   Callback = function(Value)
        AutofarmEnabled = Value
        if Value then
            -- initialize tracking UI
            autofarmStartTime = tick()
            coinBag = 0
            farmStatus = "Starting"
            updateAutofarmLabel()
        else
            updateAutofarmLabel()
        end
        if Value and not autofarmActive then
            autofarmActive = true
            startAutofarm()
            autofarmActive = false
        end
        if not Value then
            CoinCount = 0
            LastCoinPosition = nil
            disableFly()
            -- Instantly disable noclip
            local player = Players.LocalPlayer
            if player and player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
                local hum = player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.PlatformStand = false
                end
            end
        end
   end,
})

-- coin level slider (-5 to 1)
local CoinLevelSlider = AutofarmTab:Slider({
   Title = "Choose coin-collecting level",
   Step = 0.1,
   Value = {
       Min = 0,
       Max = 1,
       Default = 0,
   },
   Callback = function(v)
        CollectHeight = v
    end,
})

-- Add scroll wheel support for Coin Level slider
if CoinLevelSlider and CoinLevelSlider.Instance then
    CoinLevelSlider.Instance.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local currentValue = CollectHeight or 0
            local newValue = currentValue + (input.Position.Z > 0 and 0.1 or -0.1)
            newValue = math.clamp(newValue, 0, 1)
            CoinLevelSlider:SetValue(newValue)
        end
    end)
end

-- speed slider 20-25
--[[AutofarmTab:Slider({
   Name = "Autofarm Speed",
   Range = {0, 30},
   Increment = 1,
   Suffix = "x",
   CurrentValue = 10,
   Flag = "AutofarmSpeed",
   Callback = function(Value)
        AutofarmSpeed = Value
   end,
})--]]

-- end round toggle
--[[AutofarmTab:Toggle({
   Name = "End the round if dead or not in it",
   CurrentValue = ContinueOnDeath,
   Flag = "EndRoundToggle",
   Callback = function(v)
        ContinueOnDeath = v
   end,
})--]]

-- post farm action dropdown
--[[AutofarmTab:Dropdown({
   Name = "Select action after farming coins",
   Options = {"Reset","Afk","End All"},
   CurrentOption = {postFarmAction},
   Flag = "PostFarmAction",
   Callback = function(opt)
       postFarmAction = opt[1]
   end,
})--]]

-- optional teleport toggle
AutofarmTab:Toggle({
   Title = "Teleport to Lobby on 50",
   Value = false,
   Callback = function(v)
        TeleportOnComplete = v
    end,
})

--------------------------------------------------
-- GUN TELEPORT
--------------------------------------------------

local function findGun()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj.Name == "GunDrop" then
			return obj.Position
		end
	end
	return nil
end

local function teleportToGun()
	local localPlayer = Players.LocalPlayer
	if not localPlayer or not localPlayer.Character then return end
	
	local gunPos = findGun()
	if not gunPos then
		-- Notification disabled (Wind UI incompatible)
		return
	end
	
	-- Save current position
	OriginalPosition = localPlayer.Character.HumanoidRootPart.CFrame
	
	-- Teleport to gun instantly
	localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(gunPos + Vector3.new(0, 3, 0))
	IsAtGun = true
	
	-- Notification disabled (Wind UI incompatible)
	
	-- Monitor for gun pickup and auto-return
	local gunMonitorTaskId = task.spawn(function()
		while IsAtGun do
			task.wait(0.05)  -- Optimized: faster monitoring (was 0.1)
			local player = Players.LocalPlayer
			if player and player.Character then
				local backpack = player:FindFirstChildOfClass("Backpack")
				local hasGun = false
				
				-- Check if gun is in backpack or equipped
				if backpack and backpack:FindFirstChild("Gun") then
					hasGun = true
				elseif player.Character:FindFirstChild("Gun") then
					hasGun = true
				end
				
				-- If gun is picked up, return to original position
				if hasGun and OriginalPosition then
					player.Character.HumanoidRootPart.CFrame = OriginalPosition
					IsAtGun = false
					
					-- Notification disabled (Wind UI incompatible)
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
		-- Notification disabled (Wind UI incompatible)
		return
	end
	
	-- Teleport back instantly
	localPlayer.Character.HumanoidRootPart.CFrame = OriginalPosition
	IsAtGun = false
	
	-- Notification disabled (Wind UI incompatible)
end

local UserInputService = game:GetService("UserInputService")

--------------------------------------------------
-- TELEPORT TAB UI
--------------------------------------------------

-- GUN TELEPORT SECTION
TeleportTab:Section({Title = "Gun Teleport"})

TeleportTab:Toggle({
   Title = "Gun Teleport",
   Value = false,
   Callback = function(Value)
		GunTPEnabled = Value
   end,
})

-- MAP TELEPORTS SECTION
TeleportTab:Section({Title = "Map Teleports"})

TeleportTab:Button({
   Title = "TP To Lobby",
   Callback = function()
        teleportToLobby()
   end,
})

TeleportTab:Button({
   Title = "TP To Map",
   Callback = function()
        teleportToMap()
   end,
})

TeleportTab:Button({
   Title = "TP To Secret Place",
   Callback = function()
        teleportToSecretPlace()
   end,
})

-- PLAYER TELEPORT SECTION
TeleportTab:Section({Title = "Player Teleport"})

--------------------------------------------------
-- PLAYER TELEPORT
--------------------------------------------------

local SelectedTPPlayer = nil

local function teleportToPlayer(playerName)
	local targetPlayer = nil
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name == playerName and player ~= Players.LocalPlayer then
			targetPlayer = player
			break
		end
	end
	
	if not targetPlayer or not targetPlayer.Character then
		-- Notification disabled (Wind UI incompatible)
		return
	end
	
	local localPlayer = Players.LocalPlayer
	if not localPlayer or not localPlayer.Character then return end
	
	local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	
	if not hrp or not targetHRP then
		-- Notification disabled (Wind UI incompatible)
		return
	end
	
	-- Teleport to player position
	hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
	
	-- Notification disabled (Wind UI incompatible)
end

-- Player selection dropdown for teleport
--[[local PlayerTPDropdown = TeleportTab:Dropdown({
   Title = "Select Player to TP",
   Values = GetPlayerList(),
   Value = {"None"},
   Callback = function(Option)
       SelectedTPPlayer = Option[1]
   end,
})--]]

-- Refresh dropdown when players join/leave
--[[local function RefreshPlayerTPDropdown()
    PlayerTPDropdown:Refresh(GetPlayerList(), true)
end

-- Connect to player events to update dropdown
local playerAddedTPConn = Players.PlayerAdded:Connect(function(player)
    RefreshPlayerTPDropdown()
end)
table.insert(_G.HXN_CONNECTIONS, playerAddedTPConn)

local playerRemovingTPConn = Players.PlayerRemoving:Connect(function(player)
    if SelectedTPPlayer == player.Name then
        SelectedTPPlayer = nil
    end
    RefreshPlayerTPDropdown()
end)
table.insert(_G.HXN_CONNECTIONS, playerRemovingTPConn)--]]

-- Teleport to Player Button
TeleportTab:Button({
   Title = "TP to Selected Player",
   Callback = function()
       if not SelectedTPPlayer or SelectedTPPlayer == "None" then
           return
       end
       teleportToPlayer(SelectedTPPlayer)
   end,
})

local gunTPInputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == GunTPKeybind and GunTPEnabled then
		if not IsAtGun then
			teleportToGun()
		else
			returnToOriginalPos()
		end
	end
end)
table.insert(_G.HXN_CONNECTIONS, gunTPInputConn)

--------------------------------------------------
-- TROLLING TAB UI - FLING CONTROLS
--------------------------------------------------

-- FLING TARGET SECTION
TrollingTab:Section({Title = "Select Target"})

-- Player selection dropdown for fling
local FlingPlayerDropdown = TrollingTab:Dropdown({
   Title = "Select Player",
   Values = GetPlayerList(),
   Value = "None",
   Callback = function(option)
       SelectedFlingTarget = option
   end,
})

-- Refresh dropdown when players join/leave
local function RefreshFlingDropdown()
    if FlingPlayerDropdown then
        FlingPlayerDropdown:Refresh(GetPlayerList())
    end
end

-- Connect to player events to update dropdown
local playerAddedConn2 = Players.PlayerAdded:Connect(function(player)
    RefreshFlingDropdown()
end)
table.insert(_G.HXN_CONNECTIONS, playerAddedConn2)

local playerRemovingConn2 = Players.PlayerRemoving:Connect(function(player)
    if SelectedFlingTarget == player.Name then
        SelectedFlingTarget = nil
    end
    RefreshFlingDropdown()
end)
table.insert(_G.HXN_CONNECTIONS, playerRemovingConn2)

-- FLING CONTROLS SECTION
TrollingTab:Section({Title = "Fling Controls"})

-- Start Flinging Button
TrollingTab:Button({
   Title = "Start Flinging",
   Callback = function()
       StartFling()
   end,
})

-- Stop Flinging Button
TrollingTab:Button({
   Title = "Stop Flinging",
   Callback = function()
       StopFling()
   end,
})

-- FLING BY ROLE SECTION
TrollingTab:Section({Title = "Fling by Role"})

-- helper to fling by detected role (Murderer or Sheriff)
local function flingRole(role)
    local target = nil
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer and getRole(p) == role then
            target = p
            break
        end
    end
    if target then
        SelectedFlingTarget = target.Name
        StartFling()
    else
        -- Notification disabled (Wind UI incompatible)
    end
end

-- fling specific roles
TrollingTab:Button({
   Title = "Fling Murderer",
   Callback = function()
       flingRole("Murderer")
   end,
})

TrollingTab:Button({
   Title = "Fling Sheriff",
   Callback = function()
       flingRole("Sheriff")
   end,
})

-- FLING ALL SECTION
TrollingTab:Section({Title = "Fling All"})

-- Fling All Button
TrollingTab:Button({
   Title = "Fling All Players",
   Callback = function()
       FlingAll()
   end,
})

--------------------------------------------------
-- ESP TAB UI
--------------------------------------------------

ESPTab:Section({Title = "Main Control"})

ESPTab:Toggle({
   Title = "ESP",
   Default = false,
   Callback = function(Value)
		ESPEnabled = Value
   end,
})

ESPTab:Section({Title = "ESP Options"})

ESPTab:Toggle({
   Title = "ESP Names",
   Default = false,
   Callback = function(Value)
		ESPNamesEnabled = Value
		NameTagsEnabled = Value
   end,
})

-- DROPPED ITEMS SECTION
ESPTab:Section({Title = "Dropped Items"})

ESPTab:Toggle({
   Title = "ESP Dropped GunDrop",
   Default = false,
   Callback = function(Value)
		ESPDroppedGunEnabled = Value
		-- refresh displays when toggled
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj.Name == "GunDrop" then
				updateGunDisplay(obj)
			end
		end
   end,
})

ESPTab:Toggle({
   Title = "Show coins",
   Default = false,
   Callback = function(Value)
		ShowCoinsEnabled = Value
   end,
})

ESPTab:Toggle({
   Title = "Show thrown knife (StuckKnife)",
   Default = false,
   Callback = function(Value)
		ShowThrownKnifeEnabled = Value
   end,
})

-- DISPLAY MODE SECTION
ESPTab:Section({Title = "Display Mode"})

--[[ESPTab:Dropdown({
   Name = "ESP Mode",
   Options = {"Highlight", "Chams", "Box"},
   CurrentOption = {"Highlight"},
   Flag = "ESPMode",
   Callback = function(Option)
		ESPModeType = Option[1]
   end,
})--]]

-- ROLE ESP SECTION
ESPTab:Section({Title = "Role ESP"})

ESPTab:Toggle({
   Title = "Innocent ESP",
   Value = true,
   Callback = function(Value)
		InnocentESPEnabled = Value
   end,
})

ESPTab:Toggle({
   Title = "Sheriff ESP",
   Value = true,
   Callback = function(Value)
		SheriffESPEnabled = Value
   end,
})

ESPTab:Toggle({
   Title = "Murderer ESP",
   Value = true,
   Callback = function(Value)
		MurdererESPEnabled = Value
   end,
})

ESPTab:Toggle({
   Title = "Player Tracers",
   Default = false,
   Callback = function(Value)
        TracersEnabled = Value
   end,
})

print("[HXN] Script fully loaded and ready to use!")












