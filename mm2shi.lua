-- Cleanup old script instance if running again
print("[HXN] Starting script cleanup...")

if _G.HXN_WINDOW then
	print("[HXN] Closing old window...")
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

print("[HXN] Loading Rayfield...")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
print("[HXN] Creating window...")

-- Custom Modern Glassmorphism Theme with Red & Black Mirror Glass
local CustomTheme = {
	TextColor = Color3.fromRGB(240, 240, 240),

	-- Dark black mirror glass background effect
	Background = Color3.fromRGB(8, 8, 10),
	Topbar = Color3.fromRGB(12, 12, 15),
	Shadow = Color3.fromRGB(3, 3, 5),

	NotificationBackground = Color3.fromRGB(12, 12, 15),
	NotificationActionsBackground = Color3.fromRGB(240, 240, 245),

	-- Red glowing accents
	TabBackground = Color3.fromRGB(20, 15, 15),
	TabStroke = Color3.fromRGB(220, 40, 40),
	TabBackgroundSelected = Color3.fromRGB(180, 25, 25),
	TabTextColor = Color3.fromRGB(240, 240, 240),
	SelectedTabTextColor = Color3.fromRGB(255, 100, 100),

	ElementBackground = Color3.fromRGB(15, 12, 12),
	ElementBackgroundHover = Color3.fromRGB(35, 20, 20),
	SecondaryElementBackground = Color3.fromRGB(10, 8, 8),
	ElementStroke = Color3.fromRGB(255, 50, 50),
	SecondaryElementStroke = Color3.fromRGB(220, 40, 40),
			
	SliderBackground = Color3.fromRGB(220, 30, 30),
	SliderProgress = Color3.fromRGB(255, 60, 60),
	SliderStroke = Color3.fromRGB(255, 80, 80),

	ToggleBackground = Color3.fromRGB(15, 12, 12),
	ToggleEnabled = Color3.fromRGB(220, 35, 35),
	ToggleDisabled = Color3.fromRGB(80, 60, 60),
	ToggleEnabledStroke = Color3.fromRGB(255, 80, 80),
	ToggleDisabledStroke = Color3.fromRGB(180, 100, 100),
	ToggleEnabledOuterStroke = Color3.fromRGB(255, 120, 120),
	ToggleDisabledOuterStroke = Color3.fromRGB(150, 80, 80),

	DropdownSelected = Color3.fromRGB(35, 20, 20),
	DropdownUnselected = Color3.fromRGB(15, 12, 12),

	InputBackground = Color3.fromRGB(15, 12, 12),
	InputStroke = Color3.fromRGB(255, 50, 50),
	PlaceholderColor = Color3.fromRGB(180, 140, 140)
}

local Window = Rayfield:CreateWindow({
   Name = "MM2",
   LoadingTitle = "MM2",
   LoadingSubtitle = "by hxneey",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "HXN"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },
   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   },
   Resizable = true,
   ResizeCorner = true,
   Theme = CustomTheme
})

-- Store window and initialize task tracking
_G.HXN_WINDOW = Window
_G.HXN_TASKS = {}
_G.HXN_CONNECTIONS = {}

print("[HXN] Window created successfully!")

-- Add mirror glass effect and red glow outlines
spawn(function()
	task.wait(0.3)
	
	pcall(function()
		local CoreGui = game:GetService("CoreGui")
		local RayfieldGui = CoreGui:FindFirstChild("Rayfield")
		
		if RayfieldGui then
			-- Find all UI elements and add glow effect
			local function addGlowToElements(parent)
				for _, element in ipairs(parent:GetDescendants()) do
					if element:IsA("GuiObject") and (element:IsA("TextButton") or element:IsA("Frame")) then
						-- Make slightly transparent for mirror effect
						if element.BackgroundTransparency ~= 1 then
							element.BackgroundTransparency = math.min(element.BackgroundTransparency + 0.05, 0.7)
						end
						
						-- Remove old strokes
						for _, child in ipairs(element:GetChildren()) do
							if child:IsA("UIStroke") then
								child:Destroy()
							end
						end
						
						-- Add red glow stroke
						local glow = Instance.new("UIStroke")
						glow.Color = Color3.fromRGB(255, 50, 50)
						glow.Thickness = 1.5
						glow.Transparency = 0.4
						glow.Parent = element
					end
				end
			end
			
			addGlowToElements(RayfieldGui)
			
			-- Add a shadow/glow effect to main window
			local mainFrame = RayfieldGui:FindFirstChildWhichIsA("Frame")
			if mainFrame and mainFrame.Name == "MainFrame" or #mainFrame:GetChildren() > 5 then
				-- Add transparency for mirror effect
				mainFrame.BackgroundTransparency = 0.1
				
				-- Try to add glow
				for _, child in ipairs(mainFrame:GetChildren()) do
					if child:IsA("UIStroke") then
						child.Color = Color3.fromRGB(255, 50, 50)
						child.Thickness = 2
						child.Transparency = 0.3
					end
				end
			end
			
			print("[HXN] Red glow and mirror glass effects applied!")
		end
	end)
end)

