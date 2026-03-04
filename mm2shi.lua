local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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
   KeySystem = flase, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("🏠 Home", nil) -- Title, Image
local MainSection = MainTab:CreateSection("Main")

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
      end
   },
},
})

local Button = MainTab:CreateButton({
   Name = "Infinite Jump Toggle",
   Callback = function()
       --Toggles the infinite jump between on or off on every script run
_G.infinjump = not _G.infinjump

if _G.infinJumpStarted == nil then
	--Ensures this only runs once to save resources
	_G.infinJumpStarted = true
	
	--Notifies readiness
	game.StarterGui:SetCore("SendNotification", {Title="Youtube Hub"; Text="Infinite Jump Activated!"; Duration=5;})

	--The actual infinite jump
	local plr = game:GetService('Players').LocalPlayer
	local m = plr:GetMouse()
	m.KeyDown:connect(function(k)
		if _G.infinjump then
			if k:byte() == 32 kkthen
			humanoid = game:GetService'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
			humanoid:ChangeState('Jumping')
			wait()
			humanoid:ChangeState('Seated')
			end
		end
	end)
end
   end,
})

local Slider = MainTab:CreateSlider({
   Name = "WalkSpeed Slider",
   Range = {1, 350},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "sliderws", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = (Value)
   end,
})

local Slider = MainTab:CreateSlider({
   Name = "JumpPower Slider",
   Range = {1, 350},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "sliderjp", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = (Value)
   end,
})

local Dropdown = MainTab:CreateDropdown({
   Name = "Select Area",
   Options = {"Starter World","Pirate Island","Pineapple Paradise"},
   CurrentOption = {"Starter World"},
   MultipleOptions = false,
   Flag = "dropdownarea", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Option)
        print(Option)
   end,
})

local Input = MainTab:CreateInput({
   Name = "Walkspeed",
   PlaceholderText = "1-500",
   RemoveTextAfterFocusLost = true,
   Callback = function(Text)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = (Text)
   end,
})

local OtherSection = MainTab:CreateSection("Other")

--// SERVICES
local Players = game:GetService("Players")

--// SETTINGS
local OTHER_PLAYER_COLOR = Color3.fromRGB(0,170,255)
local LOCAL_PLAYER_COLOR = Color3.fromRGB(0,255,100)
local MURDERER_COLOR = Color3.fromRGB(255,0,0)
local SHERIFF_COLOR = Color3.fromRGB(0,0,255)

local FILL_TRANSPARENCY = 0.5
local OUTLINE_TRANSPARENCY = 0
local CHECK_INTERVAL = 0.5

--// STATES
local ESPEnabled = false
local NameTagsEnabled = false

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
	
	-- HIGHLIGHT
	local highlight = character:FindFirstChild("PlayerHighlight")
	if not highlight then
		highlight = Instance.new("Highlight")
		highlight.Name = "PlayerHighlight"
		highlight.FillTransparency = FILL_TRANSPARENCY
		highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.Parent = character
	end
	
	highlight.Enabled = ESPEnabled
	
	if player == Players.LocalPlayer then
		highlight.FillColor = LOCAL_PLAYER_COLOR
	else
		local role = getRole(player)
		if role == "Murderer" then
			highlight.FillColor = MURDERER_COLOR
		elseif role == "Sheriff" then
			highlight.FillColor = SHERIFF_COLOR
		else
			highlight.FillColor = OTHER_PLAYER_COLOR
		end
	end
	
	-- NAMETAG
	local tag = character:FindFirstChild("NameTag")
	
	if not NameTagsEnabled then
		if tag then tag:Destroy() end
	else
		if not tag then
			local head = character:WaitForChild("Head")
			
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

--------------------------------------------------
-- LOOP
--------------------------------------------------

local function startTracking(player)
	player.CharacterAdded:Connect(function()
		task.wait(0.2)
		updatePlayer(player)
	end)
	
	task.spawn(function()
		while true do
			updatePlayer(player)
			task.wait(CHECK_INTERVAL)
		end
	end)
end

for _, player in ipairs(Players:GetPlayers()) do
	startTracking(player)
end

Players.PlayerAdded:Connect(startTracking)

--------------------------------------------------
-- YOUR TOGGLE (WORKS 100%)
--------------------------------------------------

local Toggle = MainTab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Flag = "Toggle1",
   Callback = function(Value)
		ESPEnabled = Value
		NameTagsEnabled = Value
   end,
})

local TPTab = Window:CreateTab("🏝 Teleports", nil) -- Title, Image

local Button1 = TPTab:CreateButton({
   Name = "Starter Island",
   Callback = function()
        --Teleport1
   end,
})

local Button2 = TPTab:CreateButton({
   Name = "Pirate Island",
   Callback = function()
        --Teleport2
   end,
})

local Button3 = TPTab:CreateButton({
   Name = "Pineapple Paradise",
   Callback = function()
        --Teleport3
   end,
})

local TPTab = Window:CreateTab("🎲 Misc", nil) -- Title, Image
