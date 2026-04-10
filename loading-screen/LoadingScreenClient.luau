--[[
    LOADING SCREEN CLIENT SCRIPT - ORBITAL CAMERA
    Lokasi: ReplicatedFirst > LoadingScreen > LoadingScreenClient
    Tipe: LocalScript
    
    FITUR:
    - ? Kamera mengelilingi player (orbit animation)
    - ? Dimulai dari depan player, naik ke atas, berputar mengelilingi
    - ? Outro: kamera kembali ke hadapan player
    - ? Tidak ada CamPoint lagi - lebih simpel!
    - ? Tidak konflik dengan custom backpack
    - ? Player TIDAK di-freeze - hanya kontrol gerakan yang dinonaktifkan
    - ? Animasi idle/breathing player tetap berjalan natural
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

-- ========================================
-- LOAD CONFIG
-- ========================================
local Config = require(script.Parent:WaitForChild("LoadingScreenConfig"))

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ========================================
-- VARIABLES
-- ========================================
local isLoading = true
local loadingProgress = 0

-- Orbital camera variables
local orbitAngle = 0
local orbitHeight = Config.ORBIT_HEIGHT_START
local orbitDistance = Config.ORBIT_DISTANCE
local orbitSpeed = Config.ORBIT_SPEED
local isOrbiting = false

-- UI Elements
local loadingGui = nil
local progressBarFill = nil
local progressText = nil
local loadingText = nil
local backgroundFrame = nil
local skipButton = nil
local fadeFrame = nil
local spinnerImage = nil
local communityLogo = nil        -- 🎨 LOGO KOMUNITAS DITAMBAHKAN DI SINI
local backgroundImage = nil      -- 🎨 BACKGROUND IMAGE (OPTIONAL)

local skipButtonShown = false
local cameraLocked = false

-- Blur and GUI hiding
local blurEffect = nil
local hiddenCoreGuis = {}
local hiddenPlayerGuis = {}

-- Player control variables
local controlsDisabled = false

-- ========================================
-- UTILITY FUNCTIONS
-- ========================================

local function debugPrint(message)
	if Config.DEBUG_MODE then
		print(message)
	end
end

local function verbosePrint(message)
	if Config.VERBOSE_LOGS then
		print(message)
	end
end

-- ========================================
-- GUI HIDING FUNCTIONS
-- ========================================

local function hideAllGuis()
	debugPrint("?? Hiding all GUIs (except Backpack)...")

	-- Hide CoreGuis except Backpack
	local coreGuiTypes = {
		Enum.CoreGuiType.PlayerList,
		Enum.CoreGuiType.Health,
		Enum.CoreGuiType.Chat,
		Enum.CoreGuiType.EmotesMenu,
	}

	for _, guiType in ipairs(coreGuiTypes) do
		pcall(function()
			local isEnabled = StarterGui:GetCoreGuiEnabled(guiType)
			hiddenCoreGuis[guiType] = isEnabled
			if isEnabled then
				StarterGui:SetCoreGuiEnabled(guiType, false)
			end
		end)
	end

	-- Hide TopBar
	pcall(function()
		local topBarEnabled = StarterGui:GetCore("TopbarEnabled")
		hiddenCoreGuis["TopbarEnabled"] = topBarEnabled
		StarterGui:SetCore("TopbarEnabled", false)
	end)

	-- Disable chat
	pcall(function()
		local chatActive = StarterGui:GetCore("ChatActive")
		hiddenCoreGuis["ChatActive"] = chatActive
		StarterGui:SetCore("ChatActive", false)
	end)

	-- Hide PlayerGuis
	local playerGui = player:WaitForChild("PlayerGui", 5)
	if playerGui then
		for _, gui in pairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") and gui.Enabled then
				local isLoadingGui = gui.Name == "LoadingGui" 
					or gui.Name == "ScreenGui" 
					or gui == loadingGui

				if not isLoadingGui then
					table.insert(hiddenPlayerGuis, gui)
					gui.Enabled = false
				end
			end
		end

		-- Monitor new GUIs
		playerGui.ChildAdded:Connect(function(gui)
			if not isLoading then return end

			if gui:IsA("ScreenGui") then
				task.wait(0.05)

				local isLoadingGui = gui.Name == "LoadingGui" 
					or gui.Name == "ScreenGui" 
					or gui == loadingGui

				if not isLoadingGui and gui.Enabled then
					table.insert(hiddenPlayerGuis, gui)
					gui.Enabled = false
				end
			end
		end)
	end

	debugPrint("? All GUIs hidden (Backpack preserved)")
end

local function showAllGuis()
	debugPrint("??? Restoring all GUIs...")

	-- Restore CoreGuis
	for guiType, wasEnabled in pairs(hiddenCoreGuis) do
		pcall(function()
			if guiType == "TopbarEnabled" then
				StarterGui:SetCore("TopbarEnabled", wasEnabled)
			elseif guiType == "ChatActive" then
				StarterGui:SetCore("ChatActive", wasEnabled)
			else
				StarterGui:SetCoreGuiEnabled(guiType, wasEnabled)
			end
		end)
	end

	-- Restore PlayerGuis
	for _, gui in pairs(hiddenPlayerGuis) do
		if gui and gui.Parent then
			gui.Enabled = true
		end
	end

	-- Force enable critical GUIs (except Backpack)
	task.wait(0.2)
	pcall(function()
		StarterGui:SetCore("TopbarEnabled", true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	end)

	hiddenCoreGuis = {}
	hiddenPlayerGuis = {}

	debugPrint("? All GUIs restored")
end

-- ========================================
-- ?? PLAYER CONTROL FUNCTIONS (SIMPLIFIED)
-- ========================================

local function disablePlayerControls()
	if not Config.DISABLE_PLAYER_MOVEMENT then
		return
	end

	debugPrint("?? Disabling player controls (WASD/Analog only)...")

	-- ? METHOD 1: Disable PlayerModule Controls
	pcall(function()
		local Controls = require(player.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
		Controls:Disable()
		controlsDisabled = true
		debugPrint("  ? PlayerModule controls disabled")
	end)

	-- ? METHOD 2: Disable ContextActionService controls (WASD + Jump)
	local ContextActionService = game:GetService("ContextActionService")
	pcall(function()
		ContextActionService:BindAction("DisableMovement", function() 
			return Enum.ContextActionResult.Sink 
		end, false, 
		Enum.PlayerActions.CharacterForward,
		Enum.PlayerActions.CharacterBackward,
		Enum.PlayerActions.CharacterLeft,
		Enum.PlayerActions.CharacterRight,
		Enum.PlayerActions.CharacterJump
		)
		debugPrint("  ? WASD + Jump controls disabled")
	end)

	debugPrint("? Movement controls disabled! (Player can still animate)")
end

local function enablePlayerControls()
	if not controlsDisabled then
		return
	end

	debugPrint("? Enabling player controls...")

	-- Re-enable PlayerModule
	pcall(function()
		local Controls = require(player.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
		Controls:Enable()
		debugPrint("  ? PlayerModule controls enabled")
	end)

	-- Unbind ContextActionService
	local ContextActionService = game:GetService("ContextActionService")
	pcall(function()
		ContextActionService:UnbindAction("DisableMovement")
		debugPrint("  ? WASD controls enabled")
	end)

	controlsDisabled = false
	debugPrint("? Player controls enabled!")
end

-- ========================================
-- SKIP BUTTON FUNCTIONS
-- ========================================

local function onSkipButtonClicked()
	debugPrint("?? Skip button clicked!")

	if skipButton then
		skipButton.Active = false
		skipButton.Visible = false
	end

	stopLoadingScreen()
end

local function showSkipButton()
	if not skipButton or not skipButton.Parent or skipButtonShown then
		return
	end

	debugPrint("?? Showing skip button...")
	skipButtonShown = true

	skipButton.Visible = true

	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	if skipButton.BackgroundTransparency then
		TweenService:Create(skipButton, tweenInfo, {
			BackgroundTransparency = 0.3
		}):Play()
	end

	local textLabel = skipButton:FindFirstChild("TextLabel") or skipButton:FindFirstChildOfClass("TextLabel")
	if textLabel then
		TweenService:Create(textLabel, tweenInfo, {
			TextTransparency = 0
		}):Play()
	end

	local imageLabel = skipButton:FindFirstChild("ImageLabel") or skipButton:FindFirstChildOfClass("ImageLabel")
	if imageLabel then
		TweenService:Create(imageLabel, tweenInfo, {
			ImageTransparency = 0
		}):Play()
	end
end

-- ========================================
-- PROGRESS BAR FUNCTIONS
-- ========================================

local function updateProgressBar(progress)
	if progressBarFill and progressBarFill.Parent then
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(
			progressBarFill,
			tweenInfo,
			{Size = UDim2.new(progress, 0, 1, 0)}
		)
		tween:Play()
	end

	if progressText and progressText.Parent and Config.SHOW_PERCENTAGE then
		progressText.Text = math.floor(progress * 100) .. "%"
	end

	if Config.SKIP_BUTTON_ENABLED and progress >= Config.SKIP_BUTTON_THRESHOLD and not skipButtonShown then
		showSkipButton()
	end
end

local function simulateProgress()
	local messageIndex = 1
	local lastMessageChange = tick()

	for i, stage in ipairs(Config.PROGRESS_STAGES) do
		if not isLoading then break end

		local stageDuration = Config.MIN_LOADING_TIME * stage.percent
		local stageStart = tick()
		local startProgress = loadingProgress

		while tick() - stageStart < stageDuration and isLoading do
			local alpha = (tick() - stageStart) / stageDuration
			loadingProgress = startProgress + (stage.target - startProgress) * alpha
			updateProgressBar(loadingProgress)

			if tick() - lastMessageChange >= Config.MESSAGE_CHANGE_INTERVAL then
				if loadingText and loadingText.Parent then
					messageIndex = (messageIndex % #Config.LOADING_MESSAGES) + 1
					loadingText.Text = Config.LOADING_MESSAGES[messageIndex]
				end
				lastMessageChange = tick()
			end

			task.wait(0.05)
		end

		loadingProgress = stage.target
		updateProgressBar(loadingProgress)
	end

	if loadingText and loadingText.Parent then
		loadingText.Text = "Ready!"
	end
end

-- ========================================
-- ?? ORBITAL CAMERA FUNCTIONS
-- ========================================

local function getPlayerHeadPosition()
	local character = player.Character
	if not character then return nil end

	local head = character:FindFirstChild("Head")
	if not head then return nil end

	return head.Position
end

local function getPlayerLookVector()
	local character = player.Character
	if not character then return Vector3.new(0, 0, -1) end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return Vector3.new(0, 0, -1) end

	return hrp.CFrame.LookVector
end

local function calculateOrbitCamera(angle, height, distance)
	local playerPos = getPlayerHeadPosition()
	if not playerPos then
		return camera.CFrame
	end

	-- Calculate camera position in orbit
	local x = math.cos(math.rad(angle)) * distance
	local z = math.sin(math.rad(angle)) * distance

	local cameraPos = playerPos + Vector3.new(x, height, z)
	local lookAtPos = playerPos + Vector3.new(0, height * 0.5, 0)

	return CFrame.lookAt(cameraPos, lookAtPos)
end

local function playIntroAnimation()
	if not Config.INTRO_ENABLED then
		return
	end

	debugPrint("?? Playing intro animation...")

	local character = player.Character
	if not character then
		warn("?? No character for intro")
		return
	end

	task.wait(0.5)

	local playerPos = getPlayerHeadPosition()
	local lookVector = getPlayerLookVector()

	if not playerPos then
		warn("?? Can't get player position")
		return
	end

	-- Start position: in front of player
	local startDistance = Config.INTRO_DISTANCE_START
	local startPos = playerPos + (lookVector * startDistance) + Vector3.new(0, Config.INTRO_HEIGHT_START, 0)
	local startCFrame = CFrame.lookAt(startPos, playerPos + Vector3.new(0, 1, 0))

	camera.CFrame = startCFrame
	debugPrint("?? Intro start: front of player")

	-- End position: higher and slightly back
	local endDistance = Config.INTRO_DISTANCE_END
	local endHeight = Config.INTRO_HEIGHT_END
	local endPos = playerPos + (lookVector * endDistance) + Vector3.new(0, endHeight, 0)
	local endCFrame = CFrame.lookAt(endPos, playerPos + Vector3.new(0, endHeight * 0.5, 0))

	local tweenInfo = TweenInfo.new(
		Config.INTRO_DURATION,
		Config.INTRO_EASE_STYLE,
		Config.INTRO_EASE_DIRECTION
	)

	local tween = TweenService:Create(camera, tweenInfo, {CFrame = endCFrame})
	tween:Play()

	debugPrint("?? Intro: Camera moving up and back...")
	tween.Completed:Wait()

	debugPrint("? Intro complete!")

	-- Set initial orbit angle (start from front)
	orbitAngle = 0 -- 0 degrees = front of player
	orbitHeight = endHeight
end

local function startOrbitAnimation()
	debugPrint("?? Starting orbit animation...")

	isOrbiting = true

	-- Get initial player look direction to align orbit
	local lookVector = getPlayerLookVector()
	local initialAngle = math.deg(math.atan2(lookVector.Z, lookVector.X))
	orbitAngle = initialAngle

	debugPrint("?? Orbit started at angle: " .. math.floor(orbitAngle) .. "�")

	-- Animate height change if configured
	if Config.ORBIT_HEIGHT_ANIMATION then
		task.spawn(function()
			local heightStart = orbitHeight
			local heightEnd = Config.ORBIT_HEIGHT_END
			local duration = Config.ORBIT_HEIGHT_DURATION
			local startTime = tick()

			while isOrbiting and isLoading do
				local elapsed = tick() - startTime
				local alpha = math.min(elapsed / duration, 1)

				orbitHeight = heightStart + (heightEnd - heightStart) * alpha

				if alpha >= 1 then break end
				task.wait()
			end
		end)
	end

	-- Main orbit loop
	while isLoading and isOrbiting do
		local deltaTime = RunService.RenderStepped:Wait()

		-- Increment angle
		orbitAngle = orbitAngle + (orbitSpeed * deltaTime)

		-- Keep angle in range
		if orbitAngle >= 360 then
			orbitAngle = orbitAngle - 360
			debugPrint("?? Orbit completed full circle!")
		end

		-- Update camera position
		local newCFrame = calculateOrbitCamera(orbitAngle, orbitHeight, orbitDistance)
		camera.CFrame = newCFrame
	end

	debugPrint("?? Orbit animation stopped")
end

local function playOutroAnimation()
	if not Config.OUTRO_ENABLED then
		return
	end

	debugPrint("?? Playing outro animation...")

	local character = player.Character
	if not character then
		warn("?? No character for outro")
		return
	end

	isOrbiting = false
	task.wait(0.2)

	local playerPos = getPlayerHeadPosition()
	local lookVector = getPlayerLookVector()

	if not playerPos then
		warn("?? Can't get player position for outro")
		return
	end

	-- Start position: JAUH dari player (dari atas dan jauh)
	local startDistance = Config.OUTRO_DISTANCE_START
	local startHeight = Config.OUTRO_HEIGHT_START
	local startPos = playerPos + (lookVector * startDistance) + Vector3.new(0, startHeight, 0)
	local startCFrame = CFrame.lookAt(startPos, playerPos + Vector3.new(0, startHeight * 0.3, 0))

	camera.CFrame = startCFrame
	debugPrint("?? Outro start: " .. startDistance .. " studs away, " .. startHeight .. " studs high")

	-- End position: in front of player at eye level
	local endDistance = Config.OUTRO_DISTANCE_END
	local endHeight = Config.OUTRO_HEIGHT_END
	local endPos = playerPos + (lookVector * endDistance) + Vector3.new(0, endHeight, 0)
	local endCFrame = CFrame.lookAt(endPos, playerPos + Vector3.new(0, 1, 0))

	debugPrint("?? Outro: Camera walking towards player...")

	local tweenInfo = TweenInfo.new(
		Config.OUTRO_DURATION,
		Config.OUTRO_EASE_STYLE,
		Config.OUTRO_EASE_DIRECTION
	)

	local tween = TweenService:Create(camera, tweenInfo, {CFrame = endCFrame})
	tween:Play()
	tween.Completed:Wait()

	debugPrint("? Outro complete!")
	debugPrint("?? Outro end: " .. endDistance .. " studs from player")
end

-- ========================================
-- UI SETUP
-- ========================================

local function setupLoadingUI()
	debugPrint("?? Setting up loading UI...")

	loadingGui = script.Parent:FindFirstChild("ScreenGui") or script.Parent:FindFirstChild("LoadingGui")

	if not loadingGui then
		warn("? ScreenGui not found!")
		return false
	end

	loadingGui.ResetOnSpawn = false
	loadingGui.Enabled = true

	if loadingGui.Parent ~= player:WaitForChild("PlayerGui") then
		loadingGui.Parent = player:WaitForChild("PlayerGui")
	end

	-- Add blur effect
	blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "LoadingBlur"
	blurEffect.Size = Config.BLUR_SIZE or 24
	blurEffect.Parent = camera
	debugPrint("? Blur effect added")

	if Config.START_WITH_BLACK then
		fadeFrame = Instance.new("Frame")
		fadeFrame.Name = "FadeFrame"
		fadeFrame.Size = UDim2.new(1, 0, 1, 0)
		fadeFrame.Position = UDim2.new(0, 0, 0, 0)
		fadeFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		fadeFrame.BackgroundTransparency = 0
		fadeFrame.BorderSizePixel = 0
		fadeFrame.ZIndex = 1000
		fadeFrame.Parent = loadingGui
	end

	backgroundFrame = loadingGui:FindFirstChild("BackgroundFrame")
	if not backgroundFrame then
		warn("? BackgroundFrame not found!")
		return false
	end

	if Config.TRANSPARENT_BACKGROUND then
		backgroundFrame.BackgroundTransparency = 1
	end

	backgroundFrame.Visible = true

	loadingText = backgroundFrame:FindFirstChild("LoadingText")
	if loadingText then
		loadingText.Visible = true
	end

	progressText = backgroundFrame:FindFirstChild("ProgressText")
	if progressText then
		progressText.Visible = true
	end

	local progressContainer = backgroundFrame:FindFirstChild("ProgressBarContainer")
	if progressContainer then
		progressContainer.Visible = true

		progressBarFill = progressContainer:FindFirstChild("ProgressBarFill")
		if progressBarFill then
			progressBarFill.Size = UDim2.new(0, 0, 1, 0)
			progressBarFill.Visible = true

			spinnerImage = progressContainer:FindFirstChild("ImageLabel")
			if spinnerImage and Config.SPINNER_ENABLED then
				spinnerImage.Parent = progressBarFill
				spinnerImage.AnchorPoint = Vector2.new(0.5, 0.5)
				spinnerImage.Position = UDim2.new(1, 0, 0.5, 0)
				spinnerImage.Visible = true
				spinnerImage.Rotation = 0
			end
		end
	end

	skipButton = backgroundFrame:FindFirstChild("SkipButton")
	if skipButton and Config.SKIP_BUTTON_ENABLED then
		skipButton.Visible = false

		if skipButton.BackgroundTransparency then
			skipButton.BackgroundTransparency = 1
		end

		local textLabel = skipButton:FindFirstChild("TextLabel") or skipButton:FindFirstChildOfClass("TextLabel")
		if textLabel then
			textLabel.TextTransparency = 1
		end

		local imageLabel = skipButton:FindFirstChild("ImageLabel") or skipButton:FindFirstChildOfClass("ImageLabel")
		if imageLabel then
			imageLabel.ImageTransparency = 1
		end

		skipButton.Activated:Connect(onSkipButtonClicked)

	end

	-- ========================================
	-- 🎨 SETUP COMMUNITY LOGO
	-- ========================================
	if Config.SHOW_COMMUNITY_LOGO and Config.COMMUNITY_LOGO_IMAGE_ID ~= "" then
		-- 🎯 PARENT SELALU KE loadingGui (bukan backgroundFrame) agar terlihat!
		communityLogo = Instance.new("ImageLabel")
		communityLogo.Name = "CommunityLogo"
		communityLogo.Image = Config.COMMUNITY_LOGO_IMAGE_ID
		communityLogo.Size = Config.LOGO_SIZE
		communityLogo.AnchorPoint = Vector2.new(0.5, 0.5)  -- Center anchor
		communityLogo.Position = Config.LOGO_POSITION
		communityLogo.BackgroundTransparency = 1
		communityLogo.BorderSizePixel = 0
		communityLogo.ZIndex = 2000  -- 🔼 SANGAT TINGGI - di atas semuanya!
		communityLogo.Rotation = Config.LOGO_ROTATION
		communityLogo.ScaleType = Enum.ScaleType.Fit  -- Mode: Fit (maintain aspect ratio)
		communityLogo.Visible = true  -- 🔍 Explicitly set visible
		
		-- Optional: Add rounded corner
		if Config.LOGO_CORNER_RADIUS > 0 then
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, Config.LOGO_CORNER_RADIUS)
			corner.Parent = communityLogo
		end
		
		-- 🎯 PARENT KE loadingGui (terpastikan terlihat)
		communityLogo.Parent = loadingGui
		
		-- 🔍 DEBUGGING - Print detail untuk troubleshoot
		debugPrint("=" .. string.rep("=", 48) .. "=")
		debugPrint("✅ COMMUNITY LOGO SETUP COMPLETE")
		debugPrint("  Image ID: " .. Config.COMMUNITY_LOGO_IMAGE_ID)
		debugPrint("  Parent: " .. loadingGui.Name .. " (Type: " .. loadingGui.ClassName .. ")")
		debugPrint("  Position: " .. tostring(Config.LOGO_POSITION))
		debugPrint("  Size: " .. tostring(Config.LOGO_SIZE))
		debugPrint("  ZIndex: 2000")
		debugPrint("  Visible: " .. tostring(communityLogo.Visible))
		debugPrint("  Transparency: " .. tostring(communityLogo.BackgroundTransparency))
		debugPrint("  LoadingGui Enabled: " .. tostring(loadingGui.Enabled))
		debugPrint("  LoadingGui Visible: " .. tostring(loadingGui.Visible))
		debugPrint("=" .. string.rep("=", 48) .. "=")
	end

	-- ========================================
	-- 🎨 SETUP BACKGROUND IMAGE (OPTIONAL)
	-- ========================================
	if Config.SHOW_BACKGROUND_IMAGE and Config.BACKGROUND_IMAGE_ID ~= "" then
		backgroundImage = Instance.new("ImageLabel")
		backgroundImage.Name = "BackgroundImage"
		backgroundImage.Image = Config.BACKGROUND_IMAGE_ID
		backgroundImage.Size = UDim2.new(1, 0, 1, 0)
		backgroundImage.Position = UDim2.new(0, 0, 0, 0)
		backgroundImage.BackgroundTransparency = 1
		backgroundImage.BorderSizePixel = 0
		backgroundImage.ZIndex = 1  -- Background layer
		backgroundImage.ImageTransparency = Config.BACKGROUND_IMAGE_TRANSPARENCY
		backgroundImage.ScaleType = Enum.ScaleType.Stretch  -- Stretch atau Tile
		backgroundImage.Parent = loadingGui
		debugPrint("? Background image added")
	end

	debugPrint("? UI setup complete")
	return true
end

-- ========================================
-- FADE IN EFFECT
-- ========================================

local function fadeInFromBlack()
	if not fadeFrame or not Config.START_WITH_BLACK then
		return
	end

	debugPrint("?? Fading in from black...")

	local tweenInfo = TweenInfo.new(Config.FADE_IN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(fadeFrame, tweenInfo, {
		BackgroundTransparency = 1
	})

	tween:Play()
	tween.Completed:Wait()

	fadeFrame:Destroy()
	fadeFrame = nil

	debugPrint("? Fade in complete!")
end

-- ========================================
-- STOP LOADING
-- ========================================

function stopLoadingScreen()
	debugPrint("? Loading complete!")

	isOrbiting = false
	loadingProgress = 1.0
	updateProgressBar(1.0)

	if loadingText and loadingText.Parent then
		loadingText.Text = "READY!"
	end

	if progressText and progressText.Parent then
		progressText.Text = "100%"
	end

	task.wait(0.3)

	if Config.OUTRO_ENABLED then
		playOutroAnimation()
	end

	isLoading = false
	cameraLocked = false

	task.wait(0.2)

	camera.CameraType = Enum.CameraType.Custom
	debugPrint("?? Camera restored")

	-- Enable player controls
	enablePlayerControls()

	-- Remove blur
	if blurEffect and blurEffect.Parent then
		local blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.5), {Size = 0})
		blurTween:Play()
		blurTween.Completed:Wait()

		blurEffect:Destroy()
		blurEffect = nil
	end

	-- Restore GUIs
	showAllGuis()

	-- Wait for custom backpack
	task.wait(0.5)

	-- Trigger backpack refresh
	task.spawn(function()
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid:UnequipTools()

				task.wait(0.2)

				local backpack = player.Backpack
				if backpack then
					local toolsList = {}
					for _, tool in pairs(backpack:GetChildren()) do
						if tool:IsA("Tool") then
							table.insert(toolsList, tool)
						end
					end

					for _, tool in ipairs(toolsList) do
						local tempParent = tool.Parent
						tool.Parent = nil
						task.wait(0.05)
						tool.Parent = tempParent
					end
				end
			end
		end
	end)

	-- Fade out UI
	if loadingGui and loadingGui.Parent then
		local fadeTime = 0.5

		if backgroundFrame and backgroundFrame.Parent then
			for _, child in pairs(backgroundFrame:GetDescendants()) do
				if child:IsA("GuiObject") then
					task.spawn(function()
						local props = {}

						if child:IsA("TextLabel") or child:IsA("TextButton") then
							props.TextTransparency = 1
						end

						if child:IsA("ImageLabel") or child:IsA("ImageButton") then
							props.ImageTransparency = 1
						end

						if child.BackgroundTransparency < 1 then
							props.BackgroundTransparency = 1
						end

						if next(props) then
							TweenService:Create(child, TweenInfo.new(fadeTime), props):Play()
						end
					end)
				end
			end

			task.wait(fadeTime)
		end

		loadingGui.Enabled = false
		loadingGui:Destroy()
	end

	debugPrint("? Loading screen fully removed!")
end

-- ========================================
-- CAMERA PROTECTION
-- ========================================

local function protectCamera()
	camera:GetPropertyChangedSignal("CameraType"):Connect(function()
		if cameraLocked and camera.CameraType ~= Enum.CameraType.Scriptable then
			camera.CameraType = Enum.CameraType.Scriptable
		end
	end)
end

-- ========================================
-- MAIN EXECUTION
-- ========================================

debugPrint("?? ============================================")
debugPrint("?? LOADING SCREEN - ORBITAL CAMERA")
debugPrint("?? ? PLAYER NOT FROZEN - CONTROLS DISABLED ONLY")
debugPrint("?? ============================================")

task.spawn(function()
	task.wait(0.1)
	hideAllGuis()
end)

-- Disable controls immediately if spawned
if player.Character then
	task.spawn(function()
		task.wait(0.2)
		disablePlayerControls()
	end)
end

camera.CameraType = Enum.CameraType.Scriptable
cameraLocked = true
protectCamera()

local uiReady = setupLoadingUI()

if not uiReady then
	warn("? UI setup failed!")
	camera.CameraType = Enum.CameraType.Custom
	cameraLocked = false
else
	if Config.START_WITH_BLACK then
		task.spawn(fadeInFromBlack)
	end

	if not player.Character then
		debugPrint("? Waiting for character...")
		player.CharacterAdded:Wait()
	end

	debugPrint("? Character spawned!")
	task.wait(1)

	-- Disable controls only
	disablePlayerControls()

	camera.CameraType = Enum.CameraType.Scriptable
	cameraLocked = true

	-- Play intro
	if Config.INTRO_ENABLED then
		playIntroAnimation()
	end

	debugPrint("?? Starting loading sequence...")

	-- Start orbit animation
	task.spawn(startOrbitAnimation)

	-- Start progress simulation
	task.spawn(simulateProgress)

	-- Wait for loading to complete
	local loadingStartTime = tick()
	local serverSignalReceived = false

	local loadingComplete = ReplicatedStorage:FindFirstChild("LoadingComplete")

	if not loadingComplete then
		warn("?? RemoteEvent not found!")
		task.wait(Config.MIN_LOADING_TIME)
		stopLoadingScreen()
	else
		loadingComplete.OnClientEvent:Connect(function()
			debugPrint("?? Server signal received")
			serverSignalReceived = true
		end)

		while true do
			local elapsedTime = tick() - loadingStartTime

			if elapsedTime >= Config.MIN_LOADING_TIME then
				if serverSignalReceived then
					break
				end

				local waitStart = tick()
				while not serverSignalReceived and (tick() - waitStart) < 30 do
					task.wait(0.5)
				end

				break
			end

			task.wait(1)
		end

		while loadingProgress < 0.95 do
			task.wait(0.1)
		end

		stopLoadingScreen()
	end
end

debugPrint("?? Script complete")