-- create tabs for each category
local CharacterTab = Window:CreateTab("🧍 Character", nil)
local TeleportTab = Window:CreateTab("✈️ Teleport", nil)
local CombatTab = Window:CreateTab("⚔️ Combat", nil)
local TrollingTab = Window:CreateTab("😈 Trolling", nil)
local ESPTab = Window:CreateTab("👁️ ESP", nil)
local VisualTab = Window:CreateTab("🎨 Visual", nil)
local AutofarmTab = Window:CreateTab("🌾 Autofarm", nil)
local EmoteTab = Window:CreateTab("🎭 Emotes", nil)
local OtherTab = Window:CreateTab("🔧 Other", nil)

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
		Rayfield:Notify({
			Title = "Error",
			Content = "Murderer not found!",
			Duration = 2,
			Image = 4483345998,
		})
		return
	end

	-- Get gun tool
	local gunTool = getGunTool()
	if not gunTool then
		Rayfield:Notify({
			Title = "Error",
			Content = "Gun not found in inventory!",
			Duration = 2,
			Image = 4483345998,
		})
		return
	end

	-- Equip the gun
	if gunTool.Parent == localPlayer:FindFirstChildOfClass("Backpack") then
		gunTool.Parent = localPlayer.Character
		-- No delay for maximum speed
	end

	print("[HXN] Equipping gun and aiming at: " .. TargetMurderer.Name)

	-- Activate silent aim
	GunBeamAutoAimEnabled = true
	-- No delay for maximum speed

	-- Point camera at target for aiming
	local TargetPart = TargetMurderer.Character:FindFirstChild("HumanoidRootPart") or TargetMurderer.Character:FindFirstChild("Head")
	if TargetPart then
		workspace.CurrentCamera.CFrame = CFrame.new(localPlayer.Character:FindFirstChild("HumanoidRootPart").Position, TargetPart.Position)
	end

	-- No delay for maximum speed

	-- Fire the gun (activate it)
	pcall(function()
		gunTool:Activate()
		print("[HXN] GunBeam auto-aim shot fired at murderer!")
	end)

	-- No delay for maximum speed

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

-- SHERIFF COMBAT SECTION
local SheriffSection = CombatTab:CreateSection("Sheriff Combat")

local AutoShootToggle = CombatTab:CreateToggle({
	Name = "Auto Shoot Murderer",
	CurrentValue = false,
	Flag = "AutoShootMurderer",
	Callback = function(Value)
		GunBeamAutoAimEnabled = Value
		if Value then
			print("[HXN] GunBeam Auto Shoot enabled! Press Q to shoot.")
			Rayfield:Notify({
				Title = "GunBeam Silent Aim Enabled",
				Content = "Press Q to instantly shoot the murderer with auto-aim",
				Duration = 3,
				Image = 4483345998,
			})
		else
			print("[HXN] GunBeam Auto Shoot disabled.")
			GunBeamAutoAimEnabled = false
		end
	end,
})

-- Keybind listener for Q key
local UserInputService = game:GetService("UserInputService")
local shootConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.Q and GunBeamAutoAimEnabled then
		shootMurdererWithGunBeam()
	end
end)

table.insert(_G.HXN_CONNECTIONS, shootConnection)


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
    if v.Parent == game.Players.LocalPlayer.Character then return end
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
local AntiExploitSection = OtherTab:CreateSection("Anti-Exploit")

local Button = OtherTab:CreateToggle({
   Name = "Anti-AFK",
   CurrentValue = true,
   Flag = "AntiAFKToggle",
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

local Button = OtherTab:CreateToggle({
   Name = "Anti-Fling",
   CurrentValue = false,
   Flag = "AntiFlingToggle",
   Callback = function(val)
        if val then
            startAntiFling()
        else
            stopAntiFling()
        end
   end,
})

-- UTILITIES SECTION
local UtilitiesSection = OtherTab:CreateSection("Utilities")

local Button = OtherTab:CreateButton({
   Name = "Inf Yield",
   Callback = function()
        local success, result = pcall(function()
            local script = game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source")
            loadstring(script)()
        end)
        
        if not success then
            Rayfield:Notify({
                Title = "Error",
                Content = "Inf Yield Error: " .. tostring(result),
                Duration = 5,
            })
            print("[HXN] Inf Yield Error: " .. tostring(result))
        end
   end,
})

-- Ensure GunDropNotifyEnabled is initialized
if GunDropNotifyEnabled == nil then
	GunDropNotifyEnabled = false
end

Rayfield:Notify({
   Title = "You executed the script",
   Content = "Very cool gui",
   Duration = 5,
   Image = 13047715178,
   Actions = { -- Notification Buttons
      Ignore = {
         Name = "Okay!",
         Callback = function()
         print("The user tapped Okay!")
         print("[HXN] Script loaded successfully!")
      end
   },
},
})

local Button = EmoteTab:CreateButton({
   Name = "Emotes",
   Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Joystickplays/AFEM/main/max/afemmax.lua"))()
   end,
})

--------------------------------------------------
-- CHARACTER TAB UI
--------------------------------------------------

-- PERFORMANCE SECTION
local PerformanceSection = CharacterTab:CreateSection("Performance")

-- FPS and Ping Tracking Variables
local fps = 0
local lastTime = tick()
local currentPing = 0

-- FPS calculation
game:GetService("RunService").RenderStepped:Connect(function()
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

-- Performance Monitor Label
local PerformanceLabel = CharacterTab:CreateLabel("FPS: Loading...\nPing: Loading...")

-- Update performance label continuously
local performanceTaskId = task.spawn(function()
    while true do
        task.wait(0.1)
        getPing()
        local fpsStatus = fps < 30 and "🔴 " or "🟢 "
        local pingStatus = currentPing > 200 and "🔴 " or "🟢 "
        local performanceText = fpsStatus .. "FPS: " .. tostring(fps) .. 
                                "\n" .. pingStatus .. "Ping: " .. tostring(currentPing) .. " ms"
        PerformanceLabel:Set(performanceText)
    end
end)
table.insert(_G.HXN_TASKS, performanceTaskId)

-- MOVEMENT SECTION
local MovementSection = CharacterTab:CreateSection("Movement")

local currentWalkSpeed = 16
local walkSpeedEnabled = false

local WalkSpeedToggle = CharacterTab:CreateToggle({
   Name = "Enable WalkSpeed Changer",
   CurrentValue = false,
   Flag = "WalkSpeedEnable",
   Callback = function(Value)
        walkSpeedEnabled = Value
        if Value then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = currentWalkSpeed
        else
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
   end,
})

local WalkSpeedSlider = CharacterTab:CreateSlider({
   Name = "WalkSpeed Slider",
   Range = {1, 350},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "sliderws",
   Callback = function(Value)
        currentWalkSpeed = Value
        if walkSpeedEnabled then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
   end,
})

local Input = CharacterTab:CreateInput({
   Name = "Quick WalkSpeed",
   PlaceholderText = "1-500",
   RemoveTextAfterFocusLost = true,
   Callback = function(Text)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = (Text)
   end,
})

-- JUMP POWER SECTION
local JumpSection = CharacterTab:CreateSection("Jump")

local currentJumpPower = 50
local jumpPowerEnabled = false

local JumpPowerToggle = CharacterTab:CreateToggle({
   Name = "Enable JumpPower Changer",
   CurrentValue = false,
   Flag = "JumpPowerEnable",
   Callback = function(Value)
        jumpPowerEnabled = Value
        if Value then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = currentJumpPower
        else
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
        end
   end,
})

local JumpPowerSlider = CharacterTab:CreateSlider({
   Name = "JumpPower Slider",
   Range = {1, 350},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "sliderjp",
   Callback = function(Value)
        currentJumpPower = Value
        if jumpPowerEnabled then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
   end,
})

-- CAMERA SECTION
local CameraSection = CharacterTab:CreateSection("Camera")

local fov_enabled = false
local fov_value = 70

local function updateFOV()
    local cam = workspace.CurrentCamera
    if cam then
        cam.FieldOfView = fov_enabled and fov_value or 70
    end
end

CharacterTab:CreateToggle({
   Name = "Custom FOV",
   CurrentValue = fov_enabled,
   Flag = "FOVEnabled",
   Callback = function(val)
       fov_enabled = val
       updateFOV()
   end,
})

CharacterTab:CreateSlider({
   Name = "FOV Value",
   Range = {1, 120},
   Increment = 1,
   Suffix = "°",
   CurrentValue = fov_value,
   Flag = "FOVSlider",
   Callback = function(val)
       fov_value = val
       updateFOV()
   end,
})

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
local AutofarmEnabled = false
local AutofarmType = "Teleport" -- "Teleport" or "Floating"
local ContinueOnDeath = false
local CollectHeight = 1 -- how many studs above coin to touch
local AutofarmSpeed = 5
local CoinCount = 0
local LastCoinPosition = nil

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
    Rayfield:Notify({
        Title = Title,
        Text = Text,
        Duration = Time or 5,
    })
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

-- Map positions - No longer needed, using spawn locations instead
-- local mapPositions = {
-- 	-- Example: ["MapName"] = Vector3.new(x, y, z)
-- 	-- Add your 30 maps here when you provide the positions
-- }

local function teleportToLobby()
	local player = Players.LocalPlayer
	if not player or not player.Character then return end
	local hrp = player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Find the Lobby model in Workspace
	local lobby = workspace:FindFirstChild("Lobby")
	if not lobby or not lobby:IsA("Model") then
		Rayfield:Notify({
			Title = "Lobby Not Found",
			Content = "Lobby model not found in Workspace.",
			Duration = 3,
			Image = 4483362458,
		})
		return
	end

	-- Find the Spawns folder inside Lobby
	local spawnsFolder = lobby:FindFirstChild("Spawns")
	if not spawnsFolder then
		Rayfield:Notify({
			Title = "Lobby Spawns Not Found",
			Content = "Spawns folder not found in Lobby.",
			Duration = 3,
			Image = 4483362458,
		})
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
		Rayfield:Notify({
			Title = "No Lobby Spawns",
			Content = "No SpawnLocations found in Lobby/Spawns.",
			Duration = 3,
			Image = 4483362458,
		})
		return
	end

	-- Pick random spawn and teleport
	local chosenSpawn = spawnPoints[math.random(1, #spawnPoints)]
	hrp.CFrame = chosenSpawn.CFrame + Vector3.new(0, 3, 0)

	Rayfield:Notify({
		Title = "Teleported",
		Content = "Teleported to Lobby spawn!",
		Duration = 2,
		Image = 4483362458,
	})
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
		Rayfield:Notify({
			Title = "Error",
			Content = "No known map found in Workspace",
			Duration = 3
		})
		return
	end

	-- Find its Spawns folder
	local spawnsFolder = map:FindFirstChild("Spawns")
	if not spawnsFolder then
		Rayfield:Notify({
			Title = "Error",
			Content = "Spawns folder not found in " .. map.Name,
			Duration = 3
		})
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
		Rayfield:Notify({
			Title = "Error",
			Content = "No spawn points found in " .. map.Name,
			Duration = 3
		})
		return
	end

	-- Pick random spawn and teleport
	local chosenSpawn = spawnPoints[math.random(1, #spawnPoints)]
	hrp.CFrame = chosenSpawn.CFrame + Vector3.new(0, 3, 0)

	Rayfield:Notify({
		Title = "Teleported",
		Content = "Teleported to " .. map.Name .. " spawn!",
		Duration = 2
	})
end
local function teleportToSecretPlace()
	local player = Players.LocalPlayer
	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		-- Teleport to secret place
		player.Character.HumanoidRootPart.CFrame = CFrame.new(319, 537, 89)
		Rayfield:Notify({
		   Title = "Teleported",
		   Content = "Teleported to Secret Place!",
		   Duration = 2,
		   Image = 4483362458,
		})
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

	for player, line in pairs(tracerLines) do
		if not TracersEnabled then
			line.Visible = false
			continue
		end
		
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
VisualTab:CreateSection("Sky Settings")

-- Stores the current applied sky
local currentSky

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

-- DROPDOWN: select main sky
local SkyDropdown = VisualTab:CreateDropdown({
    Name = "Select Sky",
    Options = {"Default", "Aesthetic", "Night", "MC", "Pink"},
    CurrentOption = {"Default"},
    Flag = "SkySelector",
    Callback = function(option)
        applySky(option[1])
    end
})

-- EFFECTS TOGGLES
local BlurEffect
local BloomEffect
local ColorCorrection

-- Blur toggle
VisualTab:CreateToggle({
    Name = "Enable Blur",
    CurrentValue = false,
    Flag = "SkyBlur",
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
VisualTab:CreateToggle({
    Name = "Enable Bloom",
    CurrentValue = false,
    Flag = "SkyBloom",
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
VisualTab:CreateToggle({
    Name = "Enable Color Correction",
    CurrentValue = false,
    Flag = "SkyColorCorrection",
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

local function handleBagFull()
    if not AutofarmEnabled then return end
    AutofarmEnabled = false
    farmStatus = "Bag full"
    updateAutofarmLabel()
    print("[HXN] Bag full detected, stopping autofarm...")
    task.wait(0.5)
    if TeleportOnComplete then
        teleportToLobby()
        Rayfield:Notify({
            Title = "Autofarm Complete",
            Content = "Bag full! Moving to lobby.",
            Duration = 3,
            Image = 4483362458,
        })
    else
        Rayfield:Notify({
            Title = "Autofarm Complete",
            Content = "Bag full! Autofarm stopped.",
            Duration = 3,
            Image = 4483362458,
        })
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
            AutofarmStatusLabel:Set(statusText)
        else
            AutofarmStatusLabel:Set("Autofarm is disabled. Waiting...")
        end
    end
end

-- fly helper used during autofarm
local flyConn = nil
local TeleportOnComplete = false
local postFarmAction = "Reset" -- options: Afk, End Round/Kill All, Reset

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
    elseif postFarmAction == "End Round/Kill All" then
        -- placeholder: implement game-specific behaviour here
        print("[HXN] Post-farm action: End Round/Kill All (not implemented)")
    elseif postFarmAction == "Reset" then
        plr:LoadCharacter()
    end
end

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
				part.Velocity = Vector3.new(0, 0, 0)
				part.RotVelocity = Vector3.new(0, 0, 0)
			end
		end
		
		-- Set humanoid properties for better noclip
		local hum = player.Character:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.PlatformStand = true  -- Prevents ground detection
			hum.Sit = false  -- Ensure not sitting
		end
	end
	
	-- Apply noclip initially
	applyNoclip()
	
	-- Reapply noclip every few seconds to ensure it sticks
	local noclipTask = task.spawn(function()
		while AutofarmEnabled do
			applyNoclip()
			task.wait(2)  -- Reapply every 2 seconds
		end
	end)
	table.insert(_G.HXN_TASKS, noclipTask)
	
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
		
		-- Farm until no coins left or bag full
		while AutofarmEnabled do
			-- refresh bag count each tick
			coinBag = getBagCount()
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
			
			-- Find closest coin
			local closestCoin = nil
			local closestDist = math.huge
			
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj.Name == "Coin" or obj.Name == "CoinVisual" then
					local coinPart = obj
					if obj.Name == "CoinVisual" then
						coinPart = obj:FindFirstChild("MainCoin") or obj:FindFirstChildWhichIsA("BasePart")
					end
					
					if coinPart then
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
			
			-- If coin found, move to it smoothly
			local coinPos = closestCoin.Position
			local targetPos = coinPos  -- Move directly to coin position

			-- prevent map-fall death while moving
			local oldFPDH = workspace.FallenPartsDestroyHeight
			workspace.FallenPartsDestroyHeight = -math.huge

			-- Disable fly during movement to prevent upward force
			disableFly()

			-- Float smoothly to coin (always use floating for smoothness)
			local moveSteps = 15
			local startPos = hrp.CFrame
			for i = 1, moveSteps do
				if not AutofarmEnabled then break end
				local alpha = i / moveSteps
				hrp.CFrame = startPos:Lerp(CFrame.new(targetPos), alpha)
				
				-- Damp velocity to prevent shaking
				for _, part in ipairs(player.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.Velocity = Vector3.new(0, 0, 0)
						part.RotVelocity = Vector3.new(0, 0, 0)
					end
				end
				task.wait(0.02)
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
		
		-- After farming loop (no coins left), reset character and wait for next round
		if AutofarmEnabled then
			farmStatus = "Resetting"
			updateAutofarmLabel()
			local plr = Players.LocalPlayer
			if plr then
				plr:LoadCharacter()
			end
			task.wait(1)  -- Brief wait after reset
		end
	end
	
	print("[HXN] Autofarm stopped")
	
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
AutofarmTab:CreateSection("Farm progress")
local AutofarmStatusLabel = AutofarmTab:CreateLabel("Autofarm is disabled. Waiting...")

AutofarmTab:CreateSection("Autofarm Settings")

-- type dropdown
autofarmTypeDropdown = AutofarmTab:CreateDropdown({
    Name = "Type of autofarm",
    Options = {"Teleport", "Floating"},
    CurrentOption = {AutofarmType},
    Flag = "AutofarmType",
    Callback = function(opt)
        AutofarmType = opt[1]
    end,
})

-- continue on death toggle
AutofarmTab:CreateToggle({
   Name = "Continuing farm, if you are killed",
   CurrentValue = ContinueOnDeath,
   Flag = "AutofarmContinue",
   Callback = function(v)
        ContinueOnDeath = v
   end,
})

-- collect-level slider
AutofarmTab:CreateSlider({
   Name = "Choose coin-collecting level",
   Range = {0.5, 5},
   Increment = 0.5,
   Suffix = "studs",
   CurrentValue = CollectHeight,
   Flag = "CollectHeight",
   Callback = function(v)
        CollectHeight = v
   end,
})

AutofarmTab:CreateSection("Autofarm Settings")

local AutofarmToggleUI = AutofarmTab:CreateToggle({
   Name = "Autofarm",
   CurrentValue = false,
   Flag = "AutofarmToggle",
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
		end
   end,
})

local AutofarmSpeedSlider = AutofarmTab:CreateSlider({
   Name = "Autofarm Speed",
   Range = {1, 20},
   Increment = 1,
   Suffix = "x",
   CurrentValue = 5,
   Flag = "AutofarmSpeed",
   Callback = function(Value)
		AutofarmSpeed = Value
   end,
})

-- post‑farm action selector
AutofarmTab:CreateDropdown({
   Name = "Action after farming",
   Options = {"Afk", "End Round/Kill All", "Reset"},
   CurrentOption = {postFarmAction},
   Flag = "PostFarmAction",
   Callback = function(opt)
       postFarmAction = opt[1]
   end,
})

-- optional teleport toggle
AutofarmTab:CreateToggle({
   Name = "Teleport to Lobby on 50",
   CurrentValue = TeleportOnComplete,
   Flag = "TeleportOnComplete",
   Callback = function(v)
		TeleportOnComplete = v
	end,
})

-- Autofarm is now called directly from the toggle UI above

--------------------------------------------------
-- DEBUG: COIN POSITION VERIFICATION
--------------------------------------------------

local DebugCoinButton = AutofarmTab:CreateButton({
   Name = "Debug: List All Coin Positions",
   Callback = function()
       print("[HXN] Listing all coin positions:")
       local coinCount = 0
       for _, obj in ipairs(workspace:GetDescendants()) do
           if obj.Name == "Coin" or obj.Name == "CoinVisual" then
               local coinPart = obj
               if obj.Name == "CoinVisual" then
                   coinPart = obj:FindFirstChild("MainCoin") or obj:FindFirstChildWhichIsA("BasePart")
               end
               
               if coinPart then
                   coinCount = coinCount + 1
                   print("  Coin " .. coinCount .. ": " .. tostring(coinPart.Position) .. " (obj: " .. obj.Name .. ")")
               end
           end
       end
       if coinCount == 0 then
           print("[HXN] No coins found!")
       else
           print("[HXN] Total coins: " .. coinCount)
       end
       
       Rayfield:Notify({
           Title = "Coin Debug",
           Content = "Check console (F9) for coin positions. Found: " .. coinCount,
           Duration = 3,
           Image = 4483362458,
       })
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
		Rayfield:Notify({
		   Title = "No Gun Found",
		   Content = "Gun not on the map.",
		   Duration = 2,
		   Image = 4483362458,
		})
		return
	end
	
	-- Save current position
	OriginalPosition = localPlayer.Character.HumanoidRootPart.CFrame
	
	-- Teleport to gun instantly
	localPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(gunPos + Vector3.new(0, 3, 0))
	IsAtGun = true
	
	Rayfield:Notify({
	   Title = "Teleported",
	   Content = "You are now at the gun!",
	   Duration = 1,
	   Image = 4483362458,
	})
	
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
					
					Rayfield:Notify({
					   Title = "Auto-Returned",
					   Content = "Returned to original position!",
					   Duration = 1,
					   Image = 4483362458,
					})
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
		Rayfield:Notify({
		   Title = "No Save",
		   Content = "No original position saved.",
		   Duration = 2,
		   Image = 4483362458,
		})
		return
	end
	
	-- Teleport back instantly
	localPlayer.Character.HumanoidRootPart.CFrame = OriginalPosition
	IsAtGun = false
	
	Rayfield:Notify({
	   Title = "Teleported",
	   Content = "You returned to your original position!",
	   Duration = 1,
	   Image = 4483362458,
	})
end

local UserInputService = game:GetService("UserInputService")

--------------------------------------------------
-- TELEPORT TAB UI
--------------------------------------------------

-- GUN TELEPORT SECTION
local GunTeleportSection = TeleportTab:CreateSection("Gun Teleport")

local GunTPToggle = TeleportTab:CreateToggle({
   Name = "Gun Teleport",
   CurrentValue = false,
   Flag = "GunTP",
   Callback = function(Value)
		GunTPEnabled = Value
   end,
})

local GunTPKeybindInput = TeleportTab:CreateInput({
   Name = "Gun TP Keybind",
   PlaceholderText = "G (default)",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
		local keyText = string.upper(Text)
		if keyText == "E" then
			GunTPKeybind = Enum.KeyCode.E
		elseif keyText == "R" then
			GunTPKeybind = Enum.KeyCode.R
		elseif keyText == "F" then
			GunTPKeybind = Enum.KeyCode.F
		elseif keyText == "Q" then
			GunTPKeybind = Enum.KeyCode.Q
		elseif keyText == "X" then
			GunTPKeybind = Enum.KeyCode.X
		elseif keyText == "G" then
			GunTPKeybind = Enum.KeyCode.G
		else
			GunTPKeybind = Enum.KeyCode.G -- default
		end
   end,
})

-- MAP TELEPORTS SECTION
local MapTeleportSection = TeleportTab:CreateSection("Map Teleports")

local LobbyTPButton = TeleportTab:CreateButton({
   Name = "TP To Lobby",
   Callback = function()
        teleportToLobby()
   end,
})

local MapTPButton = TeleportTab:CreateButton({
   Name = "TP To Map",
   Callback = function()
        teleportToMap()
   end,
})

local SecretTPButton = TeleportTab:CreateButton({
   Name = "TP To Secret Place",
   Callback = function()
        teleportToSecretPlace()
   end,
})

-- PLAYER TELEPORT SECTION
local PlayerTeleportSection = TeleportTab:CreateSection("Player Teleport")

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
		Rayfield:Notify({
		   Title = "Error",
		   Content = "Player not found or has no character.",
		   Duration = 2,
		   Image = 4483362458,
		})
		return
	end
	
	local localPlayer = Players.LocalPlayer
	if not localPlayer or not localPlayer.Character then return end
	
	local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	
	if not hrp or not targetHRP then
		Rayfield:Notify({
		   Title = "Error",
		   Content = "Could not find character parts.",
		   Duration = 2,
		   Image = 4483362458,
		})
		return
	end
	
	-- Teleport to player position
	hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
	
	Rayfield:Notify({
	   Title = "Teleported",
	   Content = "Teleported to " .. playerName .. "!",
	   Duration = 1,
	   Image = 4483362458,
	})
end

-- Player selection dropdown for teleport
local PlayerTPDropdown = TeleportTab:CreateDropdown({
   Name = "Select Player to TP",
   Options = GetPlayerList(),
   CurrentOption = {"None"},
   MultipleOptions = false,
   Flag = "PlayerTPSelect",
   Callback = function(Options)
       SelectedTPPlayer = Options[1]
   end,
})

-- Refresh dropdown when players join/leave
local function RefreshPlayerTPDropdown()
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
table.insert(_G.HXN_CONNECTIONS, playerRemovingTPConn)

-- Teleport to Player Button
local TPToPlayerButton = TeleportTab:CreateButton({
   Name = "TP to Selected Player",
   Callback = function()
       if not SelectedTPPlayer or SelectedTPPlayer == "None" then
           Rayfield:Notify({
               Title = "Error",
               Content = "Please select a player first!",
               Duration = 2,
               Image = 4483362458,
           })
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
--------------------------------------------------
-- TROLLING TAB UI - FLING CONTROLS
--------------------------------------------------

-- FLING TARGET SECTION
local FlingTargetSection = TrollingTab:CreateSection("Select Target")

-- Player selection dropdown for fling
local FlingPlayerDropdown = TrollingTab:CreateDropdown({
   Name = "Select Player",
   Options = GetPlayerList(),
   CurrentOption = {"None"},
   MultipleOptions = false,
   Flag = "FlingPlayerSelect",
   Callback = function(Options)
       SelectedFlingTarget = Options[1]
   end,
})

-- Refresh dropdown when players join/leave
local function RefreshFlingDropdown()
    FlingPlayerDropdown:Refresh(GetPlayerList(), true)
end

-- Connect to player events to update dropdown
local playerAddedConn = Players.PlayerAdded:Connect(function(player)
    RefreshFlingDropdown()
end)
table.insert(_G.HXN_CONNECTIONS, playerAddedConn)

local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
    if SelectedFlingTarget == player.Name then
        SelectedFlingTarget = nil
    end
    RefreshFlingDropdown()
end)
table.insert(_G.HXN_CONNECTIONS, playerRemovingConn)

-- FLING CONTROLS SECTION
local FlingControlsSection = TrollingTab:CreateSection("Fling Controls")

-- Start Flinging Button
local StartFlingButton = TrollingTab:CreateButton({
   Name = "Start Flinging",
   Callback = function()
       StartFling()
   end,
})

-- Stop Flinging Button
local StopFlingButton = TrollingTab:CreateButton({
   Name = "Stop Flinging",
   Callback = function()
       StopFling()
   end,
})

-- FLING BY ROLE SECTION
local FlingRoleSection = TrollingTab:CreateSection("Fling by Role")

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
        Rayfield:Notify({
            Title = "Error",
            Content = "No " .. role .. " found to fling!",
            Duration = 2,
            Image = 4483345998,
        })
    end
end

-- fling specific roles
local FlingMurdererButton = TrollingTab:CreateButton({
   Name = "Fling Murderer",
   Callback = function()
       flingRole("Murderer")
   end,
})

local FlingSheriffButton = TrollingTab:CreateButton({
   Name = "Fling Sheriff",
   Callback = function()
       flingRole("Sheriff")
   end,
})

-- FLING ALL SECTION
local FlingAllSection = TrollingTab:CreateSection("Fling All")

-- Fling All Button
local FlingAllButton = TrollingTab:CreateButton({
   Name = "Fling All Players",
   Callback = function()
       FlingAll()
   end,
})

--------------------------------------------------
-- ESP TAB UI
--------------------------------------------------

local ESPMainToggle = ESPTab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
		ESPEnabled = Value
   end,
})

ESPTab:CreateSection("ESP Options")

local ESPNamesToggle = ESPTab:CreateToggle({
   Name = "ESP Names",
   CurrentValue = false,
   Flag = "ESPNames",
   Callback = function(Value)
		ESPNamesEnabled = Value
		NameTagsEnabled = Value
   end,
})

-- DROPPED ITEMS SECTION
local DroppedItemsSection = ESPTab:CreateSection("Dropped Items")

local ESPDroppedGunToggle = ESPTab:CreateToggle({
   Name = "ESP Dropped GunDrop",
   CurrentValue = false,
   Flag = "ESPDroppedGun",
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

local ShowCoinsToggle = ESPTab:CreateToggle({
   Name = "Show coins",
   CurrentValue = false,
   Flag = "ShowCoins",
   Callback = function(Value)
		ShowCoinsEnabled = Value
   end,
})

local ShowKnifeToggle = ESPTab:CreateToggle({
   Name = "Show thrown knife (StuckKnife)",
   CurrentValue = false,
   Flag = "ShowKnife",
   Callback = function(Value)
		ShowThrownKnifeEnabled = Value
   end,
})

-- DISPLAY MODE SECTION
local DisplayModeSection = ESPTab:CreateSection("Display Mode")

local ESPModeDropdown = ESPTab:CreateDropdown({
   Name = "ESP Mode",
   Options = {"Highlight", "Chams", "Box"},
   CurrentOption = {"Highlight"},
   Flag = "ESPMode",
   Callback = function(Option)
		ESPModeType = Option[1]
   end,
})

-- ROLE ESP SECTION
ESPTab:CreateSection("Role ESP")

local InnocentToggle = ESPTab:CreateToggle({
   Name = "Innocent ESP",
   CurrentValue = true,
   Flag = "InnocentESP",
   Callback = function(Value)
		InnocentESPEnabled = Value
   end,
})

local SheriffToggle = ESPTab:CreateToggle({
   Name = "Sheriff ESP",
   CurrentValue = true,
   Flag = "SheriffESP",
   Callback = function(Value)
		SheriffESPEnabled = Value
   end,
})

local MurdererToggle = ESPTab:CreateToggle({
   Name = "Murderer ESP",
   CurrentValue = true,
   Flag = "MurdererESP",
   Callback = function(Value)
		MurdererESPEnabled = Value
   end,
})

local TracersToggle = ESPTab:CreateToggle({
   Name = "Player Tracers",
   CurrentValue = false,
   Flag = "TracersESP",
   Callback = function(Value)
        TracersEnabled = Value
   end,
})

--------------------------------------------------
-- AUTOFARM TAB UI - COIN COUNTER
--------------------------------------------------

-- Display coin counter
AutofarmTab:CreateSection("Coin Counter")
local CoinCounterLabel = AutofarmTab:CreateLabel("Coins Collected: 0/50")

-- Update coin counter label every frame (show bag count)
local coinCounterTaskId = task.spawn(function()
	while true do
		task.wait(0.1)
		coinBag = getBagCount()
		CoinCounterLabel:Set("Coins Collected: " .. coinBag .. "/50")
	end
end)
table.insert(_G.HXN_TASKS, coinCounterTaskId)

print("[HXN] Script fully loaded and ready to use!")

